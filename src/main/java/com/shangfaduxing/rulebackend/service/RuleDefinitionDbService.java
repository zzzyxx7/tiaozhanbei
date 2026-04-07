package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class RuleDefinitionDbService {

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public RuleDefinitionDbService(JdbcTemplate jdbcTemplate, ObjectMapper objectMapper) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
    }

    public List<JudgeRule> getEnabledRulesByCause(String causeCode) {
        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                    "SELECT rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled " +
                            "FROM rule_judge_rule WHERE cause_code=? AND enabled=1 ORDER BY priority ASC, rule_id ASC",
                    causeCode
            );
            List<JudgeRule> rules = new ArrayList<>();
            for (Map<String, Object> r : rows) {
                String conditionJson = Objects.toString(r.get("condition_json"), "{}");
                JsonNode conditionNode = objectMapper.readTree(conditionJson);
                String ruleId = Objects.toString(r.get("rule_id"), "");
                List<RuleConclusionTemplate> conclusions = getConclusionsByRuleId(ruleId);
                rules.add(new JudgeRule(
                        ruleId,
                        Objects.toString(r.get("cause_code"), ""),
                        Objects.toString(r.get("rule_name"), ""),
                        Objects.toString(r.get("path_name"), ""),
                        Objects.toString(r.get("calc_expr"), "与"),
                        Objects.toString(r.get("law_ref"), ""),
                        ((Number) r.getOrDefault("priority", 1000)).intValue(),
                        conditionNode,
                        conclusions
                ));
            }
            return rules;
        } catch (Exception e) {
            return List.of();
        }
    }

    private List<RuleConclusionTemplate> getConclusionsByRuleId(String ruleId) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT c.conclusion_id, c.type, c.result, c.reason, c.level, c.law_refs_json, c.final_item, c.final_result, c.final_detail " +
                        "FROM rule_judge_rule_conclusion rc " +
                        "JOIN rule_judge_conclusion c ON c.conclusion_id=rc.conclusion_id " +
                        "WHERE rc.rule_id=? AND c.enabled=1 " +
                        "ORDER BY rc.sort_order ASC, c.conclusion_id ASC",
                ruleId
        );
        List<RuleConclusionTemplate> out = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            out.add(new RuleConclusionTemplate(
                    Objects.toString(row.get("conclusion_id"), ""),
                    Objects.toString(row.get("type"), ""),
                    Objects.toString(row.get("result"), ""),
                    Objects.toString(row.get("reason"), ""),
                    Objects.toString(row.get("level"), "warning"),
                    parseStringArray(Objects.toString(row.get("law_refs_json"), "[]")),
                    Objects.toString(row.get("final_item"), ""),
                    Objects.toString(row.get("final_result"), ""),
                    Objects.toString(row.get("final_detail"), "")
            ));
        }
        return out;
    }

    private List<String> parseStringArray(String json) {
        try {
            JsonNode node = objectMapper.readTree(json == null ? "[]" : json);
            if (!node.isArray()) return List.of();
            List<String> values = new ArrayList<>();
            for (JsonNode n : node) {
                values.add(n.asText());
            }
            return values;
        } catch (Exception e) {
            return List.of();
        }
    }

    public static class JudgeRule {
        public final String ruleId;
        public final String causeCode;
        public final String ruleName;
        public final String pathName;
        public final String calcExpr;
        public final String lawRef;
        public final int priority;
        public final JsonNode condition;
        public final List<RuleConclusionTemplate> conclusions;

        public JudgeRule(String ruleId, String causeCode, String ruleName, String pathName, String calcExpr,
                         String lawRef, int priority, JsonNode condition, List<RuleConclusionTemplate> conclusions) {
            this.ruleId = ruleId;
            this.causeCode = causeCode;
            this.ruleName = ruleName;
            this.pathName = pathName;
            this.calcExpr = calcExpr;
            this.lawRef = lawRef;
            this.priority = priority;
            this.condition = condition;
            this.conclusions = conclusions == null ? List.of() : conclusions;
        }
    }

    public static class RuleConclusionTemplate {
        public final String conclusionId;
        public final String type;
        public final String result;
        public final String reason;
        public final String level;
        public final List<String> lawRefs;
        public final String finalItem;
        public final String finalResult;
        public final String finalDetail;

        public RuleConclusionTemplate(String conclusionId, String type, String result, String reason, String level,
                                      List<String> lawRefs, String finalItem, String finalResult, String finalDetail) {
            this.conclusionId = conclusionId;
            this.type = type;
            this.result = result;
            this.reason = reason;
            this.level = level;
            this.lawRefs = lawRefs == null ? List.of() : lawRefs;
            this.finalItem = finalItem;
            this.finalResult = finalResult;
            this.finalDetail = finalDetail;
        }
    }
}
