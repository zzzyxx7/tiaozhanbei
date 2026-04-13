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
import java.text.Normalizer;
import java.time.Duration;
import java.util.*;

@Service
public class AiPrefillService {
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;
    private final CauseAssetDbService causeAssetDbService;

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

    public AiPrefillService(ObjectMapper objectMapper, CauseAssetDbService causeAssetDbService) {
        this.objectMapper = objectMapper;
        this.causeAssetDbService = causeAssetDbService;
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
        String causeCode = request.getCauseCode().trim();
        if (!causeAssetDbService.supportsPrefill(causeCode)) {
            resp.setSuccess(false);
            resp.setMessage("未知案由或暂不支持预填: " + causeCode);
            resp.setSuggestions(List.of());
            resp.setMergedAnswers(copyExistingSafe(request.getExistingAnswers()));
            return resp;
        }
        List<String> allowedKeys = resolveAllowedQuestionKeys(request, causeCode);
        boolean keysFromClient = request.getTargetKeys() != null && !request.getTargetKeys().isEmpty();
        if (!keysFromClient && allowedKeys.isEmpty()) {
            resp.setSuccess(false);
            resp.setMessage("该案由下未找到问卷题目，无法对齐预填 key；请检查 rule_cause / rule_question 配置");
            resp.setSuggestions(List.of());
            resp.setMergedAnswers(copyExistingSafe(request.getExistingAnswers()));
            return resp;
        }

        String provider = isBlank(request.getProvider()) ? defaultProvider : request.getProvider().trim().toLowerCase();
        try {
            List<AiSuggestionItem> items = callProvider(provider, request, causeCode, allowedKeys);
            Map<String, Object> merged = mergeAnswers(request.getExistingAnswers(), items, allowedKeys);
            resp.setSuccess(true);
            resp.setProvider(provider);
            resp.setFallback(false);
            resp.setSuggestions(items);
            resp.setMergedAnswers(merged);
            resp.setMessage("AI 预填完成");
            return resp;
        } catch (Exception e) {
            List<AiSuggestionItem> fallbackItems = keywordFallback(causeCode, request.getUserText(), allowedKeys);
            Map<String, Object> merged = mergeAnswers(request.getExistingAnswers(), fallbackItems, allowedKeys);
            resp.setSuccess(true);
            resp.setProvider(provider);
            resp.setFallback(true);
            resp.setSuggestions(fallbackItems);
            resp.setMergedAnswers(merged);
            resp.setMessage("AI 调用失败，已切换规则关键词预填: " + e.getMessage());
            return resp;
        }
    }

    private static Map<String, Object> copyExistingSafe(Map<String, Object> existing) {
        return existing == null ? new LinkedHashMap<>() : new LinkedHashMap<>(existing);
    }

    private List<AiSuggestionItem> callProvider(String provider, AiPrefillRequest request, String causeCode, List<String> allowedKeys) throws Exception {
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

        String prompt = buildPrompt(request, causeCode, allowedKeys);
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model);
        body.put("temperature", 0.1);
        body.put("messages", List.of(
                Map.of("role", "system", "content",
                        "你是法律问卷预填助手。suggestions 中每个 key 必须与 allowedQuestionKeys 中某项完全一致（多为中文），禁止英文 snake_case。每条必须带非空 reason（1～20 字）。金额类按 questionFields 的 unit 用「元」的数值。只输出 JSON，不要 markdown。"),
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
        List<AiSuggestionItem> parsed = parseSuggestionsFromChatResponse(response.body());
        return ensureNonBlankReasons(canonicalizeAndDedupeSuggestions(parsed, allowedKeys));
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

    /**
     * 客户端可传 targetKeys；未传时按 causeCode 从库中拉取问卷题目的 question_key，与 GET /questionnaire 一致。
     */
    private List<String> resolveAllowedQuestionKeys(AiPrefillRequest request, String causeCode) {
        if (request.getTargetKeys() != null && !request.getTargetKeys().isEmpty()) {
            List<String> out = new ArrayList<>();
            for (String k : request.getTargetKeys()) {
                if (k != null && !k.isBlank()) {
                    out.add(k.trim());
                }
            }
            return out;
        }
        try {
            List<Map<String, Object>> groups = causeAssetDbService.getQuestionGroupsForPrefill(causeCode);
            return collectQuestionKeysInOrder(groups);
        } catch (Exception e) {
            return List.of();
        }
    }

    private List<String> collectQuestionKeysInOrder(List<Map<String, Object>> groups) {
        LinkedHashSet<String> seen = new LinkedHashSet<>();
        if (groups == null) {
            return List.of();
        }
        for (Map<String, Object> g : groups) {
            Object qs = g.get("questions");
            if (!(qs instanceof List)) {
                continue;
            }
            for (Object qo : (List<?>) qs) {
                if (!(qo instanceof Map)) {
                    continue;
                }
                Object keyObj = ((Map<?, ?>) qo).get("key");
                if (keyObj == null) {
                    continue;
                }
                String k = keyObj.toString().trim();
                if (!k.isBlank()) {
                    seen.add(k);
                }
            }
        }
        return new ArrayList<>(seen);
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, String>> buildQuestionSchemaForPrompt(List<Map<String, Object>> groups) {
        List<Map<String, String>> schema = new ArrayList<>();
        if (groups == null) {
            return schema;
        }
        for (Map<String, Object> g : groups) {
            Object qs = g.get("questions");
            if (!(qs instanceof List)) {
                continue;
            }
            for (Object qo : (List<?>) qs) {
                if (!(qo instanceof Map)) {
                    continue;
                }
                Map<String, Object> q = (Map<String, Object>) qo;
                String key = Objects.toString(q.get("key"), "").trim();
                if (key.isBlank()) {
                    continue;
                }
                Map<String, String> row = new LinkedHashMap<>();
                row.put("key", key);
                row.put("inputType", Objects.toString(q.get("type"), ""));
                row.put("label", Objects.toString(q.get("text"), ""));
                schema.add(row);
            }
        }
        return schema;
    }

    private Map<String, String> buildNormalizedToCanonicalMap(List<String> allowedKeys) {
        Map<String, String> m = new LinkedHashMap<>();
        if (allowedKeys == null) {
            return m;
        }
        for (String a : allowedKeys) {
            if (a != null && !a.isBlank()) {
                m.put(normalizeKeyForm(a), a);
            }
        }
        return m;
    }

    private static String normalizeKeyForm(String s) {
        if (s == null) {
            return "";
        }
        return Normalizer.normalize(s.trim(), Normalizer.Form.NFKC);
    }

    /**
     * 将模型返回的 key 归一为库中 question_key（去首尾空白、Unicode 兼容形式），丢弃无法对应的项；同 key 保留 confidence 更高的一条。
     */
    private List<AiSuggestionItem> canonicalizeAndDedupeSuggestions(List<AiSuggestionItem> items, List<String> allowedKeys) {
        if (items == null || items.isEmpty()) {
            return List.of();
        }
        if (allowedKeys == null || allowedKeys.isEmpty()) {
            return items;
        }
        Map<String, String> normToCanon = buildNormalizedToCanonicalMap(allowedKeys);
        Map<String, AiSuggestionItem> best = new LinkedHashMap<>();
        for (AiSuggestionItem i : items) {
            String canon = resolveCanonicalKey(i.getKey(), allowedKeys, normToCanon);
            if (canon == null) {
                continue;
            }
            double conf = i.getConfidence() != null ? i.getConfidence() : 0.0;
            AiSuggestionItem candidate = new AiSuggestionItem(canon, i.getValue(), conf, i.getReason());
            AiSuggestionItem prev = best.get(canon);
            if (prev == null) {
                best.put(canon, candidate);
                continue;
            }
            double prevConf = prev.getConfidence() != null ? prev.getConfidence() : 0.0;
            if (conf > prevConf) {
                best.put(canon, candidate);
            }
        }
        return new ArrayList<>(best.values());
    }

    private String resolveCanonicalKey(String raw, List<String> allowedKeys, Map<String, String> normToCanon) {
        if (raw == null) {
            return null;
        }
        String t = raw.trim();
        if (t.isEmpty()) {
            return null;
        }
        for (String a : allowedKeys) {
            if (a != null && a.equals(t)) {
                return a;
            }
        }
        String norm = normalizeKeyForm(t);
        return normToCanon.get(norm);
    }

    private String buildPrompt(AiPrefillRequest request, String causeCode, List<String> allowedKeys) throws Exception {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("causeCode", causeCode);
        payload.put("userText", request.getUserText());
        payload.put("existingAnswers", request.getExistingAnswers() == null ? Map.of() : request.getExistingAnswers());
        payload.put("targetKeys", request.getTargetKeys() == null ? List.of() : request.getTargetKeys());

        List<Map<String, Object>> groupsForSchema = null;
        if (request.getTargetKeys() == null || request.getTargetKeys().isEmpty()) {
            try {
                groupsForSchema = causeAssetDbService.getQuestionGroupsForPrefill(causeCode);
            } catch (Exception ignored) {
                groupsForSchema = null;
            }
        }

        if (allowedKeys != null && !allowedKeys.isEmpty()) {
            payload.put("allowedQuestionKeys", allowedKeys);
            if (groupsForSchema != null && !groupsForSchema.isEmpty()) {
                payload.put("questionFields", buildQuestionSchemaForPrompt(groupsForSchema));
            }
        }

        String inputJson = objectMapper.writeValueAsString(payload);

        if (allowedKeys == null || allowedKeys.isEmpty()) {
            return "请基于输入文本提取问卷答案建议，仅返回 JSON，格式为：\n" +
                    "{\"suggestions\":[{\"key\":\"问题key\",\"value\":true,\"confidence\":0.0,\"reason\":\"简短理由\"}]}\n" +
                    "要求：\n" +
                    "1) 只返回最有把握的 3-10 条建议；\n" +
                    "2) confidence 取值 [0,1]；\n" +
                    "3) value 按 key 语义可为 boolean/string/number；金额类用阿拉伯数字表示「元」（与题干单位一致，如「28 万」写 280000）；\n" +
                    "4) 每条 suggestion 的 reason 必填，1～20 个汉字或字符，不得为空或省略；\n" +
                    "5) 不要输出任何额外文本。\n" +
                    "输入：" + inputJson;
        }

        return "你是法律问卷预填助手。下方 JSON 中的 allowedQuestionKeys 为本题问卷唯一合法的题目 key（与后端数据库 question_key 一致，多为中文）。\n" +
                "你必须严格遵守：\n" +
                "1) suggestions 数组里每个元素的 key 字段必须【逐字完全等于】allowedQuestionKeys 中的某一项，禁止自拟英文 key（如 has_contract）、禁止改写或翻译 key；\n" +
                "2) 参考 questionFields 中的 inputType：boolean 题用 true/false，number 题用数字，choice/select 题用与选项一致的 value 字符串；若某题 unit 为「元」或题干为金额，value 须为以「元」为单位的阿拉伯数字（与题干表述一致，如「28 万彩礼」写 280000）；\n" +
                "3) 每条 suggestion 必须包含非空 reason 字段，1～20 个汉字或字符，简要说明为何从用户描述得出该答案，不得省略 reason；\n" +
                "4) 只输出最有把握的 3-10 条；confidence 在 [0,1]；\n" +
                "5) 仅输出一个 JSON 对象，格式为 {\"suggestions\":[...]} ，不要 markdown、不要其它说明文字。\n" +
                "输入：" + inputJson;
    }

    /** 模型偶发省略 reason 时兜底，避免前端展示空说明。 */
    private List<AiSuggestionItem> ensureNonBlankReasons(List<AiSuggestionItem> items) {
        if (items == null || items.isEmpty()) {
            return items == null ? List.of() : items;
        }
        List<AiSuggestionItem> out = new ArrayList<>(items.size());
        for (AiSuggestionItem i : items) {
            String r = i.getReason();
            if (r == null || r.isBlank()) {
                out.add(new AiSuggestionItem(i.getKey(), i.getValue(), i.getConfidence(), "根据用户描述推断"));
            } else {
                out.add(i);
            }
        }
        return out;
    }

    private Map<String, Object> mergeAnswers(Map<String, Object> existing, List<AiSuggestionItem> items, List<String> allowedKeys) {
        Map<String, Object> merged = new LinkedHashMap<>();
        Map<String, String> normToCanon = (allowedKeys == null || allowedKeys.isEmpty())
                ? null
                : buildNormalizedToCanonicalMap(allowedKeys);

        if (existing != null) {
            for (Map.Entry<String, Object> e : existing.entrySet()) {
                String k = e.getKey();
                if (k == null || k.isBlank()) {
                    continue;
                }
                if (normToCanon == null) {
                    merged.put(k.trim(), e.getValue());
                } else {
                    String canon = resolveCanonicalKey(k, allowedKeys, normToCanon);
                    if (canon != null) {
                        merged.put(canon, e.getValue());
                    }
                }
            }
        }
        if (items != null) {
            for (AiSuggestionItem i : items) {
                if (i.getKey() == null || i.getKey().isBlank()) {
                    continue;
                }
                if (normToCanon == null || resolveCanonicalKey(i.getKey(), allowedKeys, normToCanon) != null) {
                    merged.put(i.getKey(), i.getValue());
                }
            }
        }
        return merged;
    }

    private void addFallbackIfAllowed(Set<String> allowed, List<AiSuggestionItem> out, String key, Object value, double confidence, String reason) {
        if (key == null || key.isBlank()) {
            return;
        }
        if (allowed == null || allowed.contains(key)) {
            out.add(new AiSuggestionItem(key, value, confidence, reason));
        }
    }

    private List<AiSuggestionItem> keywordFallback(String causeCode, String text, List<String> allowedKeys) {
        String t = text == null ? "" : text.toLowerCase();
        Set<String> allowed = (allowedKeys == null || allowedKeys.isEmpty()) ? null : new HashSet<>(allowedKeys);
        List<AiSuggestionItem> out = new ArrayList<>();

        if ("labor_unpaid_wages".equals(causeCode)) {
            if (containsAny(t, "欠薪", "拖欠工资", "没发工资")) {
                addFallbackIfAllowed(allowed, out, "存在欠薪", true, 0.8, "文本包含欠薪语义");
            }
            if (containsAny(t, "上班", "打卡", "出勤", "工作")) {
                addFallbackIfAllowed(allowed, out, "已提供劳动", true, 0.7, "文本包含工作/出勤语义");
            }
            if (containsAny(t, "合同", "入职", "社保")) {
                addFallbackIfAllowed(allowed, out, "存在劳动关系", true, 0.7, "文本包含劳动关系语义");
            }
            if (containsAny(t, "加班")) {
                addFallbackIfAllowed(allowed, out, "主张加班费", true, 0.8, "文本包含加班语义");
            }
            if (containsAny(t, "考勤")) {
                addFallbackIfAllowed(allowed, out, "有考勤或工作记录", true, 0.75, "文本包含考勤语义");
            }
            if (containsAny(t, "合同") || containsAny(t, "劳动合同")) {
                addFallbackIfAllowed(allowed, out, "有工资约定依据", true, 0.7, "文本提及劳动合同等约定依据");
            }
        } else if ("labor_no_contract".equals(causeCode)) {
            if (containsAny(t, "没签合同", "未签劳动合同", "没签劳动合同")) {
                addFallbackIfAllowed(allowed, out, "未签书面劳动合同", true, 0.9, "文本直接提及未签合同");
            }
            if (containsAny(t, "工资", "发薪")) {
                addFallbackIfAllowed(allowed, out, "有工资支付记录", true, 0.6, "文本存在工资语义");
            }
            if (containsAny(t, "上班", "工作")) {
                addFallbackIfAllowed(allowed, out, "存在劳动关系", true, 0.7, "文本包含劳动关系语义");
            }
        } else if ("labor_illegal_termination".equals(causeCode)) {
            if (containsAny(t, "辞退", "解除劳动合同", "开除")) {
                addFallbackIfAllowed(allowed, out, "已被解除或辞退", true, 0.9, "文本包含解除/辞退语义");
            }
            if (containsAny(t, "没有通知", "口头通知")) {
                addFallbackIfAllowed(allowed, out, "解除通知为书面", false, 0.7, "文本疑似非书面通知");
            }
            if (containsAny(t, "工会程序", "未通知工会")) {
                addFallbackIfAllowed(allowed, out, "单位是否履行工会程序", false, 0.7, "文本疑似工会程序缺失");
            }
            addFallbackIfAllowed(allowed, out, "存在劳动关系", true, 0.6, "解除争议通常以劳动关系为前提");
        } else if ("divorce_property".equals(causeCode)) {
            if (containsAny(t, "离婚")) {
                addFallbackIfAllowed(allowed, out, "婚姻关系已经解除或正在解除", true, 0.8, "文本包含离婚语义");
            }
            if (containsAny(t, "房产", "房子")) {
                addFallbackIfAllowed(allowed, out, "存在房产分割争议", true, 0.8, "文本包含房产争议语义");
            }
            if (containsAny(t, "结婚证", "婚姻")) {
                addFallbackIfAllowed(allowed, out, "存在合法婚姻关系", true, 0.7, "文本包含婚姻关系语义");
            }
        } else if ("divorce_dispute".equals(causeCode)) {
            if (containsAny(t, "离婚", "感情", "破裂", "分居")) {
                addFallbackIfAllowed(allowed, out, "感情确已破裂", true, 0.75, "文本涉及感情或离婚事由");
            }
            if (containsAny(t, "结婚", "登记", "婚姻")) {
                addFallbackIfAllowed(allowed, out, "存在合法婚姻关系", true, 0.7, "文本涉及婚姻关系");
            }
            if (containsAny(t, "子女", "抚养", "小孩")) {
                addFallbackIfAllowed(allowed, out, "涉及子女抚养", true, 0.8, "文本涉及子女抚养");
            }
            if (containsAny(t, "财产", "房产", "存款", "债务")) {
                addFallbackIfAllowed(allowed, out, "涉及夫妻共同财产", true, 0.75, "文本涉及共同财产或债务");
            }
            if (containsAny(t, "家暴", "暴力", "出轨")) {
                addFallbackIfAllowed(allowed, out, "存在家庭暴力或重大过错", true, 0.7, "文本涉及家暴或重大过错语义");
            }
        } else if ("post_divorce_property".equals(causeCode)) {
            if (containsAny(t, "离婚")) {
                addFallbackIfAllowed(allowed, out, "离婚事实已生效", true, 0.8, "文本涉及离婚事实");
            }
            if (containsAny(t, "协议")) {
                addFallbackIfAllowed(allowed, out, "存在离婚协议", true, 0.75, "文本涉及离婚协议");
            }
            if (containsAny(t, "分割", "未分", "隐瞒", "转移")) {
                addFallbackIfAllowed(allowed, out, "存在未分割共同财产", true, 0.7, "文本涉及财产分割或线索");
                addFallbackIfAllowed(allowed, out, "请求再次分割", true, 0.65, "文本涉及再次分割语义");
            }
        } else if ("betrothal_property".equals(causeCode)) {
            if (containsAny(t, "彩礼", "聘礼")) {
                addFallbackIfAllowed(allowed, out, "存在彩礼给付", true, 0.85, "文本涉及彩礼给付");
            }
            if (containsAny(t, "返还", "退")) {
                addFallbackIfAllowed(allowed, out, "存在法定返还情形", true, 0.7, "文本涉及返还语义");
            }
            if (containsAny(t, "登记", "结婚")) {
                addFallbackIfAllowed(allowed, out, "已办理结婚登记", true, 0.7, "文本涉及登记或结婚");
            }
        } else if ("labor_overtime_pay".equals(causeCode)) {
            if (containsAny(t, "加班")) {
                addFallbackIfAllowed(allowed, out, "主张加班费", true, 0.85, "文本涉及加班费主张");
                addFallbackIfAllowed(allowed, out, "存在加班事实", true, 0.8, "文本涉及加班事实");
            }
            if (containsAny(t, "工资", "少发", "未付")) {
                addFallbackIfAllowed(allowed, out, "单位未足额支付加班费", true, 0.75, "文本涉及欠付加班费");
            }
            if (containsAny(t, "考勤", "打卡")) {
                addFallbackIfAllowed(allowed, out, "有完整考勤记录", true, 0.7, "文本涉及考勤");
            }
            addFallbackIfAllowed(allowed, out, "存在劳动关系", true, 0.65, "加班争议以劳动关系为前提");
        } else if ("labor_injury_compensation".equals(causeCode)) {
            if (containsAny(t, "工伤", "受伤", "事故")) {
                addFallbackIfAllowed(allowed, out, "发生工作时间工作场所事故", true, 0.8, "文本涉及工伤或事故");
            }
            if (containsAny(t, "认定", "申请")) {
                addFallbackIfAllowed(allowed, out, "已申请或拟申请工伤认定", true, 0.75, "文本涉及工伤认定");
            }
            if (containsAny(t, "医疗费", "治疗")) {
                addFallbackIfAllowed(allowed, out, "存在医疗费用支出", true, 0.75, "文本涉及医疗费用");
            }
            addFallbackIfAllowed(allowed, out, "存在劳动关系", true, 0.65, "工伤待遇以劳动关系为前提");
        }

        return dedupeFallbackByKey(out);
    }

    private List<AiSuggestionItem> dedupeFallbackByKey(List<AiSuggestionItem> out) {
        Map<String, AiSuggestionItem> m = new LinkedHashMap<>();
        for (AiSuggestionItem i : out) {
            if (i.getKey() == null) {
                continue;
            }
            AiSuggestionItem prev = m.get(i.getKey());
            if (prev == null) {
                m.put(i.getKey(), i);
                continue;
            }
            double ic = i.getConfidence() != null ? i.getConfidence() : 0.0;
            double pc = prev.getConfidence() != null ? prev.getConfidence() : 0.0;
            if (ic > pc) {
                m.put(i.getKey(), i);
            }
        }
        return new ArrayList<>(m.values());
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
