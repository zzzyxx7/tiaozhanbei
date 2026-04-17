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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class AiPrefillService {
    private static final Pattern NUMBER_WITH_UNIT_PATTERN = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*(万|千|元|块|w|W)?");
    private static final Pattern CHINESE_WORD_PATTERN = Pattern.compile("[\\u4e00-\\u9fa5]{2,}");
    private static final String CAUSE_PROPERTY_DISPUTE = "property_dispute";
    private static final String CAUSE_DIVORCE_PROPERTY = "divorce_property";
    private static final String CAUSE_BETROTHAL_LEGACY = "betrothal_property";
    private static final String CAUSE_BETROTHAL_NEW = "marriage_betrothal_property_dispute";
    private static final Set<String> MARRIAGE_CAUSE_CODES = Set.of(
            "divorce_dispute",
            "divorce_property",
            "post_divorce_property",
            "post_divorce_damage_liability_dispute",
            "marriage_invalid_dispute",
            "marriage_annulment_dispute",
            "spousal_property_agreement_dispute",
            "in_marriage_property_division_dispute",
            "cohabitation_dispute",
            "paternity_confirmation_dispute",
            "paternity_disclaimer_dispute",
            "child_support_dispute",
            "sibling_support_dispute",
            "support_dispute",
            "inherit_dispute",
            "adoption_dispute",
            "guardianship_dispute",
            "visitation_dispute",
            "family_partition_dispute",
            "marriage_betrothal_property_dispute",
            "betrothal_property",
            CAUSE_PROPERTY_DISPUTE
    );
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;
    private final CauseAssetDbService causeAssetDbService;
    private static final Set<String> BOOLEAN_TRUE_TOKENS = Set.of("true", "1", "yes", "y", "是", "有", "已", "存在", "办理", "可以");
    private static final Set<String> BOOLEAN_FALSE_TOKENS = Set.of("false", "0", "no", "n", "否", "无", "未", "不存在", "没有", "不可以");

    private static class QuestionFieldMeta {
        private final String inputType;
        private final String label;
        private final Set<String> optionValues;
        private final Map<String, String> optionLabelToValue;

        private QuestionFieldMeta(String inputType, String label, Set<String> optionValues, Map<String, String> optionLabelToValue) {
            this.inputType = inputType;
            this.label = label;
            this.optionValues = optionValues;
            this.optionLabelToValue = optionLabelToValue;
        }
    }

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
        String causeCode = normalizeCauseCode(request.getCauseCode());
        if (!causeAssetDbService.supportsPrefill(causeCode)) {
            resp.setSuccess(false);
            resp.setMessage("未知案由或暂不支持预填: " + causeCode);
            resp.setSuggestions(List.of());
            resp.setMergedAnswers(copyExistingSafe(request.getExistingAnswers()));
            return resp;
        }
        List<Map<String, Object>> groupsForSchema = null;
        if (request.getTargetKeys() == null || request.getTargetKeys().isEmpty()) {
            try {
                groupsForSchema = causeAssetDbService.getQuestionGroupsForPrefill(causeCode);
            } catch (Exception ignored) {
                groupsForSchema = null;
            }
        }
        List<String> allowedKeys = resolveAllowedQuestionKeys(request, causeCode, groupsForSchema);
        Map<String, QuestionFieldMeta> fieldMetaMap = buildQuestionMetaMap(groupsForSchema);
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
            List<AiSuggestionItem> items = callProvider(provider, request, causeCode, allowedKeys, groupsForSchema);
            List<AiSuggestionItem> normalizedItems = normalizeSuggestionValues(items, fieldMetaMap);
            List<AiSuggestionItem> enhancedItems = augmentNumericSuggestions(request.getUserText(), normalizedItems, allowedKeys, fieldMetaMap);
            List<AiSuggestionItem> filteredItems = filterSuggestionsByRelevance(causeCode, request.getUserText(), enhancedItems, fieldMetaMap);
            Map<String, Object> merged = mergeAnswers(request.getExistingAnswers(), filteredItems, allowedKeys, fieldMetaMap);
            resp.setSuccess(true);
            resp.setProvider(provider);
            resp.setFallback(false);
            resp.setSuggestions(filteredItems);
            resp.setMergedAnswers(merged);
            resp.setMessage("AI 预填完成");
            return resp;
        } catch (Exception e) {
            List<AiSuggestionItem> fallbackItems = keywordFallback(causeCode, request.getUserText(), allowedKeys);
            List<AiSuggestionItem> normalizedItems = normalizeSuggestionValues(fallbackItems, fieldMetaMap);
            List<AiSuggestionItem> enhancedItems = augmentNumericSuggestions(request.getUserText(), normalizedItems, allowedKeys, fieldMetaMap);
            List<AiSuggestionItem> filteredItems = filterSuggestionsByRelevance(causeCode, request.getUserText(), enhancedItems, fieldMetaMap);
            Map<String, Object> merged = mergeAnswers(request.getExistingAnswers(), filteredItems, allowedKeys, fieldMetaMap);
            resp.setSuccess(true);
            resp.setProvider(provider);
            resp.setFallback(true);
            resp.setSuggestions(filteredItems);
            resp.setMergedAnswers(merged);
            resp.setMessage("AI 调用失败，已切换规则关键词预填: " + e.getMessage());
            return resp;
        }
    }

    private String normalizeCauseCode(String raw) {
        if (raw == null) return "";
        String c = raw.trim();
        if (CAUSE_PROPERTY_DISPUTE.equals(c)) {
            return CAUSE_DIVORCE_PROPERTY;
        }
        // 历史别名兼容：彩礼旧码统一映射到当前婚约财产案由
        if (CAUSE_BETROTHAL_LEGACY.equals(c)) {
            return CAUSE_BETROTHAL_NEW;
        }
        return c;
    }

    private static Map<String, Object> copyExistingSafe(Map<String, Object> existing) {
        return existing == null ? new LinkedHashMap<>() : new LinkedHashMap<>(existing);
    }

    private List<AiSuggestionItem> callProvider(
            String provider,
            AiPrefillRequest request,
            String causeCode,
            List<String> allowedKeys,
            List<Map<String, Object>> groupsForSchema
    ) throws Exception {
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

        String prompt = buildPrompt(request, causeCode, allowedKeys, groupsForSchema);
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
    private List<String> resolveAllowedQuestionKeys(
            AiPrefillRequest request,
            String causeCode,
            List<Map<String, Object>> groupsForSchema
    ) {
        if (request.getTargetKeys() != null && !request.getTargetKeys().isEmpty()) {
            List<String> out = new ArrayList<>();
            for (String k : request.getTargetKeys()) {
                if (k != null && !k.isBlank()) {
                    out.add(k.trim());
                }
            }
            return out;
        }
        if (groupsForSchema == null) {
            return List.of();
        }
        return collectQuestionKeysInOrder(groupsForSchema);
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
    private List<Map<String, Object>> buildQuestionSchemaForPrompt(List<Map<String, Object>> groups) {
        List<Map<String, Object>> schema = new ArrayList<>();
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
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("key", key);
                row.put("inputType", Objects.toString(q.get("type"), ""));
                row.put("label", Objects.toString(q.get("text"), ""));
                row.put("unit", Objects.toString(q.get("unit"), ""));
                if (q.get("options") instanceof List<?> os && !os.isEmpty()) {
                    List<Map<String, String>> opts = new ArrayList<>();
                    for (Object oo : os) {
                        if (!(oo instanceof Map<?, ?> om)) {
                            continue;
                        }
                        String ov = Objects.toString(om.get("value"), "");
                        String ol = Objects.toString(om.get("label"), "");
                        if (ov.isBlank() && ol.isBlank()) {
                            continue;
                        }
                        Map<String, String> opt = new LinkedHashMap<>();
                        opt.put("value", ov);
                        opt.put("label", ol);
                        opts.add(opt);
                    }
                    if (!opts.isEmpty()) {
                        row.put("options", opts);
                    }
                }
                schema.add(row);
            }
        }
        return schema;
    }

    @SuppressWarnings("unchecked")
    private Map<String, QuestionFieldMeta> buildQuestionMetaMap(List<Map<String, Object>> groups) {
        Map<String, QuestionFieldMeta> out = new LinkedHashMap<>();
        if (groups == null) {
            return out;
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
                String inputType = Objects.toString(q.get("type"), "").trim().toLowerCase(Locale.ROOT);
                Set<String> optionValues = new LinkedHashSet<>();
                Map<String, String> optionLabelToValue = new LinkedHashMap<>();
                if (q.get("options") instanceof List<?> os) {
                    for (Object oo : os) {
                        if (!(oo instanceof Map<?, ?> om)) {
                            continue;
                        }
                        String ov = Objects.toString(om.get("value"), "").trim();
                        String ol = Objects.toString(om.get("label"), "").trim();
                        if (!ov.isBlank()) {
                            optionValues.add(ov);
                            optionLabelToValue.put(normalizeOptionToken(ov), ov);
                        }
                        if (!ol.isBlank() && !ov.isBlank()) {
                            optionLabelToValue.put(normalizeOptionToken(ol), ov);
                        }
                    }
                }
                String label = Objects.toString(q.get("text"), "").trim();
                out.put(key, new QuestionFieldMeta(inputType, label, optionValues, optionLabelToValue));
            }
        }
        return out;
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

    private String buildPrompt(
            AiPrefillRequest request,
            String causeCode,
            List<String> allowedKeys,
            List<Map<String, Object>> groupsForSchema
    ) throws Exception {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("causeCode", causeCode);
        payload.put("userText", request.getUserText());
        payload.put("existingAnswers", request.getExistingAnswers() == null ? Map.of() : request.getExistingAnswers());
        payload.put("targetKeys", request.getTargetKeys() == null ? List.of() : request.getTargetKeys());

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

    private Map<String, Object> mergeAnswers(
            Map<String, Object> existing,
            List<AiSuggestionItem> items,
            List<String> allowedKeys,
            Map<String, QuestionFieldMeta> fieldMetaMap
    ) {
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
                        merged.put(canon, normalizeValueByFieldMeta(canon, e.getValue(), fieldMetaMap));
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
                    merged.put(i.getKey(), normalizeValueByFieldMeta(i.getKey(), i.getValue(), fieldMetaMap));
                }
            }
        }
        return merged;
    }

    private List<AiSuggestionItem> normalizeSuggestionValues(List<AiSuggestionItem> items, Map<String, QuestionFieldMeta> fieldMetaMap) {
        if (items == null || items.isEmpty()) {
            return List.of();
        }
        List<AiSuggestionItem> out = new ArrayList<>(items.size());
        for (AiSuggestionItem i : items) {
            Object normalizedValue = normalizeValueByFieldMeta(i.getKey(), i.getValue(), fieldMetaMap);
            out.add(new AiSuggestionItem(i.getKey(), normalizedValue, i.getConfidence(), i.getReason()));
        }
        return out;
    }

    private Object normalizeValueByFieldMeta(String key, Object rawValue, Map<String, QuestionFieldMeta> fieldMetaMap) {
        if (key == null || fieldMetaMap == null || fieldMetaMap.isEmpty()) {
            return rawValue;
        }
        QuestionFieldMeta meta = fieldMetaMap.get(key);
        if (meta == null || meta.inputType == null || meta.inputType.isBlank()) {
            return rawValue;
        }
        if ("boolean".equals(meta.inputType)) {
            return normalizeBooleanValue(rawValue);
        }
        if ("number".equals(meta.inputType)) {
            return normalizeNumberValue(rawValue);
        }
        if ("choice".equals(meta.inputType) || "select".equals(meta.inputType)) {
            return normalizeChoiceValue(rawValue, meta);
        }
        return rawValue;
    }

    private List<AiSuggestionItem> filterSuggestionsByRelevance(
            String causeCode,
            String userText,
            List<AiSuggestionItem> items,
            Map<String, QuestionFieldMeta> fieldMetaMap
    ) {
        if (items == null || items.isEmpty()) {
            return List.of();
        }
        if (!isMarriageCause(causeCode)) {
            return items;
        }
        String normalizedInput = normalizeOptionToken(userText == null ? "" : userText);
        List<AiSuggestionItem> kept = new ArrayList<>();
        for (AiSuggestionItem i : items) {
            if (i == null || i.getKey() == null || i.getKey().isBlank()) {
                continue;
            }
            if (isSuggestionRelevant(i, normalizedInput, fieldMetaMap.get(i.getKey()))) {
                kept.add(i);
            }
        }
        if (!kept.isEmpty()) {
            return kept;
        }
        // 如果全部被过滤，保留一条最高置信度，避免前端完全无预填。
        AiSuggestionItem best = null;
        double bestConf = -1d;
        for (AiSuggestionItem i : items) {
            if (i == null) continue;
            double conf = i.getConfidence() == null ? 0d : i.getConfidence();
            if (best == null || conf > bestConf) {
                best = i;
                bestConf = conf;
            }
        }
        return best == null ? List.of() : List.of(best);
    }

    private boolean isSuggestionRelevant(AiSuggestionItem item, String normalizedInput, QuestionFieldMeta meta) {
        double confidence = item.getConfidence() == null ? 0d : item.getConfidence();
        String keyNorm = normalizeOptionToken(item.getKey());
        String valueNorm = normalizeOptionToken(item.getValue() == null ? "" : String.valueOf(item.getValue()));
        String labelNorm = meta == null ? "" : normalizeOptionToken(meta.label);
        if (meta != null && "number".equals(meta.inputType)) {
            Object normalizedNumber = normalizeNumberValue(item.getValue());
            if (normalizedNumber instanceof Number && confidence >= 0.6d) {
                return true;
            }
        }
        boolean hasDirectSignal = containsAny(normalizedInput, keyNorm, valueNorm, labelNorm);
        boolean hasMarriageContext = containsAny(normalizedInput, "婚", "离婚", "夫妻", "子女", "抚养", "赡养", "财产", "房", "继承", "彩礼");

        if (hasDirectSignal) {
            return true;
        }
        if (meta != null && ("choice".equals(meta.inputType) || "select".equals(meta.inputType))) {
            if (valueNorm != null && !valueNorm.isBlank() && containsAny(normalizedInput, valueNorm)) {
                return true;
            }
            for (Map.Entry<String, String> e : meta.optionLabelToValue.entrySet()) {
                if (!e.getKey().isBlank() && containsAny(normalizedInput, e.getKey())) {
                    return true;
                }
            }
        }
        if (hasMarriageContext && confidence >= 0.72d) {
            return true;
        }
        return confidence >= 0.85d;
    }

    private boolean isMarriageCause(String causeCode) {
        if (causeCode == null || causeCode.isBlank()) {
            return false;
        }
        String normalized = normalizeCauseCode(causeCode);
        // 优先用 rule_cause.category_code='marriage_family' 动态判断，避免新案由加进库后仍无法触发“婚姻语义相关性过滤”
        try {
            if (causeAssetDbService != null && causeAssetDbService.isMarriageFamilyCause(normalized)) {
                return true;
            }
        } catch (Exception ignored) {
        }
        // 兜底：兼容历史静态集合
        if (MARRIAGE_CAUSE_CODES.contains(causeCode)) return true;
        return MARRIAGE_CAUSE_CODES.contains(normalized);
    }

    private Object normalizeChoiceValue(Object rawValue, QuestionFieldMeta meta) {
        if (rawValue == null) {
            return null;
        }
        String text = String.valueOf(rawValue).trim();
        if (text.isBlank()) {
            return text;
        }
        if (meta.optionValues.contains(text)) {
            return text;
        }
        String normalized = normalizeOptionToken(text);
        String direct = meta.optionLabelToValue.get(normalized);
        if (direct != null && !direct.isBlank()) {
            return direct;
        }

        if (containsAny(normalized, "贷款", "按揭", "房贷")) {
            Object v = chooseOption(meta, "按揭");
            if (v != null) return v;
        }
        if (containsAny(normalized, "全款", "一次性")) {
            Object v = chooseOption(meta, "全款");
            if (v != null) return v;
        }
        if (containsAny(normalized, "婚前")) {
            Object v = chooseOption(meta, "婚前");
            if (v != null) return v;
        }
        if (containsAny(normalized, "婚后")) {
            Object v = chooseOption(meta, "婚后");
            if (v != null) return v;
        }

        for (String ov : meta.optionValues) {
            String on = normalizeOptionToken(ov);
            if (normalized.contains(on) || on.contains(normalized)) {
                return ov;
            }
        }
        for (Map.Entry<String, String> e : meta.optionLabelToValue.entrySet()) {
            String on = e.getKey();
            if (normalized.contains(on) || on.contains(normalized)) {
                return e.getValue();
            }
        }
        return text;
    }

    private Object chooseOption(QuestionFieldMeta meta, String expected) {
        if (meta.optionValues.contains(expected)) {
            return expected;
        }
        return meta.optionLabelToValue.get(normalizeOptionToken(expected));
    }

    private Object normalizeNumberValue(Object rawValue) {
        if (rawValue == null || rawValue instanceof Number) {
            return rawValue;
        }
        String s = String.valueOf(rawValue).trim();
        if (s.isBlank()) {
            return rawValue;
        }
        try {
            String t = s.replace(",", "").replace("，", "");
            if (t.endsWith("万")) {
                return Double.parseDouble(t.substring(0, t.length() - 1).trim()) * 10000d;
            }
            if (t.endsWith("千")) {
                return Double.parseDouble(t.substring(0, t.length() - 1).trim()) * 1000d;
            }
            return Double.parseDouble(t);
        } catch (Exception ignore) {
            return rawValue;
        }
    }

    private Object normalizeBooleanValue(Object rawValue) {
        if (rawValue == null || rawValue instanceof Boolean) {
            return rawValue;
        }
        String s = String.valueOf(rawValue).trim().toLowerCase(Locale.ROOT);
        if (BOOLEAN_TRUE_TOKENS.contains(s)) {
            return true;
        }
        if (BOOLEAN_FALSE_TOKENS.contains(s)) {
            return false;
        }
        return rawValue;
    }

    private List<AiSuggestionItem> augmentNumericSuggestions(
            String userText,
            List<AiSuggestionItem> items,
            List<String> allowedKeys,
            Map<String, QuestionFieldMeta> fieldMetaMap
    ) {
        if (userText == null || userText.isBlank() || fieldMetaMap == null || fieldMetaMap.isEmpty()) {
            return items == null ? List.of() : items;
        }
        List<AiSuggestionItem> base = items == null ? List.of() : items;
        List<NumericCandidate> candidates = extractNumericCandidates(userText);
        if (candidates.isEmpty()) {
            return base;
        }

        Set<String> allowed = (allowedKeys == null || allowedKeys.isEmpty()) ? null : new HashSet<>(allowedKeys);
        List<AiSuggestionItem> out = new ArrayList<>(base);
        for (Map.Entry<String, QuestionFieldMeta> e : fieldMetaMap.entrySet()) {
            String key = e.getKey();
            QuestionFieldMeta meta = e.getValue();
            if (meta == null || !"number".equals(meta.inputType)) {
                continue;
            }
            if (allowed != null && !allowed.contains(key)) {
                continue;
            }
            if (hasNumericSuggestion(base, key)) {
                continue;
            }
            NumericCandidate best = pickBestNumericCandidate(userText, key, meta, candidates);
            if (best == null) {
                continue;
            }
            out.add(new AiSuggestionItem(
                    key,
                    best.value,
                    0.78d,
                    "根据文本数值片段提取：" + best.snippet
            ));
        }
        return canonicalizeAndDedupeSuggestions(out, allowedKeys);
    }

    private boolean hasNumericSuggestion(List<AiSuggestionItem> items, String key) {
        if (items == null || items.isEmpty()) {
            return false;
        }
        for (AiSuggestionItem i : items) {
            if (i == null || i.getKey() == null) {
                continue;
            }
            if (!key.equals(i.getKey())) {
                continue;
            }
            if (i.getValue() instanceof Number) {
                return true;
            }
            Object normalized = normalizeNumberValue(i.getValue());
            if (normalized instanceof Number) {
                return true;
            }
        }
        return false;
    }

    private NumericCandidate pickBestNumericCandidate(
            String userText,
            String key,
            QuestionFieldMeta meta,
            List<NumericCandidate> candidates
    ) {
        String full = normalizeOptionToken(key + " " + (meta.label == null ? "" : meta.label));
        Set<String> fieldWords = extractChineseWords(key + " " + (meta.label == null ? "" : meta.label));
        int bestScore = Integer.MIN_VALUE;
        NumericCandidate best = null;
        for (NumericCandidate c : candidates) {
            int score = 0;
            String ctx = normalizeOptionToken(c.context);
            for (String w : fieldWords) {
                if (ctx.contains(normalizeOptionToken(w))) {
                    score += 3;
                } else if (normalizeOptionToken(userText).contains(normalizeOptionToken(w))) {
                    score += 1;
                }
            }
            if (full.contains("每月") && c.context.contains("每月")) score += 4;
            if (full.contains("每年") && c.context.contains("每年")) score += 4;
            if (containsAny(full, "原", "之前", "曾", "既有", "约定", "判决", "调解") && containsAny(ctx, "原", "之前", "那时候", "当时", "曾", "原来", "说好", "约定", "判决", "调解")) score += 6;
            if (containsAny(full, "请求", "主张", "提高", "变更", "调整") && containsAny(ctx, "提高", "增加", "上调", "变更", "调整", "到")) score += 5;
            if (containsAny(full, "支出", "费用", "开销", "花费") && containsAny(ctx, "支出", "费用", "开销", "花费", "教育", "医疗", "生活", "钢琴")) score += 5;
            if (containsAny(full, "工资", "收入", "年薪", "月薪") && containsAny(ctx, "工资", "收入", "年薪", "月薪")) score += 5;
            if (containsAny(full, "金额", "数额", "费用", "抚养费", "赔偿", "价款", "租金", "贷款", "还款", "首付")) score += 2;
            if (c.hasYuanUnit) score += 1;
            if (c.hasWanUnit && containsAny(full, "工资", "收入", "年薪", "金额", "数额", "费用")) score += 1;

            if (score > bestScore) {
                bestScore = score;
                best = c;
            }
        }
        if (bestScore >= 1 && best != null) {
            return best;
        }
        // 对金额/费用类数字题做兜底，避免空白
        if (containsAny(full, "金额", "数额", "费用", "支出", "价款", "抚养费", "赔偿", "还款", "首付", "工资", "收入")) {
            return candidates.get(0);
        }
        return null;
    }

    private Set<String> extractChineseWords(String text) {
        Set<String> out = new LinkedHashSet<>();
        if (text == null || text.isBlank()) {
            return out;
        }
        Matcher m = CHINESE_WORD_PATTERN.matcher(text);
        while (m.find()) {
            String w = m.group();
            if (w == null || w.isBlank()) {
                continue;
            }
            if (Set.of("是否", "多少", "金额", "数额", "问题", "情况", "相关", "以及", "或者", "可以", "进行", "一个", "哪个").contains(w)) {
                continue;
            }
            out.add(w);
        }
        return out;
    }

    private List<NumericCandidate> extractNumericCandidates(String userText) {
        List<NumericCandidate> out = new ArrayList<>();
        Matcher m = NUMBER_WITH_UNIT_PATTERN.matcher(userText);
        while (m.find()) {
            String num = m.group(1);
            String unit = m.group(2);
            if (num == null || num.isBlank()) {
                continue;
            }
            Double value = toNumericValue(num, unit);
            if (value == null) {
                continue;
            }
            int start = Math.max(0, m.start() - 24);
            int end = Math.min(userText.length(), m.end() + 24);
            String ctx = userText.substring(start, end);
            String snippet = userText.substring(m.start(), m.end());
            out.add(new NumericCandidate(value, ctx, snippet, "元".equals(unit) || "块".equals(unit), "万".equalsIgnoreCase(unit), m.start()));
        }
        return out;
    }

    private Double toNumericValue(String num, String unit) {
        try {
            double v = Double.parseDouble(num);
            if (unit == null || unit.isBlank()) {
                return v;
            }
            String u = unit.toLowerCase(Locale.ROOT);
            if ("万".equals(u) || "w".equals(u)) return v * 10000d;
            if ("千".equals(u)) return v * 1000d;
            return v;
        } catch (Exception ignore) {
            return null;
        }
    }

    private static class NumericCandidate {
        private final double value;
        private final String context;
        private final String snippet;
        private final boolean hasYuanUnit;
        private final boolean hasWanUnit;
        @SuppressWarnings("unused")
        private final int position;

        private NumericCandidate(double value, String context, String snippet, boolean hasYuanUnit, boolean hasWanUnit, int position) {
            this.value = value;
            this.context = context;
            this.snippet = snippet;
            this.hasYuanUnit = hasYuanUnit;
            this.hasWanUnit = hasWanUnit;
            this.position = position;
        }
    }

    private String normalizeOptionToken(String s) {
        if (s == null) {
            return "";
        }
        String normalized = Normalizer.normalize(s.trim().toLowerCase(Locale.ROOT), Normalizer.Form.NFKC);
        return normalized.replaceAll("\\s+", "");
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
        } else if ("betrothal_property".equals(causeCode) || "marriage_betrothal_property_dispute".equals(causeCode)) {
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

        // 新增婚姻家事案由在 AI 调用失败时的通用兜底：
        // 按用户文本与问卷 key 的语义重合度，为 allowed keys 自动补最小可用建议，避免“完全无预填”。
        if (out.isEmpty() && isMarriageCause(causeCode)) {
            out.addAll(genericMarriageFallbackByAllowedKeys(t, allowed));
        }

        return dedupeFallbackByKey(out);
    }

    private List<AiSuggestionItem> genericMarriageFallbackByAllowedKeys(String normalizedText, Set<String> allowed) {
        if (allowed == null || allowed.isEmpty()) {
            return List.of();
        }
        List<AiSuggestionItem> out = new ArrayList<>();
        for (String key : allowed) {
            if (key == null || key.isBlank()) continue;
            String k = key.toLowerCase(Locale.ROOT);

            // 仅对布尔判断类 key 做保守兜底，避免误填金额/枚举。
            if (!containsAny(k, "是否", "存在", "已", "有", "涉及", "办理", "完成", "拒绝", "同意", "争议")) {
                continue;
            }
            // 用户文本与 key 至少要有一组核心词命中才给 true 建议。
            if (containsAny(normalizedText,
                    "离婚", "婚姻", "结婚", "分居", "家暴", "过错",
                    "子女", "抚养", "扶养", "赡养", "探望", "监护",
                    "财产", "债务", "彩礼", "同居", "亲子", "收养", "分家", "继承")
                    && containsAny(k,
                    "离婚", "婚姻", "结婚", "分居", "家暴", "过错",
                    "子女", "抚养", "扶养", "赡养", "探望", "监护",
                    "财产", "债务", "彩礼", "同居", "亲子", "收养", "分家", "继承")) {
                out.add(new AiSuggestionItem(key, true, 0.62, "AI失败后按案由问卷key语义兜底匹配"));
            }
        }
        return out;
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
        if (text == null || text.isBlank() || keys == null || keys.length == 0) {
            return false;
        }
        for (String k : keys) {
            if (k == null || k.isBlank()) {
                continue;
            }
            if (text.contains(k)) return true;
        }
        return false;
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
