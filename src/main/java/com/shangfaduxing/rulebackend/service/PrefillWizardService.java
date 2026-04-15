package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.*;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class PrefillWizardService {
    private static final String CAUSE_PROPERTY_DISPUTE = "property_dispute";
    private static final String CAUSE_DIVORCE_PROPERTY = "divorce_property";
    private final AiPrefillService aiPrefillService;
    private final CauseAssetDbService causeAssetDbService;

    public PrefillWizardService(AiPrefillService aiPrefillService, CauseAssetDbService causeAssetDbService) {
        this.aiPrefillService = aiPrefillService;
        this.causeAssetDbService = causeAssetDbService;
    }

    public PrefillWizardResponse run(PrefillWizardRequest req) {
        PrefillWizardResponse out = new PrefillWizardResponse();
        if (req == null || isBlank(req.getCauseCode()) || isBlank(req.getExampleText())) {
            out.setSuccess(false);
            out.setMessage("causeCode 和 exampleText 不能为空");
            out.setStage1QuestionGroups(List.of());
            out.setStage2QuestionGroups(List.of());
            out.setStage1Keys(List.of());
            out.setStage2Keys(List.of());
            out.setMergedAnswers(new LinkedHashMap<>());
            out.setSuggestions(List.of());
            return out;
        }
        String effectiveCauseCode = normalizeCauseCode(req.getCauseCode());
        int stage1 = clamp(req.getStage1Size(), 5, 1, 20);
        int stage2 = clamp(req.getStage2Size(), 3, 0, 20);

        // 1) 先跑 AI 预填（复用现有能力）
        AiPrefillRequest ar = new AiPrefillRequest();
        ar.setCauseCode(effectiveCauseCode);
        ar.setUserText(req.getExampleText());
        ar.setExistingAnswers(req.getExistingAnswers());
        ar.setProvider(req.getProvider());
        AiPrefillResponse prefill = aiPrefillService.prefill(ar);

        // 2) 拉问卷题目结构，按 question_order 展平后分段
        List<Map<String, Object>> groups = causeAssetDbService.getQuestionGroupsForPrefill(effectiveCauseCode);
        if (groups == null || groups.isEmpty()) {
            out.setSuccess(false);
            out.setMessage("该案由下未找到问卷题目；请检查 rule_cause / rule_question 配置");
            out.setProvider(prefill.getProvider());
            out.setFallback(true);
            out.setCauseCode(req.getCauseCode());
            out.setMergedAnswers(prefill.getMergedAnswers() == null ? new LinkedHashMap<>() : prefill.getMergedAnswers());
            out.setSuggestions(prefill.getSuggestions() == null ? List.of() : prefill.getSuggestions());
            out.setStage1Keys(List.of());
            out.setStage2Keys(List.of());
            out.setStage1QuestionGroups(List.of());
            out.setStage2QuestionGroups(List.of());
            return out;
        }
        Map<String, AiSuggestionItem> sugByKey = new HashMap<>();
        if (prefill.getSuggestions() != null) {
            for (AiSuggestionItem s : prefill.getSuggestions()) {
                if (s.getKey() != null) sugByKey.put(s.getKey(), s);
            }
        }

        List<QuestionRef> allQuestions = flatten(groups);
        List<String> stage1List = pickStage1(allQuestions, sugByKey, stage1);
        List<String> stage2List = pickStage2(allQuestions, stage1List, stage2);
        Set<String> stage1Keys = new HashSet<>(stage1List);
        Set<String> stage2Keys = new HashSet<>(stage2List);

        List<Map<String, Object>> stage1Groups = filterAndAttach(groups, stage1Keys, sugByKey);
        List<Map<String, Object>> stage2Groups = filterAndAttach(groups, stage2Keys, sugByKey);

        out.setSuccess(prefill.isSuccess());
        out.setMessage(prefill.getMessage());
        out.setProvider(prefill.getProvider());
        out.setFallback(prefill.isFallback());
        out.setCauseCode(req.getCauseCode());
        out.setMergedAnswers(prefill.getMergedAnswers() == null ? new LinkedHashMap<>() : prefill.getMergedAnswers());
        out.setSuggestions(prefill.getSuggestions() == null ? List.of() : prefill.getSuggestions());
        out.setStage1Keys(stage1List);
        out.setStage2Keys(stage2List);
        out.setStage1QuestionGroups(stage1Groups);
        out.setStage2QuestionGroups(stage2Groups);
        return out;
    }

    private record QuestionRef(String key, boolean required, int order) {
    }

    private static List<QuestionRef> flatten(List<Map<String, Object>> groups) {
        List<QuestionRef> out = new ArrayList<>();
        int order = 0;
        for (Map<String, Object> g : groups) {
            Object qs = g.get("questions");
            if (!(qs instanceof List<?> qList)) continue;
            for (Object qObj : qList) {
                if (!(qObj instanceof Map<?, ?> qm)) continue;
                Object k = qm.get("key");
                if (k == null) continue;
                String key = String.valueOf(k);
                if (key.isBlank()) continue;
                boolean required = Boolean.TRUE.equals(qm.get("required"));
                out.add(new QuestionRef(key, required, order++));
            }
        }
        return out;
    }

    /**
     * 第一步选题策略（更贴近真实产品）：
     * 1) 优先展示 AI 已命中的题（更“有内容”、用户确认更快）
     * 2) 其次展示必填题
     * 3) 最后按原问卷顺序补齐
     */
    private static List<String> pickStage1(List<QuestionRef> all, Map<String, AiSuggestionItem> sugByKey, int size) {
        size = Math.max(1, Math.min(50, size));
        LinkedHashSet<String> picked = new LinkedHashSet<>();

        // 1) AI 命中
        if (sugByKey != null && !sugByKey.isEmpty()) {
            for (QuestionRef q : all) {
                if (picked.size() >= size) break;
                if (sugByKey.containsKey(q.key)) picked.add(q.key);
            }
        }

        // 2) 必填
        for (QuestionRef q : all) {
            if (picked.size() >= size) break;
            if (q.required) picked.add(q.key);
        }

        // 3) 按顺序补齐
        for (QuestionRef q : all) {
            if (picked.size() >= size) break;
            picked.add(q.key);
        }
        return new ArrayList<>(picked);
    }

    /** 第二步：按原顺序取剩余题。 */
    private static List<String> pickStage2(List<QuestionRef> all, List<String> stage1, int size) {
        size = Math.max(0, Math.min(50, size));
        if (size == 0) return List.of();
        Set<String> s1 = new HashSet<>(stage1 == null ? List.of() : stage1);
        List<String> out = new ArrayList<>(size);
        for (QuestionRef q : all) {
            if (out.size() >= size) break;
            if (!s1.contains(q.key)) out.add(q.key);
        }
        return out;
    }

    private static List<Map<String, Object>> filterAndAttach(
            List<Map<String, Object>> groups,
            Set<String> keepKeys,
            Map<String, AiSuggestionItem> sugByKey
    ) {
        if (groups == null || groups.isEmpty() || keepKeys == null || keepKeys.isEmpty()) return List.of();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map<String, Object> g : groups) {
            Object qs = g.get("questions");
            if (!(qs instanceof List<?> qList)) continue;
            List<Map<String, Object>> kept = new ArrayList<>();
            for (Object qObj : qList) {
                if (!(qObj instanceof Map<?, ?> qm)) continue;
                Object rawKey = qm.get("key");
                String key = rawKey == null ? "" : String.valueOf(rawKey);
                if (!keepKeys.contains(key)) continue;
                Map<String, Object> q = new HashMap<>();
                for (Map.Entry<?, ?> e : qm.entrySet()) {
                    if (e.getKey() != null) q.put(String.valueOf(e.getKey()), e.getValue());
                }
                AiSuggestionItem sug = sugByKey.get(key);
                if (sug != null) {
                    Map<String, Object> prefill = new HashMap<>();
                    prefill.put("value", sug.getValue());
                    prefill.put("reason", sug.getReason());
                    prefill.put("confidence", sug.getConfidence());
                    q.put("prefill", prefill);
                }
                kept.add(q);
            }
            if (kept.isEmpty()) continue;
            Map<String, Object> ng = new HashMap<>(g);
            ng.put("questions", kept);
            out.add(ng);
        }
        return out;
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private static int clamp(Integer v, int def, int min, int max) {
        int x = (v == null) ? def : v;
        if (x < min) return min;
        return Math.min(x, max);
    }

    private static String normalizeCauseCode(String raw) {
        if (raw == null) return "";
        String c = raw.trim();
        if (CAUSE_PROPERTY_DISPUTE.equals(c)) {
            return CAUSE_DIVORCE_PROPERTY;
        }
        return c;
    }
}

