USE rule_engine_db;
SET NAMES utf8mb4;

-- 目的：把存量婚姻家事案由（divorce_dispute / child_support_dispute / support_dispute / post_divorce_property）
-- 的问卷 + Step2 精细化到与第一梯队一致的粒度。
-- 策略：尽量只增量 INSERT IGNORE / ON DUPLICATE KEY UPDATE，不破坏既有问卷结构；必要时新增 G4 组。

-- ==========================================================
-- A) divorce_dispute：新增问卷题（DG4）与更细 Step2 targets
-- ==========================================================

INSERT IGNORE INTO rule_question_group (questionnaire_id, group_key, group_name, group_desc, icon, group_order, enabled) VALUES
('questionnaire_divorce_dispute','DG4','离婚事由与风险','细化离婚事由、过错与风险提示','alert',4,1);

INSERT IGNORE INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, unit, input_type, required, question_order, enabled) VALUES
('questionnaire_divorce_dispute','DG4','存在家庭暴力或重大过错','存在家庭暴力或重大过错','是否存在家庭暴力/重婚/同居/虐待遗弃等重大过错？',NULL,NULL,'boolean',0,1,1),
('questionnaire_divorce_dispute','DG4','有家暴或报警记录','有家暴或报警记录','是否有报警回执、告诫书、伤情鉴定、就医记录等？',NULL,NULL,'boolean',0,2,1),
('questionnaire_divorce_dispute','DG4','存在分居事实','存在分居事实','是否存在分居事实（含各自居住/分开生活）？',NULL,NULL,'boolean',0,3,1),
('questionnaire_divorce_dispute','DG4','分居时长月数','分居时长月数','分居大概持续了几个月？',NULL,'月','number',0,4,1),
('questionnaire_divorce_dispute','DG4','对方不同意离婚或拖延','对方不同意离婚或拖延','对方是否不同意离婚或长期拖延？',NULL,NULL,'boolean',0,5,1),
('questionnaire_divorce_dispute','DG4','是否存在二次起诉离婚','是否存在二次起诉离婚','是否属于第二次起诉离婚或已有离婚诉讼史？',NULL,NULL,'boolean',0,6,1),
('questionnaire_divorce_dispute','DG4','是否存在子女意愿争议','是否存在子女意愿争议','子女意愿是否成为争议点（八周岁以上）？',NULL,NULL,'boolean',0,7,1),
('questionnaire_divorce_dispute','DG4','是否存在共同债务争议','是否存在共同债务争议','共同债务是否存在争议或需要界定？',NULL,NULL,'boolean',0,8,1);

INSERT IGNORE INTO rule_step2_target (target_id, title, descr, enabled) VALUES
('target_divorce_judgment_breakdown','判决离婚：感情破裂与事由链条','围绕感情破裂、分居/冲突/调解情况构建证明链条。',1),
('target_divorce_judgment_violence_fault','判决离婚：家暴/重大过错方向','围绕家暴或重大过错事实固定证据，强化离婚支持度及衍生请求基础。',1),
('target_divorce_custody_best_interest','离婚纠纷：子女抚养与最佳利益','围绕直接抚养、探望、抚养费与子女利益证据组织材料。',1),
('target_divorce_property_debt_scope','离婚纠纷：财产与债务范围清单化','围绕共同财产/债务范围、形成时间线、证据来源整理清单。',1);

INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order) VALUES
('divorce_dispute','target_divorce_judgment_breakdown',10),
('divorce_dispute','target_divorce_judgment_violence_fault',11),
('divorce_dispute','target_divorce_custody_best_interest',12),
('divorce_dispute','target_divorce_property_debt_scope',13);

INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES
('target_divorce_judgment_breakdown','存在合法婚姻关系','存在合法婚姻关系',1,1),
('target_divorce_judgment_breakdown','感情确已破裂','感情确已破裂',2,1),
('target_divorce_judgment_breakdown','存在分居事实','存在分居事实',3,1),
('target_divorce_judgment_breakdown','有分居证据','有分居证据',4,1),
('target_divorce_judgment_breakdown','存在调解意愿','存在调解意愿',5,1),
('target_divorce_judgment_breakdown','对方不同意离婚或拖延','对方不同意离婚或拖延',6,1),

('target_divorce_judgment_violence_fault','存在家庭暴力或重大过错','存在家庭暴力或重大过错',1,1),
('target_divorce_judgment_violence_fault','有家暴或报警记录','有家暴或报警记录',2,1),
('target_divorce_judgment_violence_fault','感情确已破裂','感情确已破裂',3,1),

('target_divorce_custody_best_interest','涉及子女抚养','涉及子女抚养',1,1),
('target_divorce_custody_best_interest','子女长期随一方生活','子女长期随一方生活',2,1),
('target_divorce_custody_best_interest','另一方存在不利抚养因素','另一方存在不利抚养因素',3,1),
('target_divorce_custody_best_interest','有抚养能力材料','有抚养能力材料',4,1),
('target_divorce_custody_best_interest','是否存在子女意愿争议','是否存在子女意愿争议',5,1),

('target_divorce_property_debt_scope','涉及夫妻共同财产','涉及夫妻共同财产',1,1),
('target_divorce_property_debt_scope','共同财产范围清晰','共同财产范围清晰',2,1),
('target_divorce_property_debt_scope','存在共同债务','存在共同债务',3,1),
('target_divorce_property_debt_scope','是否存在共同债务争议','是否存在共同债务争议',4,1);

INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES
('target_divorce_judgment_breakdown','存在合法婚姻关系','结婚证/婚姻登记档案',1,0,1),
('target_divorce_judgment_breakdown','感情确已破裂','聊天记录/调解记录/冲突证据',1,0,1),
('target_divorce_judgment_breakdown','存在分居事实','分居证明/租房合同/居住证明',1,0,1),
('target_divorce_judgment_breakdown','有分居证据','水电缴费/物业/居住证明',1,0,1),
('target_divorce_judgment_breakdown','对方不同意离婚或拖延','聊天记录/起诉材料/庭审笔录',1,0,1),

('target_divorce_judgment_violence_fault','存在家庭暴力或重大过错','报警回执/告诫书/伤情鉴定/证人证言',1,0,1),
('target_divorce_judgment_violence_fault','有家暴或报警记录','报警回执/就医记录/照片视频',1,0,1),

('target_divorce_custody_best_interest','子女长期随一方生活','就学材料/接送记录/日常照护证明',1,0,1),
('target_divorce_custody_best_interest','另一方存在不利抚养因素','不良嗜好/暴力记录/不尽抚养义务证据',1,0,1),
('target_divorce_custody_best_interest','有抚养能力材料','收入证明/住房证明/照护安排',1,0,1),
('target_divorce_custody_best_interest','是否存在子女意愿争议','学校/社工记录/沟通记录（注意保护未成年人）',1,0,1),

('target_divorce_property_debt_scope','共同财产范围清晰','不动产/车辆/存款/理财清单与凭证',1,0,1),
('target_divorce_property_debt_scope','存在共同债务','借款合同/流水/用途证明',1,0,1),
('target_divorce_property_debt_scope','是否存在共同债务争议','聊天记录/举债用途证据/家庭支出证据',1,0,1);

-- ==========================================================
-- B) child_support_dispute：更细 Step2 targets（抚养费、拖欠、变更抚养、变更金额）
-- ==========================================================

INSERT IGNORE INTO rule_step2_target (target_id, title, descr, enabled) VALUES
('target_child_support_arrears_enforcement','抚养费：拖欠与执行/补付','围绕拖欠事实、约定/判决基础、对方支付能力固定证据。',1),
('target_child_support_change_amount','抚养费：变更数额（增减）','围绕抚养支出变化、收入变化、教育医疗等重大支出构建变更理由。',1);

INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order) VALUES
('child_support_dispute','target_child_support_arrears_enforcement',10),
('child_support_dispute','target_child_support_change_amount',11);

INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES
('target_child_support_arrears_enforcement','存在亲子关系','存在亲子关系',1,1),
('target_child_support_arrears_enforcement','对方未支付抚养费','对方未支付抚养费',2,1),
('target_child_support_arrears_enforcement','是否有离婚协议或判决','是否有离婚协议或判决',3,1),
('target_child_support_arrears_enforcement','约定抚养费金额','约定抚养费金额',4,1),
('target_child_support_arrears_enforcement','对方收入水平大致明确','对方收入水平大致明确',5,1),

('target_child_support_change_amount','是否存在重大支出变化','是否存在重大支出变化',1,1),
('target_child_support_change_amount','孩子实际月支出','孩子实际月支出',2,1),
('target_child_support_change_amount','对方收入水平大致明确','对方收入水平大致明确',3,1),
('target_child_support_change_amount','是否有离婚协议或判决','是否有离婚协议或判决',4,1);

INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES
('target_child_support_arrears_enforcement','存在亲子关系','出生证明/户口簿/亲子关系证明',1,0,1),
('target_child_support_arrears_enforcement','对方未支付抚养费','转账记录/催要记录/对方承认欠付材料',1,0,1),
('target_child_support_arrears_enforcement','是否有离婚协议或判决','离婚协议/判决书/调解书',1,0,1),
('target_child_support_arrears_enforcement','对方收入水平大致明确','工资流水/个税/社保公积金/收入证明',1,0,1),

('target_child_support_change_amount','孩子实际月支出','教育医疗票据/培训合同/生活支出清单',1,0,1),
('target_child_support_change_amount','是否存在重大支出变化','病历诊断/学费通知/支出变化证明',1,0,1),
('target_child_support_change_amount','对方收入水平大致明确','工资流水/个税/社保公积金/收入证明',1,0,1);

-- ==========================================================
-- C) support_dispute（赡养纠纷）：更细 Step2 targets（生活困难、医疗失能、多个赡养人分担）
-- ==========================================================

INSERT IGNORE INTO rule_step2_target (target_id, title, descr, enabled) VALUES
('target_support_medical_disability','赡养纠纷：医疗/失能与费用链条','围绕医疗失能、护理支出与生活困难形成证明链。',1),
('target_support_multi_obligor_share','赡养纠纷：多名赡养人分担与支付能力','围绕赡养人范围、收入能力、分担方案组织证据。',1);

INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order) VALUES
('support_dispute','target_support_medical_disability',10),
('support_dispute','target_support_multi_obligor_share',11);

INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES
('target_support_medical_disability','存在赡养关系','存在赡养关系',1,1),
('target_support_medical_disability','被赡养人生活困难','被赡养人生活困难',2,1),
('target_support_medical_disability','有医疗或失能证明','有医疗或失能证明',3,1),
('target_support_medical_disability','被赡养人月基本支出','被赡养人月基本支出',4,1),

('target_support_multi_obligor_share','是否存在多名赡养人','是否存在多名赡养人',1,1),
('target_support_multi_obligor_share','赡养人收入能力大致明确','赡养人收入能力大致明确',2,1),
('target_support_multi_obligor_share','赡养人拒绝履行','赡养人拒绝履行',3,1),
('target_support_multi_obligor_share','有亲属关系证明','有亲属关系证明',4,1);

INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES
('target_support_medical_disability','有医疗或失能证明','病历/诊断证明/评残鉴定/护理记录',1,0,1),
('target_support_medical_disability','被赡养人生活困难','低保证明/收入证明/支出清单',1,0,1),
('target_support_medical_disability','被赡养人月基本支出','费用票据/租金水电/医疗缴费清单',1,0,1),

('target_support_multi_obligor_share','是否存在多名赡养人','户口簿/亲属关系证明/村居委证明',1,0,1),
('target_support_multi_obligor_share','赡养人收入能力大致明确','工资流水/个税/社保公积金/收入证明',1,0,1),
('target_support_multi_obligor_share','赡养人拒绝履行','催要记录/拒绝沟通证据/证人证言',1,0,1);

-- ==========================================================
-- D) post_divorce_property：更细 Step2 targets（协议履行、再次分割、隐藏转移、时效/发现时间）
-- ==========================================================

INSERT IGNORE INTO rule_question_group (questionnaire_id, group_key, group_name, group_desc, icon, group_order, enabled) VALUES
('questionnaire_post_divorce_property','PD4','时效与发现时间','细化发现时间、线索来源与时效风险','clock',4,1);

INSERT IGNORE INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, unit, input_type, required, question_order, enabled) VALUES
('questionnaire_post_divorce_property','PD4','发现财产线索时间明确','发现财产线索时间明确','发现未分割/隐藏财产线索的时间是否明确？',NULL,NULL,'boolean',0,1,1),
('questionnaire_post_divorce_property','PD4','离婚后已过三年风险','离婚后已过三年风险','是否可能存在诉讼时效（如发现后已过三年）风险？',NULL,NULL,'boolean',0,2,1);

INSERT IGNORE INTO rule_step2_target (target_id, title, descr, enabled) VALUES
('target_post_divorce_time_limit_risk','离婚后财产：发现时间与时效风险评估','围绕发现时间、线索来源与时效风险准备解释与证据。',1),
('target_post_divorce_agreement_validity','离婚后财产：协议效力与履行路径补强','围绕离婚协议条件、效力争议与履行证据补强。',1);

INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order) VALUES
('post_divorce_property','target_post_divorce_time_limit_risk',10),
('post_divorce_property','target_post_divorce_agreement_validity',11);

INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES
('target_post_divorce_time_limit_risk','离婚事实已生效','离婚事实已生效',1,1),
('target_post_divorce_time_limit_risk','新发现财产线索','新发现财产线索',2,1),
('target_post_divorce_time_limit_risk','发现财产线索时间明确','发现财产线索时间明确',3,1),
('target_post_divorce_time_limit_risk','离婚后已过三年风险','离婚后已过三年风险',4,1),

('target_post_divorce_agreement_validity','存在离婚协议','存在离婚协议',1,1),
('target_post_divorce_agreement_validity','离婚协议财产条款未履行','离婚协议财产条款未履行',2,1),
('target_post_divorce_agreement_validity','有离婚协议原件','有离婚协议原件',3,1),
('target_post_divorce_agreement_validity','请求执行离婚协议','请求执行离婚协议',4,1);

INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES
('target_post_divorce_time_limit_risk','发现财产线索时间明确','聊天记录/查询回执/线索来源材料',1,0,1),
('target_post_divorce_time_limit_risk','新发现财产线索','不动产查询/车辆登记/银行流水线索',1,0,1),

('target_post_divorce_agreement_validity','存在离婚协议','离婚协议/调解书/判决书',1,0,1),
('target_post_divorce_agreement_validity','离婚协议财产条款未履行','催告记录/未履行事实证据/交易记录',1,0,1),
('target_post_divorce_agreement_validity','有离婚协议原件','协议原件/公证文本/登记材料',1,0,1);

