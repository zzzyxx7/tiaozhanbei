USE rule_engine_db;
SET NAMES utf8mb4;

-- 将婚约财产纠纷合并（第 12 项）：把 betrothal_property + property_dispute 合并为一个 causeCode
-- 新 causeCode 会对应同一份“合并问卷”（覆盖彩礼、房产/加名/车辆/转账等）
-- 并把第 12 项 Step2 目标/证据与 Step1 judge 也一起合到该 causeCode 上。

SET @old_betrothal_cause := 'betrothal_property';
SET @old_property_cause := 'property_dispute';

SET @old_betrothal_q := 'questionnaire_betrothal_property';
SET @old_property_q := 'questionnaire_property_dispute';

SET @new_cause_code := 'marriage_betrothal_property_dispute';
SET @new_cause_name := '婚约财产纠纷（彩礼+房产等合并）';
SET @new_questionnaire_id := 'questionnaire_marriage_betrothal_property_dispute';

-- 允许脚本重复执行：先清理新问卷已有数据，避免重复插入报 1062
DELETE FROM rule_question_visibility_rule
WHERE question_id IN (
  SELECT id FROM rule_question WHERE questionnaire_id = @new_questionnaire_id
);

DELETE FROM rule_question_option
WHERE question_id IN (
  SELECT id FROM rule_question WHERE questionnaire_id = @new_questionnaire_id
);

DELETE FROM rule_question
WHERE questionnaire_id = @new_questionnaire_id;

DELETE FROM rule_question_group
WHERE questionnaire_id = @new_questionnaire_id;

-- =========================
-- 1) cause / questionnaire
-- =========================
INSERT INTO rule_questionnaire (questionnaire_id, name, enabled, version_no)
VALUES (@new_questionnaire_id, '婚约财产纠纷（彩礼+房产等）问卷', 1, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  enabled = VALUES(enabled),
  version_no = VALUES(version_no);

INSERT INTO rule_cause (cause_code, cause_name, questionnaire_id, category_code, enabled)
VALUES (@new_cause_code, @new_cause_name, @new_questionnaire_id, 'marriage_family', 1)
ON DUPLICATE KEY UPDATE
  cause_name = VALUES(cause_name),
  questionnaire_id = VALUES(questionnaire_id),
  category_code = VALUES(category_code),
  enabled = VALUES(enabled);

-- 为了让“数据库婚姻家庭案由数”真正减少：把原两条第 12 项旧 causeCode 下线
UPDATE rule_cause
SET enabled = 0
WHERE cause_code IN ('betrothal_property','property_dispute');

-- =========================
-- 2) 合并问卷：question_group
-- =========================
INSERT IGNORE INTO rule_question_group
  (questionnaire_id, group_key, group_order, enabled, group_name, group_desc, icon)
SELECT
  @new_questionnaire_id,
  group_key,
  group_order,
  enabled,
  group_name,
  group_desc,
  icon
FROM rule_question_group
WHERE questionnaire_id IN ('questionnaire_betrothal_property','questionnaire_property_dispute');

-- =========================
-- 3) 合并问卷：rule_question（优先 property_dispute 的 question_key）
-- =========================
-- 先放 property_dispute 全量
INSERT IGNORE INTO rule_question
  (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
SELECT
  @new_questionnaire_id,
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
WHERE questionnaire_id = 'questionnaire_property_dispute';

-- 再放 betrothal_property 中“property_dispute 没有的 question_key”
INSERT IGNORE INTO rule_question
  (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
SELECT
  @new_questionnaire_id,
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
WHERE q.questionnaire_id = 'questionnaire_betrothal_property'
  AND NOT EXISTS (
    SELECT 1
    FROM rule_question p
    WHERE p.questionnaire_id = 'questionnaire_property_dispute'
      AND p.question_key = q.question_key
  );

-- =========================
-- 4) 合并问卷：rule_question_option（只复制 choice 类型）
-- =========================
INSERT IGNORE INTO rule_question_option
  (question_id, option_value, option_label, option_order, enabled)
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
  ON newq.questionnaire_id = @new_questionnaire_id
  AND newq.question_key = oldq.question_key
  AND newq.group_key = oldq.group_key
WHERE oldq.questionnaire_id IN ('questionnaire_betrothal_property','questionnaire_property_dispute');
-- 统一使用字面量避免变量 collation 混用

-- =========================
-- 5) 合并问卷：rule_question_visibility_rule
-- =========================
DELETE FROM rule_question_visibility_rule
WHERE question_id IN (
  SELECT id FROM rule_question WHERE questionnaire_id = @new_questionnaire_id
);

INSERT INTO rule_question_visibility_rule
  (question_id, show_if, condition_json, rule_order, enabled)
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
  ON newq.questionnaire_id = @new_questionnaire_id
  AND newq.question_key = oldq.question_key
  AND newq.group_key = oldq.group_key
-- 统一使用字面量避免变量 collation 混用
WHERE oldq.questionnaire_id IN ('questionnaire_betrothal_property','questionnaire_property_dispute');

-- =========================
-- 6) cause -> step2 target 映射
--   复用现有 targets（property_dispute + betrothal_property）
-- =========================
INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order)
VALUES
(@new_cause_code, 'target_property_refund', 1),
(@new_cause_code, 'target_property_no_refund', 2),
(@new_cause_code, 'target_add_betrothal_refund_full', 3),
(@new_cause_code, 'target_add_betrothal_refund_partial', 4),
(@new_cause_code, 'target_add_betrothal_no_refund', 5);

-- =========================
-- 7) cause -> law（保证 /judge 与 Step2 legalBasis 有法条）
-- =========================
-- betrothal_property 的 law_id 集合（property_dispute 是其子集）
INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order)
VALUES
(@new_cause_code, 'law_1042', 1),
(@new_cause_code, 'law_jshj_5', 2),
(@new_cause_code, 'law_sf_hzlj_2024_2', 3),
(@new_cause_code, 'law_sf_hzlj_2024_3', 4),
(@new_cause_code, 'law_sf_hzlj_2024_5', 5),
(@new_cause_code, 'law_sf_hzlj_2024_6', 6);

-- =========================
-- 8) Step1 judge（新 cause_code 的规则 + 结论绑定）
-- =========================
-- 8.1 若 property_dispute 的结论模板不存在，则补齐
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

-- 8.2 插入新 cause_code 的 judge rule
DELETE FROM rule_judge_rule
WHERE cause_code = @new_cause_code;

INSERT INTO rule_judge_rule
  (rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled)
VALUES
-- 彩礼全额返还（复用 betrothal_property 的条件）
('r_merge_12_betrothal_full', @new_cause_code, '合并12：彩礼全额返还路径', '彩礼全额返还路径命中', '与', 'law_jshj_5', 10,
 '{"op":"and","children":[{"fact":"存在彩礼给付","cmp":"eq","value":true},{"fact":"存在法定返还情形","cmp":"eq","value":true},{"op":"or","children":[{"fact":"未办理结婚登记","cmp":"eq","value":true},{"fact":"给付导致生活困难","cmp":"eq","value":true}]}]}',
 1),
-- 彩礼部分返还
('r_merge_12_betrothal_partial', @new_cause_code, '合并12：彩礼部分返还路径', '彩礼部分返还路径命中', '与/或', 'law_jshj_5', 20,
 '{"op":"and","children":[{"fact":"存在彩礼给付","cmp":"eq","value":true},{"fact":"已办理结婚登记","cmp":"eq","value":true},{"fact":"共同生活时间较短","cmp":"eq","value":true}]}',
 1),
-- 彩礼不返还抗辩
('r_merge_12_betrothal_no_refund', @new_cause_code, '合并12：彩礼不返还抗辩路径', '彩礼不返还抗辩路径命中', '与', 'law_jshj_5', 30,
 '{"op":"and","children":[{"fact":"已办理结婚登记","cmp":"eq","value":true},{"fact":"已登记后共同生活","cmp":"eq","value":true}]}',
 1),

-- 返还支持（复用 property_dispute 的条件）
('r_merge_12_property_refund_support', @new_cause_code, '合并12：返还支持路径', '返还支持命中', '与', 'law_jshj_5', 10,
 '{"op":"and","children":[{"fact":"存在彩礼或财产给付","cmp":"eq","value":true},{"fact":"是否存在法定返还情形","cmp":"eq","value":true}]}',
 1),
-- 不返还/少返还抗辩（复用 property_dispute 的条件）
('r_merge_12_property_refund_defense', @new_cause_code, '合并12：不返还抗辩路径', '不返还抗辩命中', '与', 'law_jshj_5', 20,
 '{"op":"and","children":[{"fact":"是否已办理结婚登记","cmp":"eq","value":"已登记"},{"fact":"是否已共同生活","cmp":"eq","value":true}]}',
 1);

-- 8.3 绑定 rule -> conclusion
INSERT IGNORE INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order)
VALUES
('r_merge_12_betrothal_full','c_add_betrothal_full',1),
('r_merge_12_betrothal_partial','c_add_betrothal_partial',1),
('r_merge_12_betrothal_no_refund','c_add_betrothal_no_refund',1),
('r_merge_12_property_refund_support','c_property_refund_support',1),
('r_merge_12_property_refund_defense','c_property_refund_defense',1);

