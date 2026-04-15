USE rule_engine_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================================
-- 婚姻家事（前端命名对齐）- 新增小类案由 + 问卷 + 法条 + Step2 + 规则
-- 目标：让前端 marriage_case 下 5 个入口都“点得开、能预填、能出报告/证据指引”
-- 案由码（前端）：divorce_dispute / property_dispute / child_support_dispute / support_dispute / inherit_dispute
-- ==========================================================

-- 0) 案由注册（若已存在则更新名称/问卷/启用状态）
INSERT INTO rule_cause (cause_code, cause_name, questionnaire_id, enabled)
VALUES
('divorce_dispute', '离婚纠纷', 'questionnaire_divorce_dispute', 1),
('property_dispute', '婚约财产纠纷（如房产）', 'questionnaire_property_dispute', 1),
('child_support_dispute', '抚养费/变更抚养关系纠纷', 'questionnaire_child_support_dispute', 1),
('support_dispute', '赡养纠纷', 'questionnaire_support_dispute', 1),
('inherit_dispute', '法定继承/遗嘱继承纠纷', 'questionnaire_inherit_dispute', 1)
ON DUPLICATE KEY UPDATE
cause_name=VALUES(cause_name),
questionnaire_id=VALUES(questionnaire_id),
enabled=VALUES(enabled);

-- 1) 大类归属（若已执行 migrate_cause_categories.sql）
UPDATE rule_cause SET category_code='marriage_family'
WHERE cause_code IN ('divorce_dispute','property_dispute','child_support_dispute','support_dispute','inherit_dispute');

-- 2) 问卷主表
INSERT INTO rule_questionnaire (questionnaire_id, name, enabled, version_no)
VALUES
('questionnaire_property_dispute', '婚约财产纠纷（如房产）问卷', 1, 1),
('questionnaire_child_support_dispute', '抚养费/变更抚养关系纠纷问卷', 1, 1),
('questionnaire_support_dispute', '赡养纠纷问卷', 1, 1),
('questionnaire_inherit_dispute', '继承纠纷问卷', 1, 1)
ON DUPLICATE KEY UPDATE
name=VALUES(name), enabled=VALUES(enabled), version_no=VALUES(version_no);

-- 3) 问卷分组（每个问卷 3 组：前置/关键要件/证据补强）
INSERT INTO rule_question_group (questionnaire_id, group_key, group_order, enabled, group_name, group_desc, icon)
VALUES
('questionnaire_property_dispute','P0',1,1,'基础事实','确认是否属于婚约财产/彩礼等纠纷的基本前提','check'),
('questionnaire_property_dispute','P1',2,1,'争议要点','采集给付、登记、共同生活、金额等关键事实','folder'),
('questionnaire_property_dispute','P2',3,1,'证据补强','补充转账/收条、共同生活、困难等证据线索','plus'),

('questionnaire_child_support_dispute','C0',1,1,'前置确认','确认亲子关系与抚养争议存在','check'),
('questionnaire_child_support_dispute','C1',2,1,'抚养费要件','采集抚养费标准、支付能力、实际支出等','folder'),
('questionnaire_child_support_dispute','C2',3,1,'变更抚养（可选）','采集变更抚养关系的法定情形与证据','plus'),

('questionnaire_support_dispute','S0',1,1,'前置确认','确认赡养关系与生活困难','check'),
('questionnaire_support_dispute','S1',2,1,'赡养要件','采集被赡养人需要与赡养人能力','folder'),
('questionnaire_support_dispute','S2',3,1,'证据补强','补充疾病、收入、支出、拒绝赡养证据','plus'),

('questionnaire_inherit_dispute','I0',1,1,'前置确认','确认继承开始、继承人范围与遗产线索','check'),
('questionnaire_inherit_dispute','I1',2,1,'法定继承','采集继承顺序、份额、代位/转继承等要点','folder'),
('questionnaire_inherit_dispute','I2',3,1,'遗嘱/遗赠（可选）','采集遗嘱形式、效力、见证与保管','plus')
ON DUPLICATE KEY UPDATE
group_order=VALUES(group_order), enabled=VALUES(enabled), group_name=VALUES(group_name), group_desc=VALUES(group_desc), icon=VALUES(icon);

-- 4) 题目（question_key 使用中文，便于 AI 对齐；answer_key 与 question_key 保持一致）
-- 4.1 property_dispute（复用 betrothal_property 思路，但用前端案由码+更泛化标题）
INSERT INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
VALUES
('questionnaire_property_dispute','P0','存在彩礼或财产给付','存在彩礼或财产给付','是否存在彩礼/婚约财产给付？','如彩礼、购房首付、房产加名等围绕缔结婚姻给付的财物。','boolean',1,1,1,NULL),
('questionnaire_property_dispute','P0','是否已办理结婚登记','是否已办理结婚登记','双方是否办理过结婚登记？','以结婚证/婚姻登记信息为准。','choice',1,2,1,NULL),
('questionnaire_property_dispute','P0','是否已共同生活','是否已共同生活','双方是否实际共同生活？','共同生活指以夫妻名义共同居住、共同支出。','boolean',0,3,1,NULL),

('questionnaire_property_dispute','P1','给付是否导致生活困难','给付是否导致生活困难','给付是否导致给付方生活困难？','生活困难通常需结合收入、负债、生活支出综合判断。','boolean',0,1,1,NULL),
('questionnaire_property_dispute','P1','是否存在法定返还情形','是否存在法定返还情形','是否存在彩礼返还法定情形？','如未登记、登记未共同生活、给付导致生活困难等。','boolean',1,2,1,NULL),
('questionnaire_property_dispute','P1','给付金额','给付金额','给付金额大约是多少？','金额题按“元”填写。','number',0,3,1,'元'),
('questionnaire_property_dispute','P1','共同生活月数','共同生活月数','共同生活大约持续多久？','按月填写。','number',0,4,1,'月'),
('questionnaire_property_dispute','P1','财物类型','财物类型','主要争议财物类型是什么？','彩礼/房产加名/车辆/大额转账等。','select',0,5,1,NULL),

('questionnaire_property_dispute','P2','有转账或收条','有转账或收条','是否有转账记录/收条/借条等凭证？','如微信/支付宝/银行转账或收据。','boolean',0,1,1,NULL),
('questionnaire_property_dispute','P2','有共同生活证据','有共同生活证据','是否有共同生活证据？','如租房合同、同住照片、消费记录。','boolean',0,2,1,NULL),
('questionnaire_property_dispute','P2','有生活困难证明','有生活困难证明','是否有生活困难证明材料？','如收入证明、负债证明、低保证明等。','boolean',0,3,1,NULL)
ON DUPLICATE KEY UPDATE
label=VALUES(label), hint=VALUES(hint), input_type=VALUES(input_type), required=VALUES(required), question_order=VALUES(question_order), enabled=VALUES(enabled), unit=VALUES(unit);

-- options：是否已办理结婚登记
INSERT IGNORE INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, v.option_value, v.option_label, v.option_order, 1
FROM rule_question q
JOIN (
  SELECT '未登记' option_value, '未办理结婚登记' option_label, 0 option_order
  UNION ALL SELECT '已登记', '已办理结婚登记', 1
) v
WHERE q.questionnaire_id='questionnaire_property_dispute' AND q.question_key='是否已办理结婚登记';

-- options：财物类型
INSERT IGNORE INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, v.option_value, v.option_label, v.option_order, 1
FROM rule_question q
JOIN (
  SELECT '彩礼' option_value, '彩礼/礼金' option_label, 0 option_order
  UNION ALL SELECT '房产', '房产/加名/购房出资', 1
  UNION ALL SELECT '车辆', '车辆/大件购置', 2
  UNION ALL SELECT '转账', '大额转账/红包', 3
  UNION ALL SELECT '其他', '其他', 9
) v
WHERE q.questionnaire_id='questionnaire_property_dispute' AND q.question_key='财物类型';

-- 4.2 child_support_dispute
INSERT INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
VALUES
('questionnaire_child_support_dispute','C0','存在亲子关系','存在亲子关系','是否存在亲子关系？','通常以出生医学证明、户口簿、亲子鉴定等证明。','boolean',1,1,1,NULL),
('questionnaire_child_support_dispute','C0','目前抚养关系明确','目前抚养关系明确','目前孩子主要由哪一方直接抚养？','直接抚养指日常共同生活、照顾教育的一方。','choice',1,2,1,NULL),
('questionnaire_child_support_dispute','C0','对方未支付抚养费','对方未支付抚养费','对方是否存在未支付或少支付抚养费？','包括拖欠、拒绝或金额明显不足。','boolean',1,3,1,NULL),

('questionnaire_child_support_dispute','C1','是否有离婚协议或判决','是否有离婚协议或判决','是否有离婚协议/判决/调解书约定抚养费？','如已有生效文书通常可直接申请执行或另行主张变更。','boolean',0,1,1,NULL),
('questionnaire_child_support_dispute','C1','约定抚养费金额','约定抚养费金额','已约定/判决的抚养费金额是多少？','按“元/月”填写。','number',0,2,1,'元/月'),
('questionnaire_child_support_dispute','C1','孩子实际月支出','孩子实际月支出','孩子实际月支出大约是多少？','含教育、医疗、生活等。','number',0,3,1,'元/月'),
('questionnaire_child_support_dispute','C1','对方收入水平大致明确','对方收入水平大致明确','是否能大致证明对方收入水平？','如工资条、个税、社保、公积金、银行流水。','boolean',0,4,1,NULL),
('questionnaire_child_support_dispute','C1','是否存在重大支出变化','是否存在重大支出变化','孩子是否存在重大支出变化？','如升学、长期医疗、特殊教育等。','boolean',0,5,1,NULL),

('questionnaire_child_support_dispute','C2','是否主张变更抚养关系','是否主张变更抚养关系','是否主张变更抚养关系？','若仅抚养费纠纷可选否。','boolean',0,1,1,NULL),
('questionnaire_child_support_dispute','C2','变更原因属于法定情形','变更原因属于法定情形','变更原因是否属于法定情形？','如抚养方无力继续抚养、虐待/不尽抚养义务、严重疾病等。','boolean',0,2,1,NULL),
('questionnaire_child_support_dispute','C2','孩子已满八周岁','孩子已满八周岁','孩子是否已满八周岁？','满八周岁一般需考虑孩子意愿。','boolean',0,3,1,NULL),
('questionnaire_child_support_dispute','C2','有利于孩子成长证据','有利于孩子成长证据','是否有证据证明变更更有利于孩子成长？','如就学、居住、照护、收入、陪伴等。','boolean',0,4,1,NULL)
ON DUPLICATE KEY UPDATE
label=VALUES(label), hint=VALUES(hint), input_type=VALUES(input_type), required=VALUES(required), question_order=VALUES(question_order), enabled=VALUES(enabled), unit=VALUES(unit);

INSERT IGNORE INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, v.option_value, v.option_label, v.option_order, 1
FROM rule_question q
JOIN (
  SELECT '母亲' option_value, '母亲直接抚养' option_label, 0 option_order
  UNION ALL SELECT '父亲', '父亲直接抚养', 1
  UNION ALL SELECT '共同', '双方轮流/共同抚养', 2
  UNION ALL SELECT '其他', '其他（祖父母等）', 9
) v
WHERE q.questionnaire_id='questionnaire_child_support_dispute' AND q.question_key='目前抚养关系明确';

-- 4.3 support_dispute（赡养）
INSERT INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
VALUES
('questionnaire_support_dispute','S0','存在赡养关系','存在赡养关系','是否存在赡养关系？','如父母子女、祖父母/外祖父母与孙子女等。','boolean',1,1,1,NULL),
('questionnaire_support_dispute','S0','被赡养人生活困难','被赡养人生活困难','被赡养人是否生活困难或需要赡养支持？','如无稳定收入、患病、失能等。','boolean',1,2,1,NULL),
('questionnaire_support_dispute','S0','赡养人拒绝履行','赡养人拒绝履行','赡养人是否拒绝或未足额履行赡养义务？','如不支付生活费、不探望、不承担医疗费等。','boolean',1,3,1,NULL),

('questionnaire_support_dispute','S1','赡养方式争议','赡养方式争议','主要争议是哪种赡养方式？','生活费/医疗费/护理/探望安排等。','select',0,1,1,NULL),
('questionnaire_support_dispute','S1','被赡养人月基本支出','被赡养人月基本支出','被赡养人月基本支出约多少？','按“元/月”填写。','number',0,2,1,'元/月'),
('questionnaire_support_dispute','S1','赡养人收入能力大致明确','赡养人收入能力大致明确','是否能大致证明赡养人收入能力？','如工资、经营收入、房产/车辆等。','boolean',0,3,1,NULL),
('questionnaire_support_dispute','S1','是否存在多名赡养人','是否存在多名赡养人','是否存在多名赡养义务人需要分担？','如多个子女共同赡养。','boolean',0,4,1,NULL),

('questionnaire_support_dispute','S2','有亲属关系证明','有亲属关系证明','是否有亲属关系证明？','如户口簿、出生证明、村居委证明。','boolean',0,1,1,NULL),
('questionnaire_support_dispute','S2','有医疗或失能证明','有医疗或失能证明','是否有疾病/失能证明材料？','如病历、诊断证明、护理证明。','boolean',0,2,1,NULL),
('questionnaire_support_dispute','S2','有拒绝赡养证据','有拒绝赡养证据','是否有对方拒绝赡养的证据？','如聊天记录、转账记录、录音等。','boolean',0,3,1,NULL)
ON DUPLICATE KEY UPDATE
label=VALUES(label), hint=VALUES(hint), input_type=VALUES(input_type), required=VALUES(required), question_order=VALUES(question_order), enabled=VALUES(enabled), unit=VALUES(unit);

INSERT IGNORE INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, v.option_value, v.option_label, v.option_order, 1
FROM rule_question q
JOIN (
  SELECT '生活费' option_value, '支付赡养生活费' option_label, 0 option_order
  UNION ALL SELECT '医疗费', '承担医疗费用', 1
  UNION ALL SELECT '护理', '护理照料安排', 2
  UNION ALL SELECT '探望', '探望与照护频次', 3
  UNION ALL SELECT '综合', '综合赡养安排', 9
) v
WHERE q.questionnaire_id='questionnaire_support_dispute' AND q.question_key='赡养方式争议';

-- 4.4 inherit_dispute（继承）
INSERT INTO rule_question (questionnaire_id, group_key, question_key, answer_key, label, hint, input_type, required, question_order, enabled, unit)
VALUES
('questionnaire_inherit_dispute','I0','继承已经开始','继承已经开始','被继承人是否已经死亡（继承开始）？','继承从被继承人死亡时开始。','boolean',1,1,1,NULL),
('questionnaire_inherit_dispute','I0','遗产范围大致明确','遗产范围大致明确','遗产范围是否大致明确？','如房产、存款、车辆、股权等。','boolean',0,2,1,NULL),
('questionnaire_inherit_dispute','I0','继承人范围存在争议','继承人范围存在争议','继承人范围是否存在争议？','如是否存在非婚生子女、代位继承等。','boolean',0,3,1,NULL),

('questionnaire_inherit_dispute','I1','是否存在第一顺序继承人','是否存在第一顺序继承人','是否存在第一顺序继承人（配偶、子女、父母）？','决定继承顺序与份额。','boolean',1,1,1,NULL),
('questionnaire_inherit_dispute','I1','是否存在代位继承情形','是否存在代位继承情形','是否存在代位继承情形？','如子女先于被继承人死亡，由其晚辈直系血亲代位继承。','boolean',0,2,1,NULL),
('questionnaire_inherit_dispute','I1','是否存在继承份额争议','是否存在继承份额争议','是否存在继承份额争议？','如是否应多分/少分、照顾无劳动能力者等。','boolean',0,3,1,NULL),

('questionnaire_inherit_dispute','I2','是否存在遗嘱','是否存在遗嘱','是否存在遗嘱或遗赠扶养协议？','如自书遗嘱、公证遗嘱、代书遗嘱等。','boolean',0,1,1,NULL),
('questionnaire_inherit_dispute','I2','遗嘱形式是否合法','遗嘱形式是否合法','遗嘱形式是否可能存在瑕疵？','如见证人资格、签名日期、全文是否自书等。','boolean',0,2,1,NULL),
('questionnaire_inherit_dispute','I2','是否存在遗嘱效力争议','是否存在遗嘱效力争议','是否存在遗嘱效力争议？','如伪造、胁迫、欺诈、无民事行为能力等。','boolean',0,3,1,NULL),
('questionnaire_inherit_dispute','I2','有遗嘱原件或保管线索','有遗嘱原件或保管线索','是否有遗嘱原件或明确保管线索？','如公证处、律师处、家庭保管。','boolean',0,4,1,NULL)
ON DUPLICATE KEY UPDATE
label=VALUES(label), hint=VALUES(hint), input_type=VALUES(input_type), required=VALUES(required), question_order=VALUES(question_order), enabled=VALUES(enabled), unit=VALUES(unit);

-- 5) 法条资产（补充核心条文摘要；正文可后续由 refine 脚本补齐）
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
('law_1067', '中华人民共和国民法典', '第一千零六十七条', '父母对子女的抚养义务与子女对父母的赡养义务', '父母不履行抚养义务的，未成年子女或者不能独立生活的成年子女，有要求父母给付抚养费的权利。子女不履行赡养义务的，缺乏劳动能力或者生活困难的父母，有要求子女给付赡养费的权利。', NOW()),
('law_1085', '中华人民共和国民法典', '第一千零八十五条', '离婚后子女抚养费负担', '离婚后，子女由一方直接抚养的，另一方应当负担部分或者全部抚养费。', NOW()),
('law_1127', '中华人民共和国民法典', '第一千一百二十七条', '法定继承人的范围与顺序', '遗产按照下列顺序继承：第一顺序：配偶、子女、父母；第二顺序：兄弟姐妹、祖父母、外祖父母。', NOW()),
('law_1130', '中华人民共和国民法典', '第一千一百三十条', '同一顺序继承份额一般均等', '同一顺序继承人继承遗产的份额，一般应当均等。', NOW()),
('law_1133', '中华人民共和国民法典', '第一千一百三十三条', '遗嘱处分与遗嘱形式', '自然人可以依照本法规定立遗嘱处分个人财产。', NOW())
ON DUPLICATE KEY UPDATE
name=VALUES(name), article=VALUES(article), summary=VALUES(summary), text=VALUES(text), updated_at=VALUES(updated_at);

-- 6) 案由-法条映射
INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order) VALUES
('property_dispute','law_1042',1),('property_dispute','law_jshj_5',2),
('child_support_dispute','law_1067',1),('child_support_dispute','law_1085',2),
('support_dispute','law_1067',1),
('inherit_dispute','law_1127',1),('inherit_dispute','law_1130',2),('inherit_dispute','law_1133',3);

-- 7) Step2 目标（每案由 2-3 个）
INSERT INTO rule_step2_target (target_id, title, descr, enabled) VALUES
('target_property_refund', '主张返还彩礼/婚约财产', '围绕法定返还情形、金额与证据主张返还。', 1),
('target_property_no_refund', '抗辩不予/少予返还', '围绕登记、共同生活等事实抗辩不返还或少返还。', 1),

('target_child_support_claim_fee', '主张抚养费', '围绕抚养费标准、支出与对方收入能力主张给付。', 1),
('target_child_support_change_custody', '主张变更抚养关系', '围绕法定变更情形与有利于子女成长证据主张变更。', 1),

('target_support_claim', '主张赡养费/赡养安排', '围绕生活困难、支出与赡养人能力主张赡养。', 1),

('target_inherit_confirm_share', '确认继承人及份额', '围绕继承顺序、份额、代位继承等确认权利。', 1),
('target_inherit_dispute_will', '遗嘱效力争议处理', '围绕遗嘱形式与效力争议组织主张。', 1)
ON DUPLICATE KEY UPDATE title=VALUES(title), descr=VALUES(descr), enabled=VALUES(enabled);

-- 7.1 目标-法条引用
INSERT IGNORE INTO rule_step2_target_legal_ref (target_id, law_id, sort_order) VALUES
('target_property_refund','law_jshj_5',1),('target_property_refund','law_1042',2),
('target_property_no_refund','law_jshj_5',1),
('target_child_support_claim_fee','law_1085',1),('target_child_support_claim_fee','law_1067',2),
('target_child_support_change_custody','law_1085',1),
('target_support_claim','law_1067',1),
('target_inherit_confirm_share','law_1127',1),('target_inherit_confirm_share','law_1130',2),
('target_inherit_dispute_will','law_1133',1);

-- 7.2 案由-目标映射
INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order) VALUES
('property_dispute','target_property_refund',1),
('property_dispute','target_property_no_refund',2),
('child_support_dispute','target_child_support_claim_fee',1),
('child_support_dispute','target_child_support_change_custody',2),
('support_dispute','target_support_claim',1),
('inherit_dispute','target_inherit_confirm_share',1),
('inherit_dispute','target_inherit_dispute_will',2);

-- 7.3 目标-必要事实（用于 Step2 证据指引）
INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled) VALUES
('target_property_refund','存在彩礼或财产给付','存在给付事实',1,1),
('target_property_refund','是否存在法定返还情形','存在法定返还情形',2,1),
('target_property_refund','给付金额','给付金额明确',3,1),
('target_property_no_refund','是否已办理结婚登记','已办理结婚登记',1,1),
('target_property_no_refund','是否已共同生活','已共同生活',2,1),

('target_child_support_claim_fee','存在亲子关系','存在亲子关系',1,1),
('target_child_support_claim_fee','对方未支付抚养费','存在欠付或不足',2,1),
('target_child_support_claim_fee','孩子实际月支出','支出大致明确',3,1),
('target_child_support_change_custody','是否主张变更抚养关系','提出变更主张',1,1),
('target_child_support_change_custody','变更原因属于法定情形','符合变更法定情形',2,1),

('target_support_claim','存在赡养关系','存在赡养关系',1,1),
('target_support_claim','被赡养人生活困难','生活困难/需要支持',2,1),
('target_support_claim','赡养人拒绝履行','拒绝/不足履行',3,1),

('target_inherit_confirm_share','继承已经开始','继承开始（死亡）',1,1),
('target_inherit_confirm_share','遗产范围大致明确','遗产线索明确',2,1),
('target_inherit_dispute_will','是否存在遗嘱','存在遗嘱或协议',1,1),
('target_inherit_dispute_will','是否存在遗嘱效力争议','存在效力争议',2,1);

-- 7.4 目标-证据类型（简版但可用）
INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled) VALUES
('target_property_refund','存在彩礼或财产给付','转账记录/收条',1,0,1),
('target_property_refund','是否存在法定返还情形','未登记/共同生活证据',1,0,1),
('target_property_refund','给付金额','金额明细/聊天记录',1,0,1),
('target_child_support_claim_fee','存在亲子关系','出生证明/户口簿/亲子鉴定',1,0,1),
('target_child_support_claim_fee','对方未支付抚养费','转账记录/聊天记录/执行材料',1,0,1),
('target_child_support_claim_fee','孩子实际月支出','学费票据/医疗票据/生活支出凭证',1,0,1),
('target_child_support_change_custody','变更原因属于法定情形','学校/医疗/报警/社区证明',1,0,1),
('target_support_claim','存在赡养关系','亲属关系证明',1,0,1),
('target_support_claim','被赡养人生活困难','收入证明/病历/失能证明',1,0,1),
('target_support_claim','赡养人拒绝履行','聊天记录/录音/转账记录',1,0,1),
('target_inherit_confirm_share','继承已经开始','死亡证明/户籍注销证明',1,0,1),
('target_inherit_confirm_share','遗产范围大致明确','房产证/银行流水/车辆登记/股权资料',1,0,1),
('target_inherit_dispute_will','是否存在遗嘱','遗嘱原件/保管线索',1,0,1),
('target_inherit_dispute_will','是否存在遗嘱效力争议','见证人材料/鉴定/录音录像',1,0,1);

-- 8) 判定规则（简化但完整跑通：给出结论 + 建议诉请 + 法条依据）
-- 8.1 conclusion 定义
INSERT INTO rule_judge_conclusion (conclusion_id, type, result, reason, level, law_refs_json, final_item, final_result, final_detail, enabled)
VALUES
('c_property_refund_support','conclusion','支持主张返还彩礼/婚约财产','存在给付且满足法定返还情形，建议主张返还。','success','[\"law_jshj_5\",\"law_1042\"]','返还彩礼/婚约财产','可主张返还','围绕给付凭证、登记/共同生活、困难等举证',1),
('c_property_refund_defense','conclusion','存在不返还/少返还抗辩点','已登记且长期共同生活等情形下可抗辩不返还或少返还。','warning','[\"law_jshj_5\"]','抗辩返还请求','可抗辩不返还/少返还','围绕共同生活时间、过错、返还比例举证',1),

('c_child_support_fee','conclusion','可主张抚养费','对方未履行抚养义务或金额不足时，可主张抚养费。','success','[\"law_1085\",\"law_1067\"]','支付抚养费','可主张抚养费','结合子女实际支出与对方收入能力确定金额',1),
('c_child_support_change','conclusion','具备变更抚养关系可能','符合变更抚养法定情形且更有利于子女成长的，可主张变更。','warning','[\"law_1085\"]','变更抚养关系','可主张变更','重点证明法定情形与子女利益最大化',1),

('c_support_fee','conclusion','可主张赡养费/赡养安排','被赡养人生活困难且赡养人不履行义务的，可主张赡养。','success','[\"law_1067\"]','支付赡养费','可主张赡养费','结合生活支出与赡养人能力确定金额',1),

('c_inherit_share','conclusion','可主张确认继承份额','继承开始且遗产线索存在时，可主张确认继承人及份额并分割。','success','[\"law_1127\",\"law_1130\"]','确认继承份额','可主张确认并分割','围绕继承人范围、遗产清单、份额证据',1),
('c_inherit_will_dispute','conclusion','存在遗嘱效力争议处理空间','存在遗嘱且有形式/意思表示瑕疵线索时，可主张确认遗嘱效力或撤销。','warning','[\"law_1133\"]','遗嘱效力争议','可主张确认/撤销','围绕遗嘱形式、见证、鉴定等举证',1)
ON DUPLICATE KEY UPDATE
result=VALUES(result), reason=VALUES(reason), level=VALUES(level), law_refs_json=VALUES(law_refs_json),
final_item=VALUES(final_item), final_result=VALUES(final_result), final_detail=VALUES(final_detail), enabled=VALUES(enabled);

-- 8.2 rule 定义
INSERT INTO rule_judge_rule (rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled)
VALUES
('r_property_refund_support','property_dispute','返还支持路径','返还支持命中','与','law_jshj_5',10,
 '{\"op\":\"and\",\"children\":[{\"fact\":\"存在彩礼或财产给付\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"是否存在法定返还情形\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_property_refund_defense','property_dispute','不返还抗辩路径','不返还抗辩命中','与','law_jshj_5',20,
 '{\"op\":\"and\",\"children\":[{\"fact\":\"是否已办理结婚登记\",\"cmp\":\"eq\",\"value\":\"已登记\"},{\"fact\":\"是否已共同生活\",\"cmp\":\"eq\",\"value\":true}]}',1),

('r_child_support_fee','child_support_dispute','抚养费主张路径','抚养费命中','与','law_1085',10,
 '{\"op\":\"and\",\"children\":[{\"fact\":\"存在亲子关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"对方未支付抚养费\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_child_support_change','child_support_dispute','变更抚养路径','变更抚养命中','与','law_1085',30,
 '{\"op\":\"and\",\"children\":[{\"fact\":\"是否主张变更抚养关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"变更原因属于法定情形\",\"cmp\":\"eq\",\"value\":true}]}',1),

('r_support_fee','support_dispute','赡养费主张路径','赡养费命中','与','law_1067',10,
 '{\"op\":\"and\",\"children\":[{\"fact\":\"存在赡养关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"被赡养人生活困难\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"赡养人拒绝履行\",\"cmp\":\"eq\",\"value\":true}]}',1),

('r_inherit_share','inherit_dispute','继承份额确认路径','继承份额命中','与','law_1127',10,
 '{\"op\":\"and\",\"children\":[{\"fact\":\"继承已经开始\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"遗产范围大致明确\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_inherit_will_dispute','inherit_dispute','遗嘱效力争议路径','遗嘱争议命中','与','law_1133',30,
 '{\"op\":\"and\",\"children\":[{\"fact\":\"是否存在遗嘱\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"是否存在遗嘱效力争议\",\"cmp\":\"eq\",\"value\":true}]}',1)
ON DUPLICATE KEY UPDATE
rule_name=VALUES(rule_name), path_name=VALUES(path_name), calc_expr=VALUES(calc_expr), law_ref=VALUES(law_ref),
priority=VALUES(priority), condition_json=VALUES(condition_json), enabled=VALUES(enabled);

-- 8.3 rule -> conclusion 绑定
INSERT IGNORE INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order) VALUES
('r_property_refund_support','c_property_refund_support',1),
('r_property_refund_defense','c_property_refund_defense',1),
('r_child_support_fee','c_child_support_fee',1),
('r_child_support_change','c_child_support_change',1),
('r_support_fee','c_support_fee',1),
('r_inherit_share','c_inherit_share',1),
('r_inherit_will_dispute','c_inherit_will_dispute',1);

SET FOREIGN_KEY_CHECKS = 1;

