USE rule_engine_db;
SET NAMES utf8mb4;

-- v2：彻底避免 session 变量导致的 collation 混用。
-- 作用：合并第 12 项婚约财产纠纷（彩礼/房产等）为单一 causeCode：
--   marriage_betrothal_property_dispute
-- 同时重建合并问卷 questionnaire_marriage_betrothal_property_dispute
-- 并映射 Step2 targets + Step1 judge 到新 causeCode。

-- =========================
-- 0) 常量定义（不使用变量）
-- =========================
-- 老问卷
-- questionnaire_betrothal_property（彩礼返还细分）
-- questionnaire_property_dispute（彩礼/房产等合并问卷）
-- 老案由：betrothal_property + property_dispute
-- 新案由：marriage_betrothal_property_dispute
-- 新问卷：questionnaire_marriage_betrothal_property_dispute

-- =========================
-- 1) 清理新问卷已有数据（保证可重复执行）
-- =========================
DELETE FROM rule_question_visibility_rule
WHERE question_id IN (
  SELECT id FROM rule_question
  WHERE questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci
);

DELETE FROM rule_question_option
WHERE question_id IN (
  SELECT id FROM rule_question
  WHERE questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci
);

DELETE FROM rule_question
WHERE questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci;

DELETE FROM rule_question_group
WHERE questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci;

-- =========================
-- 2) 新增/更新问卷主表 + cause
-- =========================
INSERT INTO rule_questionnaire (questionnaire_id, name, enabled, version_no)
VALUES ('questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci,
        '婚约财产纠纷（彩礼+房产等合并）问卷', 1, 1)
ON DUPLICATE KEY UPDATE
  name = '婚约财产纠纷（彩礼+房产等合并）问卷',
  enabled = 1,
  version_no = 1;

INSERT INTO rule_cause (cause_code, cause_name, questionnaire_id, category_code, enabled)
VALUES ('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci,
        '婚约财产纠纷（彩礼+房产等合并）', 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci,
        'marriage_family', 1)
ON DUPLICATE KEY UPDATE
  cause_name = '婚约财产纠纷（彩礼+房产等合并）',
  questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute',
  category_code = 'marriage_family',
  enabled = 1;

-- 下线旧的 2 个 cause_code
UPDATE rule_cause
SET enabled = 0
WHERE cause_code IN ('betrothal_property' COLLATE utf8mb4_unicode_ci,
                      'property_dispute' COLLATE utf8mb4_unicode_ci);

-- =========================
-- 3) 合并问卷分组
-- =========================
INSERT INTO rule_question_group (questionnaire_id, group_key, group_order, enabled, group_name, group_desc, icon)
SELECT
  'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci,
  group_key,
  group_order,
  enabled,
  group_name,
  group_desc,
  icon
FROM rule_question_group
WHERE questionnaire_id IN ('questionnaire_betrothal_property' COLLATE utf8mb4_unicode_ci,
                            'questionnaire_property_dispute' COLLATE utf8mb4_unicode_ci);

-- 唯一键冲突（如果旧数据没完全清理，防守再做一次 ignore）
-- 说明：上面已 delete 掉新问卷组数据，理论上这里不会冲突；若冲突则需继续修复清理。

-- =========================
-- 4) 合并问卷题目（优先 property_dispute）
-- =========================
INSERT INTO rule_question
  (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
SELECT
  'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci,
  group_key,
  question_key,
  answer_key,
  label,
  hint,
  input_type,
  required,
  question_order,
  enabled,
  unit
FROM rule_question
WHERE questionnaire_id = 'questionnaire_property_dispute' COLLATE utf8mb4_unicode_ci;

-- 再补 betrothal_property 中 property_dispute 没有的题目
INSERT INTO rule_question
  (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
SELECT
  'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci,
  q.group_key,
  q.question_key,
  q.answer_key,
  q.label,
  q.hint,
  q.input_type,
  q.required,
  q.question_order,
  q.enabled,
  q.unit
FROM rule_question q
WHERE q.questionnaire_id = 'questionnaire_betrothal_property' COLLATE utf8mb4_unicode_ci
  AND NOT EXISTS (
    SELECT 1
    FROM rule_question p
    WHERE p.questionnaire_id = 'questionnaire_property_dispute' COLLATE utf8mb4_unicode_ci
      AND p.question_key = q.question_key
  );

-- =========================
-- 5) 合并选项（复制 choice 类型）
-- =========================
INSERT INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT
  newq.id,
  oldo.option_value,
  oldo.option_label,
  oldo.option_order,
  1
FROM rule_question_option oldo
JOIN rule_question oldq
  ON oldq.id = oldo.question_id
JOIN rule_question newq
  ON newq.questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci
  AND newq.question_key = oldq.question_key
  AND newq.group_key = oldq.group_key
WHERE oldq.questionnaire_id IN ('questionnaire_betrothal_property' COLLATE utf8mb4_unicode_ci,
                                'questionnaire_property_dispute' COLLATE utf8mb4_unicode_ci);

-- =========================
-- 6) 合并可见性规则
-- =========================
-- 说明：有些项目的 `question_key` 在合并后可能落到不同 `group_key`，
-- 为避免映射不到导致 visibility_cnt=0，这里采用“精确匹配(group_key+question_key) -> 兜底仅(question_key)”的两段式映射。
INSERT IGNORE INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT
  newq.id,
  v.show_if,
  v.condition_json,
  v.rule_order,
  v.enabled
FROM rule_question_visibility_rule v
JOIN rule_question oldq
  ON oldq.id = v.question_id
JOIN rule_question newq
  ON newq.questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci
  AND newq.question_key COLLATE utf8mb4_unicode_ci = oldq.question_key COLLATE utf8mb4_unicode_ci
  AND newq.group_key COLLATE utf8mb4_unicode_ci = oldq.group_key COLLATE utf8mb4_unicode_ci
WHERE oldq.questionnaire_id IN ('questionnaire_betrothal_property' COLLATE utf8mb4_unicode_ci,
                                'questionnaire_property_dispute' COLLATE utf8mb4_unicode_ci)
UNION ALL
SELECT
  newq2.id,
  v.show_if,
  v.condition_json,
  v.rule_order,
  v.enabled
FROM rule_question_visibility_rule v
JOIN rule_question oldq
  ON oldq.id = v.question_id
JOIN rule_question newq2
  ON newq2.questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci
  AND newq2.question_key COLLATE utf8mb4_unicode_ci = oldq.question_key COLLATE utf8mb4_unicode_ci
WHERE oldq.questionnaire_id IN ('questionnaire_betrothal_property' COLLATE utf8mb4_unicode_ci,
                                'questionnaire_property_dispute' COLLATE utf8mb4_unicode_ci)
  AND NOT EXISTS (
    SELECT 1
    FROM rule_question newq3
    WHERE newq3.questionnaire_id = 'questionnaire_marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci
      AND newq3.question_key COLLATE utf8mb4_unicode_ci = oldq.question_key COLLATE utf8mb4_unicode_ci
      AND newq3.group_key COLLATE utf8mb4_unicode_ci = oldq.group_key COLLATE utf8mb4_unicode_ci
  );

-- =========================
-- 7) cause -> step2 target
-- 复用现有 targets：返还彩礼/婚约财产 + 抗辩路径
-- =========================
INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order)
VALUES
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'target_property_refund', 1),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'target_property_no_refund', 2),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'target_add_betrothal_refund_full', 3),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'target_add_betrothal_refund_partial', 4),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'target_add_betrothal_no_refund', 5);

-- =========================
-- 8) cause -> law（复用旧婚约财产法条）
-- =========================
INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order)
VALUES
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'law_1042', 1),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'law_jshj_5', 2),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'law_sf_hzlj_2024_2', 3),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'law_sf_hzlj_2024_3', 4),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'law_sf_hzlj_2024_5', 5),
('marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, 'law_sf_hzlj_2024_6', 6);

-- =========================
-- 9) Step1 judge（新 cause_code 的规则 + 结论绑定）
-- =========================
INSERT INTO rule_judge_conclusion
  (conclusion_id, type, result, reason, level, law_refs_json, final_item, final_result, final_detail, enabled)
VALUES
('c_property_refund_support','conclusion','支持主张返还彩礼/婚约财产',
 '存在给付且满足法定返还情形，建议主张返还。','success','[\"law_jshj_5\",\"law_1042\"]',
 '返还彩礼/婚约财产','可主张返还','围绕给付凭证、登记/共同生活、困难等举证',1),
('c_property_refund_defense','conclusion','存在不返还/少返还抗辩点',
 '已登记且长期共同生活等情形下可抗辩不返还或少返还。','warning','[\"law_jshj_5\"]',
 '抗辩返还请求','可抗辩不返还/少返还','围绕共同生活时间、过错、返还比例举证',1)
ON DUPLICATE KEY UPDATE
  result = VALUES(result),
  reason = VALUES(reason),
  level = VALUES(level),
  law_refs_json = VALUES(law_refs_json),
  final_item = VALUES(final_item),
  final_result = VALUES(final_result),
  final_detail = VALUES(final_detail),
  enabled = VALUES(enabled);

DELETE FROM rule_judge_rule
WHERE cause_code = 'marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci;

INSERT INTO rule_judge_rule
  (rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled)
VALUES
('r_merge_12_betrothal_full', 'marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, '合并12：彩礼全额返还路径', '彩礼全额返还路径命中', '与', 'law_jshj_5', 10,
 '{"op":"and","children":[{"fact":"存在彩礼给付","cmp":"eq","value":true},{"fact":"存在法定返还情形","cmp":"eq","value":true},{"op":"or","children":[{"fact":"未办理结婚登记","cmp":"eq","value":true},{"fact":"给付导致生活困难","cmp":"eq","value":true}]}]}',
 1),
('r_merge_12_betrothal_partial', 'marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, '合并12：彩礼部分返还路径', '彩礼部分返还路径命中', '与/或', 'law_jshj_5', 20,
 '{"op":"and","children":[{"fact":"存在彩礼给付","cmp":"eq","value":true},{"fact":"已办理结婚登记","cmp":"eq","value":true},{"fact":"共同生活时间较短","cmp":"eq","value":true}]}',
 1),
('r_merge_12_betrothal_no_refund', 'marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, '合并12：彩礼不返还抗辩路径', '彩礼不返还抗辩路径命中', '与', 'law_jshj_5', 30,
 '{"op":"and","children":[{"fact":"已办理结婚登记","cmp":"eq","value":true},{"fact":"已登记后共同生活","cmp":"eq","value":true}]}',
 1),
('r_merge_12_property_refund_support', 'marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, '合并12：返还支持路径', '返还支持命中', '与', 'law_jshj_5', 10,
 '{"op":"and","children":[{"fact":"存在彩礼或财产给付","cmp":"eq","value":true},{"fact":"是否存在法定返还情形","cmp":"eq","value":true}]}',
 1),
('r_merge_12_property_refund_defense', 'marriage_betrothal_property_dispute' COLLATE utf8mb4_unicode_ci, '合并12：不返还抗辩路径', '不返还抗辩命中', '与', 'law_jshj_5', 20,
 '{"op":"and","children":[{"fact":"是否已办理结婚登记","cmp":"eq","value":"已登记"},{"fact":"是否已共同生活","cmp":"eq","value":true}]}',
 1);

INSERT IGNORE INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order)
VALUES
('r_merge_12_betrothal_full', 'c_add_betrothal_full', 1),
('r_merge_12_betrothal_partial', 'c_add_betrothal_partial', 1),
('r_merge_12_betrothal_no_refund', 'c_add_betrothal_no_refund', 1),
('r_merge_12_property_refund_support', 'c_property_refund_support', 1),
('r_merge_12_property_refund_defense', 'c_property_refund_defense', 1);

