USE rule_engine_db;
SET NAMES utf8mb4;

-- 婚姻家庭案由精细化（问卷 + Step2）
-- 原则：
-- 1) 增量升级，不覆盖基础补齐脚本的整体结构。
-- 2) 优先让 question_key == fact_key，直接复用 FactExtractorService fallback。
-- 3) 先精细化第一批 6 个案由，再补第二批 4 个、第三批 3 个。

-- =========================================================
-- A. 第一批 6 个案由：补充更细问卷题目
-- =========================================================

INSERT INTO rule_question_group (questionnaire_id, group_key, group_order, enabled, group_name, group_desc, icon)
VALUES
('questionnaire_marriage_invalid_dispute','G3',3,1,'精细化要件','细化婚姻无效法定事由、请求人资格及后续安排','🔎'),
('questionnaire_marriage_annulment_dispute','G3',3,1,'精细化要件','细化撤销事由、期间、损害赔偿及后续安排','🔎'),
('questionnaire_post_divorce_damage_liability_dispute','G3',3,1,'精细化要件','细化过错类型、后果、程序与赔偿范围','🔎'),
('questionnaire_paternity_confirmation_dispute','G3',3,1,'精细化要件','细化亲子确认中的鉴定配合、出生登记和举证妨碍','🔎'),
('questionnaire_paternity_disclaimer_dispute','G3',3,1,'精细化要件','细化亲子否认中的鉴定配合、出生登记和举证妨碍','🔎'),
('questionnaire_adoption_dispute','G3',3,1,'精细化要件','细化收养路径、照护能力、协议材料及解除后安排','🔎')
ON DUPLICATE KEY UPDATE
  group_order = VALUES(group_order),
  enabled = VALUES(enabled),
  group_name = VALUES(group_name),
  group_desc = VALUES(group_desc),
  icon = VALUES(icon);

INSERT INTO rule_question (
  questionnaire_id, group_key, question_key, answer_key, label, hint,
  input_type, required, question_order, enabled, unit
)
VALUES
-- marriage_invalid_dispute
('questionnaire_marriage_invalid_dispute','G3','无效事由类型','无效事由类型','无效事由类型','请选择最主要的无效事由','choice',1,1,1,NULL),
('questionnaire_marriage_invalid_dispute','G3','存在在先婚姻未解除事实','存在在先婚姻未解除事实','存在在先婚姻未解除事实','是否存在一方在先婚姻尚未解除即再次结婚','boolean',0,2,1,NULL),
('questionnaire_marriage_invalid_dispute','G3','属于禁止结婚亲属关系','属于禁止结婚亲属关系','属于禁止结婚亲属关系','是否属于法律禁止结婚的近亲属关系','boolean',0,3,1,NULL),
('questionnaire_marriage_invalid_dispute','G3','结婚时未达法定婚龄','结婚时未达法定婚龄','结婚时未达法定婚龄','登记结婚时是否未达法定婚龄','boolean',0,4,1,NULL),
('questionnaire_marriage_invalid_dispute','G3','请求人为利害关系人','请求人为利害关系人','请求人为利害关系人','提起诉请的一方是否属于法定利害关系人','boolean',1,5,1,NULL),
('questionnaire_marriage_invalid_dispute','G3','是否同时主张财产处理','是否同时主张财产处理','是否同时主张财产处理','是否一并主张同居期间财产返还或分割安排','boolean',0,6,1,NULL),
('questionnaire_marriage_invalid_dispute','G3','是否同时主张子女安排','是否同时主张子女安排','是否同时主张子女安排','是否一并涉及未成年子女抚养安排','boolean',0,7,1,NULL),

-- marriage_annulment_dispute
('questionnaire_marriage_annulment_dispute','G3','撤销事由类型','撤销事由类型','撤销事由类型','请选择最主要的撤销事由','choice',1,1,1,NULL),
('questionnaire_marriage_annulment_dispute','G3','存在胁迫结婚事实','存在胁迫结婚事实','存在胁迫结婚事实','是否存在以暴力、威胁、控制等方式迫使结婚','boolean',0,2,1,NULL),
('questionnaire_marriage_annulment_dispute','G3','婚前隐瞒重大疾病','婚前隐瞒重大疾病','婚前隐瞒重大疾病','是否存在婚前隐瞒重大疾病的情形','boolean',0,3,1,NULL),
('questionnaire_marriage_annulment_dispute','G3','在法定期间内提出撤销请求','在法定期间内提出撤销请求','在法定期间内提出撤销请求','撤销请求是否仍在法定期间内','boolean',1,4,1,NULL),
('questionnaire_marriage_annulment_dispute','G3','知道撤销事由时间明确','知道撤销事由时间明确','知道撤销事由时间明确','是否能明确知道胁迫终止或知晓疾病隐瞒的时间','boolean',0,5,1,NULL),
('questionnaire_marriage_annulment_dispute','G3','主张撤销后损害赔偿','主张撤销后损害赔偿','主张撤销后损害赔偿','是否一并主张撤销婚姻后的损害赔偿','boolean',0,6,1,NULL),
('questionnaire_marriage_annulment_dispute','G3','存在撤销后财产返还问题','存在撤销后财产返还问题','存在撤销后财产返还问题','撤销后是否存在彩礼、财产返还或分割问题','boolean',0,7,1,NULL),
('questionnaire_marriage_annulment_dispute','G3','存在撤销后子女抚养安排问题','存在撤销后子女抚养安排问题','存在撤销后子女抚养安排问题','撤销后是否需要处理未成年子女抚养安排','boolean',0,8,1,NULL),

-- post_divorce_damage_liability_dispute
('questionnaire_post_divorce_damage_liability_dispute','G3','过错类型','过错类型','过错类型','请选择主要过错或侵害类型','choice',1,1,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G3','损害后果类型','损害后果类型','损害后果类型','请选择主要损害后果类型','choice',1,2,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G3','离婚程序中是否已处理损害赔偿','离婚程序中是否已处理损害赔偿','离婚程序中是否已处理损害赔偿','离婚诉讼或协议阶段是否已处理过该赔偿问题','choice',1,3,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G3','赔偿金额或范围明确','赔偿金额或范围明确','赔偿金额或范围明确','能否明确主张的赔偿金额、区间或组成部分','boolean',1,4,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G3','存在因果关系材料','存在因果关系材料','存在因果关系材料','是否有材料证明过错行为与损害后果之间的因果关系','boolean',1,5,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G3','存在持续治疗材料','存在持续治疗材料','存在持续治疗材料','是否存在持续治疗、复诊、用药等材料','boolean',0,6,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G3','存在误工收入损失材料','存在误工收入损失材料','存在误工收入损失材料','是否存在误工、停工、收入下降等证据材料','boolean',0,7,1,NULL),

-- paternity_confirmation_dispute
('questionnaire_paternity_confirmation_dispute','G3','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定','对方是否拒绝提交样本、不到场或拖延鉴定','boolean',0,1,1,NULL),
('questionnaire_paternity_confirmation_dispute','G3','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录','是否有怀孕、生育期间的聊天、转账、探望等记录','boolean',0,2,1,NULL),
('questionnaire_paternity_confirmation_dispute','G3','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录','是否有长期共同生活、共同抚养或探望照料记录','boolean',0,3,1,NULL),
('questionnaire_paternity_confirmation_dispute','G3','出生登记信息与确认主张一致','出生登记信息与确认主张一致','出生登记信息与确认主张一致','出生医学证明、户籍登记等是否与确认主张一致','boolean',0,4,1,NULL),
('questionnaire_paternity_confirmation_dispute','G3','存在举证妨碍线索','存在举证妨碍线索','存在举证妨碍线索','是否存在隐匿样本、拒不配合调查等举证妨碍行为','boolean',0,5,1,NULL),

-- paternity_disclaimer_dispute
('questionnaire_paternity_disclaimer_dispute','G3','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定','对方是否拒绝提交样本、不到场或拖延鉴定','boolean',0,1,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G3','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录','是否有怀孕、生育期间的聊天、转账、探望等记录','boolean',0,2,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G3','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录','是否有长期共同生活、共同抚养或探望照料记录','boolean',0,3,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G3','出生登记信息与否认主张不一致','出生登记信息与否认主张不一致','出生登记信息与否认主张不一致','出生医学证明、户籍登记等是否与否认主张不一致','boolean',0,4,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G3','存在举证妨碍线索','存在举证妨碍线索','存在举证妨碍线索','是否存在隐匿样本、拒不配合调查等举证妨碍行为','boolean',0,5,1,NULL),

-- adoption_dispute
('questionnaire_adoption_dispute','G3','收养路径类型','收养路径类型','收养路径类型','请选择登记收养、事实收养或解除收养','choice',1,1,1,NULL),
('questionnaire_adoption_dispute','G3','收养人具备长期抚养能力','收养人具备长期抚养能力','收养人具备长期抚养能力','收养人是否具备稳定收入、居住和照护能力','boolean',0,2,1,NULL),
('questionnaire_adoption_dispute','G3','存在送养同意或协议材料','存在送养同意或协议材料','存在送养同意或协议材料','是否存在送养人同意、收养协议或相关文书','boolean',0,3,1,NULL),
('questionnaire_adoption_dispute','G3','解除原因类型','解除原因类型','解除原因类型','请选择解除收养的主要原因','choice',0,4,1,NULL),
('questionnaire_adoption_dispute','G3','解除后未成年人抚养安排明确','解除后未成年人抚养安排明确','解除后未成年人抚养安排明确','解除收养后未成年人由谁照顾、费用如何承担是否明确','boolean',0,5,1,NULL),
('questionnaire_adoption_dispute','G3','存在长期共同生活情况','存在长期共同生活情况','存在长期共同生活情况','是否长期以父母子女身份共同生活、照料和教育','boolean',0,6,1,NULL)
ON DUPLICATE KEY UPDATE
  label = VALUES(label),
  hint = VALUES(hint),
  input_type = VALUES(input_type),
  required = VALUES(required),
  question_order = VALUES(question_order),
  enabled = VALUES(enabled),
  unit = VALUES(unit);

INSERT INTO rule_question_option (question_id, option_value, option_label, option_order, enabled)
SELECT q.id, o.option_value, o.option_label, o.option_order, 1
FROM rule_question q
JOIN (
  SELECT 'questionnaire_marriage_invalid_dispute' AS questionnaire_id, '无效事由类型' AS question_key, 'prior_marriage' AS option_value, '存在在先婚姻未解除' AS option_label, 1 AS option_order
  UNION ALL SELECT 'questionnaire_marriage_invalid_dispute','无效事由类型','prohibited_kinship','属于禁止结婚亲属关系',2
  UNION ALL SELECT 'questionnaire_marriage_invalid_dispute','无效事由类型','underage','结婚时未达法定婚龄',3
  UNION ALL SELECT 'questionnaire_marriage_invalid_dispute','无效事由类型','other','其他法定无效事由线索',4
  UNION ALL SELECT 'questionnaire_marriage_annulment_dispute','撤销事由类型','coercion','胁迫结婚',1
  UNION ALL SELECT 'questionnaire_marriage_annulment_dispute','撤销事由类型','concealed_disease','婚前隐瞒重大疾病',2
  UNION ALL SELECT 'questionnaire_marriage_annulment_dispute','撤销事由类型','other','其他可撤销事由线索',3
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','过错类型','bigamy','重婚',1
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','过错类型','cohabitation','与他人同居',2
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','过错类型','domestic_violence','家庭暴力',3
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','过错类型','abuse_abandonment','虐待遗弃',4
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','过错类型','other_tort','其他侵害行为',5
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','损害后果类型','mental','精神损害',1
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','损害后果类型','medical','治疗费用',2
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','损害后果类型','income_loss','误工收入损失',3
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','损害后果类型','mixed','多项损害并存',4
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','离婚程序中是否已处理损害赔偿','handled_yes','已处理',1
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','离婚程序中是否已处理损害赔偿','handled_no','未处理',2
  UNION ALL SELECT 'questionnaire_post_divorce_damage_liability_dispute','离婚程序中是否已处理损害赔偿','unclear','暂不明确',3
  UNION ALL SELECT 'questionnaire_adoption_dispute','收养路径类型','registered','登记收养',1
  UNION ALL SELECT 'questionnaire_adoption_dispute','收养路径类型','de_facto','事实收养',2
  UNION ALL SELECT 'questionnaire_adoption_dispute','收养路径类型','dissolution','解除收养',3
  UNION ALL SELECT 'questionnaire_adoption_dispute','解除原因类型','relationship_breakdown','关系恶化无法共同生活',1
  UNION ALL SELECT 'questionnaire_adoption_dispute','解除原因类型','failure_support','不尽抚养义务',2
  UNION ALL SELECT 'questionnaire_adoption_dispute','解除原因类型','abuse','虐待遗弃或严重侵害',3
  UNION ALL SELECT 'questionnaire_adoption_dispute','解除原因类型','other','其他严重原因',4
) o
  ON q.questionnaire_id = o.questionnaire_id
 AND q.question_key = o.question_key
LEFT JOIN rule_question_option ro
  ON ro.question_id = q.id
 AND ro.option_value = o.option_value
WHERE ro.question_id IS NULL;

-- =========================================================
-- B. 第二批 4 个案由：补充关键问卷题目
-- =========================================================
INSERT INTO rule_question_group (questionnaire_id, group_key, group_order, enabled, group_name, group_desc, icon)
VALUES
('questionnaire_guardianship_dispute','G3',3,1,'精细化要件','细化主体资格、照护能力和财产管理需求','🔎'),
('questionnaire_visitation_dispute','G3',3,1,'精细化要件','细化子女意愿、探望方式与中止风险','🔎'),
('questionnaire_sibling_support_dispute','G3',3,1,'精细化要件','细化无劳动能力、医疗护理、多义务人与费用主张','🔎'),
('questionnaire_spousal_property_agreement_dispute','G3',3,1,'精细化要件','细化协议签署时间、书面性、公证及效力抗辩','🔎')
ON DUPLICATE KEY UPDATE
  group_order = VALUES(group_order),
  enabled = VALUES(enabled),
  group_name = VALUES(group_name),
  group_desc = VALUES(group_desc),
  icon = VALUES(icon);

INSERT INTO rule_question (
  questionnaire_id, group_key, question_key, answer_key, label, hint,
  input_type, required, question_order, enabled, unit
)
VALUES
('questionnaire_guardianship_dispute','G3','申请人主体资格明确','申请人主体资格明确','申请人主体资格明确','是否能明确申请人与被监护人的法定顺位或近亲属关系','boolean',1,1,1,NULL),
('questionnaire_guardianship_dispute','G3','申请人照护能力较强','申请人照护能力较强','申请人照护能力较强','申请人是否具备稳定照护、收入和居住条件','boolean',0,2,1,NULL),
('questionnaire_guardianship_dispute','G3','存在居委村委或民政意见','存在居委村委或民政意见','存在居委村委或民政意见','是否已有基层组织或民政部门意见材料','boolean',0,3,1,NULL),
('questionnaire_guardianship_dispute','G3','存在财产管理需求','存在财产管理需求','存在财产管理需求','是否同时涉及被监护人财产管理或保护需求','boolean',0,4,1,NULL),

('questionnaire_visitation_dispute','G3','子女已满八周岁','子女已满八周岁','子女已满八周岁','子女是否已满八周岁','boolean',0,1,1,NULL),
('questionnaire_visitation_dispute','G3','子女有明确探望意愿','子女有明确探望意愿','子女有明确探望意愿','子女是否表达了愿意或不愿意探望的意见','boolean',0,2,1,NULL),
('questionnaire_visitation_dispute','G3','主张节假日或住宿探望','主张节假日或住宿探望','主张节假日或住宿探望','是否主张节假日、寒暑假或住宿探望安排','boolean',0,3,1,NULL),
('questionnaire_visitation_dispute','G3','存在中止探望风险线索','存在中止探望风险线索','存在中止探望风险线索','是否存在暴力、酗酒、严重不利于未成年人的风险线索','boolean',0,4,1,NULL),
('questionnaire_visitation_dispute','G3','既有探望频率安排明确','既有探望频率安排明确','既有探望频率安排明确','是否已有明确的探望频率、时长或接送安排','boolean',0,5,1,NULL),

('questionnaire_sibling_support_dispute','G3','被扶养人无劳动能力或患病','被扶养人无劳动能力或患病','被扶养人无劳动能力或患病','是否存在失能、重病、高龄等情形','boolean',0,1,1,NULL),
('questionnaire_sibling_support_dispute','G3','存在重大医疗护理支出','存在重大医疗护理支出','存在重大医疗护理支出','是否存在长期治疗、住院或护理支出','boolean',0,2,1,NULL),
('questionnaire_sibling_support_dispute','G3','存在多名扶养义务人','存在多名扶养义务人','存在多名扶养义务人','是否有多名兄弟姐妹共同承担扶养义务','boolean',0,3,1,NULL),
('questionnaire_sibling_support_dispute','G3','月扶养费金额明确','月扶养费金额明确','月扶养费金额明确','是否能明确主张的月扶养费金额或计算方式','boolean',0,4,1,NULL),
('questionnaire_sibling_support_dispute','G3','已有长期照料一方','已有长期照料一方','已有长期照料一方','是否已有一方长期承担主要照料责任','boolean',0,5,1,NULL),

('questionnaire_spousal_property_agreement_dispute','G3','协议签署时间明确','协议签署时间明确','协议签署时间明确','是否能明确协议签署于婚前或婚后何时','boolean',0,1,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G3','存在书面协议文本','存在书面协议文本','存在书面协议文本','是否有书面协议、签字页或电子文本','boolean',1,2,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G3','争议财产类型明确','争议财产类型明确','争议财产类型明确','是否能明确争议标的为房产、股权、存款等','boolean',0,3,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G3','已办理公证或登记','已办理公证或登记','已办理公证或登记','是否对协议做过公证、登记或备案','boolean',0,4,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G3','存在受胁迫欺诈等效力抗辩','存在受胁迫欺诈等效力抗辩','存在受胁迫欺诈等效力抗辩','是否存在胁迫、欺诈、重大误解等效力抗辩','boolean',0,5,1,NULL)
ON DUPLICATE KEY UPDATE
  label = VALUES(label),
  hint = VALUES(hint),
  input_type = VALUES(input_type),
  required = VALUES(required),
  question_order = VALUES(question_order),
  enabled = VALUES(enabled),
  unit = VALUES(unit);

-- =========================================================
-- C. 第三批 3 个案由：补充关键问卷题目
-- =========================================================
INSERT INTO rule_question_group (questionnaire_id, group_key, group_order, enabled, group_name, group_desc, icon)
VALUES
('questionnaire_in_marriage_property_division_dispute','G3',3,1,'精细化要件','细化财产类型、转移方式、支出影响与挥霍情况','🔎'),
('questionnaire_cohabitation_dispute','G3',3,1,'精细化要件','细化同居期间、共同购置、出资比例及子女支出','🔎'),
('questionnaire_family_partition_dispute','G3',3,1,'精细化要件','细化成员范围、分家状态、占有使用和出资来源','🔎')
ON DUPLICATE KEY UPDATE
  group_order = VALUES(group_order),
  enabled = VALUES(enabled),
  group_name = VALUES(group_name),
  group_desc = VALUES(group_desc),
  icon = VALUES(icon);

INSERT INTO rule_question (
  questionnaire_id, group_key, question_key, answer_key, label, hint,
  input_type, required, question_order, enabled, unit
)
VALUES
('questionnaire_in_marriage_property_division_dispute','G3','争议财产类型明确','争议财产类型明确','争议财产类型明确','是否能明确争议财产为房产、存款、股权等','boolean',0,1,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G3','转移方式已可说明','转移方式已可说明','转移方式已可说明','是否能说明转移、变卖、隐匿的具体方式','boolean',0,2,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G3','医疗支出金额大致明确','医疗支出金额大致明确','医疗支出金额大致明确','是否能说明重大医疗支出的大致金额','boolean',0,3,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G3','已影响家庭基本生活','已影响家庭基本生活','已影响家庭基本生活','相关行为或支出是否已经影响家庭基本生活','boolean',0,4,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G3','挥霍金额或次数可说明','挥霍金额或次数可说明','挥霍金额或次数可说明','是否能说明挥霍行为的金额、次数或时间段','boolean',0,5,1,NULL),

('questionnaire_cohabitation_dispute','G3','同居起止时间明确','同居起止时间明确','同居起止时间明确','是否能大致明确同居开始和结束时间','boolean',0,1,1,NULL),
('questionnaire_cohabitation_dispute','G3','共同购置房车或大额财物','共同购置房车或大额财物','共同购置房车或大额财物','是否共同购置房屋、车辆或其他大额财物','boolean',0,2,1,NULL),
('questionnaire_cohabitation_dispute','G3','一方出资比例明显更高','一方出资比例明显更高','一方出资比例明显更高','是否存在一方明显主要出资','boolean',0,3,1,NULL),
('questionnaire_cohabitation_dispute','G3','主张子女直接抚养安排','主张子女直接抚养安排','主张子女直接抚养安排','是否同时主张确定子女直接抚养关系','boolean',0,4,1,NULL),
('questionnaire_cohabitation_dispute','G3','孩子月支出明确','孩子月支出明确','孩子月支出明确','是否能明确孩子每月生活、教育、医疗支出','boolean',0,5,1,NULL),

('questionnaire_family_partition_dispute','G3','家庭成员范围明确','家庭成员范围明确','家庭成员范围明确','是否已明确参与分家的家庭成员范围','boolean',0,1,1,NULL),
('questionnaire_family_partition_dispute','G3','已实际分家','已实际分家','已实际分家','是否已实际分灶、分居、分开经营生活','boolean',0,2,1,NULL),
('questionnaire_family_partition_dispute','G3','存在长期占有使用一方','存在长期占有使用一方','存在长期占有使用一方','是否存在某一成员长期占有、管理、使用财产','boolean',0,3,1,NULL),
('questionnaire_family_partition_dispute','G3','财产登记名义明确','财产登记名义明确','财产登记名义明确','涉案财产登记在谁名下是否清楚','boolean',0,4,1,NULL),
('questionnaire_family_partition_dispute','G3','主要出资来源明确','主要出资来源明确','主要出资来源明确','是否能说明建房、购置、装修等主要出资来源','boolean',0,5,1,NULL)
ON DUPLICATE KEY UPDATE
  label = VALUES(label),
  hint = VALUES(hint),
  input_type = VALUES(input_type),
  required = VALUES(required),
  question_order = VALUES(question_order),
  enabled = VALUES(enabled),
  unit = VALUES(unit);

-- =========================================================
-- D. 第一批 6 个案由：细化既有 Step2 target 的 required_fact / evidence_type
-- =========================================================

DELETE FROM rule_step2_required_fact
WHERE target_id IN (
  'target_invalid_marriage_confirm',
  'target_invalid_marriage_property_return',
  'target_annulment_request',
  'target_annulment_effects',
  'target_post_divorce_damage_spirit',
  'target_post_divorce_damage_economic',
  'target_paternity_confirm',
  'target_paternity_confirm_evidence',
  'target_paternity_disclaimer',
  'target_paternity_disclaimer_evidence',
  'target_adoption_confirm',
  'target_adoption_dissolve'
);

INSERT INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled)
VALUES
-- marriage_invalid_dispute
('target_invalid_marriage_confirm','无效事由类型','无效事由类型',1,1),
('target_invalid_marriage_confirm','请求人为利害关系人','请求人为利害关系人',2,1),
('target_invalid_marriage_confirm','存在在先婚姻未解除事实','存在在先婚姻未解除事实',3,1),
('target_invalid_marriage_confirm','属于禁止结婚亲属关系','属于禁止结婚亲属关系',4,1),
('target_invalid_marriage_confirm','结婚时未达法定婚龄','结婚时未达法定婚龄',5,1),
('target_invalid_marriage_confirm','有证据材料可补强','有证据材料可补强',6,1),

('target_invalid_marriage_property_return','是否同时主张财产处理','是否同时主张财产处理',1,1),
('target_invalid_marriage_property_return','是否同时主张子女安排','是否同时主张子女安排',2,1),
('target_invalid_marriage_property_return','是否已办理结婚登记','是否已办理结婚登记',3,1),
('target_invalid_marriage_property_return','有证据材料可补强','有证据材料可补强',4,1),

-- marriage_annulment_dispute
('target_annulment_request','撤销事由类型','撤销事由类型',1,1),
('target_annulment_request','存在胁迫结婚事实','存在胁迫结婚事实',2,1),
('target_annulment_request','婚前隐瞒重大疾病','婚前隐瞒重大疾病',3,1),
('target_annulment_request','在法定期间内提出撤销请求','在法定期间内提出撤销请求',4,1),
('target_annulment_request','知道撤销事由时间明确','知道撤销事由时间明确',5,1),
('target_annulment_request','有证据材料可补强','有证据材料可补强',6,1),

('target_annulment_effects','主张撤销后损害赔偿','主张撤销后损害赔偿',1,1),
('target_annulment_effects','存在撤销后财产返还问题','存在撤销后财产返还问题',2,1),
('target_annulment_effects','存在撤销后子女抚养安排问题','存在撤销后子女抚养安排问题',3,1),
('target_annulment_effects','有证据材料可补强','有证据材料可补强',4,1),

-- post_divorce_damage_liability_dispute
('target_post_divorce_damage_spirit','过错类型','过错类型',1,1),
('target_post_divorce_damage_spirit','损害后果类型','损害后果类型',2,1),
('target_post_divorce_damage_spirit','离婚程序中是否已处理损害赔偿','离婚程序中是否已处理损害赔偿',3,1),
('target_post_divorce_damage_spirit','赔偿金额或范围明确','赔偿金额或范围明确',4,1),
('target_post_divorce_damage_spirit','存在因果关系材料','存在因果关系材料',5,1),

('target_post_divorce_damage_economic','赔偿金额或范围明确','赔偿金额或范围明确',1,1),
('target_post_divorce_damage_economic','存在因果关系材料','存在因果关系材料',2,1),
('target_post_divorce_damage_economic','存在持续治疗材料','存在持续治疗材料',3,1),
('target_post_divorce_damage_economic','存在误工收入损失材料','存在误工收入损失材料',4,1),
('target_post_divorce_damage_economic','有具体损失或治疗费用/收入损失线索','有具体损失或治疗费用/收入损失线索',5,1),

-- paternity_confirmation_dispute
('target_paternity_confirm','请求确认亲子关系','请求确认亲子关系',1,1),
('target_paternity_confirm','亲子鉴定结论支持主张','亲子鉴定结论支持主张',2,1),
('target_paternity_confirm','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定',3,1),
('target_paternity_confirm','存在举证妨碍线索','存在举证妨碍线索',4,1),
('target_paternity_confirm','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录',5,1),

('target_paternity_confirm_evidence','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录',1,1),
('target_paternity_confirm_evidence','出生登记信息与确认主张一致','出生登记信息与确认主张一致',2,1),
('target_paternity_confirm_evidence','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明',3,1),
('target_paternity_confirm_evidence','有证据材料可补强','有证据材料可补强',4,1),

-- paternity_disclaimer_dispute
('target_paternity_disclaimer','请求否认亲子关系','请求否认亲子关系',1,1),
('target_paternity_disclaimer','亲子鉴定结论支持否认方主张','亲子鉴定结论支持否认方主张',2,1),
('target_paternity_disclaimer','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定',3,1),
('target_paternity_disclaimer','存在举证妨碍线索','存在举证妨碍线索',4,1),
('target_paternity_disclaimer','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录',5,1),

('target_paternity_disclaimer_evidence','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录',1,1),
('target_paternity_disclaimer_evidence','出生登记信息与否认主张不一致','出生登记信息与否认主张不一致',2,1),
('target_paternity_disclaimer_evidence','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明',3,1),
('target_paternity_disclaimer_evidence','有证据材料可补强','有证据材料可补强',4,1),

-- adoption_dispute
('target_adoption_confirm','收养路径类型','收养路径类型',1,1),
('target_adoption_confirm','是否已办理收养登记','是否已办理收养登记',2,1),
('target_adoption_confirm','存在事实收养长期维持','存在事实收养长期维持',3,1),
('target_adoption_confirm','存在送养同意或协议材料','存在送养同意或协议材料',4,1),
('target_adoption_confirm','收养人具备长期抚养能力','收养人具备长期抚养能力',5,1),
('target_adoption_confirm','存在长期共同生活情况','存在长期共同生活情况',6,1),

('target_adoption_dissolve','收养路径类型','收养路径类型',1,1),
('target_adoption_dissolve','请求解除收养关系','请求解除收养关系',2,1),
('target_adoption_dissolve','解除原因类型','解除原因类型',3,1),
('target_adoption_dissolve','存在解除原因线索','存在解除原因线索',4,1),
('target_adoption_dissolve','解除后未成年人抚养安排明确','解除后未成年人抚养安排明确',5,1),
('target_adoption_dissolve','有证据材料可补强','有证据材料可补强',6,1);

DELETE FROM rule_step2_evidence_type
WHERE target_id IN (
  'target_invalid_marriage_confirm',
  'target_invalid_marriage_property_return',
  'target_annulment_request',
  'target_annulment_effects',
  'target_post_divorce_damage_spirit',
  'target_post_divorce_damage_economic',
  'target_paternity_confirm',
  'target_paternity_confirm_evidence',
  'target_paternity_disclaimer',
  'target_paternity_disclaimer_evidence',
  'target_adoption_confirm',
  'target_adoption_dissolve'
);

INSERT INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled)
VALUES
-- marriage_invalid_dispute
('target_invalid_marriage_confirm','无效事由类型','结婚证/婚姻登记信息/户口簿',1,0,1),
('target_invalid_marriage_confirm','无效事由类型','身份材料/亲属关系证明/案件线索说明',2,0,1),
('target_invalid_marriage_confirm','存在在先婚姻未解除事实','前婚结婚证/离婚判决或未离婚证明',1,0,1),
('target_invalid_marriage_confirm','存在在先婚姻未解除事实','婚姻登记档案/民政查询材料',2,0,1),
('target_invalid_marriage_confirm','属于禁止结婚亲属关系','户口簿/出生证明/亲属关系证明',1,0,1),
('target_invalid_marriage_confirm','属于禁止结婚亲属关系','家谱材料/村居委证明/公安档案',2,0,1),
('target_invalid_marriage_confirm','结婚时未达法定婚龄','身份证/户口簿/出生医学证明',1,0,1),
('target_invalid_marriage_confirm','结婚时未达法定婚龄','婚姻登记档案/结婚申请材料',2,0,1),
('target_invalid_marriage_confirm','请求人为利害关系人','身份证明/亲属关系材料/授权文件',1,0,1),
('target_invalid_marriage_confirm','请求人为利害关系人','起诉材料/主体资格说明',2,0,1),

('target_invalid_marriage_property_return','是否同时主张财产处理','转账流水/收条/借条/支付明细',1,0,1),
('target_invalid_marriage_property_return','是否同时主张财产处理','财产清单/合同/登记凭证',2,0,1),
('target_invalid_marriage_property_return','是否同时主张子女安排','出生证明/户口簿/亲子关系材料',1,0,1),
('target_invalid_marriage_property_return','是否同时主张子女安排','学校医疗票据/抚养支出清单',2,0,1),
('target_invalid_marriage_property_return','是否已办理结婚登记','结婚证/婚姻登记信息',1,0,1),
('target_invalid_marriage_property_return','是否已办理结婚登记','身份材料/登记档案',2,0,1),

-- marriage_annulment_dispute
('target_annulment_request','撤销事由类型','结婚证/婚姻登记信息/身份材料',1,0,1),
('target_annulment_request','撤销事由类型','聊天记录/录音/病历诊断等事由材料',2,0,1),
('target_annulment_request','存在胁迫结婚事实','聊天记录/录音录像/报警记录',1,0,1),
('target_annulment_request','存在胁迫结婚事实','伤情材料/证人证言/求助记录',2,0,1),
('target_annulment_request','婚前隐瞒重大疾病','病历/诊断证明/住院记录',1,0,1),
('target_annulment_request','婚前隐瞒重大疾病','婚前体检资料/聊天记录/告知缺失材料',2,0,1),
('target_annulment_request','在法定期间内提出撤销请求','起诉状/立案材料/时间线说明',1,0,1),
('target_annulment_request','在法定期间内提出撤销请求','胁迫终止时间或知晓时间证据',2,0,1),
('target_annulment_request','知道撤销事由时间明确','聊天记录/就诊记录/报案记录',1,0,1),
('target_annulment_request','知道撤销事由时间明确','证人证言/说明材料',2,0,1),

('target_annulment_effects','主张撤销后损害赔偿','病历/诊断证明/费用清单',1,0,1),
('target_annulment_effects','主张撤销后损害赔偿','收入损失材料/工资流水',2,0,1),
('target_annulment_effects','存在撤销后财产返还问题','转账流水/收条/财产清单',1,0,1),
('target_annulment_effects','存在撤销后财产返还问题','不动产登记信息/购置合同',2,0,1),
('target_annulment_effects','存在撤销后子女抚养安排问题','出生证明/户口簿/亲子关系材料',1,0,1),
('target_annulment_effects','存在撤销后子女抚养安排问题','抚养支出清单/学校医疗票据',2,0,1),

-- post_divorce_damage_liability_dispute
('target_post_divorce_damage_spirit','过错类型','聊天记录/录音录像/报警记录',1,0,1),
('target_post_divorce_damage_spirit','过错类型','判决文书/行政处理材料/证人证言',2,0,1),
('target_post_divorce_damage_spirit','损害后果类型','病历/诊断证明/精神损害材料',1,0,1),
('target_post_divorce_damage_spirit','损害后果类型','治疗票据/误工材料/收入证明',2,0,1),
('target_post_divorce_damage_spirit','离婚程序中是否已处理损害赔偿','离婚判决书/调解书/离婚协议',1,0,1),
('target_post_divorce_damage_spirit','离婚程序中是否已处理损害赔偿','诉讼材料/庭审笔录线索',2,0,1),
('target_post_divorce_damage_spirit','赔偿金额或范围明确','费用清单/计算说明/票据汇总',1,0,1),
('target_post_divorce_damage_spirit','赔偿金额或范围明确','工资流水/银行回单/支付凭证',2,0,1),
('target_post_divorce_damage_spirit','存在因果关系材料','病历时间线/聊天记录/报警记录',1,0,1),
('target_post_divorce_damage_spirit','存在因果关系材料','鉴定意见/医生说明/证人证言',2,0,1),

('target_post_divorce_damage_economic','存在持续治疗材料','复诊记录/住院病历/用药清单',1,0,1),
('target_post_divorce_damage_economic','存在持续治疗材料','护理证明/后续治疗方案',2,0,1),
('target_post_divorce_damage_economic','存在误工收入损失材料','工资流水/收入证明/考勤记录',1,0,1),
('target_post_divorce_damage_economic','存在误工收入损失材料','请假记录/单位证明/社保公积金',2,0,1),
('target_post_divorce_damage_economic','有具体损失或治疗费用/收入损失线索','医疗票据/支付凭证/费用汇总',1,0,1),
('target_post_divorce_damage_economic','有具体损失或治疗费用/收入损失线索','银行流水/工资单/个税材料',2,0,1),

-- paternity_confirmation_dispute
('target_paternity_confirm','亲子鉴定结论支持主张','亲子鉴定报告/委托鉴定材料',1,0,1),
('target_paternity_confirm','亲子鉴定结论支持主张','样本来源说明/鉴定缴费凭证',2,0,1),
('target_paternity_confirm','对方拒绝配合亲子鉴定','鉴定通知/送达回证/拒绝说明',1,0,1),
('target_paternity_confirm','对方拒绝配合亲子鉴定','聊天记录/录音/庭审笔录',2,0,1),
('target_paternity_confirm','存在举证妨碍线索','隐匿样本线索/拒绝调查记录',1,0,1),
('target_paternity_confirm','存在举证妨碍线索','法院通知/调查令执行线索',2,0,1),
('target_paternity_confirm','存在怀孕生育期间往来记录','聊天记录/转账流水/探望记录',1,0,1),
('target_paternity_confirm','存在怀孕生育期间往来记录','照片视频/产检陪同记录',2,0,1),

('target_paternity_confirm_evidence','存在长期共同生活或抚养记录','同住证明/抚养支出记录/学校医疗记录',1,0,1),
('target_paternity_confirm_evidence','存在长期共同生活或抚养记录','照片视频/聊天记录/社区证明',2,0,1),
('target_paternity_confirm_evidence','出生登记信息与确认主张一致','出生医学证明/户口簿/登记信息',1,0,1),
('target_paternity_confirm_evidence','出生登记信息与确认主张一致','医院分娩记录/出生申报材料',2,0,1),

-- paternity_disclaimer_dispute
('target_paternity_disclaimer','亲子鉴定结论支持否认方主张','亲子鉴定报告/委托鉴定材料',1,0,1),
('target_paternity_disclaimer','亲子鉴定结论支持否认方主张','样本来源说明/鉴定缴费凭证',2,0,1),
('target_paternity_disclaimer','对方拒绝配合亲子鉴定','鉴定通知/送达回证/拒绝说明',1,0,1),
('target_paternity_disclaimer','对方拒绝配合亲子鉴定','聊天记录/录音/庭审笔录',2,0,1),
('target_paternity_disclaimer','存在举证妨碍线索','隐匿样本线索/拒绝调查记录',1,0,1),
('target_paternity_disclaimer','存在举证妨碍线索','法院通知/调查令执行线索',2,0,1),
('target_paternity_disclaimer','存在怀孕生育期间往来记录','聊天记录/转账流水/探望记录',1,0,1),
('target_paternity_disclaimer','存在怀孕生育期间往来记录','照片视频/产检陪同记录',2,0,1),

('target_paternity_disclaimer_evidence','存在长期共同生活或抚养记录','同住证明/抚养支出记录/学校医疗记录',1,0,1),
('target_paternity_disclaimer_evidence','存在长期共同生活或抚养记录','照片视频/聊天记录/社区证明',2,0,1),
('target_paternity_disclaimer_evidence','出生登记信息与否认主张不一致','出生医学证明/户口簿/登记信息',1,0,1),
('target_paternity_disclaimer_evidence','出生登记信息与否认主张不一致','医院分娩记录/出生申报材料',2,0,1),

-- adoption_dispute
('target_adoption_confirm','收养路径类型','收养登记证/户口簿/登记材料',1,0,1),
('target_adoption_confirm','收养路径类型','收养协议/长期照顾说明',2,0,1),
('target_adoption_confirm','存在事实收养长期维持','共同生活记录/照片视频/学校医疗材料',1,0,1),
('target_adoption_confirm','存在事实收养长期维持','社区证明/证人证言/转账记录',2,0,1),
('target_adoption_confirm','存在送养同意或协议材料','送养同意书/收养协议/公证材料',1,0,1),
('target_adoption_confirm','存在送养同意或协议材料','聊天记录/签字材料/村居委证明',2,0,1),
('target_adoption_confirm','收养人具备长期抚养能力','收入证明/银行流水/房屋居住材料',1,0,1),
('target_adoption_confirm','收养人具备长期抚养能力','工作证明/教育医疗支付记录',2,0,1),
('target_adoption_confirm','存在长期共同生活情况','同住证明/照片视频/学校接送记录',1,0,1),
('target_adoption_confirm','存在长期共同生活情况','医疗陪护记录/保险缴费记录',2,0,1),

('target_adoption_dissolve','解除原因类型','聊天记录/录音/矛盾冲突材料',1,0,1),
('target_adoption_dissolve','解除原因类型','病历/报警记录/村居委调解材料',2,0,1),
('target_adoption_dissolve','存在解除原因线索','不尽抚养义务证据/转账不足材料',1,0,1),
('target_adoption_dissolve','存在解除原因线索','虐待遗弃线索/报警记录/病历',2,0,1),
('target_adoption_dissolve','解除后未成年人抚养安排明确','抚养方案说明/监护安排材料',1,0,1),
('target_adoption_dissolve','解除后未成年人抚养安排明确','生活费教育费测算/学校医疗材料',2,0,1);

-- =========================================================
-- D2. 第一批 6 个案由：继续细化 Step2 target / cause_law
-- 向 marriage_betrothal_property_dispute 的完整度靠拢
-- =========================================================

INSERT INTO rule_step2_target (target_id, title, descr, enabled)
VALUES
('target_invalid_prior_marriage','婚姻无效：在先婚姻未解除的无效确认路径','围绕在先婚姻未解除、登记信息和请求主体资格组织无效确认。',1),
('target_invalid_prohibited_kinship','婚姻无效：禁止结婚亲属关系路径','围绕亲属关系证明、登记信息和主体资格组织无效确认。',1),
('target_invalid_underage','婚姻无效：未达法定婚龄路径','围绕年龄事实、登记材料和主体资格组织无效确认。',1),

('target_annulment_coercion','撤销婚姻：胁迫结婚路径','围绕胁迫事实、胁迫终止时间和撤销请求组织证据。',1),
('target_annulment_concealed_disease','撤销婚姻：婚前隐瞒重大疾病路径','围绕重大疾病隐瞒、知晓时间和撤销请求组织证据。',1),
('target_annulment_time_limit','撤销婚姻：法定期间审查路径','围绕提出时间、知晓时间和程序风险组织证据。',1),

('target_post_divorce_damage_fault','离婚后损害：过错类型与程序障碍审查','围绕过错类型、离婚程序是否处理过及独立主张空间组织证据。',1),
('target_post_divorce_damage_causation','离婚后损害：损害后果与因果关系路径','围绕损害后果、因果关系与后续治疗误工材料组织证据。',1),
('target_post_divorce_damage_amount_detail','离婚后损害：赔偿项目与金额测算路径','围绕金额区间、具体费用、误工和持续治疗等项目细化请求。',1),

('target_paternity_confirm_birth_record','亲子确认：出生登记一致与生育往来路径','围绕出生登记、一致性、生育往来和共同抚养记录组织证据。',1),
('target_paternity_confirm_obstruction','亲子确认：拒检与举证妨碍路径','围绕拒绝鉴定、调查受阻和证明妨碍行为强化确认主张。',1),
('target_paternity_disclaimer_birth_record','亲子否认：出生登记不一致与往来缺失路径','围绕出生登记不一致、生育往来和共同生活缺失组织证据。',1),
('target_paternity_disclaimer_obstruction','亲子否认：拒检与举证妨碍路径','围绕拒绝鉴定、调查受阻和证明妨碍行为强化否认主张。',1),

('target_adoption_registered_confirm','收养确认：登记收养成立路径','围绕收养登记、送养同意和主体资格组织确认收养关系。',1),
('target_adoption_de_facto_confirm','收养确认：事实收养长期维持路径','围绕长期共同生活、照顾记录和抚养能力组织事实收养确认。',1),
('target_adoption_dissolve_reason','解除收养：解除原因审查路径','围绕解除原因、不尽抚养义务或严重矛盾组织解除主张。',1),
('target_adoption_post_dissolve_arrangement','解除收养：解除后未成年人安排路径','围绕解除后的监护、抚养费用和生活安排组织方案。',1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  descr = VALUES(descr),
  enabled = VALUES(enabled);

INSERT IGNORE INTO rule_step2_target_legal_ref (target_id, law_id, sort_order)
VALUES
('target_invalid_prior_marriage','law_1051',1),
('target_invalid_prior_marriage','law_1052',2),
('target_invalid_prohibited_kinship','law_1051',1),
('target_invalid_underage','law_1051',1),
('target_invalid_underage','law_1054',2),

('target_annulment_coercion','law_1052',1),
('target_annulment_coercion','law_1053',2),
('target_annulment_concealed_disease','law_1053',1),
('target_annulment_time_limit','law_1053',1),

('target_post_divorce_damage_fault','law_1091',1),
('target_post_divorce_damage_causation','law_1183',1),
('target_post_divorce_damage_amount_detail','law_1183',1),
('target_post_divorce_damage_amount_detail','law_1179',2),

('target_paternity_confirm_birth_record','law_1073',1),
('target_paternity_confirm_obstruction','law_81',1),
('target_paternity_disclaimer_birth_record','law_1073',1),
('target_paternity_disclaimer_obstruction','law_81',1),

('target_adoption_registered_confirm','law_1093',1),
('target_adoption_registered_confirm','law_1105',2),
('target_adoption_de_facto_confirm','law_1093',1),
('target_adoption_dissolve_reason','law_1115',1),
('target_adoption_post_dissolve_arrangement','law_1115',1),
('target_adoption_post_dissolve_arrangement','law_1084',2);

INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order)
VALUES
('marriage_invalid_dispute','target_invalid_prior_marriage',3),
('marriage_invalid_dispute','target_invalid_prohibited_kinship',4),
('marriage_invalid_dispute','target_invalid_underage',5),

('marriage_annulment_dispute','target_annulment_coercion',3),
('marriage_annulment_dispute','target_annulment_concealed_disease',4),
('marriage_annulment_dispute','target_annulment_time_limit',5),

('post_divorce_damage_liability_dispute','target_post_divorce_damage_fault',3),
('post_divorce_damage_liability_dispute','target_post_divorce_damage_causation',4),
('post_divorce_damage_liability_dispute','target_post_divorce_damage_amount_detail',5),

('paternity_confirmation_dispute','target_paternity_confirm_birth_record',3),
('paternity_confirmation_dispute','target_paternity_confirm_obstruction',4),
('paternity_disclaimer_dispute','target_paternity_disclaimer_birth_record',3),
('paternity_disclaimer_dispute','target_paternity_disclaimer_obstruction',4),

('adoption_dispute','target_adoption_registered_confirm',3),
('adoption_dispute','target_adoption_de_facto_confirm',4),
('adoption_dispute','target_adoption_dissolve_reason',5),
('adoption_dispute','target_adoption_post_dissolve_arrangement',6);

INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order)
VALUES
('marriage_invalid_dispute','law_1051',1),
('marriage_invalid_dispute','law_1052',2),
('marriage_invalid_dispute','law_1054',3),

('marriage_annulment_dispute','law_1052',1),
('marriage_annulment_dispute','law_1053',2),
('marriage_annulment_dispute','law_1054',3),

('post_divorce_damage_liability_dispute','law_1091',1),
('post_divorce_damage_liability_dispute','law_1183',2),
('post_divorce_damage_liability_dispute','law_1179',3),

('paternity_confirmation_dispute','law_1073',1),
('paternity_confirmation_dispute','law_81',2),
('paternity_disclaimer_dispute','law_1073',1),
('paternity_disclaimer_dispute','law_81',2),

('adoption_dispute','law_1093',1),
('adoption_dispute','law_1105',2),
('adoption_dispute','law_1115',3),
('adoption_dispute','law_1084',4);

INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled)
VALUES
('target_invalid_prior_marriage','存在在先婚姻未解除事实','存在在先婚姻未解除事实',1,1),
('target_invalid_prior_marriage','请求人为利害关系人','请求人为利害关系人',2,1),
('target_invalid_prior_marriage','是否已办理结婚登记','是否已办理结婚登记',3,1),

('target_invalid_prohibited_kinship','属于禁止结婚亲属关系','属于禁止结婚亲属关系',1,1),
('target_invalid_prohibited_kinship','请求人为利害关系人','请求人为利害关系人',2,1),
('target_invalid_prohibited_kinship','是否已办理结婚登记','是否已办理结婚登记',3,1),

('target_invalid_underage','结婚时未达法定婚龄','结婚时未达法定婚龄',1,1),
('target_invalid_underage','请求人为利害关系人','请求人为利害关系人',2,1),
('target_invalid_underage','是否已办理结婚登记','是否已办理结婚登记',3,1),

('target_annulment_coercion','存在胁迫结婚事实','存在胁迫结婚事实',1,1),
('target_annulment_coercion','在法定期间内提出撤销请求','在法定期间内提出撤销请求',2,1),
('target_annulment_coercion','知道撤销事由时间明确','知道撤销事由时间明确',3,1),

('target_annulment_concealed_disease','婚前隐瞒重大疾病','婚前隐瞒重大疾病',1,1),
('target_annulment_concealed_disease','在法定期间内提出撤销请求','在法定期间内提出撤销请求',2,1),
('target_annulment_concealed_disease','知道撤销事由时间明确','知道撤销事由时间明确',3,1),

('target_annulment_time_limit','在法定期间内提出撤销请求','在法定期间内提出撤销请求',1,1),
('target_annulment_time_limit','知道撤销事由时间明确','知道撤销事由时间明确',2,1),
('target_annulment_time_limit','请求撤销婚姻','请求撤销婚姻',3,1),

('target_post_divorce_damage_fault','过错类型','过错类型',1,1),
('target_post_divorce_damage_fault','离婚程序中是否已处理损害赔偿','离婚程序中是否已处理损害赔偿',2,1),
('target_post_divorce_damage_fault','存在婚内严重过错或侵害事实线索','存在婚内严重过错或侵害事实线索',3,1),

('target_post_divorce_damage_causation','损害后果类型','损害后果类型',1,1),
('target_post_divorce_damage_causation','存在因果关系材料','存在因果关系材料',2,1),
('target_post_divorce_damage_causation','存在持续治疗材料','存在持续治疗材料',3,1),

('target_post_divorce_damage_amount_detail','赔偿金额或范围明确','赔偿金额或范围明确',1,1),
('target_post_divorce_damage_amount_detail','存在误工收入损失材料','存在误工收入损失材料',2,1),
('target_post_divorce_damage_amount_detail','有具体损失或治疗费用/收入损失线索','有具体损失或治疗费用/收入损失线索',3,1),

('target_paternity_confirm_birth_record','出生登记信息与确认主张一致','出生登记信息与确认主张一致',1,1),
('target_paternity_confirm_birth_record','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录',2,1),
('target_paternity_confirm_birth_record','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录',3,1),

('target_paternity_confirm_obstruction','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定',1,1),
('target_paternity_confirm_obstruction','存在举证妨碍线索','存在举证妨碍线索',2,1),
('target_paternity_confirm_obstruction','请求确认亲子关系','请求确认亲子关系',3,1),

('target_paternity_disclaimer_birth_record','出生登记信息与否认主张不一致','出生登记信息与否认主张不一致',1,1),
('target_paternity_disclaimer_birth_record','存在怀孕生育期间往来记录','存在怀孕生育期间往来记录',2,1),
('target_paternity_disclaimer_birth_record','存在长期共同生活或抚养记录','存在长期共同生活或抚养记录',3,1),

('target_paternity_disclaimer_obstruction','对方拒绝配合亲子鉴定','对方拒绝配合亲子鉴定',1,1),
('target_paternity_disclaimer_obstruction','存在举证妨碍线索','存在举证妨碍线索',2,1),
('target_paternity_disclaimer_obstruction','请求否认亲子关系','请求否认亲子关系',3,1),

('target_adoption_registered_confirm','是否已办理收养登记','是否已办理收养登记',1,1),
('target_adoption_registered_confirm','存在送养同意或协议材料','存在送养同意或协议材料',2,1),
('target_adoption_registered_confirm','收养人具备长期抚养能力','收养人具备长期抚养能力',3,1),

('target_adoption_de_facto_confirm','存在事实收养长期维持','存在事实收养长期维持',1,1),
('target_adoption_de_facto_confirm','存在长期共同生活情况','存在长期共同生活情况',2,1),
('target_adoption_de_facto_confirm','收养人具备长期抚养能力','收养人具备长期抚养能力',3,1),

('target_adoption_dissolve_reason','请求解除收养关系','请求解除收养关系',1,1),
('target_adoption_dissolve_reason','解除原因类型','解除原因类型',2,1),
('target_adoption_dissolve_reason','存在解除原因线索','存在解除原因线索',3,1),

('target_adoption_post_dissolve_arrangement','解除后未成年人抚养安排明确','解除后未成年人抚养安排明确',1,1),
('target_adoption_post_dissolve_arrangement','有证据材料可补强','有证据材料可补强',2,1),
('target_adoption_post_dissolve_arrangement','存在长期共同生活情况','存在长期共同生活情况',3,1);

INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled)
VALUES
('target_invalid_prior_marriage','存在在先婚姻未解除事实','前婚结婚证/离婚判决/婚姻登记档案',1,0,1),
('target_invalid_prior_marriage','存在在先婚姻未解除事实','民政查询记录/身份材料',2,0,1),
('target_invalid_prohibited_kinship','属于禁止结婚亲属关系','户口簿/出生证明/亲属关系证明',1,0,1),
('target_invalid_prohibited_kinship','属于禁止结婚亲属关系','家谱材料/村居委证明/公安档案',2,0,1),
('target_invalid_underage','结婚时未达法定婚龄','身份证/户口簿/出生医学证明',1,0,1),
('target_invalid_underage','结婚时未达法定婚龄','结婚申请材料/登记档案',2,0,1),

('target_annulment_coercion','存在胁迫结婚事实','聊天记录/录音录像/报警记录',1,0,1),
('target_annulment_coercion','存在胁迫结婚事实','伤情材料/证人证言/求助记录',2,0,1),
('target_annulment_concealed_disease','婚前隐瞒重大疾病','病历/诊断证明/住院记录',1,0,1),
('target_annulment_concealed_disease','婚前隐瞒重大疾病','婚前体检资料/聊天记录',2,0,1),
('target_annulment_time_limit','在法定期间内提出撤销请求','立案材料/起诉状/时间线说明',1,0,1),
('target_annulment_time_limit','知道撤销事由时间明确','聊天记录/就诊记录/报案记录',2,0,1),

('target_post_divorce_damage_fault','过错类型','聊天记录/录音录像/报警记录',1,0,1),
('target_post_divorce_damage_fault','离婚程序中是否已处理损害赔偿','离婚判决书/调解书/离婚协议',2,0,1),
('target_post_divorce_damage_causation','损害后果类型','病历/诊断证明/费用清单',1,0,1),
('target_post_divorce_damage_causation','存在因果关系材料','病历时间线/鉴定意见/证人证言',2,0,1),
('target_post_divorce_damage_amount_detail','赔偿金额或范围明确','费用清单/工资流水/银行回单',1,0,1),
('target_post_divorce_damage_amount_detail','存在误工收入损失材料','请假记录/单位证明/社保公积金',2,0,1),

('target_paternity_confirm_birth_record','出生登记信息与确认主张一致','出生医学证明/户口簿/出生申报材料',1,0,1),
('target_paternity_confirm_birth_record','存在怀孕生育期间往来记录','聊天记录/转账流水/探望记录',2,0,1),
('target_paternity_confirm_obstruction','对方拒绝配合亲子鉴定','鉴定通知/送达回证/拒绝说明',1,0,1),
('target_paternity_confirm_obstruction','存在举证妨碍线索','法院通知/调查令执行线索',2,0,1),
('target_paternity_disclaimer_birth_record','出生登记信息与否认主张不一致','出生医学证明/户口簿/登记信息',1,0,1),
('target_paternity_disclaimer_birth_record','存在长期共同生活或抚养记录','同住证明/学校医疗记录/社区证明',2,0,1),
('target_paternity_disclaimer_obstruction','对方拒绝配合亲子鉴定','鉴定通知/送达回证/拒绝说明',1,0,1),
('target_paternity_disclaimer_obstruction','存在举证妨碍线索','法院通知/调查令执行线索',2,0,1),

('target_adoption_registered_confirm','是否已办理收养登记','收养登记证/户口簿/登记材料',1,0,1),
('target_adoption_registered_confirm','存在送养同意或协议材料','送养同意书/收养协议/公证材料',2,0,1),
('target_adoption_de_facto_confirm','存在事实收养长期维持','共同生活记录/照片视频/学校医疗材料',1,0,1),
('target_adoption_de_facto_confirm','收养人具备长期抚养能力','收入证明/银行流水/居住材料',2,0,1),
('target_adoption_dissolve_reason','解除原因类型','聊天记录/录音/矛盾冲突材料',1,0,1),
('target_adoption_dissolve_reason','存在解除原因线索','不尽抚养义务证据/报警记录/病历',2,0,1),
('target_adoption_post_dissolve_arrangement','解除后未成年人抚养安排明确','抚养方案说明/监护安排材料',1,0,1),
('target_adoption_post_dissolve_arrangement','解除后未成年人抚养安排明确','生活费教育费测算/学校医疗材料',2,0,1);

-- =========================================================
-- D3. 第二批 4 个案由：继续细化 Step2 target / cause_law
-- =========================================================

INSERT INTO rule_step2_target (target_id, title, descr, enabled)
VALUES
('target_guardianship_subject_qualification','监护权：申请人主体资格与顺位路径','围绕申请人身份顺位、近亲属关系和基层意见组织监护资格审查。',1),
('target_guardianship_care_ability','监护权：照护能力与居住安排路径','围绕照护能力、稳定居住和日常照护安排组织监护适格性审查。',1),

('target_visitation_child_will','探望权：子女年龄、意愿与既有频率路径','围绕八周岁以上子女意愿、既有探望安排和可执行性组织方案。',1),
('target_visitation_suspension_risk','探望权：中止探望风险审查路径','围绕不利于未成年人的风险线索和探望限制方式组织审查。',1),

('target_sibling_support_medical','扶养纠纷：重大医疗护理支出路径','围绕重大医疗护理支出、失能患病和费用分担组织扶养请求。',1),
('target_sibling_support_multi_obligor','扶养纠纷：多义务人与长期照料分担路径','围绕多名扶养义务人、长期照料一方和分担比例组织方案。',1),

('target_spousal_agreement_validity','夫妻财产约定：协议成立与效力路径','围绕书面协议、签署时间、财产类型和公证登记组织效力主张。',1),
('target_spousal_agreement_performance','夫妻财产约定：履行争议与催告路径','围绕未履行、争议履行和催告记录组织履行请求。',1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  descr = VALUES(descr),
  enabled = VALUES(enabled);

INSERT IGNORE INTO rule_step2_target_legal_ref (target_id, law_id, sort_order)
VALUES
('target_guardianship_subject_qualification','law_27',1),
('target_guardianship_care_ability','law_31',1),
('target_guardianship_care_ability','law_35',2),
('target_visitation_child_will','law_1086',1),
('target_visitation_suspension_risk','law_1086',1),
('target_sibling_support_medical','law_1075',1),
('target_sibling_support_multi_obligor','law_1075',1),
('target_spousal_agreement_validity','law_1065',1),
('target_spousal_agreement_performance','law_1065',1);

INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order)
VALUES
('guardianship_dispute','target_guardianship_subject_qualification',3),
('guardianship_dispute','target_guardianship_care_ability',4),
('visitation_dispute','target_visitation_child_will',3),
('visitation_dispute','target_visitation_suspension_risk',4),
('sibling_support_dispute','target_sibling_support_medical',3),
('sibling_support_dispute','target_sibling_support_multi_obligor',4),
('spousal_property_agreement_dispute','target_spousal_agreement_validity',3),
('spousal_property_agreement_dispute','target_spousal_agreement_performance',4);

INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order)
VALUES
('guardianship_dispute','law_27',1),
('guardianship_dispute','law_31',2),
('guardianship_dispute','law_35',3),
('visitation_dispute','law_1086',1),
('sibling_support_dispute','law_1075',1),
('spousal_property_agreement_dispute','law_1065',1),
('spousal_property_agreement_dispute','law_143',2),
('spousal_property_agreement_dispute','law_148',3);

INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled)
VALUES
('target_guardianship_subject_qualification','申请人主体资格明确','申请人主体资格明确',1,1),
('target_guardianship_subject_qualification','存在居委村委或民政意见','存在居委村委或民政意见',2,1),
('target_guardianship_subject_qualification','请求指定或变更监护人','请求指定或变更监护人',3,1),

('target_guardianship_care_ability','申请人照护能力较强','申请人照护能力较强',1,1),
('target_guardianship_care_ability','存在财产管理需求','存在财产管理需求',2,1),
('target_guardianship_care_ability','有医学鉴定或诊断证据','有医学鉴定或诊断证据',3,1),

('target_visitation_child_will','子女已满八周岁','子女已满八周岁',1,1),
('target_visitation_child_will','子女有明确探望意愿','子女有明确探望意愿',2,1),
('target_visitation_child_will','既有探望频率安排明确','既有探望频率安排明确',3,1),

('target_visitation_suspension_risk','存在中止探望风险线索','存在中止探望风险线索',1,1),
('target_visitation_suspension_risk','主张节假日或住宿探望','主张节假日或住宿探望',2,1),
('target_visitation_suspension_risk','请求法院明确探望方式时间','请求法院明确探望方式时间',3,1),

('target_sibling_support_medical','被扶养人无劳动能力或患病','被扶养人无劳动能力或患病',1,1),
('target_sibling_support_medical','存在重大医疗护理支出','存在重大医疗护理支出',2,1),
('target_sibling_support_medical','月扶养费金额明确','月扶养费金额明确',3,1),

('target_sibling_support_multi_obligor','存在多名扶养义务人','存在多名扶养义务人',1,1),
('target_sibling_support_multi_obligor','已有长期照料一方','已有长期照料一方',2,1),
('target_sibling_support_multi_obligor','扶养人收入能力明确','扶养人收入能力明确',3,1),

('target_spousal_agreement_validity','存在书面协议文本','存在书面协议文本',1,1),
('target_spousal_agreement_validity','协议签署时间明确','协议签署时间明确',2,1),
('target_spousal_agreement_validity','已办理公证或登记','已办理公证或登记',3,1),

('target_spousal_agreement_performance','协议未履行或争议履行','协议未履行或争议履行',1,1),
('target_spousal_agreement_performance','争议财产类型明确','争议财产类型明确',2,1),
('target_spousal_agreement_performance','请求确认协议有效并要求履行','请求确认协议有效并要求履行',3,1);

INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled)
VALUES
('target_guardianship_subject_qualification','申请人主体资格明确','身份证明/户口簿/亲属关系证明',1,0,1),
('target_guardianship_subject_qualification','存在居委村委或民政意见','居委会证明/村委会证明/民政意见',2,0,1),
('target_guardianship_care_ability','申请人照护能力较强','收入证明/银行流水/居住材料',1,0,1),
('target_guardianship_care_ability','存在财产管理需求','财产清单/不动产登记信息/账户材料',2,0,1),

('target_visitation_child_will','子女已满八周岁','出生证明/户口簿/学籍材料',1,0,1),
('target_visitation_child_will','子女有明确探望意愿','谈话记录/学校意见/社工记录',2,0,1),
('target_visitation_suspension_risk','存在中止探望风险线索','病历/报警记录/行政处罚材料',1,0,1),
('target_visitation_suspension_risk','主张节假日或住宿探望','探望方案说明/时间安排表',2,0,1),

('target_sibling_support_medical','存在重大医疗护理支出','医疗票据/护理费票据/费用清单',1,0,1),
('target_sibling_support_medical','被扶养人无劳动能力或患病','病历/诊断证明/失能鉴定',2,0,1),
('target_sibling_support_multi_obligor','存在多名扶养义务人','户口簿/亲属关系证明/成员清单',1,0,1),
('target_sibling_support_multi_obligor','已有长期照料一方','照护记录/医疗陪护记录/聊天记录',2,0,1),

('target_spousal_agreement_validity','存在书面协议文本','协议原件/签字页/电子文本',1,0,1),
('target_spousal_agreement_validity','协议签署时间明确','协议签署页/邮件记录/聊天记录',2,0,1),
('target_spousal_agreement_performance','协议未履行或争议履行','催告函/聊天记录/录音',1,0,1),
('target_spousal_agreement_performance','争议财产类型明确','房产证/股权材料/存款清单',2,0,1);

-- =========================================================
-- D4. 第三批 3 个案由：继续细化 Step2 target / cause_law
-- =========================================================

INSERT INTO rule_step2_target (target_id, title, descr, enabled)
VALUES
('target_in_marriage_property_type_scope','婚内财产分割：争议财产类型与范围路径','围绕争议财产类型、范围和共同财产边界组织分割主张。',1),
('target_in_marriage_property_livelihood_impact','婚内财产分割：基本生活受影响与紧迫性路径','围绕重大医疗支出、挥霍处置和家庭基本生活受影响组织紧迫性论证。',1),

('target_cohab_contribution_ratio','同居财产：出资比例与共同购置路径','围绕共同购置房车、大额财物和一方明显高额出资组织析产方案。',1),
('target_cohab_direct_custody','同居子女：直接抚养与月支出路径','围绕直接抚养主张、月支出和现有照料安排组织抚养方案。',1),

('target_family_partition_member_boundary','分家析产：成员范围与分家状态路径','围绕家庭成员范围、是否已实际分家和长期占有使用状态组织析产入口。',1),
('target_family_partition_registration_source','分家析产：登记名义与主要出资来源路径','围绕登记名义、主要出资来源和权属材料组织份额主张。',1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  descr = VALUES(descr),
  enabled = VALUES(enabled);

INSERT IGNORE INTO rule_step2_target_legal_ref (target_id, law_id, sort_order)
VALUES
('target_in_marriage_property_type_scope','law_1087',1),
('target_in_marriage_property_type_scope','law_1092',2),
('target_in_marriage_property_livelihood_impact','law_1087',1),
('target_in_marriage_property_livelihood_impact','law_1092',2),
('target_cohab_contribution_ratio','law_308',1),
('target_cohab_direct_custody','law_1084',1),
('target_cohab_direct_custody','law_1085',2),
('target_family_partition_member_boundary','law_308',1),
('target_family_partition_registration_source','law_309',1);

INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order)
VALUES
('in_marriage_property_division_dispute','target_in_marriage_property_type_scope',3),
('in_marriage_property_division_dispute','target_in_marriage_property_livelihood_impact',4),
('cohabitation_dispute','target_cohab_contribution_ratio',3),
('cohabitation_dispute','target_cohab_direct_custody',4),
('family_partition_dispute','target_family_partition_member_boundary',3),
('family_partition_dispute','target_family_partition_registration_source',4);

INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order)
VALUES
('in_marriage_property_division_dispute','law_1087',1),
('in_marriage_property_division_dispute','law_1092',2),
('cohabitation_dispute','law_308',1),
('cohabitation_dispute','law_1084',2),
('cohabitation_dispute','law_1085',3),
('family_partition_dispute','law_308',1),
('family_partition_dispute','law_309',2);

INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled)
VALUES
('target_in_marriage_property_type_scope','争议财产类型明确','争议财产类型明确',1,1),
('target_in_marriage_property_type_scope','共同财产范围清晰','共同财产范围清晰',2,1),
('target_in_marriage_property_type_scope','转移方式已可说明','转移方式已可说明',3,1),

('target_in_marriage_property_livelihood_impact','存在重大医疗支出或紧急治疗需求','存在重大医疗支出或紧急治疗需求',1,1),
('target_in_marriage_property_livelihood_impact','医疗支出金额大致明确','医疗支出金额大致明确',2,1),
('target_in_marriage_property_livelihood_impact','已影响家庭基本生活','已影响家庭基本生活',3,1),

('target_cohab_contribution_ratio','同居起止时间明确','同居起止时间明确',1,1),
('target_cohab_contribution_ratio','共同购置房车或大额财物','共同购置房车或大额财物',2,1),
('target_cohab_contribution_ratio','一方出资比例明显更高','一方出资比例明显更高',3,1),

('target_cohab_direct_custody','主张子女直接抚养安排','主张子女直接抚养安排',1,1),
('target_cohab_direct_custody','子女主要由一方抚养','子女主要由一方抚养',2,1),
('target_cohab_direct_custody','孩子月支出明确','孩子月支出明确',3,1),

('target_family_partition_member_boundary','家庭成员范围明确','家庭成员范围明确',1,1),
('target_family_partition_member_boundary','已实际分家','已实际分家',2,1),
('target_family_partition_member_boundary','存在长期占有使用一方','存在长期占有使用一方',3,1),

('target_family_partition_registration_source','财产登记名义明确','财产登记名义明确',1,1),
('target_family_partition_registration_source','主要出资来源明确','主要出资来源明确',2,1),
('target_family_partition_registration_source','共同财产范围清晰','共同财产范围清晰',3,1);

INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled)
VALUES
('target_in_marriage_property_type_scope','争议财产类型明确','房产证/银行账户清单/股权材料',1,0,1),
('target_in_marriage_property_type_scope','共同财产范围清晰','财产清单/账本/资产负债明细',2,0,1),
('target_in_marriage_property_livelihood_impact','医疗支出金额大致明确','病历/诊断证明/医疗票据',1,0,1),
('target_in_marriage_property_livelihood_impact','已影响家庭基本生活','家庭支出清单/欠费记录/沟通记录',2,0,1),

('target_cohab_contribution_ratio','共同购置房车或大额财物','购房合同/购车合同/支付凭证',1,0,1),
('target_cohab_contribution_ratio','一方出资比例明显更高','转账流水/银行回单/收入证明',2,0,1),
('target_cohab_direct_custody','主张子女直接抚养安排','主张说明/抚养方案/协商记录',1,0,1),
('target_cohab_direct_custody','孩子月支出明确','生活教育医疗支出清单/票据',2,0,1),

('target_family_partition_member_boundary','家庭成员范围明确','户口簿/成员清单/家庭关系说明',1,0,1),
('target_family_partition_member_boundary','已实际分家','分灶分居证明/邻里证明/历史协议',2,0,1),
('target_family_partition_registration_source','财产登记名义明确','不动产登记信息/权属证明/合同票据',1,0,1),
('target_family_partition_registration_source','主要出资来源明确','转账流水/建房购置支出清单/借款凭证',2,0,1);

-- =========================================================
-- E. 第二批 + 第三批案由：细化既有 Step2 target 的 required_fact / evidence_type
-- =========================================================

DELETE FROM rule_step2_required_fact
WHERE target_id IN (
  'target_guardianship_assign',
  'target_guardianship_evidence',
  'target_visitation_fix',
  'target_visitation_evidence',
  'target_sibling_support_fee_claim',
  'target_sibling_support_change',
  'target_spousal_agreement_enforce',
  'target_spousal_agreement_defense',
  'target_in_marriage_division_conceal_transfer',
  'target_in_marriage_division_waste_medical',
  'target_cohab_property_partition',
  'target_cohab_child_custody',
  'target_family_partition_plan',
  'target_family_partition_evidence'
);

INSERT INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled)
VALUES
-- guardianship_dispute
('target_guardianship_assign','申请人主体资格明确','申请人主体资格明确',1,1),
('target_guardianship_assign','被监护人无或限制民事行为能力','被监护人无或限制民事行为能力',2,1),
('target_guardianship_assign','有医学鉴定或诊断证据','有医学鉴定或诊断证据',3,1),
('target_guardianship_assign','申请人照护能力较强','申请人照护能力较强',4,1),
('target_guardianship_assign','请求指定或变更监护人','请求指定或变更监护人',5,1),

('target_guardianship_evidence','当前监护人不适合或不履行','当前监护人不适合或不履行',1,1),
('target_guardianship_evidence','存在居委村委或民政意见','存在居委村委或民政意见',2,1),
('target_guardianship_evidence','存在财产管理需求','存在财产管理需求',3,1),
('target_guardianship_evidence','有证据材料可补强','有证据材料可补强',4,1),

-- visitation_dispute
('target_visitation_fix','为非直接抚养方','为非直接抚养方',1,1),
('target_visitation_fix','存在拒绝探望或障碍','存在拒绝探望或障碍',2,1),
('target_visitation_fix','主张节假日或住宿探望','主张节假日或住宿探望',3,1),
('target_visitation_fix','请求法院明确探望方式时间','请求法院明确探望方式时间',4,1),

('target_visitation_evidence','子女已满八周岁','子女已满八周岁',1,1),
('target_visitation_evidence','子女有明确探望意愿','子女有明确探望意愿',2,1),
('target_visitation_evidence','既有探望频率安排明确','既有探望频率安排明确',3,1),
('target_visitation_evidence','存在中止探望风险线索','存在中止探望风险线索',4,1),

-- sibling_support_dispute
('target_sibling_support_fee_claim','存在扶养义务关系','存在扶养义务关系',1,1),
('target_sibling_support_fee_claim','被扶养人无劳动能力或患病','被扶养人无劳动能力或患病',2,1),
('target_sibling_support_fee_claim','存在重大医疗护理支出','存在重大医疗护理支出',3,1),
('target_sibling_support_fee_claim','扶养人收入能力明确','扶养人收入能力明确',4,1),
('target_sibling_support_fee_claim','月扶养费金额明确','月扶养费金额明确',5,1),

('target_sibling_support_change','主张变更扶养关系','主张变更扶养关系',1,1),
('target_sibling_support_change','变更原因属于法定情形','变更原因属于法定情形',2,1),
('target_sibling_support_change','存在多名扶养义务人','存在多名扶养义务人',3,1),
('target_sibling_support_change','已有长期照料一方','已有长期照料一方',4,1),

-- spousal_property_agreement_dispute
('target_spousal_agreement_enforce','存在夫妻财产约定协议','存在夫妻财产约定协议',1,1),
('target_spousal_agreement_enforce','存在书面协议文本','存在书面协议文本',2,1),
('target_spousal_agreement_enforce','协议签署时间明确','协议签署时间明确',3,1),
('target_spousal_agreement_enforce','争议财产类型明确','争议财产类型明确',4,1),
('target_spousal_agreement_enforce','协议未履行或争议履行','协议未履行或争议履行',5,1),

('target_spousal_agreement_defense','存在受胁迫欺诈等效力抗辩','存在受胁迫欺诈等效力抗辩',1,1),
('target_spousal_agreement_defense','对方主张协议无效或被撤销','对方主张协议无效或被撤销',2,1),
('target_spousal_agreement_defense','已办理公证或登记','已办理公证或登记',3,1),
('target_spousal_agreement_defense','有证据材料可补强','有证据材料可补强',4,1),

-- in_marriage_property_division_dispute
('target_in_marriage_division_conceal_transfer','存在婚内共同财产争议','存在婚内共同财产争议',1,1),
('target_in_marriage_division_conceal_transfer','存在藏匿转移共同财产线索','存在藏匿转移共同财产线索',2,1),
('target_in_marriage_division_conceal_transfer','争议财产类型明确','争议财产类型明确',3,1),
('target_in_marriage_division_conceal_transfer','转移方式已可说明','转移方式已可说明',4,1),
('target_in_marriage_division_conceal_transfer','共同财产范围清晰','共同财产范围清晰',5,1),

('target_in_marriage_division_waste_medical','存在挥霍家产或恶意处置','存在挥霍家产或恶意处置',1,1),
('target_in_marriage_division_waste_medical','挥霍金额或次数可说明','挥霍金额或次数可说明',2,1),
('target_in_marriage_division_waste_medical','存在重大医疗支出或紧急治疗需求','存在重大医疗支出或紧急治疗需求',3,1),
('target_in_marriage_division_waste_medical','医疗支出金额大致明确','医疗支出金额大致明确',4,1),
('target_in_marriage_division_waste_medical','已影响家庭基本生活','已影响家庭基本生活',5,1),

-- cohabitation_dispute
('target_cohab_property_partition','是否存在同居关系','是否存在同居关系',1,1),
('target_cohab_property_partition','同居起止时间明确','同居起止时间明确',2,1),
('target_cohab_property_partition','共同购置房车或大额财物','共同购置房车或大额财物',3,1),
('target_cohab_property_partition','一方出资比例明显更高','一方出资比例明显更高',4,1),
('target_cohab_property_partition','存在财产分割争议','存在财产分割争议',5,1),

('target_cohab_child_custody','是否存在子女','是否存在子女',1,1),
('target_cohab_child_custody','主张子女直接抚养安排','主张子女直接抚养安排',2,1),
('target_cohab_child_custody','子女主要由一方抚养','子女主要由一方抚养',3,1),
('target_cohab_child_custody','对方拒绝或未支付抚养费','对方拒绝或未支付抚养费',4,1),
('target_cohab_child_custody','孩子月支出明确','孩子月支出明确',5,1),

-- family_partition_dispute
('target_family_partition_plan','家庭成员范围明确','家庭成员范围明确',1,1),
('target_family_partition_plan','已实际分家','已实际分家',2,1),
('target_family_partition_plan','存在长期占有使用一方','存在长期占有使用一方',3,1),
('target_family_partition_plan','请求分割/析产','请求分割/析产',4,1),
('target_family_partition_plan','存在分割争议','存在分割争议',5,1),

('target_family_partition_evidence','共同财产范围清晰','共同财产范围清晰',1,1),
('target_family_partition_evidence','财产登记名义明确','财产登记名义明确',2,1),
('target_family_partition_evidence','主要出资来源明确','主要出资来源明确',3,1),
('target_family_partition_evidence','有财产清单/账本/沟通记录','有财产清单/账本/沟通记录',4,1);

DELETE FROM rule_step2_evidence_type
WHERE target_id IN (
  'target_guardianship_assign',
  'target_guardianship_evidence',
  'target_visitation_fix',
  'target_visitation_evidence',
  'target_sibling_support_fee_claim',
  'target_sibling_support_change',
  'target_spousal_agreement_enforce',
  'target_spousal_agreement_defense',
  'target_in_marriage_division_conceal_transfer',
  'target_in_marriage_division_waste_medical',
  'target_cohab_property_partition',
  'target_cohab_child_custody',
  'target_family_partition_plan',
  'target_family_partition_evidence'
);

INSERT INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled)
VALUES
-- guardianship_dispute
('target_guardianship_assign','申请人主体资格明确','身份证明/户口簿/亲属关系证明',1,0,1),
('target_guardianship_assign','申请人主体资格明确','监护顺位说明/授权材料/基层证明',2,0,1),
('target_guardianship_assign','申请人照护能力较强','收入证明/银行流水/居住材料',1,0,1),
('target_guardianship_assign','申请人照护能力较强','工作证明/照护安排说明/社区证明',2,0,1),
('target_guardianship_assign','被监护人无或限制民事行为能力','病历/诊断证明/鉴定结论',1,0,1),
('target_guardianship_assign','被监护人无或限制民事行为能力','护理记录/失能证明/医疗票据',2,0,1),
('target_guardianship_assign','有医学鉴定或诊断证据','鉴定意见/病历复印件/诊断证明',1,0,1),
('target_guardianship_assign','有医学鉴定或诊断证据','就诊记录/住院病案/复查记录',2,0,1),
('target_guardianship_assign','请求指定或变更监护人','申请书/起诉状/证据清单',1,0,1),
('target_guardianship_assign','请求指定或变更监护人','司法文书/调解材料/说明材料',2,0,1),

('target_guardianship_evidence','当前监护人不适合或不履行','聊天记录/录音/照护缺位证明',1,0,1),
('target_guardianship_evidence','当前监护人不适合或不履行','费用欠付记录/报警记录/基层意见',2,0,1),
('target_guardianship_evidence','存在居委村委或民政意见','居委会证明/村委会证明/民政意见',1,0,1),
('target_guardianship_evidence','存在居委村委或民政意见','调解记录/走访记录/函件材料',2,0,1),
('target_guardianship_evidence','存在财产管理需求','财产清单/银行流水/不动产登记信息',1,0,1),
('target_guardianship_evidence','存在财产管理需求','保管风险说明/合同票据/账户明细',2,0,1),

-- visitation_dispute
('target_visitation_fix','为非直接抚养方','离婚协议/判决文书/抚养安排材料',1,0,1),
('target_visitation_fix','为非直接抚养方','沟通记录/身份关系说明',2,0,1),
('target_visitation_fix','存在拒绝探望或障碍','聊天记录/录音录像/报警记录',1,0,1),
('target_visitation_fix','存在拒绝探望或障碍','探望到场记录/照片视频/证人证言',2,0,1),
('target_visitation_fix','主张节假日或住宿探望','探望方案说明/时间安排表',1,0,1),
('target_visitation_fix','主张节假日或住宿探望','既往探望记录/行程安排材料',2,0,1),
('target_visitation_fix','请求法院明确探望方式时间','起诉状/申请书/证据目录',1,0,1),
('target_visitation_fix','请求法院明确探望方式时间','既有协商方案/律师函/沟通记录',2,0,1),

('target_visitation_evidence','子女已满八周岁','出生证明/户口簿/身份证明',1,0,1),
('target_visitation_evidence','子女已满八周岁','学籍材料/学校证明',2,0,1),
('target_visitation_evidence','子女有明确探望意愿','谈话记录/社工或学校意见',1,0,1),
('target_visitation_evidence','子女有明确探望意愿','聊天记录/录音录像/书面意见',2,0,1),
('target_visitation_evidence','既有探望频率安排明确','探望协议/判决文书/调解笔录',1,0,1),
('target_visitation_evidence','既有探望频率安排明确','接送安排记录/日历计划/聊天记录',2,0,1),
('target_visitation_evidence','存在中止探望风险线索','病历/报警记录/行政处罚材料',1,0,1),
('target_visitation_evidence','存在中止探望风险线索','证人证言/聊天记录/视频材料',2,0,1),

-- sibling_support_dispute
('target_sibling_support_fee_claim','被扶养人无劳动能力或患病','病历/诊断证明/失能鉴定',1,0,1),
('target_sibling_support_fee_claim','被扶养人无劳动能力或患病','住院材料/长期用药记录/护理证明',2,0,1),
('target_sibling_support_fee_claim','存在重大医疗护理支出','医疗票据/护理费票据/费用清单',1,0,1),
('target_sibling_support_fee_claim','存在重大医疗护理支出','住院记录/支付凭证/转账流水',2,0,1),
('target_sibling_support_fee_claim','扶养人收入能力明确','工资流水/银行流水/收入证明',1,0,1),
('target_sibling_support_fee_claim','扶养人收入能力明确','社保公积金/经营收入材料',2,0,1),
('target_sibling_support_fee_claim','月扶养费金额明确','费用测算表/生活支出清单',1,0,1),
('target_sibling_support_fee_claim','月扶养费金额明确','医疗护理支出表/支付凭证',2,0,1),

('target_sibling_support_change','存在多名扶养义务人','户口簿/亲属关系证明/成员清单',1,0,1),
('target_sibling_support_change','存在多名扶养义务人','村居委证明/家庭关系说明',2,0,1),
('target_sibling_support_change','已有长期照料一方','照护记录/探视记录/邻里证明',1,0,1),
('target_sibling_support_change','已有长期照料一方','医疗陪护记录/转账流水/聊天记录',2,0,1),

-- spousal_property_agreement_dispute
('target_spousal_agreement_enforce','存在书面协议文本','协议原件/签字页/电子文本',1,0,1),
('target_spousal_agreement_enforce','存在书面协议文本','公证书/登记材料/扫描件',2,0,1),
('target_spousal_agreement_enforce','协议签署时间明确','协议签署页/聊天记录/邮件记录',1,0,1),
('target_spousal_agreement_enforce','协议签署时间明确','公证时间/登记时间/见证说明',2,0,1),
('target_spousal_agreement_enforce','争议财产类型明确','房产证/股权材料/存款清单',1,0,1),
('target_spousal_agreement_enforce','争议财产类型明确','合同/登记信息/资产清单',2,0,1),
('target_spousal_agreement_enforce','协议未履行或争议履行','催告函/聊天记录/录音',1,0,1),
('target_spousal_agreement_enforce','协议未履行或争议履行','转账记录/履行情况说明/支付凭证',2,0,1),

('target_spousal_agreement_defense','存在受胁迫欺诈等效力抗辩','聊天记录/录音录像/报警记录',1,0,1),
('target_spousal_agreement_defense','存在受胁迫欺诈等效力抗辩','病历/心理评估/证人证言',2,0,1),
('target_spousal_agreement_defense','已办理公证或登记','公证书/登记回执/备案材料',1,0,1),
('target_spousal_agreement_defense','已办理公证或登记','受理单/查询记录/档案复印件',2,0,1),

-- in_marriage_property_division_dispute
('target_in_marriage_division_conceal_transfer','争议财产类型明确','房产证/银行账户清单/股权材料',1,0,1),
('target_in_marriage_division_conceal_transfer','争议财产类型明确','车辆登记/理财清单/资产目录',2,0,1),
('target_in_marriage_division_conceal_transfer','转移方式已可说明','转账流水/交易记录/账户明细',1,0,1),
('target_in_marriage_division_conceal_transfer','转移方式已可说明','聊天记录/合同票据/收条借条',2,0,1),
('target_in_marriage_division_conceal_transfer','共同财产范围清晰','财产清单/账本/不动产登记信息',1,0,1),
('target_in_marriage_division_conceal_transfer','共同财产范围清晰','银行流水/资产负债清单/购置合同',2,0,1),

('target_in_marriage_division_waste_medical','挥霍金额或次数可说明','消费记录/转账流水/账单明细',1,0,1),
('target_in_marriage_division_waste_medical','挥霍金额或次数可说明','聊天记录/证人证言/照片视频',2,0,1),
('target_in_marriage_division_waste_medical','医疗支出金额大致明确','病历/诊断证明/医疗票据',1,0,1),
('target_in_marriage_division_waste_medical','医疗支出金额大致明确','费用清单/支付凭证/护理材料',2,0,1),
('target_in_marriage_division_waste_medical','已影响家庭基本生活','家庭支出清单/欠费记录/沟通记录',1,0,1),
('target_in_marriage_division_waste_medical','已影响家庭基本生活','转账流水/借款凭证/社区证明',2,0,1),

-- cohabitation_dispute
('target_cohab_property_partition','同居起止时间明确','租房合同/居住登记/同住证明',1,0,1),
('target_cohab_property_partition','同居起止时间明确','聊天记录/照片视频/邻里证明',2,0,1),
('target_cohab_property_partition','共同购置房车或大额财物','购房合同/购车合同/支付凭证',1,0,1),
('target_cohab_property_partition','共同购置房车或大额财物','不动产登记信息/车辆登记/发票',2,0,1),
('target_cohab_property_partition','一方出资比例明显更高','转账流水/银行回单/收入证明',1,0,1),
('target_cohab_property_partition','一方出资比例明显更高','出资说明/账本清单/聊天记录',2,0,1),

('target_cohab_child_custody','主张子女直接抚养安排','起诉状/主张说明/协商记录',1,0,1),
('target_cohab_child_custody','主张子女直接抚养安排','抚养方案/照护安排说明',2,0,1),
('target_cohab_child_custody','孩子月支出明确','生活教育医疗支出清单',1,0,1),
('target_cohab_child_custody','孩子月支出明确','票据发票/转账记录/缴费记录',2,0,1),

-- family_partition_dispute
('target_family_partition_plan','家庭成员范围明确','户口簿/家庭关系说明/成员清单',1,0,1),
('target_family_partition_plan','家庭成员范围明确','村居委证明/族谱或分家说明',2,0,1),
('target_family_partition_plan','已实际分家','分灶分居证明/居住情况说明',1,0,1),
('target_family_partition_plan','已实际分家','聊天记录/邻里证明/历史协议',2,0,1),
('target_family_partition_plan','存在长期占有使用一方','占有使用说明/租住使用记录',1,0,1),
('target_family_partition_plan','存在长期占有使用一方','水电费记录/管理收支账本',2,0,1),

('target_family_partition_evidence','财产登记名义明确','不动产登记信息/车辆登记/账户资料',1,0,1),
('target_family_partition_evidence','财产登记名义明确','权属证明/合同票据/证照复印件',2,0,1),
('target_family_partition_evidence','主要出资来源明确','转账流水/建房购置支出清单',1,0,1),
('target_family_partition_evidence','主要出资来源明确','借款凭证/收入证明/账本材料',2,0,1);
