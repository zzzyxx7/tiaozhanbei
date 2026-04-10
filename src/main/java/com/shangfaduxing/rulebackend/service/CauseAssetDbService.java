package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.Law;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CauseAssetDbService {

    private final JdbcTemplate jdbcTemplate;
    private final QuestionnaireDbService questionnaireDbService;

    public CauseAssetDbService(JdbcTemplate jdbcTemplate, QuestionnaireDbService questionnaireDbService) {
        this.jdbcTemplate = jdbcTemplate;
        this.questionnaireDbService = questionnaireDbService;
    }

    public boolean supports(String causeCode) {
        try {
            Integer cnt = jdbcTemplate.queryForObject(
                    "SELECT COUNT(1) FROM rule_cause WHERE cause_code=? AND enabled=1",
                    Integer.class,
                    causeCode
            );
            return cnt != null && cnt > 0;
        } catch (Exception e) {
            return false;
        }
    }

    public List<Map<String, Object>> listEnabledCauses() {
        try {
            return jdbcTemplate.query(
                    "SELECT cause_code, cause_name, questionnaire_id FROM rule_cause WHERE enabled=1 ORDER BY cause_code",
                    (rs, rowNum) -> {
                        Map<String, Object> m = new LinkedHashMap<>();
                        m.put("causeCode", rs.getString("cause_code"));
                        m.put("causeName", rs.getString("cause_name"));
                        m.put("questionnaireId", rs.getString("questionnaire_id"));
                        return m;
                    }
            );
        } catch (Exception e) {
            return List.of();
        }
    }

    public List<Map<String, Object>> getQuestionGroups(String causeCode) {
        try {
            String questionnaireId = jdbcTemplate.queryForObject(
                    "SELECT questionnaire_id FROM rule_cause WHERE cause_code=? AND enabled=1",
                    String.class,
                    causeCode
            );
            if (questionnaireId == null || questionnaireId.isBlank()) {
                return List.of();
            }
            return questionnaireDbService.getQuestionGroups(questionnaireId);
        } catch (Exception e) {
            return List.of();
        }
    }

    public List<Law> getLawsByCause(String causeCode) {
        try {
            List<Law> mapped = jdbcTemplate.query(
                    "SELECT l.id, l.name, l.article, l.summary, l.text, l.updated_at " +
                            "FROM rule_law l " +
                            "JOIN rule_cause_law cl ON cl.law_id=l.id " +
                            "WHERE cl.cause_code=? " +
                            "ORDER BY cl.sort_order",
                    (rs, rowNum) -> new Law(
                            rs.getString("id"),
                            rs.getString("name"),
                            rs.getString("article"),
                            rs.getString("summary"),
                            rs.getString("text"),
                            rs.getString("updated_at")
                    ),
                    causeCode
            );
            if (!mapped.isEmpty()) return mapped;
            return jdbcTemplate.query(
                    "SELECT id, name, article, summary, text, updated_at FROM rule_law ORDER BY id",
                    (rs, rowNum) -> new Law(
                            rs.getString("id"),
                            rs.getString("name"),
                            rs.getString("article"),
                            rs.getString("summary"),
                            rs.getString("text"),
                            rs.getString("updated_at")
                    )
            );
        } catch (Exception e) {
            return List.of();
        }
    }

    public List<TargetDef> getTargetsByCause(String causeCode) {
        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                    "SELECT t.target_id, t.title, t.descr " +
                            "FROM rule_step2_target t " +
                            "JOIN rule_cause_target ct ON ct.target_id=t.target_id " +
                            "WHERE ct.cause_code=? AND t.enabled=1 " +
                            "ORDER BY ct.sort_order",
                    causeCode
            );
            if (rows.isEmpty()) {
                rows = jdbcTemplate.queryForList(
                        "SELECT target_id, title, descr FROM rule_step2_target WHERE enabled=1 ORDER BY target_id"
                );
            }
            List<TargetDef> defs = new ArrayList<>();
            for (Map<String, Object> row : rows) {
                String targetId = Objects.toString(row.get("target_id"), "");
                String title = Objects.toString(row.get("title"), "");
                String desc = Objects.toString(row.get("descr"), "");
                List<String> legalRefs = jdbcTemplate.query(
                        "SELECT law_id FROM rule_step2_target_legal_ref WHERE target_id=? ORDER BY sort_order",
                        (rs, i) -> rs.getString("law_id"),
                        targetId
                );
                List<RequiredFactDef> requiredFacts = jdbcTemplate.query(
                        "SELECT fact_key, label FROM rule_step2_required_fact WHERE target_id=? AND enabled=1 ORDER BY required_order",
                        (rs, i) -> new RequiredFactDef(rs.getString("fact_key"), rs.getString("label")),
                        targetId
                );
                Map<String, List<String>> evidenceMap = new LinkedHashMap<>();
                List<Map<String, Object>> evRows = jdbcTemplate.queryForList(
                        "SELECT fact_key, evidence_type FROM rule_step2_evidence_type WHERE target_id=? AND enabled=1 ORDER BY evidence_order",
                        targetId
                );
                for (Map<String, Object> ev : evRows) {
                    String factKey = Objects.toString(ev.get("fact_key"), "");
                    String evType = Objects.toString(ev.get("evidence_type"), "");
                    evidenceMap.computeIfAbsent(factKey, k -> new ArrayList<>()).add(evType);
                }
                defs.add(new TargetDef(targetId, title, desc, legalRefs, requiredFacts, evidenceMap));
            }
            return defs;
        } catch (Exception e) {
            return List.of();
        }
    }

    public static class TargetDef {
        public final String targetId;
        public final String title;
        public final String desc;
        public final List<String> legalRefs;
        public final List<RequiredFactDef> requiredFacts;
        public final Map<String, List<String>> evidenceMap;

        public TargetDef(String targetId, String title, String desc, List<String> legalRefs,
                         List<RequiredFactDef> requiredFacts, Map<String, List<String>> evidenceMap) {
            this.targetId = targetId;
            this.title = title;
            this.desc = desc;
            this.legalRefs = legalRefs == null ? List.of() : legalRefs;
            this.requiredFacts = requiredFacts == null ? List.of() : requiredFacts;
            this.evidenceMap = evidenceMap == null ? Map.of() : evidenceMap;
        }
    }

    public static class RequiredFactDef {
        public final String key;
        public final String label;

        public RequiredFactDef(String key, String label) {
            this.key = key;
            this.label = label;
        }
    }
}
