USE rule_engine_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================================
-- A) 案由基础映射（按前端展示补齐，完善版）
-- ==========================================================
INSERT INTO rule_cause (cause_code, cause_name, questionnaire_id, enabled) VALUES
('betrothal_property', '婚约财产纠纷', 'questionnaire_betrothal_property', 1),
('divorce_dispute', '离婚纠纷', 'questionnaire_divorce_dispute', 1),
('post_divorce_property', '离婚后财产纠纷', 'questionnaire_post_divorce_property', 1),
('labor_injury_compensation', '工伤赔偿纠纷', 'questionnaire_labor_injury_compensation', 1),
('labor_overtime_pay', '加班费争议', 'questionnaire_labor_overtime_pay', 1)
ON DUPLICATE KEY UPDATE
cause_name=VALUES(cause_name), questionnaire_id=VALUES(questionnaire_id), enabled=VALUES(enabled);

-- ==========================================================
-- B) 法条资产（补齐新增案由）
-- ==========================================================
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
('law_1042', '中华人民共和国民法典', '第一千零四十二条', '禁止借婚姻索取财物', '禁止借婚姻索取财物。', NOW()),
('law_jshj_5', '最高人民法院关于适用《中华人民共和国民法典》婚姻家庭编的解释（一）（法释〔2020〕22号）', '第五条', '彩礼返还的法定情形', '当事人请求返还按照习俗给付的彩礼的，如果查明属于以下情形，人民法院应当予以支持：（一）双方未办理结婚登记手续；（二）双方办理结婚登记手续但确未共同生活；（三）婚前给付并导致给付人生活困难。适用前款第二项、第三项的规定，应当以双方离婚为条件。', NOW()),
('law_1079', '中华人民共和国民法典', '第一千零七十九条', '诉讼离婚条件', '夫妻感情确已破裂，调解无效的，应准予离婚。', NOW()),
('law_1084', '中华人民共和国民法典', '第一千零八十四条', '子女抚养', '离婚后，子女由一方直接抚养，另一方负担抚养费。', NOW()),
('law_1087', '中华人民共和国民法典', '第一千零八十七条', '共同财产分割', '离婚时，共同财产由双方协议处理；协议不成由法院判决。', NOW()),
('law_1092', '中华人民共和国民法典', '第一千零九十二条', '隐藏转移共同财产责任', '一方隐藏、转移共同财产的，离婚分割时可少分或不分。', NOW()),
('law_injury_14', '工伤保险条例', '第十四条', '应当认定工伤情形', '工作时间、工作场所、因工作原因受伤，应认定工伤。', NOW()),
('law_injury_30', '工伤保险条例', '第三十条', '工伤医疗待遇', '治疗工伤应享受工伤医疗待遇。', NOW()),
('law_injury_33', '工伤保险条例', '第三十三条', '停工留薪期待遇', '停工留薪期内原工资福利待遇不变。', NOW()),
('law_injury_37', '工伤保险条例', '第三十七条', '伤残待遇', '因工伤残可享受一次性伤残补助金等待遇。', NOW()),
('law_labor_44', '中华人民共和国劳动法', '第四十四条', '加班工资标准', '延长工时、休息日加班、法定节假日加班应支付加班工资。', NOW()),
('law_contract_31', '中华人民共和国劳动合同法', '第三十一条', '加班安排限制', '用人单位应严格执行劳动定额标准，不得强迫或者变相强迫劳动者加班。', NOW())
ON DUPLICATE KEY UPDATE
name=VALUES(name), article=VALUES(article), summary=VALUES(summary), text=VALUES(text), updated_at=VALUES(updated_at);

-- ==========================================================
-- C) Step2 目标（每案由 2-4 个）
-- ==========================================================
DELETE FROM rule_step2_evidence_type WHERE target_id LIKE 'target_add_%';
DELETE FROM rule_step2_required_fact WHERE target_id LIKE 'target_add_%';
DELETE FROM rule_step2_target_legal_ref WHERE target_id LIKE 'target_add_%';
DELETE FROM rule_step2_target WHERE target_id LIKE 'target_add_%';

INSERT INTO rule_step2_target (target_id, title, descr, enabled) VALUES
('target_add_betrothal_refund_full', '主张全额返还彩礼', '围绕法定返还要件及金额证据主张全额返还。', 1),
('target_add_betrothal_refund_partial', '主张部分返还彩礼', '在已共同生活或已登记情形下主张部分返还。', 1),
('target_add_betrothal_no_refund', '抗辩不予返还彩礼', '通过共同生活、登记等事实抗辩不返还或少返还。', 1),

('target_add_divorce_general_judgment', '请求判决离婚', '围绕感情破裂事实请求判决离婚。', 1),
('target_add_divorce_general_custody', '子女抚养方案请求', '围绕子女利益与抚养条件提出抚养方案。', 1),
('target_add_divorce_general_property', '财产与债务处理方案', '围绕共同财产、共同债务提出分割方案。', 1),

('target_add_post_divorce_redistribute', '离婚后再次分割财产', '针对未分割财产请求再次分割。', 1),
('target_add_post_divorce_conceal_penalty', '追究隐藏转移财产责任', '针对隐藏转移财产请求少分或不分。', 1),
('target_add_post_divorce_agreement_enforce', '请求履行离婚协议财产条款', '针对协议未履行请求确认并履行。', 1),

('target_add_labor_injury_recognition', '确认工伤并主张工伤待遇', '围绕工伤认定与待遇项目组织请求。', 1),
('target_add_labor_injury_medical', '主张工伤医疗费用待遇', '围绕医疗费用及票据主张支付。', 1),
('target_add_labor_injury_disability', '主张伤残待遇', '针对伤残等级主张补助金等待遇。', 1),

('target_add_labor_overtime_workday', '主张工作日延时加班费', '围绕工作日延时加班事实与时长主张差额。', 1),
('target_add_labor_overtime_restday', '主张休息日加班费', '围绕休息日加班且未补休主张加班费。', 1),
('target_add_labor_overtime_holiday', '主张法定节假日加班费', '围绕法定节假日加班主张法定标准加班费。', 1);

INSERT INTO rule_step2_target_legal_ref (target_id, law_id, sort_order) VALUES
('target_add_betrothal_refund_full','law_1042',1),('target_add_betrothal_refund_full','law_jshj_5',2),
('target_add_betrothal_refund_partial','law_jshj_5',1),
('target_add_betrothal_no_refund','law_jshj_5',1),

('target_add_divorce_general_judgment','law_1079',1),
('target_add_divorce_general_custody','law_1084',1),
('target_add_divorce_general_property','law_1087',1),

('target_add_post_divorce_redistribute','law_1087',1),('target_add_post_divorce_redistribute','law_1092',2),
('target_add_post_divorce_conceal_penalty','law_1092',1),
('target_add_post_divorce_agreement_enforce','law_1087',1),

('target_add_labor_injury_recognition','law_injury_14',1),
('target_add_labor_injury_medical','law_injury_30',1),
('target_add_labor_injury_disability','law_injury_37',1),

('target_add_labor_overtime_workday','law_labor_44',1),('target_add_labor_overtime_workday','law_contract_31',2),
('target_add_labor_overtime_restday','law_labor_44',1),
('target_add_labor_overtime_holiday','law_labor_44',1);

INSERT INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES
('target_add_betrothal_refund_full','存在彩礼给付','存在彩礼给付事实',1,1),
('target_add_betrothal_refund_full','存在法定返还情形','存在彩礼返还法定情形',2,1),
('target_add_betrothal_refund_full','彩礼金额','彩礼金额明确',3,1),
('target_add_betrothal_refund_partial','存在彩礼给付','存在彩礼给付事实',1,1),
('target_add_betrothal_refund_partial','已办理结婚登记','已办理结婚登记',2,1),
('target_add_betrothal_refund_partial','共同生活时间较短','共同生活时间较短',3,1),
('target_add_betrothal_no_refund','已办理结婚登记','已办理结婚登记',1,1),
('target_add_betrothal_no_refund','已登记后共同生活','已登记并长期共同生活',2,1),

('target_add_divorce_general_judgment','存在合法婚姻关系','存在合法婚姻关系',1,1),
('target_add_divorce_general_judgment','感情确已破裂','感情确已破裂',2,1),
('target_add_divorce_general_custody','涉及子女抚养','涉及子女抚养',1,1),
('target_add_divorce_general_custody','子女长期随一方生活','子女长期随一方生活',2,1),
('target_add_divorce_general_property','涉及夫妻共同财产','涉及夫妻共同财产',1,1),
('target_add_divorce_general_property','共同财产范围清晰','共同财产范围清晰',2,1),

('target_add_post_divorce_redistribute','离婚事实已生效','离婚事实已生效',1,1),
('target_add_post_divorce_redistribute','存在未分割共同财产','存在未分割共同财产',2,1),
('target_add_post_divorce_redistribute','请求再次分割','请求再次分割',3,1),
('target_add_post_divorce_conceal_penalty','存在隐藏转移财产线索','存在隐藏转移财产线索',1,1),
('target_add_post_divorce_conceal_penalty','有证据证明隐藏转移','有证据证明隐藏转移',2,1),
('target_add_post_divorce_agreement_enforce','存在离婚协议','存在离婚协议',1,1),
('target_add_post_divorce_agreement_enforce','离婚协议财产条款未履行','离婚协议财产条款未履行',2,1),

('target_add_labor_injury_recognition','存在劳动关系','存在劳动关系',1,1),
('target_add_labor_injury_recognition','发生工作时间工作场所事故','工作时间工作场所事故',2,1),
('target_add_labor_injury_recognition','已申请或拟申请工伤认定','已申请或拟申请工伤认定',3,1),
('target_add_labor_injury_medical','存在医疗费用支出','存在医疗费用支出',1,1),
('target_add_labor_injury_medical','已申请或拟申请工伤认定','已申请或拟申请工伤认定',2,1),
('target_add_labor_injury_disability','已认定伤残等级','已认定伤残等级',1,1),
('target_add_labor_injury_disability','单位拒绝支付工伤待遇','单位拒绝支付工伤待遇',2,1),

('target_add_labor_overtime_workday','存在工作日延时加班','存在工作日延时加班',1,1),
('target_add_labor_overtime_workday','单位未足额支付加班费','单位未足额支付加班费',2,1),
('target_add_labor_overtime_restday','存在休息日加班','存在休息日加班',1,1),
('target_add_labor_overtime_restday','休息日未安排补休','休息日未安排补休',2,1),
('target_add_labor_overtime_holiday','存在法定节假日加班','存在法定节假日加班',1,1),
('target_add_labor_overtime_holiday','单位未足额支付加班费','单位未足额支付加班费',2,1);

INSERT INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES
('target_add_betrothal_refund_full','存在彩礼给付','转账记录/收条',1,0,1),
('target_add_betrothal_refund_full','存在法定返还情形','未登记或共同生活证据',1,0,1),
('target_add_betrothal_refund_full','彩礼金额','支付明细/聊天记录',1,0,1),
('target_add_betrothal_refund_partial','共同生活时间较短','共同生活期间证据',1,0,1),
('target_add_betrothal_no_refund','已登记后共同生活','登记与共同生活证据',1,0,1),

('target_add_divorce_general_judgment','感情确已破裂','分居/报警/矛盾证据',1,0,1),
('target_add_divorce_general_custody','子女长期随一方生活','就学与日常照顾证据',1,0,1),
('target_add_divorce_general_property','共同财产范围清晰','不动产/存款/负债清单',1,0,1),

('target_add_post_divorce_redistribute','存在未分割共同财产','财产线索清单',1,0,1),
('target_add_post_divorce_conceal_penalty','有证据证明隐藏转移','流水/交易记录',1,0,1),
('target_add_post_divorce_agreement_enforce','离婚协议财产条款未履行','协议与催告记录',1,0,1),

('target_add_labor_injury_recognition','发生工作时间工作场所事故','事故记录/证人证言',1,0,1),
('target_add_labor_injury_medical','存在医疗费用支出','医疗票据/病历',1,0,1),
('target_add_labor_injury_disability','已认定伤残等级','伤残鉴定结论',1,0,1),

('target_add_labor_overtime_workday','存在工作日延时加班','考勤/审批/聊天记录',1,0,1),
('target_add_labor_overtime_restday','休息日未安排补休','排班/补休记录',1,0,1),
('target_add_labor_overtime_holiday','存在法定节假日加班','节假日值班记录',1,0,1);

-- ==========================================================
-- D) 案由与法条/目标映射
-- ==========================================================
DELETE FROM rule_cause_law WHERE cause_code IN (
  'betrothal_property','divorce_dispute','post_divorce_property','labor_injury_compensation','labor_overtime_pay'
);
INSERT INTO rule_cause_law (cause_code, law_id, sort_order) VALUES
('betrothal_property','law_1042',1),('betrothal_property','law_jshj_5',2),
('divorce_dispute','law_1079',1),('divorce_dispute','law_1084',2),('divorce_dispute','law_1087',3),
('post_divorce_property','law_1087',1),('post_divorce_property','law_1092',2),
('labor_injury_compensation','law_injury_14',1),('labor_injury_compensation','law_injury_30',2),('labor_injury_compensation','law_injury_33',3),('labor_injury_compensation','law_injury_37',4),
('labor_overtime_pay','law_labor_44',1),('labor_overtime_pay','law_contract_31',2),('labor_overtime_pay','law_contract_30',3);

DELETE FROM rule_cause_target WHERE cause_code IN (
  'betrothal_property','divorce_dispute','post_divorce_property','labor_injury_compensation','labor_overtime_pay'
);
INSERT INTO rule_cause_target (cause_code, target_id, sort_order) VALUES
('betrothal_property','target_add_betrothal_refund_full',1),
('betrothal_property','target_add_betrothal_refund_partial',2),
('betrothal_property','target_add_betrothal_no_refund',3),

('divorce_dispute','target_add_divorce_general_judgment',1),
('divorce_dispute','target_add_divorce_general_custody',2),
('divorce_dispute','target_add_divorce_general_property',3),

('post_divorce_property','target_add_post_divorce_redistribute',1),
('post_divorce_property','target_add_post_divorce_conceal_penalty',2),
('post_divorce_property','target_add_post_divorce_agreement_enforce',3),

('labor_injury_compensation','target_add_labor_injury_recognition',1),
('labor_injury_compensation','target_add_labor_injury_medical',2),
('labor_injury_compensation','target_add_labor_injury_disability',3),

('labor_overtime_pay','target_add_labor_overtime_workday',1),
('labor_overtime_pay','target_add_labor_overtime_restday',2),
('labor_overtime_pay','target_add_labor_overtime_holiday',3);

-- ==========================================================
-- E) 问卷（每案由 2 组以上）
-- ==========================================================
DELETE FROM rule_question_visibility_rule WHERE question_id IN (
  SELECT id FROM rule_question WHERE questionnaire_id IN (
    'questionnaire_betrothal_property','questionnaire_divorce_dispute','questionnaire_post_divorce_property',
    'questionnaire_labor_injury_compensation','questionnaire_labor_overtime_pay'
  )
);
DELETE FROM rule_question_option WHERE question_id IN (
  SELECT id FROM rule_question WHERE questionnaire_id IN (
    'questionnaire_betrothal_property','questionnaire_divorce_dispute','questionnaire_post_divorce_property',
    'questionnaire_labor_injury_compensation','questionnaire_labor_overtime_pay'
  )
);
DELETE FROM rule_question WHERE questionnaire_id IN (
  'questionnaire_betrothal_property','questionnaire_divorce_dispute','questionnaire_post_divorce_property',
  'questionnaire_labor_injury_compensation','questionnaire_labor_overtime_pay'
);
DELETE FROM rule_question_group WHERE questionnaire_id IN (
  'questionnaire_betrothal_property','questionnaire_divorce_dispute','questionnaire_post_divorce_property',
  'questionnaire_labor_injury_compensation','questionnaire_labor_overtime_pay'
);

INSERT INTO rule_question_group (questionnaire_id, group_key, group_name, group_desc, icon, group_order, enabled) VALUES
('questionnaire_betrothal_property','BP1','基础事实','确认彩礼给付与登记情况','check',1,1),
('questionnaire_betrothal_property','BP2','返还要件','确认法定返还与补强事实','folder',2,1),
('questionnaire_betrothal_property','BP3','证据补强','补充支付凭证与共同生活证据','plus',3,1),

('questionnaire_divorce_dispute','DG1','离婚前提','确认婚姻关系与感情破裂','check',1,1),
('questionnaire_divorce_dispute','DG2','争议范围','确认子女、财产、债务争议','folder',2,1),
('questionnaire_divorce_dispute','DG3','证据补强','补充感情破裂与抚养能力证据','plus',3,1),

('questionnaire_post_divorce_property','PD1','离婚后前提','确认离婚已生效及请求方向','check',1,1),
('questionnaire_post_divorce_property','PD2','财产线索','确认未分割或隐藏转移线索','folder',2,1),
('questionnaire_post_divorce_property','PD3','证据补强','补充协议、线索与交易证据','plus',3,1),

('questionnaire_labor_injury_compensation','LI1','工伤前提','确认劳动关系与事故事实','check',1,1),
('questionnaire_labor_injury_compensation','LI2','待遇项目','确认医疗费/停工留薪/伤残事实','folder',2,1),
('questionnaire_labor_injury_compensation','LI3','证据补强','补充事故、病历和鉴定材料','plus',3,1),

('questionnaire_labor_overtime_pay','LO1','加班前提','确认劳动关系和主张方向','check',1,1),
('questionnaire_labor_overtime_pay','LO2','加班细项','确认工作日/休息日/节假日加班事实','folder',2,1),
('questionnaire_labor_overtime_pay','LO3','证据补强','补充考勤、审批和工资对照材料','plus',3,1);

INSERT INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, unit, input_type, required, question_order, enabled) VALUES
-- BP1/BP2
('questionnaire_betrothal_property','BP1','存在彩礼给付','存在彩礼给付','是否存在彩礼给付？',NULL,NULL,'boolean',1,1,1),
('questionnaire_betrothal_property','BP1','未办理结婚登记','未办理结婚登记','双方是否未办理结婚登记？',NULL,NULL,'boolean',0,2,1),
('questionnaire_betrothal_property','BP1','已办理结婚登记','已办理结婚登记','双方是否已办理结婚登记？',NULL,NULL,'boolean',0,3,1),
('questionnaire_betrothal_property','BP2','已登记后共同生活','已登记后共同生活','登记后是否共同生活较长时间？',NULL,NULL,'boolean',0,1,1),
('questionnaire_betrothal_property','BP2','共同生活时间较短','共同生活时间较短','共同生活时间是否较短？',NULL,NULL,'boolean',0,2,1),
('questionnaire_betrothal_property','BP2','给付导致生活困难','给付导致生活困难','彩礼给付是否导致给付方生活困难？',NULL,NULL,'boolean',0,3,1),
('questionnaire_betrothal_property','BP2','对方存在重大过错','对方存在重大过错','对方是否存在重大过错？',NULL,NULL,'boolean',0,4,1),
('questionnaire_betrothal_property','BP2','存在法定返还情形','存在法定返还情形','是否存在彩礼返还法定情形？',NULL,NULL,'boolean',1,5,1),
('questionnaire_betrothal_property','BP2','彩礼金额','彩礼金额','彩礼金额约多少？',NULL,'元','number',0,6,1),
('questionnaire_betrothal_property','BP2','共同生活月数','共同生活月数','共同生活约几个月？',NULL,'月','number',0,7,1),
('questionnaire_betrothal_property','BP3','有彩礼转账凭证','有彩礼转账凭证','是否有彩礼转账凭证或收条？',NULL,NULL,'boolean',0,1,1),
('questionnaire_betrothal_property','BP3','有共同生活证据','有共同生活证据','是否有共同生活证据（租房、消费、同住）？',NULL,NULL,'boolean',0,2,1),
('questionnaire_betrothal_property','BP3','有困难证明材料','有困难证明材料','是否有生活困难证明材料？',NULL,NULL,'boolean',0,3,1),

-- DG1/DG2
('questionnaire_divorce_dispute','DG1','存在合法婚姻关系','存在合法婚姻关系','是否存在合法婚姻关系？',NULL,NULL,'boolean',1,1,1),
('questionnaire_divorce_dispute','DG1','感情确已破裂','感情确已破裂','是否存在感情确已破裂事实？',NULL,NULL,'boolean',1,2,1),
('questionnaire_divorce_dispute','DG1','分居满一年','分居满一年','是否存在分居满一年情形？',NULL,NULL,'boolean',0,3,1),
('questionnaire_divorce_dispute','DG1','存在调解意愿','存在调解意愿','是否仍存在调解意愿？',NULL,NULL,'boolean',0,4,1),
('questionnaire_divorce_dispute','DG2','涉及子女抚养','涉及子女抚养','是否涉及子女抚养问题？',NULL,NULL,'boolean',0,1,1),
('questionnaire_divorce_dispute','DG2','子女长期随一方生活','子女长期随一方生活','子女是否长期随一方生活？',NULL,NULL,'boolean',0,2,1),
('questionnaire_divorce_dispute','DG2','另一方存在不利抚养因素','另一方存在不利抚养因素','另一方是否存在不利抚养因素？',NULL,NULL,'boolean',0,3,1),
('questionnaire_divorce_dispute','DG2','涉及夫妻共同财产','涉及夫妻共同财产','是否涉及共同财产分割？',NULL,NULL,'boolean',0,4,1),
('questionnaire_divorce_dispute','DG2','共同财产范围清晰','共同财产范围清晰','共同财产范围是否清晰？',NULL,NULL,'boolean',0,5,1),
('questionnaire_divorce_dispute','DG2','存在共同债务','存在共同债务','是否存在夫妻共同债务？',NULL,NULL,'boolean',0,6,1),
('questionnaire_divorce_dispute','DG2','存在家庭暴力或重大过错','存在家庭暴力或重大过错','是否存在家庭暴力或重大过错？',NULL,NULL,'boolean',0,7,1),
('questionnaire_divorce_dispute','DG3','有分居证据','有分居证据','是否有分居证据（租房合同、居住证明）？',NULL,NULL,'boolean',0,1,1),
('questionnaire_divorce_dispute','DG3','有家暴或报警记录','有家暴或报警记录','是否有家暴或报警记录？',NULL,NULL,'boolean',0,2,1),
('questionnaire_divorce_dispute','DG3','有抚养能力材料','有抚养能力材料','是否有稳定收入和抚养能力材料？',NULL,NULL,'boolean',0,3,1),

-- PD1/PD2
('questionnaire_post_divorce_property','PD1','离婚事实已生效','离婚事实已生效','离婚事实是否已生效？',NULL,NULL,'boolean',1,1,1),
('questionnaire_post_divorce_property','PD1','存在离婚协议','存在离婚协议','是否存在离婚协议？',NULL,NULL,'boolean',0,2,1),
('questionnaire_post_divorce_property','PD1','离婚协议财产条款未履行','离婚协议财产条款未履行','协议财产条款是否未履行？',NULL,NULL,'boolean',0,3,1),
('questionnaire_post_divorce_property','PD1','请求再次分割','请求再次分割','是否请求再次分割财产？',NULL,NULL,'boolean',1,4,1),
('questionnaire_post_divorce_property','PD1','请求执行离婚协议','请求执行离婚协议','是否请求执行离婚协议？',NULL,NULL,'boolean',0,5,1),
('questionnaire_post_divorce_property','PD2','存在未分割共同财产','存在未分割共同财产','是否存在未分割共同财产？',NULL,NULL,'boolean',1,1,1),
('questionnaire_post_divorce_property','PD2','新发现财产线索','新发现财产线索','是否新发现财产线索？',NULL,NULL,'boolean',0,2,1),
('questionnaire_post_divorce_property','PD2','存在隐藏转移财产线索','存在隐藏转移财产线索','是否存在隐藏转移财产线索？',NULL,NULL,'boolean',0,3,1),
('questionnaire_post_divorce_property','PD2','有证据证明隐藏转移','有证据证明隐藏转移','是否有证据证明隐藏转移？',NULL,NULL,'boolean',0,4,1),
('questionnaire_post_divorce_property','PD3','有离婚协议原件','有离婚协议原件','是否有离婚协议原件或公证文本？',NULL,NULL,'boolean',0,1,1),
('questionnaire_post_divorce_property','PD3','有财产交易流水','有财产交易流水','是否有财产交易流水或账户明细？',NULL,NULL,'boolean',0,2,1),
('questionnaire_post_divorce_property','PD3','有对方名下财产线索','有对方名下财产线索','是否有对方名下新增财产线索？',NULL,NULL,'boolean',0,3,1),

-- LI1/LI2
('questionnaire_labor_injury_compensation','LI1','存在劳动关系','存在劳动关系','是否存在劳动关系？',NULL,NULL,'boolean',1,1,1),
('questionnaire_labor_injury_compensation','LI1','发生工作时间工作场所事故','发生工作时间工作场所事故','是否在工作时间和工作场所发生事故？',NULL,NULL,'boolean',1,2,1),
('questionnaire_labor_injury_compensation','LI1','已申请或拟申请工伤认定','已申请或拟申请工伤认定','是否已申请或拟申请工伤认定？',NULL,NULL,'boolean',1,3,1),
('questionnaire_labor_injury_compensation','LI1','单位已缴纳工伤保险','单位已缴纳工伤保险','单位是否已缴纳工伤保险？',NULL,NULL,'boolean',0,4,1),
('questionnaire_labor_injury_compensation','LI2','存在医疗费用支出','存在医疗费用支出','是否存在医疗费用支出？',NULL,NULL,'boolean',0,1,1),
('questionnaire_labor_injury_compensation','LI2','存在停工留薪损失','存在停工留薪损失','是否存在停工留薪损失？',NULL,NULL,'boolean',0,2,1),
('questionnaire_labor_injury_compensation','LI2','已认定伤残等级','已认定伤残等级','是否已认定伤残等级？',NULL,NULL,'boolean',0,3,1),
('questionnaire_labor_injury_compensation','LI2','单位拒绝支付工伤待遇','单位拒绝支付工伤待遇','单位是否拒绝支付工伤待遇？',NULL,NULL,'boolean',0,4,1),
('questionnaire_labor_injury_compensation','LI3','有事故报告或证人证言','有事故报告或证人证言','是否有事故报告或证人证言？',NULL,NULL,'boolean',0,1,1),
('questionnaire_labor_injury_compensation','LI3','有病历及费用票据','有病历及费用票据','是否有病历和医疗费用票据？',NULL,NULL,'boolean',0,2,1),
('questionnaire_labor_injury_compensation','LI3','有伤残鉴定文书','有伤残鉴定文书','是否有伤残等级鉴定文书？',NULL,NULL,'boolean',0,3,1),

-- LO1/LO2
('questionnaire_labor_overtime_pay','LO1','存在劳动关系','存在劳动关系','是否存在劳动关系？',NULL,NULL,'boolean',1,1,1),
('questionnaire_labor_overtime_pay','LO1','主张加班费','主张加班费','是否主张加班费？',NULL,NULL,'boolean',1,2,1),
('questionnaire_labor_overtime_pay','LO1','单位未足额支付加班费','单位未足额支付加班费','单位是否未足额支付加班费？',NULL,NULL,'boolean',1,3,1),
('questionnaire_labor_overtime_pay','LO1','月均加班时长','月均加班时长','月均加班时长约多少？',NULL,'小时','number',0,4,1),
('questionnaire_labor_overtime_pay','LO2','存在加班事实','存在加班事实','是否存在加班事实？',NULL,NULL,'boolean',1,1,1),
('questionnaire_labor_overtime_pay','LO2','有加班证据','有加班证据','是否有加班证据（考勤/审批）？',NULL,NULL,'boolean',0,2,1),
('questionnaire_labor_overtime_pay','LO2','存在工作日延时加班','存在工作日延时加班','是否存在工作日延时加班？',NULL,NULL,'boolean',0,3,1),
('questionnaire_labor_overtime_pay','LO2','存在休息日加班','存在休息日加班','是否存在休息日加班？',NULL,NULL,'boolean',0,4,1),
('questionnaire_labor_overtime_pay','LO2','休息日未安排补休','休息日未安排补休','休息日加班是否未安排补休？',NULL,NULL,'boolean',0,5,1),
('questionnaire_labor_overtime_pay','LO2','存在法定节假日加班','存在法定节假日加班','是否存在法定节假日加班？',NULL,NULL,'boolean',0,6,1),
('questionnaire_labor_overtime_pay','LO3','有完整考勤记录','有完整考勤记录','是否有完整考勤记录（打卡/门禁）？',NULL,NULL,'boolean',0,1,1),
('questionnaire_labor_overtime_pay','LO3','有加班审批记录','有加班审批记录','是否有加班审批或排班记录？',NULL,NULL,'boolean',0,2,1),
('questionnaire_labor_overtime_pay','LO3','有工资条与流水对照','有工资条与流水对照','是否有工资条与银行流水对照？',NULL,NULL,'boolean',0,3,1);

-- ==========================================================
-- F) 规则（每案由多分支）
-- ==========================================================
DELETE rc FROM rule_judge_rule_conclusion rc
JOIN rule_judge_rule r ON r.rule_id=rc.rule_id
WHERE r.cause_code IN ('betrothal_property','divorce_dispute','post_divorce_property','labor_injury_compensation','labor_overtime_pay');
DELETE FROM rule_judge_conclusion WHERE conclusion_id LIKE 'c_add_%';
DELETE FROM rule_judge_rule WHERE cause_code IN ('betrothal_property','divorce_dispute','post_divorce_property','labor_injury_compensation','labor_overtime_pay');

INSERT INTO rule_judge_rule (rule_id,cause_code,rule_name,path_name,calc_expr,law_ref,priority,condition_json,enabled) VALUES
('r_add_betrothal_full','betrothal_property','彩礼全额返还路径','彩礼全额返还路径命中','与','law_jshj_5',10,
'{"op":"and","children":[{"fact":"存在彩礼给付","cmp":"eq","value":true},{"fact":"存在法定返还情形","cmp":"eq","value":true},{"op":"or","children":[{"fact":"未办理结婚登记","cmp":"eq","value":true},{"fact":"给付导致生活困难","cmp":"eq","value":true}]}]}',1),
('r_add_betrothal_partial','betrothal_property','彩礼部分返还路径','彩礼部分返还路径命中','与/或','law_jshj_5',20,
'{"op":"and","children":[{"fact":"存在彩礼给付","cmp":"eq","value":true},{"fact":"已办理结婚登记","cmp":"eq","value":true},{"fact":"共同生活时间较短","cmp":"eq","value":true}]}',1),
('r_add_betrothal_no_refund','betrothal_property','彩礼不返还抗辩路径','彩礼不返还抗辩路径命中','与','law_jshj_5',30,
'{"op":"and","children":[{"fact":"已办理结婚登记","cmp":"eq","value":true},{"fact":"已登记后共同生活","cmp":"eq","value":true}]}',1),

('r_add_divorce_judgment','divorce_dispute','离婚判决路径','离婚判决路径命中','与','law_1079',10,
'{"op":"and","children":[{"fact":"存在合法婚姻关系","cmp":"eq","value":true},{"fact":"感情确已破裂","cmp":"eq","value":true}]}',1),
('r_add_divorce_custody','divorce_dispute','子女抚养路径','子女抚养路径命中','与','law_1084',20,
'{"op":"and","children":[{"fact":"涉及子女抚养","cmp":"eq","value":true},{"op":"or","children":[{"fact":"子女长期随一方生活","cmp":"eq","value":true},{"fact":"另一方存在不利抚养因素","cmp":"eq","value":true}]}]}',1),
('r_add_divorce_property','divorce_dispute','财产债务处理路径','财产债务处理路径命中','与/或','law_1087',30,
'{"op":"or","children":[{"fact":"涉及夫妻共同财产","cmp":"eq","value":true},{"fact":"存在共同债务","cmp":"eq","value":true},{"fact":"共同财产范围清晰","cmp":"eq","value":true}]}',1),

('r_add_post_divorce_redistribute','post_divorce_property','离婚后再分割路径','离婚后再分割路径命中','与','law_1087',10,
'{"op":"and","children":[{"fact":"离婚事实已生效","cmp":"eq","value":true},{"fact":"存在未分割共同财产","cmp":"eq","value":true},{"fact":"请求再次分割","cmp":"eq","value":true}]}',1),
('r_add_post_divorce_conceal','post_divorce_property','隐藏转移财产路径','隐藏转移财产路径命中','与','law_1092',20,
'{"op":"and","children":[{"fact":"存在隐藏转移财产线索","cmp":"eq","value":true},{"fact":"有证据证明隐藏转移","cmp":"eq","value":true}]}',1),
('r_add_post_divorce_agreement','post_divorce_property','协议履行路径','协议履行路径命中','与','law_1087',30,
'{"op":"and","children":[{"fact":"存在离婚协议","cmp":"eq","value":true},{"fact":"离婚协议财产条款未履行","cmp":"eq","value":true},{"fact":"请求执行离婚协议","cmp":"eq","value":true}]}',1),

('r_add_labor_injury_recognition','labor_injury_compensation','工伤认定路径','工伤认定路径命中','与','law_injury_14',10,
'{"op":"and","children":[{"fact":"存在劳动关系","cmp":"eq","value":true},{"fact":"发生工作时间工作场所事故","cmp":"eq","value":true},{"fact":"已申请或拟申请工伤认定","cmp":"eq","value":true}]}',1),
('r_add_labor_injury_medical','labor_injury_compensation','工伤医疗路径','工伤医疗路径命中','与','law_injury_30',20,
'{"op":"and","children":[{"fact":"存在医疗费用支出","cmp":"eq","value":true},{"fact":"已申请或拟申请工伤认定","cmp":"eq","value":true}]}',1),
('r_add_labor_injury_disability','labor_injury_compensation','伤残待遇路径','伤残待遇路径命中','与','law_injury_37',30,
'{"op":"and","children":[{"fact":"已认定伤残等级","cmp":"eq","value":true},{"fact":"单位拒绝支付工伤待遇","cmp":"eq","value":true}]}',1),

('r_add_overtime_workday','labor_overtime_pay','工作日加班费路径','工作日加班费路径命中','与','law_labor_44',10,
'{"op":"and","children":[{"fact":"存在劳动关系","cmp":"eq","value":true},{"fact":"主张加班费","cmp":"eq","value":true},{"fact":"存在工作日延时加班","cmp":"eq","value":true},{"fact":"单位未足额支付加班费","cmp":"eq","value":true}]}',1),
('r_add_overtime_restday','labor_overtime_pay','休息日加班费路径','休息日加班费路径命中','与','law_labor_44',20,
'{"op":"and","children":[{"fact":"存在休息日加班","cmp":"eq","value":true},{"fact":"休息日未安排补休","cmp":"eq","value":true},{"fact":"单位未足额支付加班费","cmp":"eq","value":true}]}',1),
('r_add_overtime_holiday','labor_overtime_pay','节假日加班费路径','节假日加班费路径命中','与','law_labor_44',30,
'{"op":"and","children":[{"fact":"存在法定节假日加班","cmp":"eq","value":true},{"fact":"单位未足额支付加班费","cmp":"eq","value":true}]}',1);

INSERT INTO rule_judge_conclusion (conclusion_id,type,result,reason,level,law_refs_json,final_item,final_result,final_detail,enabled) VALUES
('c_add_betrothal_full','betrothal','可主张全额返还彩礼','满足彩礼给付与法定返还关键要件。','important','["law_1042","law_jshj_5"]','彩礼返还请求','全额返还支持可能性较高','建议重点提交彩礼支付凭证、未登记/困难证明材料。',1),
('c_add_betrothal_partial','betrothal','可主张部分返还彩礼','存在已登记且共同生活较短等情形，倾向部分返还。','warning','["law_jshj_5"]','彩礼返还请求','部分返还支持可能性较高','建议围绕共同生活时长和财产去向补强证据。',1),
('c_add_betrothal_no_refund','betrothal','存在不返还抗辩空间','已登记并长期共同生活，不返还抗辩空间较大。','warning','["law_jshj_5"]','抗辩方向','可主张不返还或少返还','建议提交共同生活事实与支出证据。',1),

('c_add_divorce_judgment','divorce','可请求判决离婚','满足婚姻关系与感情破裂要件。','important','["law_1079"]','离婚诉请','判决离婚支持可能性较高','建议补充分居、冲突、调解失败材料。',1),
('c_add_divorce_custody','divorce','可形成子女抚养优势主张','子女长期随一方生活或另一方存在不利因素。','important','["law_1084"]','抚养诉请','可优先主张直接抚养','建议提交学习生活照料及稳定性材料。',1),
('c_add_divorce_property','divorce','可同步主张财产债务处理','已涉及共同财产或共同债务处理。','important','["law_1087"]','财产债务诉请','建议一并处理共同财产债务','建议提交资产负债清单与凭证。',1),

('c_add_post_divorce_redistribute','post_divorce','可请求离婚后再次分割财产','存在未分割共同财产且已明确再分割请求。','important','["law_1087"]','再分割请求','具备请求基础','建议整理离婚文书与财产线索。',1),
('c_add_post_divorce_conceal','post_divorce','可主张隐藏转移财产责任','存在隐藏转移线索且证据较充分。','important','["law_1092"]','责任追究请求','可请求对方少分或不分','建议固定流水、交易、账户证据。',1),
('c_add_post_divorce_agreement','post_divorce','可请求履行离婚协议财产条款','存在协议且财产条款未履行。','important','["law_1087"]','协议履行请求','可请求确认并履行协议','建议提交协议文本与催告记录。',1),

('c_add_labor_injury_recognition','labor_injury','工伤认定主张有支持可能','工伤认定核心前提基本具备。','important','["law_injury_14"]','工伤认定请求','可优先推进工伤认定','建议尽快提交认定申请及事故材料。',1),
('c_add_labor_injury_medical','labor_injury','工伤医疗费用主张有支持可能','存在工伤医疗支出且已申请认定。','important','["law_injury_30"]','医疗待遇请求','可主张工伤医疗费用','建议汇总票据、病历及支付记录。',1),
('c_add_labor_injury_disability','labor_injury','伤残待遇主张有支持可能','已认定伤残且单位拒绝支付待遇。','important','["law_injury_37"]','伤残待遇请求','可主张一次性伤残补助等','建议提交伤残等级结论与拒付证据。',1),

('c_add_overtime_workday','labor_overtime','工作日加班费主张有支持可能','工作日延时加班事实与欠付事实较明确。','important','["law_labor_44","law_contract_31"]','加班费请求','可主张工作日加班费差额','建议按月整理工时和工资差额。',1),
('c_add_overtime_restday','labor_overtime','休息日加班费主张有支持可能','存在休息日加班且未补休。','important','["law_labor_44"]','加班费请求','可主张休息日加班费','建议提交排班与补休记录。',1),
('c_add_overtime_holiday','labor_overtime','节假日加班费主张有支持可能','存在法定节假日加班且未足额支付。','important','["law_labor_44"]','加班费请求','可主张节假日加班费','建议提交节假日值班及发薪对照材料。',1);

INSERT INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order) VALUES
('r_add_betrothal_full','c_add_betrothal_full',1),
('r_add_betrothal_partial','c_add_betrothal_partial',1),
('r_add_betrothal_no_refund','c_add_betrothal_no_refund',1),
('r_add_divorce_judgment','c_add_divorce_judgment',1),
('r_add_divorce_custody','c_add_divorce_custody',1),
('r_add_divorce_property','c_add_divorce_property',1),
('r_add_post_divorce_redistribute','c_add_post_divorce_redistribute',1),
('r_add_post_divorce_conceal','c_add_post_divorce_conceal',1),
('r_add_post_divorce_agreement','c_add_post_divorce_agreement',1),
('r_add_labor_injury_recognition','c_add_labor_injury_recognition',1),
('r_add_labor_injury_medical','c_add_labor_injury_medical',1),
('r_add_labor_injury_disability','c_add_labor_injury_disability',1),
('r_add_overtime_workday','c_add_overtime_workday',1),
('r_add_overtime_restday','c_add_overtime_restday',1),
('r_add_overtime_holiday','c_add_overtime_holiday',1);

SET FOREIGN_KEY_CHECKS = 1;
