USE rule_engine_db;
SET NAMES utf8mb4;

-- 婚姻家庭案由精细化执行后校验
-- 用途：
-- 1) 校验最终案由口径是否正确
-- 2) 校验问卷 / Step1 / Step2 是否完成闭环
-- 3) 重点检查第一批 6 个案由是否已从“基础入口”升级为“多分支 + 精细 Step2”

-- =========================================================
-- 0. 最终 common cause 口径校验
-- =========================================================
SELECT category_code, cause_code, sort_order, enabled
FROM rule_common_cause
WHERE category_code = 'marriage_family'
ORDER BY sort_order, cause_code;

SELECT cause_code, enabled
FROM rule_common_cause
WHERE category_code = 'marriage_family'
  AND cause_code IN ('betrothal_property', 'property_dispute');

-- =========================================================
-- 1. 最终 cause 主数据校验
-- =========================================================
SELECT cause_code, cause_name, questionnaire_id, category_code, enabled
FROM rule_cause
WHERE cause_code IN ('divorce_dispute','marriage_betrothal_property_dispute','child_support_dispute','support_dispute','post_divorce_property','in_marriage_property_division_dispute','post_divorce_damage_liability_dispute','marriage_invalid_dispute','marriage_annulment_dispute','spousal_property_agreement_dispute','cohabitation_dispute','paternity_confirmation_dispute','paternity_disclaimer_dispute','sibling_support_dispute','adoption_dispute','guardianship_dispute','visitation_dispute','family_partition_dispute')
ORDER BY cause_code;

-- =========================================================
-- 2. 问卷题目数量校验
-- =========================================================
SELECT
  questionnaire_id,
  COUNT(*) AS question_cnt,
  SUM(CASE WHEN group_key = 'G3' THEN 1 ELSE 0 END) AS refined_question_cnt
FROM rule_question
WHERE questionnaire_id IN (
  'questionnaire_divorce_dispute',
  'questionnaire_child_support_dispute',
  'questionnaire_support_dispute',
  'questionnaire_post_divorce_property',
  'questionnaire_in_marriage_property_division_dispute',
  'questionnaire_post_divorce_damage_liability_dispute',
  'questionnaire_marriage_invalid_dispute',
  'questionnaire_marriage_annulment_dispute',
  'questionnaire_spousal_property_agreement_dispute',
  'questionnaire_cohabitation_dispute',
  'questionnaire_paternity_confirmation_dispute',
  'questionnaire_paternity_disclaimer_dispute',
  'questionnaire_sibling_support_dispute',
  'questionnaire_adoption_dispute',
  'questionnaire_guardianship_dispute',
  'questionnaire_visitation_dispute',
  'questionnaire_family_partition_dispute'
)
GROUP BY questionnaire_id
ORDER BY questionnaire_id;

-- G3 分组是否落库
SELECT questionnaire_id, group_key, group_name, group_order, enabled
FROM rule_question_group
WHERE questionnaire_id IN (
  'questionnaire_divorce_dispute',
  'questionnaire_child_support_dispute',
  'questionnaire_support_dispute',
  'questionnaire_post_divorce_property',
  'questionnaire_in_marriage_property_division_dispute',
  'questionnaire_post_divorce_damage_liability_dispute',
  'questionnaire_marriage_invalid_dispute',
  'questionnaire_marriage_annulment_dispute',
  'questionnaire_spousal_property_agreement_dispute',
  'questionnaire_cohabitation_dispute',
  'questionnaire_paternity_confirmation_dispute',
  'questionnaire_paternity_disclaimer_dispute',
  'questionnaire_sibling_support_dispute',
  'questionnaire_adoption_dispute',
  'questionnaire_guardianship_dispute',
  'questionnaire_visitation_dispute',
  'questionnaire_family_partition_dispute'
)
  AND group_key = 'G3'
ORDER BY questionnaire_id;

-- =========================================================
-- 3. Step1 规则数量校验
-- 期望：不再只有 *_init，而是多分支
-- =========================================================
SELECT
  cause_code,
  COUNT(*) AS rule_cnt,
  GROUP_CONCAT(rule_id ORDER BY priority SEPARATOR ', ') AS rule_ids
FROM rule_judge_rule
WHERE cause_code IN (
  'divorce_dispute',
  'child_support_dispute',
  'support_dispute',
  'post_divorce_property',
  'in_marriage_property_division_dispute',
  'post_divorce_damage_liability_dispute',
  'marriage_invalid_dispute',
  'marriage_annulment_dispute',
  'spousal_property_agreement_dispute',
  'cohabitation_dispute',
  'paternity_confirmation_dispute',
  'paternity_disclaimer_dispute',
  'sibling_support_dispute',
  'adoption_dispute',
  'guardianship_dispute',
  'visitation_dispute',
  'family_partition_dispute'
)
GROUP BY cause_code
ORDER BY cause_code;

-- 是否还存在基础版 init 规则
SELECT cause_code, rule_id, priority
FROM rule_judge_rule
WHERE cause_code IN (
  'divorce_dispute',
  'child_support_dispute',
  'support_dispute',
  'post_divorce_property',
  'in_marriage_property_division_dispute',
  'post_divorce_damage_liability_dispute',
  'marriage_invalid_dispute',
  'marriage_annulment_dispute',
  'spousal_property_agreement_dispute',
  'cohabitation_dispute',
  'paternity_confirmation_dispute',
  'paternity_disclaimer_dispute',
  'sibling_support_dispute',
  'adoption_dispute',
  'guardianship_dispute',
  'visitation_dispute',
  'family_partition_dispute'
)
  AND rule_id LIKE 'r\\_%\\_init' ESCAPE '\\'
ORDER BY cause_code, rule_id;

-- Step1 规则与结论绑定是否完整
SELECT
  r.cause_code,
  r.rule_id,
  COUNT(rc.conclusion_id) AS conclusion_bind_cnt
FROM rule_judge_rule r
LEFT JOIN rule_judge_rule_conclusion rc
  ON rc.rule_id = r.rule_id
WHERE r.cause_code IN (
  'divorce_dispute',
  'child_support_dispute',
  'support_dispute',
  'post_divorce_property',
  'in_marriage_property_division_dispute',
  'post_divorce_damage_liability_dispute',
  'marriage_invalid_dispute',
  'marriage_annulment_dispute',
  'spousal_property_agreement_dispute',
  'cohabitation_dispute',
  'paternity_confirmation_dispute',
  'paternity_disclaimer_dispute',
  'sibling_support_dispute',
  'adoption_dispute',
  'guardianship_dispute',
  'visitation_dispute',
  'family_partition_dispute'
)
GROUP BY r.cause_code, r.rule_id
ORDER BY r.cause_code, r.priority, r.rule_id;

-- =========================================================
-- 4. cause_law / Step2 target / required_fact / evidence_type 数量校验
-- =========================================================
SELECT
  cause_code,
  COUNT(*) AS cause_law_cnt,
  GROUP_CONCAT(law_id ORDER BY sort_order SEPARATOR ', ') AS law_ids
FROM rule_cause_law
WHERE cause_code IN ('divorce_dispute','child_support_dispute','support_dispute','post_divorce_property','in_marriage_property_division_dispute','post_divorce_damage_liability_dispute','marriage_invalid_dispute','marriage_annulment_dispute','spousal_property_agreement_dispute','cohabitation_dispute','paternity_confirmation_dispute','paternity_disclaimer_dispute','sibling_support_dispute','adoption_dispute','guardianship_dispute','visitation_dispute','family_partition_dispute')
GROUP BY cause_code
ORDER BY cause_code;

SELECT
  ct.cause_code,
  COUNT(DISTINCT ct.target_id) AS target_cnt,
  COUNT(DISTINCT rf.fact_key) AS required_fact_cnt,
  COUNT(DISTINCT CONCAT(et.target_id, '::', et.fact_key, '::', et.evidence_type)) AS evidence_type_cnt
FROM rule_cause_target ct
LEFT JOIN rule_step2_required_fact rf
  ON rf.target_id = ct.target_id
LEFT JOIN rule_step2_evidence_type et
  ON et.target_id = ct.target_id
WHERE ct.cause_code IN ('divorce_dispute','child_support_dispute','support_dispute','post_divorce_property','in_marriage_property_division_dispute','post_divorce_damage_liability_dispute','marriage_invalid_dispute','marriage_annulment_dispute','spousal_property_agreement_dispute','cohabitation_dispute','paternity_confirmation_dispute','paternity_disclaimer_dispute','sibling_support_dispute','adoption_dispute','guardianship_dispute','visitation_dispute','family_partition_dispute')
GROUP BY ct.cause_code
ORDER BY ct.cause_code;

-- 第一批 6 个案由：target 详情
SELECT ct.cause_code, ct.target_id, ct.sort_order, t.title
FROM rule_cause_target ct
JOIN rule_step2_target t
  ON t.target_id = ct.target_id
WHERE ct.cause_code IN (
  'post_divorce_damage_liability_dispute',
  'marriage_invalid_dispute',
  'marriage_annulment_dispute',
  'paternity_confirmation_dispute',
  'paternity_disclaimer_dispute',
  'adoption_dispute'
)
ORDER BY ct.cause_code, ct.sort_order, ct.target_id;

-- 第一批 6 个案由：required_fact 详情
SELECT ct.cause_code, rf.target_id, rf.required_order, rf.fact_key
FROM rule_cause_target ct
JOIN rule_step2_required_fact rf
  ON rf.target_id = ct.target_id
WHERE ct.cause_code IN (
  'post_divorce_damage_liability_dispute',
  'marriage_invalid_dispute',
  'marriage_annulment_dispute',
  'paternity_confirmation_dispute',
  'paternity_disclaimer_dispute',
  'adoption_dispute'
)
ORDER BY ct.cause_code, rf.target_id, rf.required_order;

-- 第二批 + 第三批：required_fact 详情
SELECT ct.cause_code, rf.target_id, rf.required_order, rf.fact_key
FROM rule_cause_target ct
JOIN rule_step2_required_fact rf
  ON rf.target_id = ct.target_id
WHERE ct.cause_code IN (
  'guardianship_dispute',
  'visitation_dispute',
  'sibling_support_dispute',
  'spousal_property_agreement_dispute',
  'in_marriage_property_division_dispute',
  'cohabitation_dispute',
  'family_partition_dispute'
)
ORDER BY ct.cause_code, rf.target_id, rf.required_order;

-- =========================================================
-- 5. 问卷字段是否能直接对应 Step2 required_fact
-- 目标：question_key == fact_key 尽量对齐
-- =========================================================
SELECT
  c.cause_code,
  rf.fact_key,
  CASE WHEN q.question_key IS NOT NULL THEN 'matched' ELSE 'missing_question' END AS questionnaire_match
FROM rule_cause c
JOIN rule_cause_target ct
  ON ct.cause_code = c.cause_code
JOIN rule_step2_required_fact rf
  ON rf.target_id = ct.target_id
LEFT JOIN rule_question q
  ON q.questionnaire_id = c.questionnaire_id
 AND q.question_key = rf.fact_key
WHERE c.cause_code IN (
  'in_marriage_property_division_dispute',
  'post_divorce_damage_liability_dispute',
  'marriage_invalid_dispute',
  'marriage_annulment_dispute',
  'spousal_property_agreement_dispute',
  'cohabitation_dispute',
  'paternity_confirmation_dispute',
  'paternity_disclaimer_dispute',
  'sibling_support_dispute',
  'adoption_dispute',
  'guardianship_dispute',
  'visitation_dispute',
  'family_partition_dispute'
)
ORDER BY c.cause_code, questionnaire_match DESC, rf.fact_key;

-- =========================================================
-- 6. /judge 是否容易“答非所问”的快速排查点
-- 第一批重点案由，查看是否已拆分 precondition / support / exception
-- =========================================================
SELECT cause_code, path_name, COUNT(*) AS cnt
FROM rule_judge_rule
WHERE cause_code IN (
  'post_divorce_damage_liability_dispute',
  'marriage_invalid_dispute',
  'marriage_annulment_dispute',
  'paternity_confirmation_dispute',
  'paternity_disclaimer_dispute',
  'adoption_dispute'
)
GROUP BY cause_code, path_name
ORDER BY cause_code, path_name;

-- =========================================================
-- 7. 第 12 项合并口径复查
-- =========================================================
SELECT cause_code, cause_name, questionnaire_id, enabled
FROM rule_cause
WHERE cause_code IN (
  'marriage_betrothal_property_dispute',
  'betrothal_property',
  'property_dispute'
)
ORDER BY cause_code;

SELECT category_code, cause_code, enabled, sort_order
FROM rule_common_cause
WHERE category_code = 'marriage_family'
  AND cause_code IN (
    'marriage_betrothal_property_dispute',
    'betrothal_property',
    'property_dispute'
  )
ORDER BY cause_code;
