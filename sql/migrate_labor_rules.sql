-- 目标：
-- 1) 将劳动三案由（拖欠工资/未签合同/违法解除）写入当前 rule-backend 既有数据库表
-- 2) 不改动离婚数据；只覆盖劳动相关 target/questionnaire 数据
-- 3) 兼容你当前 Java 查询结构（RuleDbDataService + QuestionnaireDbService）

CREATE DATABASE IF NOT EXISTS rule_engine_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE rule_engine_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 关键修复：
-- 你遇到的 ERROR 1366 是表/列字符集不是 utf8mb4 导致中文写入失败。
-- 这里统一把相关表转为 utf8mb4，避免 fact_key/question_key/group_name 等中文字段报错。
ALTER TABLE rule_law CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_target CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_target_legal_ref CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_required_fact CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_evidence_type CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question_group CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question_option CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question_visibility_rule CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

START TRANSACTION;

-- =========================
-- 一、先清理劳动问卷旧数据（避免重复）
-- =========================
DELETE v
FROM rule_question_visibility_rule v
JOIN rule_question q ON q.id = v.question_id
WHERE q.questionnaire_id IN (
  'questionnaire_labor_unpaid_wages',
  'questionnaire_labor_no_contract',
  'questionnaire_labor_illegal_termination'
);

DELETE o
FROM rule_question_option o
JOIN rule_question q ON q.id = o.question_id
WHERE q.questionnaire_id IN (
  'questionnaire_labor_unpaid_wages',
  'questionnaire_labor_no_contract',
  'questionnaire_labor_illegal_termination'
);

DELETE FROM rule_question
WHERE questionnaire_id IN (
  'questionnaire_labor_unpaid_wages',
  'questionnaire_labor_no_contract',
  'questionnaire_labor_illegal_termination'
);

DELETE FROM rule_question_group
WHERE questionnaire_id IN (
  'questionnaire_labor_unpaid_wages',
  'questionnaire_labor_no_contract',
  'questionnaire_labor_illegal_termination'
);

-- =========================
-- 二、清理劳动 Step2 旧数据
-- =========================
DELETE FROM rule_step2_evidence_type
WHERE target_id IN (
  'target_labor_unpaid_wages_full_payment',
  'target_labor_unpaid_wages_overtime',
  'target_labor_unpaid_wages_termination_compensation',
  'target_labor_unpaid_wages_additional_compensation',
  'target_labor_no_contract_double_wage',
  'target_labor_no_contract_sign_contract',
  'target_labor_no_contract_open_term',
  'target_illegal_termination_compensation',
  'target_illegal_termination_reinstatement',
  'target_illegal_termination_wage_gap',
  'target_illegal_termination_revoke_decision'
);

DELETE FROM rule_step2_required_fact
WHERE target_id IN (
  'target_labor_unpaid_wages_full_payment',
  'target_labor_unpaid_wages_overtime',
  'target_labor_unpaid_wages_termination_compensation',
  'target_labor_unpaid_wages_additional_compensation',
  'target_labor_no_contract_double_wage',
  'target_labor_no_contract_sign_contract',
  'target_labor_no_contract_open_term',
  'target_illegal_termination_compensation',
  'target_illegal_termination_reinstatement',
  'target_illegal_termination_wage_gap',
  'target_illegal_termination_revoke_decision'
);

DELETE FROM rule_step2_target_legal_ref
WHERE target_id IN (
  'target_labor_unpaid_wages_full_payment',
  'target_labor_unpaid_wages_overtime',
  'target_labor_unpaid_wages_termination_compensation',
  'target_labor_unpaid_wages_additional_compensation',
  'target_labor_no_contract_double_wage',
  'target_labor_no_contract_sign_contract',
  'target_labor_no_contract_open_term',
  'target_illegal_termination_compensation',
  'target_illegal_termination_reinstatement',
  'target_illegal_termination_wage_gap',
  'target_illegal_termination_revoke_decision'
);

DELETE FROM rule_step2_target
WHERE target_id IN (
  'target_labor_unpaid_wages_full_payment',
  'target_labor_unpaid_wages_overtime',
  'target_labor_unpaid_wages_termination_compensation',
  'target_labor_unpaid_wages_additional_compensation',
  'target_labor_no_contract_double_wage',
  'target_labor_no_contract_sign_contract',
  'target_labor_no_contract_open_term',
  'target_illegal_termination_compensation',
  'target_illegal_termination_reinstatement',
  'target_illegal_termination_wage_gap',
  'target_illegal_termination_revoke_decision'
);

-- =========================
-- 三、法条（upsert）
-- =========================
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
('law_labor_50', '中华人民共和国劳动法', '第五十条', '工资应当按月支付', '工资应当以货币形式按月支付给劳动者本人，不得克扣或者无故拖欠劳动者的工资。', NOW()),
('law_contract_30', '中华人民共和国劳动合同法', '第三十条', '按约足额支付劳动报酬', '用人单位应当按照劳动合同约定和国家规定，向劳动者及时足额支付劳动报酬。', NOW()),
('law_contract_85', '中华人民共和国劳动合同法', '第八十五条', '未按约支付劳动报酬责任', '用人单位未及时足额支付劳动报酬的，由劳动行政部门责令限期支付；逾期不支付的，可责令加付赔偿金。', NOW()),
('law_reg_16', '工资支付暂行规定（劳部发〔1994〕489号）', '第十八条', '劳动行政部门对克扣、无故拖欠工资等的监察处理', '各级劳动行政部门有权监察用人单位工资支付的情况。用人单位有下列侵害劳动者合法权益行为的，由劳动行政部门责令其支付劳动者工资和经济补偿，并可责令其支付赔偿金：（一）克扣或者无故拖欠劳动者工资的；（二）拒不支付劳动者延长工作时间工资报酬的；（三）低于当地最低工资标准支付劳动者工资的。经济补偿和赔偿金的标准，按国家有关规定执行。', NOW()),
('law_contract_10', '中华人民共和国劳动合同法', '第十条', '建立劳动关系应订立书面劳动合同', '建立劳动关系，应当订立书面劳动合同。', NOW()),
('law_contract_82', '中华人民共和国劳动合同法', '第八十二条', '未签书面劳动合同双倍工资', '超过一个月未签书面劳动合同的，应当支付二倍工资。', NOW()),
('law_contract_14', '中华人民共和国劳动合同法', '第十四条', '无固定期限劳动合同情形', '符合连续订立合同等法定条件的，可要求无固定期限劳动合同。', NOW()),
('law_contract_39', '中华人民共和国劳动合同法', '第三十九条', '过失性解除', '劳动者存在严重违纪等法定情形的，用人单位可以解除劳动合同。', NOW()),
('law_contract_40', '中华人民共和国劳动合同法', '第四十条', '无过失性解除', '用人单位依据法定事由解除劳动合同的，应提前三十日书面通知或支付代通知金。', NOW()),
('law_contract_41', '中华人民共和国劳动合同法', '第四十一条', '经济性裁员', '经济性裁员应符合法定人数、程序和报告要求。', NOW()),
('law_contract_48', '中华人民共和国劳动合同法', '第四十八条', '违法解除后果', '违法解除的，劳动者可请求继续履行劳动合同或者请求赔偿金。', NOW()),
('law_contract_87', '中华人民共和国劳动合同法', '第八十七条', '违法解除赔偿金', '违法解除劳动合同的，应按经济补偿标准二倍支付赔偿金。', NOW())
ON DUPLICATE KEY UPDATE
name = VALUES(name),
article = VALUES(article),
summary = VALUES(summary),
text = VALUES(text),
updated_at = VALUES(updated_at);

-- =========================
-- 四、Step2 target 主表
-- =========================
INSERT INTO rule_step2_target (target_id, title, descr, enabled) VALUES
('target_labor_unpaid_wages_full_payment', '争取尽快足额支付欠薪', '重点证成劳动关系、实际劳动及欠薪事实，并补强金额依据。', 1),
('target_labor_unpaid_wages_overtime', '一并主张加班费', '在欠薪之外，主张存在加班且未依法支付加班费。', 1),
('target_labor_unpaid_wages_termination_compensation', '争取解除劳动关系并主张经济补偿', '当单位长期欠薪时，考虑依法解除并主张经济补偿。', 1),
('target_labor_unpaid_wages_additional_compensation', '争取逾期支付加付赔偿金', '针对欠薪且经催告/责令后仍不支付的情形，主张加付赔偿金。', 1),
('target_labor_no_contract_double_wage', '争取未签合同期间双倍工资', '重点证明劳动关系成立、未签合同持续时间及工资支付事实。', 1),
('target_labor_no_contract_sign_contract', '请求补签书面劳动合同', '在劳动关系持续期间，要求单位补签书面劳动合同。', 1),
('target_labor_no_contract_open_term', '请求订立无固定期限劳动合同', '符合条件时请求订立无固定期限劳动合同。', 1),
('target_illegal_termination_compensation', '主张违法解除赔偿金', '重点证明解除缺乏法定事由或程序违法，进而请求二倍赔偿。', 1),
('target_illegal_termination_reinstatement', '请求继续履行劳动合同', '在违法解除情形下，优先请求恢复劳动关系并继续履行合同。', 1),
('target_illegal_termination_wage_gap', '主张停工期间工资损失', '在解除违法且未及时恢复岗位时，主张停工待岗期间工资等损失。', 1),
('target_illegal_termination_revoke_decision', '确认解除决定违法并撤销', '确认解除决定违法，作为赔偿或恢复劳动关系前置支撑。', 1);

-- =========================
-- 五、Step2 legal refs
-- =========================
INSERT INTO rule_step2_target_legal_ref (target_id, law_id, sort_order) VALUES
('target_labor_unpaid_wages_full_payment', 'law_labor_50', 1),
('target_labor_unpaid_wages_full_payment', 'law_contract_30', 2),
('target_labor_unpaid_wages_full_payment', 'law_contract_85', 3),
('target_labor_unpaid_wages_full_payment', 'law_reg_16', 4),
('target_labor_unpaid_wages_overtime', 'law_contract_30', 1),
('target_labor_unpaid_wages_termination_compensation', 'law_contract_85', 1),
('target_labor_unpaid_wages_additional_compensation', 'law_contract_85', 1),
('target_labor_unpaid_wages_additional_compensation', 'law_reg_16', 2),
('target_labor_no_contract_double_wage', 'law_contract_10', 1),
('target_labor_no_contract_double_wage', 'law_contract_82', 2),
('target_labor_no_contract_sign_contract', 'law_contract_10', 1),
('target_labor_no_contract_open_term', 'law_contract_14', 1),
('target_illegal_termination_compensation', 'law_contract_48', 1),
('target_illegal_termination_compensation', 'law_contract_87', 2),
('target_illegal_termination_compensation', 'law_contract_39', 3),
('target_illegal_termination_compensation', 'law_contract_40', 4),
('target_illegal_termination_compensation', 'law_contract_41', 5),
('target_illegal_termination_reinstatement', 'law_contract_48', 1),
('target_illegal_termination_wage_gap', 'law_contract_48', 1),
('target_illegal_termination_wage_gap', 'law_contract_87', 2),
('target_illegal_termination_revoke_decision', 'law_contract_39', 1),
('target_illegal_termination_revoke_decision', 'law_contract_40', 2),
('target_illegal_termination_revoke_decision', 'law_contract_41', 3),
('target_illegal_termination_revoke_decision', 'law_contract_48', 4);

-- =========================
-- 六、Step2 required facts
-- =========================
INSERT INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES
('target_labor_unpaid_wages_full_payment', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_labor_unpaid_wages_full_payment', '已提供劳动', '已经实际提供劳动', 2, 1),
('target_labor_unpaid_wages_full_payment', '存在欠薪', '存在拖欠工资事实', 3, 1),
('target_labor_unpaid_wages_full_payment', '有工资约定依据', '有工资标准/约定依据', 4, 1),
('target_labor_unpaid_wages_full_payment', '有工资支付记录', '有工资发放/欠发记录', 5, 1),
('target_labor_unpaid_wages_full_payment', '有催要工资记录', '有催要工资沟通记录', 6, 1),
('target_labor_unpaid_wages_full_payment', '有明确工资周期约定', '有明确工资发放周期约定', 7, 1),
('target_labor_unpaid_wages_overtime', '主张加班费', '明确提出加班费请求', 1, 1),
('target_labor_unpaid_wages_overtime', '有加班事实证据', '有加班事实证据', 2, 1),
('target_labor_unpaid_wages_overtime', '有加班工资约定依据', '有加班工资计算依据', 3, 1),
('target_labor_unpaid_wages_termination_compensation', '主张解除补偿', '明确提出解除补偿请求', 1, 1),
('target_labor_unpaid_wages_termination_compensation', '存在欠薪', '存在拖欠工资事实', 2, 1),
('target_labor_unpaid_wages_termination_compensation', '解除原因偏向单位责任', '解除原因与单位欠薪行为相关', 3, 1),
('target_labor_unpaid_wages_additional_compensation', '存在欠薪', '存在拖欠工资事实', 1, 1),
('target_labor_unpaid_wages_additional_compensation', '已向劳动监察投诉', '已向劳动监察投诉或正式催告', 2, 1),
('target_labor_unpaid_wages_additional_compensation', '单位逾期仍未支付', '单位逾期仍未支付', 3, 1),
('target_labor_no_contract_double_wage', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_labor_no_contract_double_wage', '未签书面劳动合同', '超过一个月未签书面劳动合同', 2, 1),
('target_labor_no_contract_double_wage', '有工资支付记录', '存在工资发放事实', 3, 1),
('target_labor_no_contract_sign_contract', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_labor_no_contract_sign_contract', '未签书面劳动合同', '尚未签订书面劳动合同', 2, 1),
('target_labor_no_contract_sign_contract', '主张补签书面合同', '已明确请求补签合同', 3, 1),
('target_labor_no_contract_open_term', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_labor_no_contract_open_term', '主张无固定期限合同', '已明确主张无固定期限合同', 2, 1),
('target_labor_no_contract_open_term', '满足无固定期限条件', '已满足法定条件', 3, 1),
('target_illegal_termination_compensation', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_illegal_termination_compensation', '已被解除或辞退', '已发生解除/辞退事实', 2, 1),
('target_illegal_termination_compensation', '解除程序或理由存在瑕疵', '解除理由或程序存在违法情形', 3, 1),
('target_illegal_termination_reinstatement', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_illegal_termination_reinstatement', '已被解除或辞退', '已发生解除/辞退事实', 2, 1),
('target_illegal_termination_reinstatement', '主张继续履行劳动合同', '已明确请求恢复劳动关系', 3, 1),
('target_illegal_termination_wage_gap', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_illegal_termination_wage_gap', '已被解除或辞退', '已发生解除/辞退事实', 2, 1),
('target_illegal_termination_wage_gap', '主张停工期间工资损失', '已明确主张停工期间工资损失', 3, 1),
('target_illegal_termination_revoke_decision', '存在劳动关系', '与单位存在劳动关系', 1, 1),
('target_illegal_termination_revoke_decision', '已被解除或辞退', '已发生解除/辞退事实', 2, 1),
('target_illegal_termination_revoke_decision', '解除理由不明确', '解除理由不明确或与法条不匹配', 3, 1),
('target_illegal_termination_revoke_decision', '解除通知为书面', '解除通知书面瑕疵（反向佐证）', 4, 1);

-- =========================
-- 七、Step2 evidence types
-- =========================
INSERT INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES
('target_labor_unpaid_wages_full_payment', '存在劳动关系', '劳动合同', 1, 0, 1),
('target_labor_unpaid_wages_full_payment', '存在劳动关系', '入职登记信息', 2, 0, 1),
('target_labor_unpaid_wages_full_payment', '存在劳动关系', '社保缴纳记录', 3, 0, 1),
('target_labor_unpaid_wages_full_payment', '已提供劳动', '考勤记录', 1, 0, 1),
('target_labor_unpaid_wages_full_payment', '已提供劳动', '工作群记录', 2, 0, 1),
('target_labor_unpaid_wages_full_payment', '已提供劳动', '工作成果材料', 3, 0, 1),
('target_labor_unpaid_wages_full_payment', '存在欠薪', '工资发放明细', 1, 0, 1),
('target_labor_unpaid_wages_full_payment', '存在欠薪', '银行流水', 2, 0, 1),
('target_labor_unpaid_wages_full_payment', '有工资约定依据', '劳动合同', 1, 0, 1),
('target_labor_unpaid_wages_full_payment', '有工资约定依据', '工资条', 2, 0, 1),
('target_labor_unpaid_wages_full_payment', '有工资约定依据', '薪酬制度文件', 3, 0, 1),
('target_labor_unpaid_wages_full_payment', '有工资支付记录', '银行流水', 1, 0, 1),
('target_labor_unpaid_wages_full_payment', '有工资支付记录', '工资转账记录', 2, 0, 1),
('target_labor_unpaid_wages_full_payment', '有工资支付记录', '工资条', 3, 0, 1),
('target_labor_unpaid_wages_full_payment', '有催要工资记录', '微信聊天记录', 1, 0, 1),
('target_labor_unpaid_wages_full_payment', '有催要工资记录', '短信记录', 2, 0, 1),
('target_labor_unpaid_wages_full_payment', '有催要工资记录', '通话录音', 3, 0, 1),
('target_labor_unpaid_wages_full_payment', '有明确工资周期约定', '劳动合同条款', 1, 0, 1),
('target_labor_unpaid_wages_full_payment', '有明确工资周期约定', '薪资制度文件', 2, 0, 1),
('target_labor_unpaid_wages_overtime', '主张加班费', '仲裁请求清单', 1, 0, 1),
('target_labor_unpaid_wages_overtime', '有加班事实证据', '考勤记录', 1, 0, 1),
('target_labor_unpaid_wages_overtime', '有加班事实证据', '加班审批单', 2, 0, 1),
('target_labor_unpaid_wages_overtime', '有加班事实证据', '门禁记录', 3, 0, 1),
('target_labor_unpaid_wages_overtime', '有加班工资约定依据', '公司规章制度', 1, 0, 1),
('target_labor_unpaid_wages_overtime', '有加班工资约定依据', '劳动合同条款', 2, 0, 1),
('target_labor_unpaid_wages_termination_compensation', '主张解除补偿', '解除通知', 1, 0, 1),
('target_labor_unpaid_wages_termination_compensation', '主张解除补偿', '仲裁请求清单', 2, 0, 1),
('target_labor_unpaid_wages_termination_compensation', '存在欠薪', '银行流水', 1, 0, 1),
('target_labor_unpaid_wages_termination_compensation', '存在欠薪', '工资条', 2, 0, 1),
('target_labor_unpaid_wages_termination_compensation', '解除原因偏向单位责任', '催告记录', 1, 0, 1),
('target_labor_unpaid_wages_termination_compensation', '解除原因偏向单位责任', '解除沟通记录', 2, 0, 1),
('target_labor_unpaid_wages_additional_compensation', '存在欠薪', '工资条', 1, 0, 1),
('target_labor_unpaid_wages_additional_compensation', '存在欠薪', '银行流水', 2, 0, 1),
('target_labor_unpaid_wages_additional_compensation', '已向劳动监察投诉', '投诉回执', 1, 0, 1),
('target_labor_unpaid_wages_additional_compensation', '已向劳动监察投诉', '受理通知', 2, 0, 1),
('target_labor_unpaid_wages_additional_compensation', '单位逾期仍未支付', '限期支付通知', 1, 0, 1),
('target_labor_unpaid_wages_additional_compensation', '单位逾期仍未支付', '逾期未支付证明', 2, 0, 1),
('target_labor_no_contract_double_wage', '存在劳动关系', '考勤记录', 1, 0, 1),
('target_labor_no_contract_double_wage', '存在劳动关系', '工作安排聊天记录', 2, 0, 1),
('target_labor_no_contract_double_wage', '未签书面劳动合同', '合同缺失说明', 1, 0, 1),
('target_labor_no_contract_double_wage', '未签书面劳动合同', '沟通记录', 2, 0, 1),
('target_labor_no_contract_double_wage', '有工资支付记录', '银行流水', 1, 0, 1),
('target_labor_no_contract_double_wage', '有工资支付记录', '工资条', 2, 0, 1),
('target_labor_no_contract_sign_contract', '存在劳动关系', '考勤记录', 1, 0, 1),
('target_labor_no_contract_sign_contract', '存在劳动关系', '工牌', 2, 0, 1),
('target_labor_no_contract_sign_contract', '未签书面劳动合同', '合同缺失说明', 1, 0, 1),
('target_labor_no_contract_sign_contract', '未签书面劳动合同', '入职材料', 2, 0, 1),
('target_labor_no_contract_sign_contract', '主张补签书面合同', '书面申请', 1, 0, 1),
('target_labor_no_contract_sign_contract', '主张补签书面合同', '邮件记录', 2, 0, 1),
('target_labor_no_contract_open_term', '存在劳动关系', '劳动关系证明材料', 1, 0, 1),
('target_labor_no_contract_open_term', '主张无固定期限合同', '请求书', 1, 0, 1),
('target_labor_no_contract_open_term', '满足无固定期限条件', '工龄证明', 1, 0, 1),
('target_labor_no_contract_open_term', '满足无固定期限条件', '续签记录', 2, 0, 1),
('target_illegal_termination_compensation', '存在劳动关系', '劳动合同', 1, 0, 1),
('target_illegal_termination_compensation', '存在劳动关系', '社保记录', 2, 0, 1),
('target_illegal_termination_compensation', '存在劳动关系', '工资记录', 3, 0, 1),
('target_illegal_termination_compensation', '已被解除或辞退', '解除通知书', 1, 0, 1),
('target_illegal_termination_compensation', '已被解除或辞退', '辞退聊天记录', 2, 0, 1),
('target_illegal_termination_compensation', '解除程序或理由存在瑕疵', '解除通知内容', 1, 0, 1),
('target_illegal_termination_compensation', '解除程序或理由存在瑕疵', '规章制度', 2, 0, 1),
('target_illegal_termination_compensation', '解除程序或理由存在瑕疵', '工会材料', 3, 0, 1),
('target_illegal_termination_reinstatement', '存在劳动关系', '劳动合同', 1, 0, 1),
('target_illegal_termination_reinstatement', '存在劳动关系', '工资流水', 2, 0, 1),
('target_illegal_termination_reinstatement', '已被解除或辞退', '解除通知书', 1, 0, 1),
('target_illegal_termination_reinstatement', '主张继续履行劳动合同', '仲裁请求书', 1, 0, 1),
('target_illegal_termination_reinstatement', '主张继续履行劳动合同', '复工申请', 2, 0, 1),
('target_illegal_termination_wage_gap', '存在劳动关系', '劳动合同', 1, 0, 1),
('target_illegal_termination_wage_gap', '存在劳动关系', '工资记录', 2, 0, 1),
('target_illegal_termination_wage_gap', '已被解除或辞退', '解除通知', 1, 0, 1),
('target_illegal_termination_wage_gap', '已被解除或辞退', '系统停权记录', 2, 0, 1),
('target_illegal_termination_wage_gap', '主张停工期间工资损失', '工资标准依据', 1, 0, 1),
('target_illegal_termination_wage_gap', '主张停工期间工资损失', '历史工资流水', 2, 0, 1),
('target_illegal_termination_revoke_decision', '存在劳动关系', '劳动合同', 1, 0, 1),
('target_illegal_termination_revoke_decision', '存在劳动关系', '工资流水', 2, 0, 1),
('target_illegal_termination_revoke_decision', '已被解除或辞退', '解除通知', 1, 0, 1),
('target_illegal_termination_revoke_decision', '解除理由不明确', '解除通知内容', 1, 0, 1),
('target_illegal_termination_revoke_decision', '解除理由不明确', '单位说明材料', 2, 0, 1),
('target_illegal_termination_revoke_decision', '解除通知为书面', '书面通知原件', 1, 0, 1),
('target_illegal_termination_revoke_decision', '解除通知为书面', '送达记录', 2, 0, 1);

-- =========================
-- 八、问卷分组
-- =========================
INSERT INTO rule_question_group (questionnaire_id, group_key, group_name, group_desc, icon, group_order, enabled) VALUES
('questionnaire_labor_unpaid_wages', 'LW0', '前置事实确认', '先确认是否属于拖欠工资纠纷的基本前提', 'check', 1, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '劳动关系与工资约定', '先把劳动关系和工资标准证据补齐', 'folder', 2, 1),
('questionnaire_labor_unpaid_wages', 'LW2', '延伸请求（可选）', '如需主张加班费或解除补偿，补充对应事实', 'plus', 3, 1),
('questionnaire_labor_no_contract', 'LN0', '前置事实确认', '确认是否属于未签劳动合同争议', 'check', 1, 1),
('questionnaire_labor_no_contract', 'LN1', '关键要件补全', '确认用工时长、补签情况及基础证据', 'folder', 2, 1),
('questionnaire_labor_no_contract', 'LN2', '延伸请求（可选）', '补充无固定期限合同等进阶诉请', 'plus', 3, 1),
('questionnaire_labor_illegal_termination', 'LT0', '前置事实确认', '先确认是否属于违法解除劳动争议', 'check', 1, 1),
('questionnaire_labor_illegal_termination', 'LT1', '解除事实', '补充解除通知、解除理由及程序事实', 'folder', 2, 1),
('questionnaire_labor_illegal_termination', 'LT2', '延伸事实', '核对特殊保护期及单位证据情况', 'plus', 3, 1);

-- =========================
-- 九、问卷题目
-- =========================
INSERT INTO rule_question
  (questionnaire_id, group_key, question_key, answer_key, label, hint, unit, input_type, required, question_order, enabled)
VALUES
-- LW0
('questionnaire_labor_unpaid_wages', 'LW0', '存在劳动关系', '存在劳动关系', '你与单位之间是否存在劳动关系？', NULL, NULL, 'boolean', 1, 1, 1),
('questionnaire_labor_unpaid_wages', 'LW0', '已提供劳动', '已提供劳动', '你是否已经实际提供劳动？', NULL, NULL, 'boolean', 1, 2, 1),
('questionnaire_labor_unpaid_wages', 'LW0', '存在欠薪', '存在欠薪', '单位是否存在拖欠工资的情形？', NULL, NULL, 'boolean', 1, 3, 1),
-- LW1
('questionnaire_labor_unpaid_wages', 'LW1', '入职时间已明确', '入职时间已明确', '你的入职时间是否可以明确到年月？', NULL, NULL, 'boolean', 0, 1, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '离职时间已明确', '离职时间已明确', '如已离职，离职时间是否可以明确到年月？', NULL, NULL, 'boolean', 0, 2, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '欠薪金额', '欠薪金额', '拖欠工资金额大约是多少？', NULL, '元', 'number', 0, 3, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '欠薪时长', '欠薪时长', '拖欠工资已持续多久？', NULL, '个月', 'number', 0, 4, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '有工资约定依据', '有工资约定依据', '是否有劳动合同/工资条等工资约定依据？', NULL, NULL, 'boolean', 0, 5, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '有考勤或工作记录', '有考勤或工作记录', '是否有考勤记录、工作群记录、工作成果等劳动证据？', NULL, NULL, 'boolean', 0, 6, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '有工资支付记录', '有工资支付记录', '是否有银行流水/工资发放记录？', NULL, NULL, 'boolean', 0, 7, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '有催要工资记录', '有催要工资记录', '是否有催要工资的聊天记录/短信/录音？', NULL, NULL, 'boolean', 0, 8, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '单位书面承认欠薪', '单位书面承认欠薪', '单位是否有书面承认欠薪的材料？', NULL, NULL, 'boolean', 0, 9, 1),
('questionnaire_labor_unpaid_wages', 'LW1', '有明确工资周期约定', '有明确工资周期约定', '是否有明确工资发放周期约定（按月/按周）？', NULL, NULL, 'boolean', 0, 10, 1),
-- LW2
('questionnaire_labor_unpaid_wages', 'LW2', '主张加班费', '主张加班费', '你是否希望一并主张加班费？', NULL, NULL, 'boolean', 0, 1, 1),
('questionnaire_labor_unpaid_wages', 'LW2', '有加班事实证据', '有加班事实证据', '是否有加班记录（考勤、审批、聊天等）？', NULL, NULL, 'boolean', 0, 2, 1),
('questionnaire_labor_unpaid_wages', 'LW2', '有加班工资约定依据', '有加班工资约定依据', '是否有加班工资计算依据（制度/约定）？', NULL, NULL, 'boolean', 0, 3, 1),
('questionnaire_labor_unpaid_wages', 'LW2', '主张解除补偿', '主张解除补偿', '你是否希望主张解除劳动关系经济补偿？', NULL, NULL, 'boolean', 0, 4, 1),
('questionnaire_labor_unpaid_wages', 'LW2', '解除原因偏向单位责任', '解除原因偏向单位责任', '解除劳动关系是否主要因单位未及时足额支付劳动报酬？', NULL, NULL, 'boolean', 0, 5, 1),
('questionnaire_labor_unpaid_wages', 'LW2', '已向劳动监察投诉', '已向劳动监察投诉', '是否已向劳动监察部门投诉欠薪？', NULL, NULL, 'boolean', 0, 6, 1),
('questionnaire_labor_unpaid_wages', 'LW2', '单位逾期仍未支付', '单位逾期仍未支付', '在催告或责令后单位是否逾期仍未支付？', NULL, NULL, 'boolean', 0, 7, 1),

-- LN0
('questionnaire_labor_no_contract', 'LN0', '存在劳动关系', '存在劳动关系', '你与单位之间是否存在劳动关系？', NULL, NULL, 'boolean', 1, 1, 1),
('questionnaire_labor_no_contract', 'LN0', '未签书面劳动合同', '未签书面劳动合同', '你是否未与单位签订书面劳动合同？', NULL, NULL, 'boolean', 1, 2, 1),
-- LN1
('questionnaire_labor_no_contract', 'LN1', '入职月数', '入职月数', '从入职至今共工作了几个月？', NULL, '个月', 'number', 0, 1, 1),
('questionnaire_labor_no_contract', 'LN1', '已补签劳动合同', '已补签劳动合同', '后续是否已经补签过劳动合同？', NULL, NULL, 'boolean', 0, 2, 1),
('questionnaire_labor_no_contract', 'LN1', '有工资支付记录', '有工资支付记录', '是否有工资发放记录（转账、工资条等）？', NULL, NULL, 'boolean', 0, 3, 1),
('questionnaire_labor_no_contract', 'LN1', '有工作管理证据', '有工作管理证据', '是否有考勤、工作安排、工牌等管理从属性证据？', NULL, NULL, 'boolean', 0, 4, 1),
('questionnaire_labor_no_contract', 'LN1', '单位拒绝签合同', '单位拒绝签合同', '是否有单位拒绝签订书面合同的沟通记录？', NULL, NULL, 'boolean', 0, 5, 1),
-- LN2
('questionnaire_labor_no_contract', 'LN2', '主张补签书面合同', '主张补签书面合同', '你是否主张补签书面劳动合同？', NULL, NULL, 'boolean', 0, 1, 1),
('questionnaire_labor_no_contract', 'LN2', '主张无固定期限合同', '主张无固定期限合同', '你是否主张签订无固定期限劳动合同？', NULL, NULL, 'boolean', 0, 2, 1),
('questionnaire_labor_no_contract', 'LN2', '满足无固定期限条件', '满足无固定期限条件', '你是否已满足无固定期限劳动合同法定条件？', NULL, NULL, 'boolean', 0, 3, 1),

-- LT0
('questionnaire_labor_illegal_termination', 'LT0', '存在劳动关系', '存在劳动关系', '你与单位之间是否存在劳动关系？', NULL, NULL, 'boolean', 1, 1, 1),
('questionnaire_labor_illegal_termination', 'LT0', '已被解除或辞退', '已被解除或辞退', '你是否已被解除劳动合同或辞退？', NULL, NULL, 'boolean', 1, 2, 1),
-- LT1
('questionnaire_labor_illegal_termination', 'LT1', '有解除通知', '有解除通知', '单位是否向你发出过解除/辞退通知？', NULL, NULL, 'boolean', 0, 1, 1),
('questionnaire_labor_illegal_termination', 'LT1', '解除通知为书面', '解除通知为书面', '该解除通知是否为书面形式？', NULL, NULL, 'boolean', 0, 2, 1),
('questionnaire_labor_illegal_termination', 'LT1', '解除理由类型', '解除理由类型', '单位主张的解除理由属于哪一类？', NULL, NULL, 'select', 0, 3, 1),
('questionnaire_labor_illegal_termination', 'LT1', '提前30日通知或支付代通知金', '提前30日通知或支付代通知金', '如属第40条情形，单位是否提前30日书面通知或支付代通知金？', NULL, NULL, 'boolean', 0, 4, 1),
('questionnaire_labor_illegal_termination', 'LT1', '单位是否履行工会程序', '单位是否履行工会程序', '单位解除前是否履行通知工会等程序？', NULL, NULL, 'boolean', 0, 5, 1),
('questionnaire_labor_illegal_termination', 'LT1', '规章制度已公示且合法', '规章制度已公示且合法', '单位依据的规章制度是否经过民主程序并已公示？', NULL, NULL, 'boolean', 0, 6, 1),
-- LT2
('questionnaire_labor_illegal_termination', 'LT2', '处于特殊保护期', '处于特殊保护期', '解除时你是否处于医疗期/孕期/工伤停工留薪期等特殊保护期？', NULL, NULL, 'boolean', 0, 1, 1),
('questionnaire_labor_illegal_termination', 'LT2', '单位有严重违纪证据', '单位有严重违纪证据', '单位是否能提供你严重违纪的明确证据？', NULL, NULL, 'boolean', 0, 2, 1),
('questionnaire_labor_illegal_termination', 'LT2', '经济性裁员符合法定人数与报告程序', '经济性裁员符合法定人数与报告程序', '如属经济性裁员，单位是否满足法定人数与报告程序？', NULL, NULL, 'boolean', 0, 3, 1),
('questionnaire_labor_illegal_termination', 'LT2', '主张继续履行劳动合同', '主张继续履行劳动合同', '你是否希望优先主张恢复劳动关系（继续履行劳动合同）？', NULL, NULL, 'boolean', 0, 4, 1),
('questionnaire_labor_illegal_termination', 'LT2', '主张停工期间工资损失', '主张停工期间工资损失', '你是否主张停工期间工资损失（或等待恢复期间损失）？', NULL, NULL, 'boolean', 0, 5, 1);

-- =========================
-- 十、问卷选项（select题）
-- =========================
INSERT INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, 'article_39', '过失性解除（第39条）', 1, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_illegal_termination' AND q.group_key='LT1' AND q.question_key='解除理由类型';

INSERT INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, 'article_40', '无过失性解除（第40条）', 2, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_illegal_termination' AND q.group_key='LT1' AND q.question_key='解除理由类型';

INSERT INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, 'article_41', '经济性裁员（第41条）', 3, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_illegal_termination' AND q.group_key='LT1' AND q.question_key='解除理由类型';

INSERT INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, 'unknown', '无法说明或其他', 4, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_illegal_termination' AND q.group_key='LT1' AND q.question_key='解除理由类型';

-- =========================
-- 十一、题目显示条件（condition_json）
-- =========================
INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT q.id, 1, '{"op":"eq","answerKey":"主张加班费","value":true}', 1, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_unpaid_wages' AND q.question_key='有加班事实证据';

INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT q.id, 1, '{"op":"eq","answerKey":"主张加班费","value":true}', 1, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_unpaid_wages' AND q.question_key='有加班工资约定依据';

INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT q.id, 1, '{"op":"eq","answerKey":"主张解除补偿","value":true}', 1, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_unpaid_wages' AND q.question_key='解除原因偏向单位责任';

INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT q.id, 1, '{"op":"eq","answerKey":"主张无固定期限合同","value":true}', 1, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_no_contract' AND q.question_key='满足无固定期限条件';

INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT q.id, 1, '{"op":"eq","answerKey":"有解除通知","value":true}', 1, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_illegal_termination' AND q.question_key='解除通知为书面';

INSERT INTO rule_question_visibility_rule (question_id, show_if, condition_json, rule_order, enabled)
SELECT q.id, 1, '{"op":"eq","answerKey":"解除理由类型","value":"article_40"}', 1, 1
FROM rule_question q
WHERE q.questionnaire_id='questionnaire_labor_illegal_termination' AND q.question_key='提前30日通知或支付代通知金';

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;

-- 执行后建议：
-- 1) 调用 /api/rule/questionnaire?causeCode=labor_unpaid_wages 验证问卷
-- 2) 若后续要让劳动案由从 DB 读取 Step2/law，可继续在 Java 侧按 causeCode 过滤接入 rule_* 表
