package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class QuestionnaireDbService {
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public QuestionnaireDbService(JdbcTemplate jdbcTemplate, ObjectMapper objectMapper) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
    }

    /**
     * 返回结构与 utils/divorce-rules.js 的 questionGroups 尽量保持一致，
     * 便于小程序直接渲染。
     */
    public List<Map<String, Object>> getQuestionGroups(String questionnaireId) {
        List<Map<String, Object>> groups = jdbcTemplate.query(
                "SELECT group_key, group_name, group_desc, icon, group_order " +
                        "FROM rule_question_group WHERE questionnaire_id=? AND enabled=1 ORDER BY group_order",
                (rs, rowNum) -> {
                    Map<String, Object> g = new HashMap<>();
                    g.put("groupId", rs.getString("group_key"));
                    g.put("groupName", rs.getString("group_name"));
                    g.put("groupDesc", rs.getString("group_desc"));
                    g.put("icon", rs.getString("icon"));
                    g.put("_groupKey", rs.getString("group_key"));
                    return g;
                },
                questionnaireId
        );

        // 为了方便再次查询，保留 group_key
        for (Map<String, Object> g : groups) {
            String groupKey = (String) g.get("_groupKey");

            List<Map<String, Object>> questions = jdbcTemplate.query(
                    "SELECT id, question_key, answer_key, label, hint, unit, input_type, required, question_order " +
                            "FROM rule_question " +
                            "WHERE questionnaire_id=? AND group_key=? AND enabled=1 ORDER BY question_order",
                    (rs, rowNum) -> {
                        Map<String, Object> q = new HashMap<>();
                        q.put("_questionId", rs.getLong("id"));
                        q.put("key", rs.getString("question_key"));
                        q.put("text", rs.getString("label"));
                        q.put("hint", rs.getString("hint"));
                        q.put("unit", rs.getString("unit"));
                        q.put("type", rs.getString("input_type"));
                        q.put("required", rs.getInt("required") == 1);
                        return q;
                    },
                    questionnaireId,
                    groupKey
            );

            for (Map<String, Object> q : questions) {
                long questionId = (long) q.get("_questionId");

                List<Map<String, Object>> options = jdbcTemplate.query(
                        "SELECT option_value, option_label, option_order " +
                                "FROM rule_question_option " +
                                "WHERE question_id=? AND enabled=1 ORDER BY option_order",
                        (rs, rowNum) -> {
                            Map<String, Object> o = new HashMap<>();
                            o.put("value", rs.getString("option_value"));
                            o.put("label", rs.getString("option_label"));
                            return o;
                        },
                        questionId
                );
                if (!options.isEmpty()) {
                    q.put("options", options);
                }

                // condition
                List<Map<String, Object>> condRows = jdbcTemplate.queryForList(
                        "SELECT condition_json FROM rule_question_visibility_rule " +
                                "WHERE question_id=? AND show_if=1 AND enabled=1 ORDER BY rule_order LIMIT 1",
                        questionId
                );
                if (!condRows.isEmpty()) {
                    String condJson = Objects.toString(condRows.get(0).get("condition_json"), null);
                    if (condJson != null && !condJson.isBlank()) {
                        q.put("condition", parseCondition(condJson));
                    }
                }

                q.remove("_questionId");
            }

            // 重新塞回 groupKey 对应的 questions（清理中间字段）
            g.put("questions", questions);
            g.remove("_groupKey");
        }

        return groups;
    }

    private Map<String, Object> parseCondition(String conditionJson) {
        try {
            JsonNode node = objectMapper.readTree(conditionJson);
            String op = node.has("op") ? node.get("op").asText() : null;
            String answerKey = node.has("answerKey") ? node.get("answerKey").asText() : null;

            if (answerKey == null) return null;

            if ("eq".equalsIgnoreCase(op)) {
                JsonNode v = node.get("value");
                if (v == null || v.isNull()) return null;
                Map<String, Object> cond = new HashMap<>();
                cond.put("key", answerKey);
                if (v.isBoolean()) cond.put("value", v.booleanValue());
                else cond.put("value", v.asText());
                return cond;
            }

            if ("neq".equalsIgnoreCase(op)) {
                JsonNode nv = node.get("notValue");
                if (nv == null || nv.isNull()) return null;
                Map<String, Object> cond = new HashMap<>();
                cond.put("key", answerKey);
                cond.put("notValue", nv.asText());
                return cond;
            }
        } catch (Exception ignored) {
        }
        return null;
    }
}

