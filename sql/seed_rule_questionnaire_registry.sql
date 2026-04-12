-- 为 rule_question_group 外键补齐 rule_questionnaire 主表行（与 rule_cause.questionnaire_id 一致）。
-- 不执行也不影响现有接口；执行后建议重新 mysqldump。
USE rule_engine_db;
SET NAMES utf8mb4;

INSERT INTO rule_questionnaire (questionnaire_id, name, enabled, version_no) VALUES
('questionnaire_divorce_property_split', '离婚房产分割问卷', 1, 1),
('questionnaire_labor_unpaid_wages', '拖欠工资纠纷问卷', 1, 1),
('questionnaire_labor_no_contract', '未签劳动合同纠纷问卷', 1, 1),
('questionnaire_labor_illegal_termination', '违法解除劳动关系纠纷问卷', 1, 1),
('questionnaire_betrothal_property', '婚约财产纠纷问卷', 1, 1),
('questionnaire_divorce_dispute', '离婚纠纷问卷', 1, 1),
('questionnaire_post_divorce_property', '离婚后财产纠纷问卷', 1, 1),
('questionnaire_labor_injury_compensation', '工伤赔偿纠纷问卷', 1, 1),
('questionnaire_labor_overtime_pay', '加班费争议问卷', 1, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  enabled = VALUES(enabled);
