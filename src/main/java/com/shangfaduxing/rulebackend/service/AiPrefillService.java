package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.shangfaduxing.rulebackend.model.AiPrefillRequest;
import com.shangfaduxing.rulebackend.model.AiPrefillResponse;
import com.shangfaduxing.rulebackend.model.AiSuggestionItem;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.*;

@Service
public class AiPrefillService {
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    @Value("${ai.prefill.default-provider:deepseek}")
    private String defaultProvider;
    @Value("${ai.prefill.timeout-ms:12000}")
    private int timeoutMs;

    @Value("${ai.deepseek.base-url:https://api.deepseek.com}")
    private String deepseekBaseUrl;
    @Value("${ai.deepseek.model:deepseek-chat}")
    private String deepseekModel;
    @Value("${ai.deepseek.api-key:}")
    private String deepseekApiKey;

    @Value("${ai.openai.base-url:https://api.openai.com}")
    private String openaiBaseUrl;
    @Value("${ai.openai.model:gpt-4o-mini}")
    private String openaiModel;
    @Value("${ai.openai.api-key:}")
    private String openaiApiKey;

    public AiPrefillService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(8)).build();
    }

    public AiPrefillResponse prefill(AiPrefillRequest request) {
        AiPrefillResponse resp = new AiPrefillResponse();
        if (request == null || isBlank(request.getCauseCode()) || isBlank(request.getUserText())) {
            resp.setSuccess(false);
            resp.setMessage("causeCode 和 userText 不能为空");
            resp.setSuggestions(List.of());
            resp.setMergedAnswers(request == null || request.getExistingAnswers() == null ? new LinkedHashMap<>() : new LinkedHashMap<>(request.getExistingAnswers()));
            return resp;
        }
        String provider = isBlank(request.getProvider()) ? defaultProvider : request.getProvider().trim().toLowerCase();
        try {
            List<AiSuggestionItem> items = callProvider(provider, request);
            Map<String, Object> merged = mergeAnswers(request.getExistingAnswers(), items);
            resp.setSuccess(true);
            resp.setProvider(provider);
            resp.setFallback(false);
            resp.setSuggestions(items);
            resp.setMergedAnswers(merged);
            resp.setMessage("AI 预填完成");
            return resp;
        } catch (Exception e) {
            List<AiSuggestionItem> fallbackItems = keywordFallback(request.getCauseCode(), request.getUserText());
            Map<String, Object> merged = mergeAnswers(request.getExistingAnswers(), fallbackItems);
            resp.setSuccess(true);
            resp.setProvider(provider);
            resp.setFallback(true);
            resp.setSuggestions(fallbackItems);
            resp.setMergedAnswers(merged);
            resp.setMessage("AI 调用失败，已切换规则关键词预填: " + e.getMessage());
            return resp;
        }
    }

    private List<AiSuggestionItem> callProvider(String provider, AiPrefillRequest request) throws Exception {
        String apiKey;
        String model;
        String baseUrl;
        if ("openai".equals(provider)) {
            apiKey = openaiApiKey;
            model = openaiModel;
            baseUrl = openaiBaseUrl;
        } else {
            apiKey = deepseekApiKey;
            model = deepseekModel;
            baseUrl = deepseekBaseUrl;
        }
        if (isBlank(apiKey)) {
            throw new IllegalStateException("缺少 API Key");
        }

        String prompt = buildPrompt(request);
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model);
        body.put("temperature", 0.2);
        body.put("messages", List.of(
                Map.of("role", "system", "content", "你是法律问卷预填助手。只输出 JSON，不要输出 markdown。"),
                Map.of("role", "user", "content", prompt)
        ));
        String jsonBody = objectMapper.writeValueAsString(body);

        HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + "/v1/chat/completions"))
                .timeout(Duration.ofMillis(timeoutMs))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();
        HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("HTTP " + response.statusCode() + ": " + response.body());
        }
        return parseSuggestionsFromChatResponse(response.body());
    }

    private List<AiSuggestionItem> parseSuggestionsFromChatResponse(String chatJson) throws Exception {
        JsonNode root = objectMapper.readTree(chatJson);
        String content = root.path("choices").path(0).path("message").path("content").asText("");
        if (content.isBlank()) return List.of();
        String clean = stripCodeFence(content);
        JsonNode payload = objectMapper.readTree(clean);
        JsonNode arr = payload.path("suggestions");
        if (!arr.isArray()) return List.of();
        List<AiSuggestionItem> out = new ArrayList<>();
        for (JsonNode n : arr) {
            String key = n.path("key").asText("");
            if (key.isBlank()) continue;
            JsonNode valueNode = n.get("value");
            Object value = jsonNodeToObject(valueNode);
            double confidence = n.path("confidence").asDouble(0.7);
            String reason = n.path("reason").asText("");
            out.add(new AiSuggestionItem(key, value, confidence, reason));
        }
        return out;
    }

    private Object jsonNodeToObject(JsonNode n) {
        if (n == null || n.isNull()) return null;
        if (n.isBoolean()) return n.booleanValue();
        if (n.isInt()) return n.intValue();
        if (n.isLong()) return n.longValue();
        if (n.isDouble() || n.isFloat() || n.isBigDecimal()) return n.doubleValue();
        return n.asText();
    }

    private String stripCodeFence(String text) {
        String s = text.trim();
        if (s.startsWith("```")) {
            int first = s.indexOf('\n');
            if (first > -1) s = s.substring(first + 1);
            if (s.endsWith("```")) s = s.substring(0, s.length() - 3);
        }
        return s.trim();
    }

    private String buildPrompt(AiPrefillRequest request) throws Exception {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("causeCode", request.getCauseCode());
        payload.put("userText", request.getUserText());
        payload.put("existingAnswers", request.getExistingAnswers() == null ? Map.of() : request.getExistingAnswers());
        payload.put("targetKeys", request.getTargetKeys() == null ? List.of() : request.getTargetKeys());
        String inputJson = objectMapper.writeValueAsString(payload);
        return "请基于输入文本提取问卷答案建议，仅返回 JSON，格式为：\n" +
                "{\"suggestions\":[{\"key\":\"问题key\",\"value\":true,\"confidence\":0.0,\"reason\":\"简短理由\"}]}\n" +
                "要求：\n" +
                "1) 只返回最有把握的 3-10 条建议；\n" +
                "2) confidence 取值 [0,1]；\n" +
                "3) value 按 key 语义可为 boolean/string/number；\n" +
                "4) 不要输出任何额外文本。\n" +
                "输入：" + inputJson;
    }

    private Map<String, Object> mergeAnswers(Map<String, Object> existing, List<AiSuggestionItem> items) {
        Map<String, Object> merged = new LinkedHashMap<>();
        if (existing != null) merged.putAll(existing);
        if (items != null) {
            for (AiSuggestionItem i : items) {
                if (i.getKey() != null && !i.getKey().isBlank()) {
                    merged.put(i.getKey(), i.getValue());
                }
            }
        }
        return merged;
    }

    private List<AiSuggestionItem> keywordFallback(String causeCode, String text) {
        String t = text == null ? "" : text.toLowerCase();
        List<AiSuggestionItem> out = new ArrayList<>();
        if ("labor_unpaid_wages".equals(causeCode)) {
            if (containsAny(t, "欠薪", "拖欠工资", "没发工资")) out.add(new AiSuggestionItem("存在欠薪", true, 0.8, "文本包含欠薪语义"));
            if (containsAny(t, "上班", "打卡", "出勤", "工作")) out.add(new AiSuggestionItem("已提供劳动", true, 0.7, "文本包含工作/出勤语义"));
            if (containsAny(t, "合同", "入职", "社保")) out.add(new AiSuggestionItem("存在劳动关系", true, 0.7, "文本包含劳动关系语义"));
            if (containsAny(t, "加班")) out.add(new AiSuggestionItem("主张加班费", true, 0.8, "文本包含加班语义"));
        } else if ("labor_no_contract".equals(causeCode)) {
            if (containsAny(t, "没签合同", "未签劳动合同", "没签劳动合同")) out.add(new AiSuggestionItem("未签书面劳动合同", true, 0.9, "文本直接提及未签合同"));
            if (containsAny(t, "工资", "发薪")) out.add(new AiSuggestionItem("有工资支付记录", true, 0.6, "文本存在工资语义"));
            if (containsAny(t, "上班", "工作")) out.add(new AiSuggestionItem("存在劳动关系", true, 0.7, "文本包含劳动关系语义"));
        } else if ("labor_illegal_termination".equals(causeCode)) {
            if (containsAny(t, "辞退", "解除劳动合同", "开除")) out.add(new AiSuggestionItem("已被解除或辞退", true, 0.9, "文本包含解除/辞退语义"));
            if (containsAny(t, "没有通知", "口头通知")) out.add(new AiSuggestionItem("解除通知为书面", false, 0.7, "文本疑似非书面通知"));
            if (containsAny(t, "工会程序", "未通知工会")) out.add(new AiSuggestionItem("单位是否履行工会程序", false, 0.7, "文本疑似工会程序缺失"));
            out.add(new AiSuggestionItem("存在劳动关系", true, 0.6, "解除争议通常以劳动关系为前提"));
        } else if ("divorce_property".equals(causeCode)) {
            if (containsAny(t, "离婚")) out.add(new AiSuggestionItem("婚姻关系已经解除或正在解除", true, 0.8, "文本包含离婚语义"));
            if (containsAny(t, "房产", "房子")) out.add(new AiSuggestionItem("存在房产分割争议", true, 0.8, "文本包含房产争议语义"));
            if (containsAny(t, "结婚证", "婚姻")) out.add(new AiSuggestionItem("存在合法婚姻关系", true, 0.7, "文本包含婚姻关系语义"));
        }
        return out;
    }

    private boolean containsAny(String text, String... keys) {
        for (String k : keys) {
            if (text.contains(k)) return true;
        }
        return false;
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
