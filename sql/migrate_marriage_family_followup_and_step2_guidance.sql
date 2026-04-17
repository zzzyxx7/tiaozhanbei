USE rule_engine_db;
SET NAMES utf8mb4;

-- 婚姻家庭 18 个重点案由：
-- 1) 为“证据/材料/证明/记录/凭证”等布尔题补充回答“是”后的追问题；
-- 2) 通过 visibility_rule 让追问只在父题回答 true 时显示；
-- 3) 采用增量方式，支持重复执行。

-- 先补个别问卷缺失的证据入口题，避免没有“是后追问”的入口
INSERT INTO rule_question_group (questionnaire_id, group_key, group_name, group_desc, icon, group_order, enabled)
VALUES
('questionnaire_in_marriage_property_division_dispute','G2','证据线索','补充财产清单、流水和医疗票据等证据线索','file',2,1)
ON DUPLICATE KEY UPDATE
  group_name = VALUES(group_name),
  group_desc = VALUES(group_desc),
  icon = VALUES(icon),
  group_order = VALUES(group_order),
  enabled = VALUES(enabled);

INSERT INTO rule_question (
  questionnaire_id, group_key, question_key, answer_key, label, hint,
  input_type, required, question_order, enabled, unit
)
VALUES
('questionnaire_in_marriage_property_division_dispute','G2','有财产清单或转账流水材料','有财产清单或转账流水材料','是否已有财产清单、账户流水、转账记录或处分记录？','用于锁定共同财产范围、转移路径和挥霍事实。','boolean',0,1,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G2','有重大医疗支出票据或病历材料','有重大医疗支出票据或病历材料','是否已有重大医疗支出票据、病历或诊断材料？','用于证明紧急医疗需求、支出金额和对家庭生活的影响。','boolean',0,2,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G2','有财产清单或转账流水材料_原始载体','有财产清单或转账流水材料_原始载体','是否已有财产清单、账户流水、转账记录或处分记录？ 对应材料是否能提供原件/原始载体/盖章件','如仅有截图、照片或转述，请说明原始载体是否可调取、补正或申请法院调查。','boolean',0,12,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G2','有重大医疗支出票据或病历材料_原始载体','有重大医疗支出票据或病历材料_原始载体','是否已有重大医疗支出票据、病历或诊断材料？ 对应材料是否能提供原件/原始载体/盖章件','如仅有截图、照片或转述，请说明原始载体是否可调取、补正或申请法院调查。','boolean',0,22,1,NULL)
ON DUPLICATE KEY UPDATE
  label = VALUES(label),
  hint = VALUES(hint),
  input_type = VALUES(input_type),
  required = VALUES(required),
  question_order = VALUES(question_order),
  enabled = VALUES(enabled),
  unit = VALUES(unit);

-- 一、补“请补充证据细节”追问题
INSERT INTO rule_question (
  questionnaire_id, group_key, question_key, answer_key, label, hint,
  input_type, required, question_order, enabled, unit
)
SELECT
  q.questionnaire_id,
  q.group_key,
  CONCAT(q.question_key, '_补充说明'),
  CONCAT(q.answer_key, '_补充说明'),
  CONCAT(q.label, ' 如回答“是”，请补充证据细节'),
  '请填写证据来源、形成时间、关键内容、与争议事实的对应关系以及证明目的。',
  'text',
  0,
  q.question_order * 10 + 1,
  1,
  NULL
FROM rule_question q
WHERE q.enabled = 1
  AND q.input_type = 'boolean'
  AND q.questionnaire_id IN (
    'questionnaire_marriage_betrothal_property_dispute',
    'questionnaire_in_marriage_property_division_dispute',
    'questionnaire_divorce_dispute',
    'questionnaire_post_divorce_property',
    'questionnaire_post_divorce_damage_liability_dispute',
    'questionnaire_marriage_invalid_dispute',
    'questionnaire_marriage_annulment_dispute',
    'questionnaire_spousal_property_agreement_dispute',
    'questionnaire_cohabitation_dispute',
    'questionnaire_paternity_confirmation_dispute',
    'questionnaire_paternity_disclaimer_dispute',
    'questionnaire_child_support_dispute',
    'questionnaire_sibling_support_dispute',
    'questionnaire_support_dispute',
    'questionnaire_adoption_dispute',
    'questionnaire_guardianship_dispute',
    'questionnaire_visitation_dispute',
    'questionnaire_family_partition_dispute'
  )
  AND (
    q.label LIKE '%证据%' OR q.label LIKE '%证明%' OR q.label LIKE '%材料%' OR q.label LIKE '%记录%' OR q.label LIKE '%凭证%'
    OR q.label LIKE '%流水%' OR q.label LIKE '%协议%' OR q.label LIKE '%判决%' OR q.label LIKE '%调解书%'
    OR q.label LIKE '%登记%' OR q.label LIKE '%合同%' OR q.label LIKE '%鉴定%' OR q.label LIKE '%病历%'
    OR q.label LIKE '%回执%' OR q.label LIKE '%户口%' OR q.label LIKE '%出生证明%' OR q.label LIKE '%公证%'
    OR q.answer_key LIKE '%证据%' OR q.answer_key LIKE '%证明%' OR q.answer_key LIKE '%材料%' OR q.answer_key LIKE '%记录%'
    OR q.answer_key LIKE '%凭证%' OR q.answer_key LIKE '%流水%' OR q.answer_key LIKE '%协议%' OR q.answer_key LIKE '%判决%'
    OR q.answer_key LIKE '%登记%' OR q.answer_key LIKE '%合同%' OR q.answer_key LIKE '%鉴定%' OR q.answer_key LIKE '%病历%'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM rule_question q2
    WHERE q2.questionnaire_id = q.questionnaire_id
      AND q2.question_key = CONCAT(q.question_key, '_补充说明')
  );

-- 二、补“是否能提供原件/原始载体”追问题
INSERT INTO rule_question (
  questionnaire_id, group_key, question_key, answer_key, label, hint,
  input_type, required, question_order, enabled, unit
)
SELECT
  q.questionnaire_id,
  q.group_key,
  CONCAT(q.question_key, '_原始载体'),
  CONCAT(q.answer_key, '_原始载体'),
  CONCAT(q.label, ' 对应材料是否能提供原件/原始载体/盖章件'),
  '如仅有截图、照片或转述，请说明原始载体是否可调取、补正或申请法院调查。',
  'boolean',
  0,
  q.question_order * 10 + 2,
  1,
  NULL
FROM rule_question q
WHERE q.enabled = 1
  AND q.input_type = 'boolean'
  AND q.questionnaire_id IN (
    'questionnaire_marriage_betrothal_property_dispute',
    'questionnaire_in_marriage_property_division_dispute',
    'questionnaire_divorce_dispute',
    'questionnaire_post_divorce_property',
    'questionnaire_post_divorce_damage_liability_dispute',
    'questionnaire_marriage_invalid_dispute',
    'questionnaire_marriage_annulment_dispute',
    'questionnaire_spousal_property_agreement_dispute',
    'questionnaire_cohabitation_dispute',
    'questionnaire_paternity_confirmation_dispute',
    'questionnaire_paternity_disclaimer_dispute',
    'questionnaire_child_support_dispute',
    'questionnaire_sibling_support_dispute',
    'questionnaire_support_dispute',
    'questionnaire_adoption_dispute',
    'questionnaire_guardianship_dispute',
    'questionnaire_visitation_dispute',
    'questionnaire_family_partition_dispute'
  )
  AND (
    q.label LIKE '%证据%' OR q.label LIKE '%证明%' OR q.label LIKE '%材料%' OR q.label LIKE '%记录%' OR q.label LIKE '%凭证%'
    OR q.label LIKE '%流水%' OR q.label LIKE '%协议%' OR q.label LIKE '%判决%' OR q.label LIKE '%调解书%'
    OR q.label LIKE '%登记%' OR q.label LIKE '%合同%' OR q.label LIKE '%鉴定%' OR q.label LIKE '%病历%'
    OR q.label LIKE '%回执%' OR q.label LIKE '%户口%' OR q.label LIKE '%出生证明%' OR q.label LIKE '%公证%'
    OR q.answer_key LIKE '%证据%' OR q.answer_key LIKE '%证明%' OR q.answer_key LIKE '%材料%' OR q.answer_key LIKE '%记录%'
    OR q.answer_key LIKE '%凭证%' OR q.answer_key LIKE '%流水%' OR q.answer_key LIKE '%协议%' OR q.answer_key LIKE '%判决%'
    OR q.answer_key LIKE '%登记%' OR q.answer_key LIKE '%合同%' OR q.answer_key LIKE '%鉴定%' OR q.answer_key LIKE '%病历%'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM rule_question q2
    WHERE q2.questionnaire_id = q.questionnaire_id
      AND q2.question_key = CONCAT(q.question_key, '_原始载体')
  );

-- 三、补显隐规则：仅在父题回答 true 时显示“补充说明”
INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT
  child.id,
  1,
  JSON_OBJECT('op', 'eq', 'value', TRUE, 'answerKey', parent.answer_key),
  1,
  1
FROM rule_question parent
JOIN rule_question child
  ON child.questionnaire_id = parent.questionnaire_id
 AND child.question_key = CONCAT(parent.question_key, '_补充说明')
LEFT JOIN rule_question_visibility_rule vr
  ON vr.question_id = child.id
 AND vr.enabled = 1
 AND JSON_UNQUOTE(JSON_EXTRACT(vr.condition_json, '$.answerKey')) = parent.answer_key
WHERE parent.enabled = 1
  AND parent.input_type = 'boolean'
  AND parent.questionnaire_id IN (
    'questionnaire_marriage_betrothal_property_dispute',
    'questionnaire_in_marriage_property_division_dispute',
    'questionnaire_divorce_dispute',
    'questionnaire_post_divorce_property',
    'questionnaire_post_divorce_damage_liability_dispute',
    'questionnaire_marriage_invalid_dispute',
    'questionnaire_marriage_annulment_dispute',
    'questionnaire_spousal_property_agreement_dispute',
    'questionnaire_cohabitation_dispute',
    'questionnaire_paternity_confirmation_dispute',
    'questionnaire_paternity_disclaimer_dispute',
    'questionnaire_child_support_dispute',
    'questionnaire_sibling_support_dispute',
    'questionnaire_support_dispute',
    'questionnaire_adoption_dispute',
    'questionnaire_guardianship_dispute',
    'questionnaire_visitation_dispute',
    'questionnaire_family_partition_dispute'
  )
  AND vr.id IS NULL;

-- 四、补显隐规则：仅在父题回答 true 时显示“原始载体”
INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT
  child.id,
  1,
  JSON_OBJECT('op', 'eq', 'value', TRUE, 'answerKey', parent.answer_key),
  1,
  1
FROM rule_question parent
JOIN rule_question child
  ON child.questionnaire_id = parent.questionnaire_id
 AND child.question_key = CONCAT(parent.question_key, '_原始载体')
LEFT JOIN rule_question_visibility_rule vr
  ON vr.question_id = child.id
 AND vr.enabled = 1
 AND JSON_UNQUOTE(JSON_EXTRACT(vr.condition_json, '$.answerKey')) = parent.answer_key
WHERE parent.enabled = 1
  AND parent.input_type = 'boolean'
  AND parent.questionnaire_id IN (
    'questionnaire_marriage_betrothal_property_dispute',
    'questionnaire_in_marriage_property_division_dispute',
    'questionnaire_divorce_dispute',
    'questionnaire_post_divorce_property',
    'questionnaire_post_divorce_damage_liability_dispute',
    'questionnaire_marriage_invalid_dispute',
    'questionnaire_marriage_annulment_dispute',
    'questionnaire_spousal_property_agreement_dispute',
    'questionnaire_cohabitation_dispute',
    'questionnaire_paternity_confirmation_dispute',
    'questionnaire_paternity_disclaimer_dispute',
    'questionnaire_child_support_dispute',
    'questionnaire_sibling_support_dispute',
    'questionnaire_support_dispute',
    'questionnaire_adoption_dispute',
    'questionnaire_guardianship_dispute',
    'questionnaire_visitation_dispute',
    'questionnaire_family_partition_dispute'
  )
  AND vr.id IS NULL;
