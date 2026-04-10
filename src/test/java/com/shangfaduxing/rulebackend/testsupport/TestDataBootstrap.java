package com.shangfaduxing.rulebackend.testsupport;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

@TestConfiguration
public class TestDataBootstrap {

    public static final List<String> CAUSES = List.of(
            "labor_unpaid_wages",
            "labor_no_contract",
            "labor_illegal_termination",
            "betrothal_property",
            "divorce_dispute",
            "post_divorce_property",
            "labor_injury_compensation",
            "labor_overtime_pay"
    );

    @Bean
    CommandLineRunner bootstrapTestData(JdbcTemplate jdbcTemplate) {
        return args -> {
            Timestamp now = Timestamp.from(Instant.now());

            for (String cause : CAUSES) {
                String qid = "questionnaire_" + cause;
                String lawId = "law_" + cause;
                String targetId = "target_" + cause + "_t1";
                String ruleId = "rule_" + cause + "_r1";
                String conclusionId = "conclusion_" + cause + "_c1";

                jdbcTemplate.update(
                        "MERGE INTO rule_cause KEY(cause_code) VALUES(?,?,?,?,?)",
                        cause, cause + "（测试）", qid, 1, now
                );

                jdbcTemplate.update(
                        "MERGE INTO rule_law KEY(id) VALUES(?,?,?,?,?,?)",
                        lawId, "示例法条（测试）", "第一条", "测试摘要", "测试法条正文", now
                );

                jdbcTemplate.update(
                        "MERGE INTO rule_cause_law KEY(cause_code, law_id) VALUES(?,?,?)",
                        cause, lawId, 1
                );

                jdbcTemplate.update(
                        "MERGE INTO rule_step2_target KEY(target_id) VALUES(?,?,?,?)",
                        targetId, "目标1（测试）", "用于自动化测试的 Step2 目标", 1
                );

                jdbcTemplate.update(
                        "MERGE INTO rule_cause_target KEY(cause_code, target_id) VALUES(?,?,?)",
                        cause, targetId, 1
                );

                jdbcTemplate.update(
                        "MERGE INTO rule_step2_target_legal_ref KEY(target_id, law_id) VALUES(?,?,?)",
                        targetId, lawId, 1
                );

                jdbcTemplate.update(
                        "INSERT INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES (?,?,?,?,?)",
                        targetId, "F1", "要件1（测试）", 1, 1
                );

                jdbcTemplate.update(
                        "INSERT INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES (?,?,?,?,?,?)",
                        targetId, "F1", "证据材料1（测试）", 1, 0, 1
                );

                jdbcTemplate.update(
                        "INSERT INTO rule_question_group (questionnaire_id, group_key, group_name, group_desc, icon, group_order, enabled) VALUES (?,?,?,?,?,?,?)",
                        qid, "G1", "基本信息（测试）", "用于自动化测试", "check", 1, 1
                );

                jdbcTemplate.update(
                        "INSERT INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, unit, input_type, required, question_order, enabled) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                        qid, "G1", "Q1", "A1", "这是一个测试问题？", null, null, "boolean", 1, 1, 1
                );

                // 规则：condition_json 为 {} => 永真匹配（DbRuleExecutorService 的默认行为）
                jdbcTemplate.update(
                        "MERGE INTO rule_judge_rule KEY(rule_id) VALUES(?,?,?,?,?,?,?,?,?,?)",
                        ruleId, cause, "规则1（测试）", "路径1（测试）", "与", lawId, 1, "{}", 1, now
                );

                jdbcTemplate.update(
                        "MERGE INTO rule_judge_conclusion KEY(conclusion_id) VALUES(?,?,?,?,?,?,?,?,?,?,?)",
                        conclusionId, "info", "命中结论（测试）", "用于判断接口已联通且规则可执行", "info",
                        "[\"" + lawId + "\"]", "终局项（测试）", "支持", "终局详情（测试）", 1, now
                );

                jdbcTemplate.update(
                        "MERGE INTO rule_judge_rule_conclusion KEY(rule_id, conclusion_id) VALUES(?,?,?)",
                        ruleId, conclusionId, 1
                );
            }
        };
    }
}

