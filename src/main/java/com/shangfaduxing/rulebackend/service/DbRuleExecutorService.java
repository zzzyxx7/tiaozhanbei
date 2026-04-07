package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.shangfaduxing.rulebackend.model.*;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class DbRuleExecutorService {
    private final RuleDefinitionDbService ruleDefinitionDbService;
    private final CauseAssetDbService causeAssetDbService;

    public DbRuleExecutorService(RuleDefinitionDbService ruleDefinitionDbService, CauseAssetDbService causeAssetDbService) {
        this.ruleDefinitionDbService = ruleDefinitionDbService;
        this.causeAssetDbService = causeAssetDbService;
    }

    public JudgeResponse execute(String causeCode, Map<String, Object> answers, Map<String, Object> facts) {
        List<RuleDefinitionDbService.JudgeRule> rules = ruleDefinitionDbService.getEnabledRulesByCause(causeCode);
        List<ActivatedPath> paths = new ArrayList<>();
        List<Conclusion> conclusions = new ArrayList<>();
        List<FinalResultItem> finals = new ArrayList<>();
        Set<String> lawRefs = new LinkedHashSet<>();

        for (RuleDefinitionDbService.JudgeRule rule : rules) {
            if (!matchCondition(rule.condition, facts)) continue;
            List<String> conditionDesc = extractConditionDescriptions(rule.condition, facts);
            if (!rule.pathName.isBlank()) {
                paths.add(new ActivatedPath(rule.pathName, conditionDesc, rule.calcExpr, rule.lawRef));
            }
            if (!rule.lawRef.isBlank()) lawRefs.add(rule.lawRef);
            for (RuleDefinitionDbService.RuleConclusionTemplate c : rule.conclusions) {
                conclusions.add(new Conclusion(c.type, c.result, c.reason, c.lawRefs, c.level));
                lawRefs.addAll(c.lawRefs);
                if (!c.finalItem.isBlank() || !c.finalResult.isBlank() || !c.finalDetail.isBlank()) {
                    finals.add(new FinalResultItem(c.finalItem, c.finalResult, c.finalDetail));
                }
            }
        }

        JudgeResponse resp = new JudgeResponse();
        resp.setSuccess(!conclusions.isEmpty() || !paths.isEmpty());
        resp.setMessage(resp.isSuccess() ? "裁判推理完成" : "未命中规则，请补充事实后重试");
        resp.setAnswers(answers);
        resp.setFacts(facts);
        resp.setActivatedPaths(paths);
        resp.setConclusions(conclusions);
        resp.setFinalResults(finals);
        resp.setLawsApplied(causeAssetDbService.getLawsByCause(causeCode).stream()
                .filter(l -> lawRefs.contains(l.getId()))
                .collect(Collectors.toList()));
        resp.setStep2(buildStep2Meta(causeCode, facts));
        return resp;
    }

    private Step2Meta buildStep2Meta(String causeCode, Map<String, Object> facts) {
        List<CauseAssetDbService.TargetDef> defs = causeAssetDbService.getTargetsByCause(causeCode);
        List<Step2TargetMeta> targets = defs.stream()
                .map(d -> new Step2TargetMeta(d.targetId, d.title, d.desc))
                .collect(Collectors.toList());
        List<String> suggested = defs.stream()
                .filter(d -> {
                    if (d.requiredFacts.isEmpty()) return true;
                    long proved = d.requiredFacts.stream().filter(r -> Boolean.TRUE.equals(facts.get(r.key))).count();
                    return ((double) proved / d.requiredFacts.size()) >= 0.5d;
                })
                .map(d -> d.targetId)
                .collect(Collectors.toList());
        return new Step2Meta(targets, suggested);
    }

    private boolean matchCondition(JsonNode node, Map<String, Object> facts) {
        if (node == null || node.isNull()) return true;
        String op = node.path("op").asText("fact");
        if ("and".equalsIgnoreCase(op)) {
            JsonNode children = node.path("children");
            if (!children.isArray()) return false;
            for (JsonNode c : children) if (!matchCondition(c, facts)) return false;
            return true;
        }
        if ("or".equalsIgnoreCase(op)) {
            JsonNode children = node.path("children");
            if (!children.isArray()) return false;
            for (JsonNode c : children) if (matchCondition(c, facts)) return true;
            return false;
        }
        if ("not".equalsIgnoreCase(op)) {
            return !matchCondition(node.path("child"), facts);
        }
        String fact = node.path("fact").asText("");
        String cmp = node.path("cmp").asText("eq");
        JsonNode value = node.get("value");
        Object factValue = facts.get(fact);
        return compare(factValue, cmp, value);
    }

    private boolean compare(Object factValue, String cmp, JsonNode value) {
        if ("eq".equalsIgnoreCase(cmp)) return Objects.equals(normalize(factValue), normalizeJson(value));
        if ("neq".equalsIgnoreCase(cmp)) return !Objects.equals(normalize(factValue), normalizeJson(value));
        if ("gt".equalsIgnoreCase(cmp)) return toDouble(factValue) > toDouble(value);
        if ("gte".equalsIgnoreCase(cmp)) return toDouble(factValue) >= toDouble(value);
        if ("lt".equalsIgnoreCase(cmp)) return toDouble(factValue) < toDouble(value);
        if ("lte".equalsIgnoreCase(cmp)) return toDouble(factValue) <= toDouble(value);
        if ("true".equalsIgnoreCase(cmp)) return Boolean.TRUE.equals(normalize(factValue));
        if ("false".equalsIgnoreCase(cmp)) return Boolean.FALSE.equals(normalize(factValue));
        return false;
    }

    private Object normalize(Object v) {
        if (v instanceof Number n) return n.doubleValue();
        return v;
    }

    private Object normalizeJson(JsonNode n) {
        if (n == null || n.isNull()) return null;
        if (n.isBoolean()) return n.booleanValue();
        if (n.isNumber()) return n.doubleValue();
        return n.asText();
    }

    private double toDouble(Object v) {
        if (v instanceof Number n) return n.doubleValue();
        try {
            return Double.parseDouble(String.valueOf(v));
        } catch (Exception e) {
            return 0d;
        }
    }

    private double toDouble(JsonNode n) {
        if (n == null || n.isNull()) return 0d;
        if (n.isNumber()) return n.doubleValue();
        try {
            return Double.parseDouble(n.asText());
        } catch (Exception e) {
            return 0d;
        }
    }

    private List<String> extractConditionDescriptions(JsonNode node, Map<String, Object> facts) {
        List<String> result = new ArrayList<>();
        flatten(node, facts, result);
        return result;
    }

    private void flatten(JsonNode node, Map<String, Object> facts, List<String> out) {
        if (node == null || node.isNull()) return;
        String op = node.path("op").asText("fact");
        if ("and".equalsIgnoreCase(op) || "or".equalsIgnoreCase(op)) {
            JsonNode children = node.path("children");
            if (children.isArray()) for (JsonNode c : children) flatten(c, facts, out);
            return;
        }
        if ("not".equalsIgnoreCase(op)) {
            flatten(node.path("child"), facts, out);
            return;
        }
        String fact = node.path("fact").asText("");
        Object val = facts.get(fact);
        out.add(fact + "=" + (Boolean.TRUE.equals(val) ? "是" : Boolean.FALSE.equals(val) ? "否" : String.valueOf(val)));
    }
}
