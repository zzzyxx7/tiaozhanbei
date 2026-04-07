package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shangfaduxing.rulebackend.model.Law;
import com.shangfaduxing.rulebackend.rules.step2.Step2Target;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;

import java.sql.Timestamp;
import java.util.*;

/**
 * 从 MySQL 读取规则数据并缓存到内存。
 * 这样可以让“新增/修改法条、Step2 target、问卷题目”等不需要重新改代码。
 */
@Service
public class RuleDbDataService {

    private final JdbcTemplate jdbcTemplate;
    private volatile List<Law> lawsCache = List.of();
    private volatile List<Step2Target> step2TargetsCache = List.of();

    public RuleDbDataService(JdbcTemplate jdbcTemplate, ObjectMapper objectMapper) {
        this.jdbcTemplate = jdbcTemplate;
        // objectMapper 目前未直接使用，保留构造参数以便后续扩展（如 JSON 字段映射）
    }

    @PostConstruct
    public void init() {
        reload();
    }

    public void reload() {
        this.lawsCache = loadLaws();
        this.step2TargetsCache = loadStep2Targets();
    }

    public List<Law> getLaws() {
        return lawsCache;
    }

    public List<Step2Target> getStep2Targets() {
        return step2TargetsCache;
    }

    private List<Law> loadLaws() {
        try {
            return jdbcTemplate.query(
                    "SELECT id, name, article, summary, text, updated_at FROM rule_law",
                    (rs, rowNum) -> {
                        Law law = new Law();
                        law.setId(rs.getString("id"));
                        law.setName(rs.getString("name"));
                        law.setArticle(rs.getString("article"));
                        law.setSummary(rs.getString("summary"));
                        law.setText(rs.getString("text"));
                        Timestamp ts = rs.getTimestamp("updated_at");
                        law.setEffectDate(ts == null ? null : ts.toString());
                        return law;
                    }
            );
        } catch (Exception e) {
            // 表不存在/权限不足：返回空，避免整个后端起不来
            return List.of();
        }
    }

    private List<Step2Target> loadStep2Targets() {
        try {
            List<Map<String, Object>> targets = jdbcTemplate.queryForList(
                    "SELECT target_id, title, descr FROM rule_step2_target WHERE enabled=1 ORDER BY target_id"
            );

            List<Step2Target> result = new ArrayList<>();
            for (Map<String, Object> t : targets) {
                String targetId = Objects.toString(t.get("target_id"), "");
                String title = Objects.toString(t.get("title"), "");
                String desc = Objects.toString(t.get("descr"), "");

                List<String> legalRefs = jdbcTemplate.query(
                        "SELECT law_id FROM rule_step2_target_legal_ref WHERE target_id=? ORDER BY sort_order",
                        (rs, rowNum) -> rs.getString("law_id"),
                        targetId
                );

                List<Step2Target.RequiredFact> requiredFacts = jdbcTemplate.query(
                        "SELECT fact_key, label, required_order FROM rule_step2_required_fact WHERE target_id=? AND enabled=1 ORDER BY required_order",
                        (rs, rowNum) -> new Step2Target.RequiredFact(
                                rs.getString("fact_key"),
                                rs.getString("label")
                        ),
                        targetId
                );

                // evidenceMap：只存 specific evidence_type（other_option=0）
                Map<String, List<String>> evidenceMap = new HashMap<>();
                List<Map<String, Object>> evidenceRows = jdbcTemplate.queryForList(
                        "SELECT fact_key, evidence_type, evidence_order, other_option " +
                                "FROM rule_step2_evidence_type " +
                                "WHERE target_id=? AND enabled=1 ORDER BY evidence_order",
                        targetId
                );
                for (Map<String, Object> er : evidenceRows) {
                    int otherOption = ((Number) er.get("other_option")).intValue();
                    if (otherOption != 0) continue;
                    String factKey = Objects.toString(er.get("fact_key"), "");
                    String evidenceType = Objects.toString(er.get("evidence_type"), "");
                    evidenceMap.computeIfAbsent(factKey, k -> new ArrayList<>()).add(evidenceType);
                }

                result.add(new Step2Target(targetId, title, desc, legalRefs, requiredFacts, evidenceMap));
            }

            return result;
        } catch (Exception e) {
            return List.of();
        }
    }
}

