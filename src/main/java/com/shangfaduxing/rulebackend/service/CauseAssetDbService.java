package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.Law;
import com.shangfaduxing.rulebackend.model.CauseCategory;
import com.shangfaduxing.rulebackend.model.CauseItem;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CauseAssetDbService {

    /**
     * 不在 rule_cause 表中、但历史上或前端仍可能传入的案由码 → 直接映射问卷（与 rule_questionnaire 一致）。
     */
    private static final Map<String, String> QUESTIONNAIRE_ALIASES = Map.of(
            // 历史别名：旧前端/旧接口里可能传 divorce_property
            "divorce_property", "questionnaire_divorce_property_split",
            // 前端命名 property_dispute 统一走离婚房产分割问卷
            "property_dispute", "questionnaire_divorce_property_split"
    );

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

    /** 预填：支持 rule_cause 中的案由，以及 PREFILL_QUESTIONNAIRE_ALIASES 中的别名案由。 */
    public boolean supportsPrefill(String causeCode) {
        if (causeCode == null || causeCode.isBlank()) {
            return false;
        }
        return supports(causeCode) || QUESTIONNAIRE_ALIASES.containsKey(causeCode);
    }

    /**
     * 预填拉问卷：先按 rule_cause；若无题目且存在别名，则按别名问卷 ID 加载（如 divorce_property → 离婚房产分割问卷）。
     */
    public List<Map<String, Object>> getQuestionGroupsForPrefill(String causeCode) {
        if (causeCode == null || causeCode.isBlank()) {
            return List.of();
        }
        List<Map<String, Object>> groups = getQuestionGroups(causeCode);
        if (!groups.isEmpty()) {
            return groups;
        }
        String qid = QUESTIONNAIRE_ALIASES.get(causeCode);
        if (qid != null && !qid.isBlank()) {
            try {
                return questionnaireDbService.getQuestionGroups(qid);
            } catch (Exception e) {
                return List.of();
            }
        }
        return List.of();
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

    public List<CauseItem> listCommonCauses(String categoryCode) {
        if (categoryCode == null || categoryCode.isBlank()) return List.of();
        try {
            return jdbcTemplate.query(
                    "SELECT c.cause_code, c.cause_name, c.questionnaire_id " +
                            "FROM rule_common_cause cc " +
                            "JOIN rule_cause c ON c.cause_code=cc.cause_code " +
                            "WHERE cc.category_code=? AND cc.enabled=1 AND c.enabled=1 " +
                            "ORDER BY cc.sort_order, cc.cause_code",
                    (rs, rowNum) -> new CauseItem(
                            rs.getString("cause_code"),
                            rs.getString("cause_name"),
                            rs.getString("questionnaire_id")
                    ),
                    categoryCode
            );
        } catch (Exception e) {
            return List.of();
        }
    }

    public List<CauseCategory> listEnabledCategoriesTree() {
        try {
            List<CauseCategory> categories = jdbcTemplate.query(
                    "SELECT category_code, category_name " +
                            "FROM rule_cause_category WHERE enabled=1 ORDER BY sort_order, category_code",
                    (rs, rowNum) -> new CauseCategory(
                            rs.getString("category_code"),
                            rs.getString("category_name"),
                            new ArrayList<>()
                    )
            );

            Map<String, CauseCategory> byCode = new LinkedHashMap<>();
            for (CauseCategory c : categories) {
                byCode.put(c.getCategoryCode(), c);
            }

            List<Map<String, Object>> causeWithCategory = jdbcTemplate.query(
                    "SELECT category_code, cause_code, cause_name, questionnaire_id " +
                            "FROM rule_cause WHERE enabled=1 ORDER BY category_code, cause_code",
                    (rs, rowNum) -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("categoryCode", rs.getString("category_code"));
                        m.put("causeCode", rs.getString("cause_code"));
                        m.put("causeName", rs.getString("cause_name"));
                        m.put("questionnaireId", rs.getString("questionnaire_id"));
                        return m;
                    }
            );

            for (Map<String, Object> m : causeWithCategory) {
                String categoryCode = String.valueOf(m.getOrDefault("categoryCode", "other"));
                String causeCode = String.valueOf(m.getOrDefault("causeCode", ""));
                String causeName = String.valueOf(m.getOrDefault("causeName", ""));
                String questionnaireId = String.valueOf(m.getOrDefault("questionnaireId", ""));

                CauseCategory cat = byCode.get(categoryCode);
                if (cat == null) {
                    cat = byCode.computeIfAbsent("other", k -> new CauseCategory("other", "其他", new ArrayList<>()));
                }
                cat.getCauses().add(new CauseItem(causeCode, causeName, questionnaireId));
            }

            // 返回顺序：按大类 sort_order，其下按 cause_code
            for (CauseCategory cat : byCode.values()) {
                cat.getCauses().sort(Comparator.comparing(CauseItem::getCauseCode, Comparator.nullsLast(String::compareTo)));
            }
            return new ArrayList<>(byCode.values());
        } catch (Exception e) {
            return List.of();
        }
    }

    public boolean isInCategory(String causeCode, String categoryCode) {
        if (causeCode == null || causeCode.isBlank()) return false;
        if (categoryCode == null || categoryCode.isBlank()) return false;
        try {
            Integer cnt = jdbcTemplate.queryForObject(
                    "SELECT COUNT(1) FROM rule_cause WHERE cause_code=? AND enabled=1 AND category_code=?",
                    Integer.class,
                    causeCode,
                    categoryCode
            );
            return cnt != null && cnt > 0;
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isMarriageFamilyCause(String causeCode) {
        return isInCategory(causeCode, "marriage_family");
    }

    public CauseCategory getEnabledCategory(String categoryCode) {
        if (categoryCode == null || categoryCode.isBlank()) {
            return null;
        }
        try {
            List<CauseCategory> cats = jdbcTemplate.query(
                    "SELECT category_code, category_name " +
                            "FROM rule_cause_category WHERE enabled=1 AND category_code=? LIMIT 1",
                    (rs, rowNum) -> new CauseCategory(
                            rs.getString("category_code"),
                            rs.getString("category_name"),
                            new ArrayList<>()
                    ),
                    categoryCode
            );
            if (cats.isEmpty()) return null;
            CauseCategory cat = cats.get(0);
            List<CauseItem> causes = jdbcTemplate.query(
                    "SELECT cause_code, cause_name, questionnaire_id " +
                            "FROM rule_cause WHERE enabled=1 AND category_code=? ORDER BY cause_code",
                    (rs, rowNum) -> new CauseItem(
                            rs.getString("cause_code"),
                            rs.getString("cause_name"),
                            rs.getString("questionnaire_id")
                    ),
                    categoryCode
            );
            cat.setCauses(causes);
            return cat;
        } catch (Exception e) {
            return null;
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
                String aliasQid = QUESTIONNAIRE_ALIASES.get(causeCode);
                if (aliasQid == null || aliasQid.isBlank()) {
                    return List.of();
                }
                return questionnaireDbService.getQuestionGroups(aliasQid);
            }
            return questionnaireDbService.getQuestionGroups(questionnaireId);
        } catch (Exception e) {
            String aliasQid = QUESTIONNAIRE_ALIASES.get(causeCode);
            if (aliasQid != null && !aliasQid.isBlank()) {
                try {
                    return questionnaireDbService.getQuestionGroups(aliasQid);
                } catch (Exception ignored) {
                }
            }
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
