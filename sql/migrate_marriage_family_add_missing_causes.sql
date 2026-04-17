USE rule_engine_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================================
-- 婚姻家庭（不含继承）案由补齐：13-28 缺失部分
-- 说明：本脚本“结构完整可跑通”为优先，确保：
--   - 新增 cause_code 并归类到 category_code=marriage_family
--   - 新增问卷 questionnaire + 分组 + 问题（主要用 boolean，降低前端/事实对齐风险）
--   - 新增 Step2 target/required_fact/evidence_type/cause_target
--   - 新增 Step1 judge_rule + judge_conclusion（保证 /judge 可返回结构化结果）
-- ==========================================================

-- -------------------------
-- 1) 新增 cause_code
-- -------------------------
INSERT INTO rule_cause (cause_code, cause_name, questionnaire_id, enabled)
VALUES
('in_marriage_property_division_dispute','婚内夫妻财产分割纠纷','questionnaire_in_marriage_property_division_dispute',1),
('post_divorce_damage_liability_dispute','离婚后损害责任纠纷','questionnaire_post_divorce_damage_liability_dispute',1),
('marriage_invalid_dispute','婚姻无效纠纷','questionnaire_marriage_invalid_dispute',1),
('marriage_annulment_dispute','撤销婚姻纠纷','questionnaire_marriage_annulment_dispute',1),
('spousal_property_agreement_dispute','夫妻财产约定纠纷','questionnaire_spousal_property_agreement_dispute',1),
('cohabitation_dispute','同居关系纠纷','questionnaire_cohabitation_dispute',1),
('paternity_confirmation_dispute','亲子关系纠纷-确认亲子关系','questionnaire_paternity_confirmation_dispute',1),
('paternity_disclaimer_dispute','亲子关系纠纷-否认亲子关系','questionnaire_paternity_disclaimer_dispute',1),
('sibling_support_dispute','扶养纠纷-扶养义务','questionnaire_sibling_support_dispute',1),
('adoption_dispute','收养关系纠纷','questionnaire_adoption_dispute',1),
('guardianship_dispute','监护权纠纷','questionnaire_guardianship_dispute',1),
('visitation_dispute','探望权纠纷','questionnaire_visitation_dispute',1),
('family_partition_dispute','分家析产纠纷','questionnaire_family_partition_dispute',1)
ON DUPLICATE KEY UPDATE
cause_name=VALUES(cause_name),
questionnaire_id=VALUES(questionnaire_id),
enabled=VALUES(enabled);

UPDATE rule_cause
SET category_code='marriage_family'
WHERE cause_code IN (
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
);

-- -------------------------
-- 2) 問卷主表
-- -------------------------
INSERT INTO rule_questionnaire (questionnaire_id, name, enabled, version_no)
VALUES
('questionnaire_in_marriage_property_division_dispute','婚内夫妻财产分割纠纷问卷',1,1),
('questionnaire_post_divorce_damage_liability_dispute','离婚后损害责任纠纷问卷',1,1),
('questionnaire_marriage_invalid_dispute','婚姻无效纠纷问卷',1,1),
('questionnaire_marriage_annulment_dispute','撤销婚姻纠纷问卷',1,1),
('questionnaire_spousal_property_agreement_dispute','夫妻财产约定纠纷问卷',1,1),
('questionnaire_cohabitation_dispute','同居关系纠纷问卷',1,1),
('questionnaire_paternity_confirmation_dispute','亲子关系纠纷-确认问卷',1,1),
('questionnaire_paternity_disclaimer_dispute','亲子关系纠纷-否认问卷',1,1),
('questionnaire_sibling_support_dispute','扶养纠纷问卷',1,1),
('questionnaire_adoption_dispute','收养关系纠纷问卷',1,1),
('questionnaire_guardianship_dispute','监护权纠纷问卷',1,1),
('questionnaire_visitation_dispute','探望权纠纷问卷',1,1),
('questionnaire_family_partition_dispute','分家析产纠纷问卷',1,1)
ON DUPLICATE KEY UPDATE
name=VALUES(name),
enabled=VALUES(enabled),
version_no=VALUES(version_no);

-- -------------------------
-- 3) 问卷分组（统一 G0/G1/G2）
-- -------------------------
INSERT INTO rule_question_group (questionnaire_id, group_key, group_order, enabled, group_name, group_desc, icon)
VALUES
('questionnaire_in_marriage_property_division_dispute','G0',0,1,'前置程序确认','确认婚内财产分割审查入口','⚖️'),
('questionnaire_in_marriage_property_division_dispute','G1',1,1,'争议要点','采集藏匿转移/挥霍/医疗紧急支出等关键事实','📌'),
('questionnaire_in_marriage_property_division_dispute','G2',2,1,'证据补强','补充转账流水、票据、登记与资产清单等','🧾'),

('questionnaire_post_divorce_damage_liability_dispute','G0',0,1,'前置程序确认','确认离婚后损害责任可进入审查','⚖️'),
('questionnaire_post_divorce_damage_liability_dispute','G1',1,1,'损害与过错要件','采集过错线索与损害后果','📌'),
('questionnaire_post_divorce_damage_liability_dispute','G2',2,1,'证据补强','补充聊天、病历、费用清单等','🧾'),

('questionnaire_marriage_invalid_dispute','G0',0,1,'前置程序确认','确认婚姻无效类型与请求方向','⚖️'),
('questionnaire_marriage_invalid_dispute','G1',1,1,'无效原因要点','采集无效原因线索与关键要件','📌'),
('questionnaire_marriage_invalid_dispute','G2',2,1,'证据补强','补充登记、身份与财产/子女线索','🧾'),

('questionnaire_marriage_annulment_dispute','G0',0,1,'前置程序确认','确认撤销婚姻原因与请求方向','⚖️'),
('questionnaire_marriage_annulment_dispute','G1',1,1,'撤销原因要点','采集胁迫/欺诈/隐瞒重大疾病等线索','📌'),
('questionnaire_marriage_annulment_dispute','G2',2,1,'证据补强','补充录音聊天、病历诊断与登记材料','🧾'),

('questionnaire_spousal_property_agreement_dispute','G0',0,1,'前置程序确认','确认是否存在夫妻财产约定协议','⚖️'),
('questionnaire_spousal_property_agreement_dispute','G1',1,1,'协议争议要点','采集约定明确性、履行争议与无效抗辩','📌'),
('questionnaire_spousal_property_agreement_dispute','G2',2,1,'证据补强','补充协议文本、公证/登记与催告履行证据','🧾'),

('questionnaire_cohabitation_dispute','G0',0,1,'前置程序确认','确认同居背景与纠纷入口','⚖️'),
('questionnaire_cohabitation_dispute','G1',1,1,'财产与子女要点','采集共同生活/投入、财产争议与抚养问题','📌'),
('questionnaire_cohabitation_dispute','G2',2,1,'证据补强','补充转账流水、同住证据、收入与沟通记录','🧾'),

('questionnaire_paternity_confirmation_dispute','G0',0,1,'前置程序确认','确认亲子关系争议与确认请求方向','⚖️'),
('questionnaire_paternity_confirmation_dispute','G1',1,1,'鉴定与要件','采集鉴定情况与结论支持指向','📌'),
('questionnaire_paternity_confirmation_dispute','G2',2,1,'证据补强','补充出生/户籍/亲属关系与鉴定材料','🧾'),

('questionnaire_paternity_disclaimer_dispute','G0',0,1,'前置程序确认','确认亲子关系争议与否认请求方向','⚖️'),
('questionnaire_paternity_disclaimer_dispute','G1',1,1,'鉴定与要件','采集鉴定情况与结论不支持指向','📌'),
('questionnaire_paternity_disclaimer_dispute','G2',2,1,'证据补强','补充出生/户籍/亲属关系与鉴定材料','🧾'),

('questionnaire_sibling_support_dispute','G0',0,1,'前置程序确认','确认扶养义务关系与争议入口','⚖️'),
('questionnaire_sibling_support_dispute','G1',1,1,'要件要点','采集困难、能力、拒绝履行与变更主张','📌'),
('questionnaire_sibling_support_dispute','G2',2,1,'证据补强','补充收入证明、医疗/失能与沟通/转账证据','🧾'),

('questionnaire_adoption_dispute','G0',0,1,'前置程序确认','确认收养请求方向：确认或解除','⚖️'),
('questionnaire_adoption_dispute','G1',1,1,'登记/事实要点','采集登记与长期事实维持情况','📌'),
('questionnaire_adoption_dispute','G2',2,1,'证据补强','补充登记材料、照顾记录、协议与解除原因线索','🧾'),

('questionnaire_guardianship_dispute','G0',0,1,'前置程序确认','确认监护需求与请求方向','⚖️'),
('questionnaire_guardianship_dispute','G1',1,1,'能力与现状要点','采集无/限制能力与现任监护履职情况','📌'),
('questionnaire_guardianship_dispute','G2',2,1,'证据补强','补充鉴定/诊断材料与申请文书线索','🧾'),

('questionnaire_visitation_dispute','G0',0,1,'前置程序确认','确认分开背景与探望请求方向','⚖️'),
('questionnaire_visitation_dispute','G1',1,1,'探望障碍要点','采集拒绝探望/安排协议与实施情况','📌'),
('questionnaire_visitation_dispute','G2',2,1,'证据补强','补充沟通记录、视频/录音与文书材料','🧾'),

('questionnaire_family_partition_dispute','G0',0,1,'前置程序确认','确认同堂共同生活与析产入口','⚖️'),
('questionnaire_family_partition_dispute','G1',1,1,'财产争议要点','采集共同置办财产、登记证据与分割争议','📌'),
('questionnaire_family_partition_dispute','G2',2,1,'证据补强','补充资金来源、财产清单/账本与沟通记录','🧾')
ON DUPLICATE KEY UPDATE
enabled=VALUES(enabled),
group_name=VALUES(group_name),
group_desc=VALUES(group_desc),
icon=VALUES(icon),
group_order=VALUES(group_order);

-- -------------------------
-- 4) 问卷题目（boolean 为主）
-- -------------------------
INSERT INTO rule_question (
  questionnaire_id, group_key, question_key, answer_key, label, hint,
  input_type, required, question_order, enabled, unit
)
VALUES
-- 13 婚内夫妻财产分割纠纷
('questionnaire_in_marriage_property_division_dispute','G0','婚姻关系已存续且未离婚','婚姻关系已存续且未离婚','婚姻关系已存续且未离婚','婚内未离婚或未进入离婚后状态','boolean',1,1,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G1','存在婚内共同财产争议','存在婚内共同财产争议','存在婚内共同财产争议','婚内共同财产存在争议','boolean',1,2,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G1','存在藏匿转移共同财产线索','存在藏匿转移共同财产线索','存在藏匿转移共同财产线索','存在隐匿/转移/变卖线索','boolean',1,3,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G1','存在挥霍家产或恶意处置','存在挥霍家产或恶意处置','存在挥霍家产或恶意处置','存在挥霍/恶意处置行为','boolean',0,4,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G1','存在重大医疗支出或紧急治疗需求','存在重大医疗支出或紧急治疗需求','存在重大医疗支出或紧急治疗需求','存在紧急治疗/重大医疗支出','boolean',0,5,1,NULL),
('questionnaire_in_marriage_property_division_dispute','G1','共同财产范围清晰','共同财产范围清晰','共同财产范围清晰','能大致列明共同财产范围与来源','boolean',1,6,1,NULL),

-- 16 离婚后损害责任纠纷
('questionnaire_post_divorce_damage_liability_dispute','G0','离婚事实已生效','离婚事实已生效','离婚事实已生效','离婚已生效/已领取离婚证/判决已生效','boolean',1,1,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G0','存在婚内严重过错或侵害事实线索','存在婚内严重过错或侵害事实线索','存在婚内严重过错或侵害事实线索','婚内过错或侵害事实线索存在','boolean',1,2,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G1','存在精神损害或经济损失后果','存在精神损害或经济损失后果','存在精神损害或经济损失后果','已产生后果/损失线索','boolean',1,1,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G1','已收集可补强的过错/后果证据线索','已收集可补强的过错/后果证据线索','已收集可补强的过错/后果证据线索','已有聊天/录音/病历等证据线索','boolean',0,2,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G1','明确请求赔偿范围','明确请求赔偿范围','明确请求赔偿范围','明确请求赔偿范围/金额/计算依据','boolean',1,3,1,NULL),
('questionnaire_post_divorce_damage_liability_dispute','G1','有具体损失或治疗费用/收入损失线索','有具体损失或治疗费用/收入损失线索','有具体损失或治疗费用/收入损失线索','能证明具体费用/损失或收入损失线索','boolean',0,4,1,NULL),

-- 17 婚姻无效纠纷
('questionnaire_marriage_invalid_dispute','G0','存在无效婚姻原因线索','存在无效婚姻原因线索','存在无效婚姻原因线索','存在导致婚姻无效的事实线索','boolean',1,1,1,NULL),
('questionnaire_marriage_invalid_dispute','G0','请求确认婚姻无效','请求确认婚姻无效','请求确认婚姻无效','请求法院确认婚姻无效','boolean',1,2,1,NULL),
('questionnaire_marriage_invalid_dispute','G1','是否涉及重婚或与他人同居','是否涉及重婚或与他人同居','是否涉及重婚或与他人同居','存在重婚或与他人同居无效情形线索','boolean',0,1,1,NULL),
('questionnaire_marriage_invalid_dispute','G1','是否涉及近亲结婚或未达婚龄','是否涉及近亲结婚或未达婚龄','是否涉及近亲结婚或未达婚龄','存在近亲结婚或未达婚龄等无效情形线索','boolean',0,2,1,NULL),
('questionnaire_marriage_invalid_dispute','G1','有证据材料可补强','有证据材料可补强','有证据材料可补强','已有或可调取证明无效原因的材料','boolean',1,3,1,NULL),
('questionnaire_marriage_invalid_dispute','G1','是否已办理结婚登记','是否已办理结婚登记','是否已办理结婚登记','是否存在结婚登记信息/结婚证','boolean',0,4,1,NULL),

-- 18 撤销婚姻纠纷
('questionnaire_marriage_annulment_dispute','G0','存在撤销原因线索','存在撤销原因线索','存在撤销原因线索','存在胁迫/欺诈/隐瞒重大疾病等撤销原因线索','boolean',1,1,1,NULL),
('questionnaire_marriage_annulment_dispute','G0','请求撤销婚姻','请求撤销婚姻','请求撤销婚姻','请求法院撤销婚姻','boolean',1,2,1,NULL),
('questionnaire_marriage_annulment_dispute','G1','存在胁迫或控制行为证据','存在胁迫或控制行为证据','存在胁迫或控制行为证据','存在胁迫/控制行为证据线索','boolean',0,1,1,NULL),
('questionnaire_marriage_annulment_dispute','G1','存在欺诈或隐瞒重大疾病证据','存在欺诈或隐瞒重大疾病证据','存在欺诈或隐瞒重大疾病证据','存在欺诈/隐瞒重大疾病证据线索','boolean',0,2,1,NULL),
('questionnaire_marriage_annulment_dispute','G1','有证据材料可补强','有证据材料可补强','有证据材料可补强','已有或可调取用于证明撤销原因的材料','boolean',1,3,1,NULL),
('questionnaire_marriage_annulment_dispute','G1','撤销后财产返还或损害赔偿需求','撤销后财产返还或损害赔偿需求','撤销后财产返还或损害赔偿需求','撤销后涉及财产返还/损害赔偿需求','boolean',0,4,1,NULL),
('questionnaire_marriage_annulment_dispute','G1','存在未成年子女需抚养安排','存在未成年子女需抚养安排','存在未成年子女需抚养安排','撤销后需考虑子女抚养安排','boolean',0,5,1,NULL),

-- 19 夫妻财产约定纠纷
('questionnaire_spousal_property_agreement_dispute','G0','存在夫妻财产约定协议','存在夫妻财产约定协议','存在夫妻财产约定协议','双方存在夫妻财产约定协议或约定材料','boolean',1,1,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G0','约定内容明确','约定内容明确','约定内容明确','协议内容明确具体','boolean',1,2,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G1','协议未履行或争议履行','协议未履行或争议履行','协议未履行或争议履行','对方未履行或履行存在争议','boolean',1,1,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G1','对方主张协议无效或被撤销','对方主张协议无效或被撤销','对方主张协议无效或被撤销','对方主张协议无效/被撤销','boolean',0,2,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G0','请求确认协议有效并要求履行','请求确认协议有效并要求履行','请求确认协议有效并要求履行','请求确认协议有效并要求履行','boolean',1,3,1,NULL),
('questionnaire_spousal_property_agreement_dispute','G2','有证据材料可补强','有证据材料可补强','有证据材料可补强','已有或可调取协议文本、公证/登记、催告履行证据','boolean',1,1,1,NULL),

-- 20 同居关系纠纷
('questionnaire_cohabitation_dispute','G0','是否存在同居关系','是否存在同居关系','是否存在同居关系','存在同居关系（未办结婚登记）','boolean',1,1,1,NULL),
('questionnaire_cohabitation_dispute','G1','同居期间共同生活或共同投入','同居期间共同生活或共同投入','同居期间共同生活或共同投入','存在共同生活、支出或共同投入','boolean',1,1,1,NULL),
('questionnaire_cohabitation_dispute','G1','共同财产范围清晰','共同财产范围清晰','共同财产范围清晰','能列明共同财产范围与来源','boolean',1,2,1,NULL),
('questionnaire_cohabitation_dispute','G1','存在财产分割争议','存在财产分割争议','存在财产分割争议','对财产归属/价值存在争议','boolean',1,3,1,NULL),
('questionnaire_cohabitation_dispute','G1','是否存在子女','是否存在子女','是否存在子女','同居期间有子女','boolean',0,4,1,NULL),
('questionnaire_cohabitation_dispute','G1','子女主要由一方抚养','子女主要由一方抚养','子女主要由一方抚养','目前主要由一方照顾抚养','boolean',0,5,1,NULL),
('questionnaire_cohabitation_dispute','G1','对方拒绝或未支付抚养费','对方拒绝或未支付抚养费','对方拒绝或未支付抚养费','对方拒绝或未足额支付抚养费','boolean',0,6,1,NULL),
('questionnaire_cohabitation_dispute','G2','有关键同住/转账/沟通证据','有关键同住/转账/沟通证据','有关键同住/转账/沟通证据','可提供同住证据、转账流水及沟通记录','boolean',0,1,1,NULL),

-- 21 亲子确认
('questionnaire_paternity_confirmation_dispute','G0','存在亲子关系争议','存在亲子关系争议','存在亲子关系争议','当事人对亲子关系存在争议','boolean',1,1,1,NULL),
('questionnaire_paternity_confirmation_dispute','G0','请求确认亲子关系','请求确认亲子关系','请求确认亲子关系','请求法院确认亲子关系','boolean',1,2,1,NULL),
('questionnaire_paternity_confirmation_dispute','G1','是否已做亲子鉴定','是否已做亲子鉴定','是否已做亲子鉴定','已做亲子鉴定','boolean',0,1,1,NULL),
('questionnaire_paternity_confirmation_dispute','G1','亲子鉴定结论支持主张','亲子鉴定结论支持主张','亲子鉴定结论支持主张','鉴定结论支持确认主张','boolean',1,2,1,NULL),
('questionnaire_paternity_confirmation_dispute','G1','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明','有出生证明/户口/亲属关系材料','boolean',0,3,1,NULL),
('questionnaire_paternity_confirmation_dispute','G2','有证据材料可补强','有证据材料可补强','有证据材料可补强','已有或可调取证明材料','boolean',1,1,1,NULL),

-- 21 亲子否认
('questionnaire_paternity_disclaimer_dispute','G0','存在亲子关系争议','存在亲子关系争议','存在亲子关系争议','当事人对亲子关系存在争议','boolean',1,1,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G0','请求否认亲子关系','请求否认亲子关系','请求否认亲子关系','请求法院否认亲子关系','boolean',1,2,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G1','是否已做亲子鉴定','是否已做亲子鉴定','是否已做亲子鉴定','已做亲子鉴定','boolean',0,1,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G1','亲子鉴定结论不支持主张','亲子鉴定结论不支持主张','亲子鉴定结论不支持主张','鉴定结论不支持否认方主张','boolean',0,2,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G1','亲子鉴定结论支持否认方主张','亲子鉴定结论支持否认方主张','亲子鉴定结论支持否认方主张','鉴定结论支持否认方主张','boolean',1,3,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G1','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明','有出生证明/户口/亲属关系材料','boolean',0,4,1,NULL),
('questionnaire_paternity_disclaimer_dispute','G2','有证据材料可补强','有证据材料可补强','有证据材料可补强','已有或可调取证明材料','boolean',1,1,1,NULL),

-- 23 扶养纠纷
('questionnaire_sibling_support_dispute','G0','存在扶养义务关系','存在扶养义务关系','存在扶养义务关系','存在扶养义务关系或可能义务主体','boolean',1,1,1,NULL),
('questionnaire_sibling_support_dispute','G0','被扶养人生活困难','被扶养人生活困难','被扶养人生活困难','被扶养人生活困难','boolean',1,2,1,NULL),
('questionnaire_sibling_support_dispute','G1','扶养人收入能力明确','扶养人收入能力明确','扶养人收入能力明确','扶养人具备收入/能力分担扶养义务','boolean',1,1,1,NULL),
('questionnaire_sibling_support_dispute','G1','拒绝履行或未足额支付','拒绝履行或未足额支付','拒绝履行或未足额支付','拒绝履行或支付不足','boolean',1,2,1,NULL),
('questionnaire_sibling_support_dispute','G1','主张变更扶养关系','主张变更扶养关系','主张变更扶养关系','主张变更扶养关系/扶养安排','boolean',0,3,1,NULL),
('questionnaire_sibling_support_dispute','G1','变更原因属于法定情形','变更原因属于法定情形','变更原因属于法定情形','变更理由属于法定情形','boolean',0,4,1,NULL),
('questionnaire_sibling_support_dispute','G2','有关键收入/医疗/沟通与转账证据','有关键收入/医疗/沟通与转账证据','有关键收入/医疗/沟通与转账证据','可提供收入证明/医疗/沟通与转账证据','boolean',0,1,1,NULL),

-- 25 收养关系
('questionnaire_adoption_dispute','G0','请求确认收养关系','请求确认收养关系','请求确认收养关系','请求确认收养关系成立','boolean',1,1,1,NULL),
('questionnaire_adoption_dispute','G0','请求解除收养关系','请求解除收养关系','请求解除收养关系','请求解除收养关系','boolean',0,2,1,NULL),
('questionnaire_adoption_dispute','G1','是否已办理收养登记','是否已办理收养登记','是否已办理收养登记','已办理收养登记/可查询登记记录','boolean',1,1,1,NULL),
('questionnaire_adoption_dispute','G1','存在事实收养长期维持','存在事实收养长期维持','存在事实收养长期维持','未办理登记但长期以收养方式相处/照顾','boolean',0,2,1,NULL),
('questionnaire_adoption_dispute','G1','存在收养协议或照顾记录','存在收养协议或照顾记录','存在收养协议或照顾记录','存在收养协议、照顾记录或证明材料','boolean',0,3,1,NULL),
('questionnaire_adoption_dispute','G1','存在解除原因线索','存在解除原因线索','存在解除原因线索','存在解除收养的原因线索（矛盾/不尽扶养等）','boolean',0,4,1,NULL),
('questionnaire_adoption_dispute','G2','有证据材料可补强','有证据材料可补强','有证据材料可补强','已有或可调取用于确认/解除的证据材料','boolean',1,1,1,NULL),

-- 26 监护权
('questionnaire_guardianship_dispute','G0','需要确定或变更监护人','需要确定或变更监护人','需要确定或变更监护人','需要法院指定或变更监护人','boolean',1,1,1,NULL),
('questionnaire_guardianship_dispute','G1','被监护人无或限制民事行为能力','被监护人无或限制民事行为能力','被监护人无或限制民事行为能力','被监护人属于无/限制民事行为能力状态','boolean',1,2,1,NULL),
('questionnaire_guardianship_dispute','G1','有医学鉴定或诊断证据','有医学鉴定或诊断证据','有医学鉴定或诊断证据','有病历/诊断或鉴定结论证据','boolean',1,3,1,NULL),
('questionnaire_guardianship_dispute','G1','当前监护人不适合或不履行','当前监护人不适合或不履行','当前监护人不适合或不履行','现任监护人不适合或不能有效履行','boolean',0,4,1,NULL),
('questionnaire_guardianship_dispute','G0','请求指定或变更监护人','请求指定或变更监护人','请求指定或变更监护人','明确请求指定/变更监护人','boolean',1,2,1,NULL),
('questionnaire_guardianship_dispute','G2','有证据材料可补强','有证据材料可补强','有证据材料可补强','已有或可调取相关证据材料与申请文书线索','boolean',1,1,1,NULL),

-- 27 探望权
('questionnaire_visitation_dispute','G0','已离婚或已分开','已离婚或已分开','已离婚或已分开','已离婚或已分开','boolean',1,1,1,NULL),
('questionnaire_visitation_dispute','G0','为非直接抚养方','为非直接抚养方','为非直接抚养方','申请探望的一方为非直接抚养方','boolean',1,2,1,NULL),
('questionnaire_visitation_dispute','G1','存在拒绝探望或障碍','存在拒绝探望或障碍','存在拒绝探望或障碍','存在拒绝探望或客观障碍','boolean',1,1,1,NULL),
('questionnaire_visitation_dispute','G1','存在探望安排协议或文书','存在探望安排协议或文书','存在探望安排协议或文书','存在探望安排协议或文书','boolean',0,2,1,NULL),
('questionnaire_visitation_dispute','G1','有探望实施或沟通记录','有探望实施或沟通记录','有探望实施或沟通记录','有实施探望或沟通记录','boolean',0,3,1,NULL),
('questionnaire_visitation_dispute','G0','请求法院明确探望方式时间','请求法院明确探望方式时间','请求法院明确探望方式时间','请求法院明确探望方式/时间/执行安排','boolean',1,3,1,NULL),
('questionnaire_visitation_dispute','G2','有关键沟通/录音/视频证据','有关键沟通/录音/视频证据','有关键沟通/录音/视频证据','可提供沟通/录音/视频等证据线索','boolean',0,1,1,NULL),

-- 28 分家析产
('questionnaire_family_partition_dispute','G0','家庭共同生活或共同置办财产','家庭共同生活或共同置办财产','家庭共同生活或共同置办财产','同堂共同生活并共同置办财产','boolean',1,1,1,NULL),
('questionnaire_family_partition_dispute','G1','共同财产范围清晰','共同财产范围清晰','共同财产范围清晰','共同财产范围与来源清晰','boolean',1,1,1,NULL),
('questionnaire_family_partition_dispute','G1','有不动产或财产登记证据','有不动产或财产登记证据','有不动产或财产登记证据','有房产/不动产登记或财产登记凭证','boolean',0,2,1,NULL),
('questionnaire_family_partition_dispute','G1','存在分割争议','存在分割争议','存在分割争议','对归属/份额/价值存在争议','boolean',1,3,1,NULL),
('questionnaire_family_partition_dispute','G0','请求分割/析产','请求分割/析产','请求分割/析产','请求分家析产/确定各自权利份额','boolean',1,2,1,NULL),
('questionnaire_family_partition_dispute','G1','有资金来源与支付证据','有资金来源与支付证据','有资金来源与支付证据','有出资与支付凭证或资金来源材料','boolean',0,4,1,NULL),
('questionnaire_family_partition_dispute','G2','有财产清单/账本/沟通记录','有财产清单/账本/沟通记录','有财产清单/账本/沟通记录','有财产清单/账本/沟通记录等','boolean',0,1,1,NULL)
ON DUPLICATE KEY UPDATE
label=VALUES(label),
hint=VALUES(hint),
input_type=VALUES(input_type),
required=VALUES(required),
question_order=VALUES(question_order),
enabled=VALUES(enabled),
unit=VALUES(unit);

-- -------------------------
-- 5) Step2 target
-- -------------------------
INSERT INTO rule_step2_target (target_id, title, descr, enabled)
VALUES
('target_in_marriage_division_conceal_transfer','婚内财产分割：藏匿/转移处理方案','围绕婚内共同财产争议、藏匿转移线索与范围清晰提出分割证成。',1),
('target_in_marriage_division_waste_medical','婚内财产分割：挥霍/恶意处置与医疗紧急应对','围绕挥霍/恶意处置、重大医疗支出/紧急治疗需求与范围清晰提出处置方案。',1),

('target_post_divorce_damage_spirit','离婚后损害：精神损害/责任要件与请求范围','围绕过错侵害事实、后果损害与请求范围组织证据补强。',1),
('target_post_divorce_damage_economic','离婚后损害：经济损失/费用与证据链','围绕后果、可补强证据线索与具体费用/损失组织证据。',1),

('target_invalid_marriage_confirm','婚姻无效：确认无效与关键要件','围绕无效原因线索、确认请求与证据材料组织证成。',1),
('target_invalid_marriage_property_return','婚姻无效：财产返还/子女安排（证据补强）','围绕结婚登记信息与证据材料组织返还/安排论证。',1),

('target_annulment_request','撤销婚姻：撤销原因与请求证成','围绕撤销原因线索、撤销请求与证据材料组织证成。',1),
('target_annulment_effects','撤销婚姻：撤销后的财产返还与子女抚养安排','围绕撤销后需求、子女抚养安排与证据材料组织方案。',1),

('target_spousal_agreement_enforce','夫妻财产约定：协议有效并要求履行','围绕协议存在、约定明确性、未履行/争议与请求履行组织证成。',1),
('target_spousal_agreement_defense','夫妻财产约定：无效/被撤销抗辩的证据应对','围绕无效/被撤销主张、证据材料与约定明确性组织反证。',1),

('target_cohab_property_partition','同居财产：同居投入与析产方案','围绕同居关系、共同投入/财产范围清晰与分割争议组织证成。',1),
('target_cohab_child_custody','同居子女：抚养费/抚养关系处理方案','围绕存在子女、主要抚养状况与拒绝/未支付抚养费组织方案。',1),

('target_paternity_confirm','亲子确认：亲子争议与鉴定支持证成','围绕确认请求、亲子争议与鉴定支持结论组织证成。',1),
('target_paternity_confirm_evidence','亲子确认：出生/户籍/亲属关系与证据补强','围绕鉴定结论支持与证据材料组织证成补强。',1),

('target_paternity_disclaimer','亲子否认：鉴定支持否认主张与请求证成','围绕否认请求、亲子争议与鉴定支持否认结论组织证成。',1),
('target_paternity_disclaimer_evidence','亲子否认：出生/户籍/亲属关系与证据补强','围绕鉴定支持与证据材料组织证成补强。',1),

('target_sibling_support_fee_claim','扶养费/扶养安排：扶养义务与履行不足','围绕扶养义务、生活困难、能力与拒绝履行/不足组织证成。',1),
('target_sibling_support_change','扶养变更：法定情形与生活困难证成','围绕变更主张、法定情形与生活困难组织证成。',1),

('target_adoption_confirm','收养确认：登记/事实与证据补强','围绕确认请求、收养登记及证据材料组织证成。',1),
('target_adoption_dissolve','收养解除：解除原因与证据补强','围绕解除请求、解除原因线索与证据材料组织证成。',1),

('target_guardianship_assign','监护权指定/变更：能力与鉴定证据要件','围绕监护需求、无/限制能力、医学鉴定与请求指定组织证成。',1),
('target_guardianship_evidence','监护权材料整合：现任监护不适合/不履行与证据补强','围绕证据材料与现任监护不适合/不履行组织反证/证成。',1),

('target_visitation_fix','探望权：拒绝/障碍与明确探望请求证成','围绕非直接抚养、拒绝探望/障碍与明确探望请求组织证成。',1),
('target_visitation_evidence','探望权：探望安排文书与沟通实施证据补强','围绕探望文书与实施/沟通记录组织证成补强。',1),

('target_family_partition_plan','分家析产：共同生活投入与析产请求证成','围绕共同生活/置办、共同财产范围清晰、分割争议与请求组织证成。',1),
('target_family_partition_evidence','分家析产：财产清单/登记证据与资金来源补强','围绕财产范围清晰、不动产登记证据与清单/账本证据组织。',1)
ON DUPLICATE KEY UPDATE
title=VALUES(title),
descr=VALUES(descr),
enabled=VALUES(enabled);

-- target - 法条引用（复用现有 law_id；保证外键可用）
INSERT IGNORE INTO rule_step2_target_legal_ref (target_id, law_id, sort_order)
VALUES
-- in_marriage_property_division_dispute
('target_in_marriage_division_conceal_transfer','law_1087',1),('target_in_marriage_division_conceal_transfer','law_1092',2),
('target_in_marriage_division_waste_medical','law_1087',1),('target_in_marriage_division_waste_medical','law_1085',2),

-- post_divorce_damage_liability_dispute
('target_post_divorce_damage_spirit','law_1079',1),('target_post_divorce_damage_spirit','law_1087',2),
('target_post_divorce_damage_economic','law_1079',1),('target_post_divorce_damage_economic','law_1087',2),

-- marriage_invalid_dispute
('target_invalid_marriage_confirm','law_1079',1),('target_invalid_marriage_confirm','law_1087',2),
('target_invalid_marriage_property_return','law_1079',1),('target_invalid_marriage_property_return','law_1087',2),

-- marriage_annulment_dispute
('target_annulment_request','law_1079',1),('target_annulment_request','law_1087',2),
('target_annulment_effects','law_1079',1),('target_annulment_effects','law_1087',2),

-- spousal_property_agreement_dispute
('target_spousal_agreement_enforce','law_1087',1),('target_spousal_agreement_enforce','law_1092',2),
('target_spousal_agreement_defense','law_1087',1),

-- cohabitation_dispute
('target_cohab_property_partition','law_1087',1),('target_cohab_property_partition','law_1062',2),
('target_cohab_child_custody','law_1084',1),('target_cohab_child_custody','law_1085',2),

-- paternity_confirmation_dispute / disclaimer
('target_paternity_confirm','law_1084',1),
('target_paternity_confirm_evidence','law_1084',1),
('target_paternity_disclaimer','law_1084',1),
('target_paternity_disclaimer_evidence','law_1084',1),

-- sibling_support_dispute
('target_sibling_support_fee_claim','law_1067',1),
('target_sibling_support_change','law_1067',1),

-- adoption_dispute / guardianship / visitation
('target_adoption_confirm','law_1084',1),
('target_adoption_dissolve','law_1084',1),
('target_guardianship_assign','law_1084',1),
('target_guardianship_evidence','law_1084',1),
('target_visitation_fix','law_1084',1),
('target_visitation_evidence','law_1084',1),

-- family_partition_dispute
('target_family_partition_plan','law_1087',1),
('target_family_partition_evidence','law_1087',1),('target_family_partition_evidence','law_1092',2);

-- cause - target 映射
INSERT IGNORE INTO rule_cause_target (cause_code, target_id, sort_order)
VALUES
('in_marriage_property_division_dispute','target_in_marriage_division_conceal_transfer',1),
('in_marriage_property_division_dispute','target_in_marriage_division_waste_medical',2),

('post_divorce_damage_liability_dispute','target_post_divorce_damage_spirit',1),
('post_divorce_damage_liability_dispute','target_post_divorce_damage_economic',2),

('marriage_invalid_dispute','target_invalid_marriage_confirm',1),
('marriage_invalid_dispute','target_invalid_marriage_property_return',2),

('marriage_annulment_dispute','target_annulment_request',1),
('marriage_annulment_dispute','target_annulment_effects',2),

('spousal_property_agreement_dispute','target_spousal_agreement_enforce',1),
('spousal_property_agreement_dispute','target_spousal_agreement_defense',2),

('cohabitation_dispute','target_cohab_property_partition',1),
('cohabitation_dispute','target_cohab_child_custody',2),

('paternity_confirmation_dispute','target_paternity_confirm',1),
('paternity_confirmation_dispute','target_paternity_confirm_evidence',2),

('paternity_disclaimer_dispute','target_paternity_disclaimer',1),
('paternity_disclaimer_dispute','target_paternity_disclaimer_evidence',2),

('sibling_support_dispute','target_sibling_support_fee_claim',1),
('sibling_support_dispute','target_sibling_support_change',2),

('adoption_dispute','target_adoption_confirm',1),
('adoption_dispute','target_adoption_dissolve',2),

('guardianship_dispute','target_guardianship_assign',1),
('guardianship_dispute','target_guardianship_evidence',2),

('visitation_dispute','target_visitation_fix',1),
('visitation_dispute','target_visitation_evidence',2),

('family_partition_dispute','target_family_partition_plan',1),
('family_partition_dispute','target_family_partition_evidence',2);

-- target - required_fact
INSERT IGNORE INTO rule_step2_required_fact (target_id, fact_key, label, required_order, enabled)
VALUES
-- 13 targets
('target_in_marriage_division_conceal_transfer','存在婚内共同财产争议','存在婚内共同财产争议',1,1),
('target_in_marriage_division_conceal_transfer','存在藏匿转移共同财产线索','存在藏匿转移共同财产线索',2,1),
('target_in_marriage_division_conceal_transfer','共同财产范围清晰','共同财产范围清晰',3,1),

('target_in_marriage_division_waste_medical','存在婚内共同财产争议','存在婚内共同财产争议',1,1),
('target_in_marriage_division_waste_medical','存在挥霍家产或恶意处置','存在挥霍家产或恶意处置',2,1),
('target_in_marriage_division_waste_medical','存在重大医疗支出或紧急治疗需求','存在重大医疗支出或紧急治疗需求',3,1),
('target_in_marriage_division_waste_medical','共同财产范围清晰','共同财产范围清晰',4,1),

-- 16 targets
('target_post_divorce_damage_spirit','明确请求赔偿范围','明确请求赔偿范围',1,1),
('target_post_divorce_damage_spirit','存在精神损害或经济损失后果','存在精神损害或经济损失后果',2,1),
('target_post_divorce_damage_spirit','存在婚内严重过错或侵害事实线索','存在婚内严重过错或侵害事实线索',3,1),

('target_post_divorce_damage_economic','存在精神损害或经济损失后果','存在精神损害或经济损失后果',1,1),
('target_post_divorce_damage_economic','已收集可补强的过错/后果证据线索','已收集可补强的过错/后果证据线索',2,1),
('target_post_divorce_damage_economic','有具体损失或治疗费用/收入损失线索','有具体损失或治疗费用/收入损失线索',3,1),

-- 17 targets
('target_invalid_marriage_confirm','存在无效婚姻原因线索','存在无效婚姻原因线索',1,1),
('target_invalid_marriage_confirm','请求确认婚姻无效','请求确认婚姻无效',2,1),
('target_invalid_marriage_confirm','有证据材料可补强','有证据材料可补强',3,1),

('target_invalid_marriage_property_return','请求确认婚姻无效','请求确认婚姻无效',1,1),
('target_invalid_marriage_property_return','是否已办理结婚登记','是否已办理结婚登记',2,1),
('target_invalid_marriage_property_return','有证据材料可补强','有证据材料可补强',3,1),

-- 18 targets
('target_annulment_request','存在撤销原因线索','存在撤销原因线索',1,1),
('target_annulment_request','请求撤销婚姻','请求撤销婚姻',2,1),
('target_annulment_request','有证据材料可补强','有证据材料可补强',3,1),

('target_annulment_effects','撤销后财产返还或损害赔偿需求','撤销后财产返还或损害赔偿需求',1,1),
('target_annulment_effects','存在未成年子女需抚养安排','存在未成年子女需抚养安排',2,1),
('target_annulment_effects','有证据材料可补强','有证据材料可补强',3,1),

-- 19 targets
('target_spousal_agreement_enforce','存在夫妻财产约定协议','存在夫妻财产约定协议',1,1),
('target_spousal_agreement_enforce','约定内容明确','约定内容明确',2,1),
('target_spousal_agreement_enforce','协议未履行或争议履行','协议未履行或争议履行',3,1),
('target_spousal_agreement_enforce','请求确认协议有效并要求履行','请求确认协议有效并要求履行',4,1),

('target_spousal_agreement_defense','对方主张协议无效或被撤销','对方主张协议无效或被撤销',1,1),
('target_spousal_agreement_defense','有证据材料可补强','有证据材料可补强',2,1),
('target_spousal_agreement_defense','约定内容明确','约定内容明确',3,1),

-- 20 targets
('target_cohab_property_partition','是否存在同居关系','是否存在同居关系',1,1),
('target_cohab_property_partition','同居期间共同生活或共同投入','同居期间共同生活或共同投入',2,1),
('target_cohab_property_partition','共同财产范围清晰','共同财产范围清晰',3,1),
('target_cohab_property_partition','存在财产分割争议','存在财产分割争议',4,1),

('target_cohab_child_custody','是否存在子女','是否存在子女',1,1),
('target_cohab_child_custody','子女主要由一方抚养','子女主要由一方抚养',2,1),
('target_cohab_child_custody','对方拒绝或未支付抚养费','对方拒绝或未支付抚养费',3,1),

-- 21 targets: 确认
('target_paternity_confirm','存在亲子关系争议','存在亲子关系争议',1,1),
('target_paternity_confirm','请求确认亲子关系','请求确认亲子关系',2,1),
('target_paternity_confirm','亲子鉴定结论支持主张','亲子鉴定结论支持主张',3,1),

('target_paternity_confirm_evidence','亲子鉴定结论支持主张','亲子鉴定结论支持主张',1,1),
('target_paternity_confirm_evidence','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明',2,1),
('target_paternity_confirm_evidence','有证据材料可补强','有证据材料可补强',3,1),

-- 21 targets: 否认
('target_paternity_disclaimer','存在亲子关系争议','存在亲子关系争议',1,1),
('target_paternity_disclaimer','请求否认亲子关系','请求否认亲子关系',2,1),
('target_paternity_disclaimer','亲子鉴定结论支持否认方主张','亲子鉴定结论支持否认方主张',3,1),

('target_paternity_disclaimer_evidence','亲子鉴定结论支持否认方主张','亲子鉴定结论支持否认方主张',1,1),
('target_paternity_disclaimer_evidence','有出生证明/户口簿或亲属关系证明','有出生证明/户口簿或亲属关系证明',2,1),
('target_paternity_disclaimer_evidence','有证据材料可补强','有证据材料可补强',3,1),

-- 23 targets
('target_sibling_support_fee_claim','存在扶养义务关系','存在扶养义务关系',1,1),
('target_sibling_support_fee_claim','被扶养人生活困难','被扶养人生活困难',2,1),
('target_sibling_support_fee_claim','扶养人收入能力明确','扶养人收入能力明确',3,1),
('target_sibling_support_fee_claim','拒绝履行或未足额支付','拒绝履行或未足额支付',4,1),

('target_sibling_support_change','主张变更扶养关系','主张变更扶养关系',1,1),
('target_sibling_support_change','变更原因属于法定情形','变更原因属于法定情形',2,1),
('target_sibling_support_change','被扶养人生活困难','被扶养人生活困难',3,1),

-- 25 targets
('target_adoption_confirm','请求确认收养关系','请求确认收养关系',1,1),
('target_adoption_confirm','是否已办理收养登记','是否已办理收养登记',2,1),
('target_adoption_confirm','有证据材料可补强','有证据材料可补强',3,1),

('target_adoption_dissolve','请求解除收养关系','请求解除收养关系',1,1),
('target_adoption_dissolve','存在解除原因线索','存在解除原因线索',2,1),
('target_adoption_dissolve','有证据材料可补强','有证据材料可补强',3,1),

-- 26 targets
('target_guardianship_assign','需要确定或变更监护人','需要确定或变更监护人',1,1),
('target_guardianship_assign','被监护人无或限制民事行为能力','被监护人无或限制民事行为能力',2,1),
('target_guardianship_assign','有医学鉴定或诊断证据','有医学鉴定或诊断证据',3,1),
('target_guardianship_assign','请求指定或变更监护人','请求指定或变更监护人',4,1),

('target_guardianship_evidence','有证据材料可补强','有证据材料可补强',1,1),
('target_guardianship_evidence','当前监护人不适合或不履行','当前监护人不适合或不履行',2,1),
('target_guardianship_evidence','请求指定或变更监护人','请求指定或变更监护人',3,1),

-- 27 targets
('target_visitation_fix','为非直接抚养方','为非直接抚养方',1,1),
('target_visitation_fix','存在拒绝探望或障碍','存在拒绝探望或障碍',2,1),
('target_visitation_fix','请求法院明确探望方式时间','请求法院明确探望方式时间',3,1),

('target_visitation_evidence','存在探望安排协议或文书','存在探望安排协议或文书',1,1),
('target_visitation_evidence','有探望实施或沟通记录','有探望实施或沟通记录',2,1),
('target_visitation_evidence','请求法院明确探望方式时间','请求法院明确探望方式时间',3,1),

-- 28 targets
('target_family_partition_plan','家庭共同生活或共同置办财产','家庭共同生活或共同置办财产',1,1),
('target_family_partition_plan','共同财产范围清晰','共同财产范围清晰',2,1),
('target_family_partition_plan','存在分割争议','存在分割争议',3,1),
('target_family_partition_plan','请求分割/析产','请求分割/析产',4,1),

('target_family_partition_evidence','共同财产范围清晰','共同财产范围清晰',1,1),
('target_family_partition_evidence','有不动产或财产登记证据','有不动产或财产登记证据',2,1),
('target_family_partition_evidence','有财产清单/账本/沟通记录','有财产清单/账本/沟通记录',3,1);

-- target - evidence_type
-- 规则：evidence_type 字符串里尽量包含触发内置“证据追问”的关键词（转账/流水/聊天/病历/诊断/登记/合同/出生证明/亲子鉴定等）
INSERT IGNORE INTO rule_step2_evidence_type (target_id, fact_key, evidence_type, evidence_order, other_option, enabled)
VALUES
-- 13 - conceal/transfer
('target_in_marriage_division_conceal_transfer','存在婚内共同财产争议','财产线索清单/不动产登记信息',1,0,1),
('target_in_marriage_division_conceal_transfer','存在婚内共同财产争议','沟通记录/争议要点说明',2,0,1),
('target_in_marriage_division_conceal_transfer','存在藏匿转移共同财产线索','转账流水/交易记录/账户明细',1,0,1),
('target_in_marriage_division_conceal_transfer','存在藏匿转移共同财产线索','收条/借条/凭证',2,0,1),
('target_in_marriage_division_conceal_transfer','共同财产范围清晰','房产证/不动产登记信息/资产负债清单',1,0,1),
('target_in_marriage_division_conceal_transfer','共同财产范围清晰','合同/登记凭证/产权材料',2,0,1),

-- 13 - waste/medical
('target_in_marriage_division_waste_medical','存在婚内共同财产争议','共同财产证据清单/登记材料',1,0,1),
('target_in_marriage_division_waste_medical','存在婚内共同财产争议','聊天截图/协商记录',2,0,1),
('target_in_marriage_division_waste_medical','存在挥霍家产或恶意处置','消费记录/聊天截图/转账流水',1,0,1),
('target_in_marriage_division_waste_medical','存在挥霍家产或恶意处置','证人证言/转账凭证',2,0,1),
('target_in_marriage_division_waste_medical','存在重大医疗支出或紧急治疗需求','病历/诊断证明/医疗票据/费用清单',1,0,1),
('target_in_marriage_division_waste_medical','存在重大医疗支出或紧急治疗需求','护理证明/失能证明/治疗费用材料',2,0,1),
('target_in_marriage_division_waste_medical','共同财产范围清晰','房产证/银行流水/不动产登记信息',1,0,1),
('target_in_marriage_division_waste_medical','共同财产范围清晰','财产清单/账本/共同购置记录',2,0,1),

-- 16 - spirit
('target_post_divorce_damage_spirit','明确请求赔偿范围','费用明细/支出清单/工资流水',1,0,1),
('target_post_divorce_damage_spirit','明确请求赔偿范围','聊天记录/催告记录',2,0,1),
('target_post_divorce_damage_spirit','存在精神损害或经济损失后果','医疗诊断/病历/费用清单',1,0,1),
('target_post_divorce_damage_spirit','存在精神损害或经济损失后果','收入损失/工资流水/社保公积金',2,0,1),
('target_post_divorce_damage_spirit','存在婚内严重过错或侵害事实线索','聊天记录/录音/报警记录/照片',1,0,1),
('target_post_divorce_damage_spirit','存在婚内严重过错或侵害事实线索','转账流水/隐匿转移交易记录',2,0,1),

-- 16 - economic
('target_post_divorce_damage_economic','存在精神损害或经济损失后果','费用清单/医疗票据/支付凭证',1,0,1),
('target_post_divorce_damage_economic','存在精神损害或经济损失后果','收入损失/工资流水/个税社保公积金',2,0,1),
('target_post_divorce_damage_economic','已收集可补强的过错/后果证据线索','病历/诊断证明/鉴定结论',1,0,1),
('target_post_divorce_damage_economic','已收集可补强的过错/后果证据线索','聊天记录/录音/转账凭证',2,0,1),
('target_post_divorce_damage_economic','有具体损失或治疗费用/收入损失线索','医疗票据/治疗费用/护理费证据',1,0,1),
('target_post_divorce_damage_economic','有具体损失或治疗费用/收入损失线索','工资流水/银行回单/支付明细',2,0,1),

-- 17 - invalid confirm
('target_invalid_marriage_confirm','存在无效婚姻原因线索','报警记录/聊天记录/同住证据',1,0,1),
('target_invalid_marriage_confirm','存在无效婚姻原因线索','亲属关系/身份材料/登记信息',2,0,1),
('target_invalid_marriage_confirm','请求确认婚姻无效','起诉状/证据清单/材料目录',1,0,1),
('target_invalid_marriage_confirm','请求确认婚姻无效','沟通记录/催告证据',2,0,1),
('target_invalid_marriage_confirm','有证据材料可补强','结婚证/婚姻登记信息/登记材料',1,0,1),
('target_invalid_marriage_confirm','有证据材料可补强','户口簿/出生证明/亲属关系证明',2,0,1),

-- 17 - property return
('target_invalid_marriage_property_return','请求确认婚姻无效','离婚/婚姻登记信息/结婚证',1,0,1),
('target_invalid_marriage_property_return','请求确认婚姻无效','转账流水/财物给付凭证',2,0,1),
('target_invalid_marriage_property_return','是否已办理结婚登记','结婚证/登记信息/不动产登记信息',1,0,1),
('target_invalid_marriage_property_return','是否已办理结婚登记','户口簿/身份材料/婚姻登记记录',2,0,1),
('target_invalid_marriage_property_return','有证据材料可补强','证据清单/账本/支付凭证',1,0,1),
('target_invalid_marriage_property_return','有证据材料可补强','聊天记录/录音/转账回单',2,0,1),

-- 18 - annulment request
('target_annulment_request','存在撤销原因线索','聊天记录/录音/控制或胁迫证据',1,0,1),
('target_annulment_request','存在撤销原因线索','病历/诊断证明/鉴定结论/医疗票据',2,0,1),
('target_annulment_request','请求撤销婚姻','起诉状/证据清单/材料目录',1,0,1),
('target_annulment_request','请求撤销婚姻','登记信息/结婚证/身份材料',2,0,1),
('target_annulment_request','有证据材料可补强','证据清单/合同/登记凭证',1,0,1),
('target_annulment_request','有证据材料可补强','聊天记录/转账凭证/照片视频',2,0,1),

-- 18 - effects
('target_annulment_effects','撤销后财产返还或损害赔偿需求','转账流水/收条/借条/支付明细',1,0,1),
('target_annulment_effects','撤销后财产返还或损害赔偿需求','病历/诊断证明/费用清单',2,0,1),
('target_annulment_effects','存在未成年子女需抚养安排','出生证明/户口簿/亲子关系材料',1,0,1),
('target_annulment_effects','存在未成年子女需抚养安排','学校/培训/医疗票据/生活支出证据',2,0,1),
('target_annulment_effects','有证据材料可补强','证据清单/账本/沟通记录',1,0,1),
('target_annulment_effects','有证据材料可补强','聊天记录/录音/转账回单',2,0,1),

-- 19 - agreement enforce
('target_spousal_agreement_enforce','存在夫妻财产约定协议','协议文本/签署页/公证书/登记材料',1,0,1),
('target_spousal_agreement_enforce','存在夫妻财产约定协议','催告记录/聊天记录/履行沟通',2,0,1),
('target_spousal_agreement_enforce','约定内容明确','协议文本/合同/登记或公证材料',1,0,1),
('target_spousal_agreement_enforce','约定内容明确','聊天记录/签署过程说明',2,0,1),
('target_spousal_agreement_enforce','协议未履行或争议履行','转账流水/支付明细/催告材料',1,0,1),
('target_spousal_agreement_enforce','协议未履行或争议履行','聊天记录/沟通记录/录音',2,0,1),
('target_spousal_agreement_enforce','请求确认协议有效并要求履行','起诉状/证据清单/材料目录',1,0,1),
('target_spousal_agreement_enforce','请求确认协议有效并要求履行','合同/登记凭证/公证材料',2,0,1),

-- 19 - agreement defense
('target_spousal_agreement_defense','对方主张协议无效或被撤销','聊天记录/录音/胁迫欺诈沟通证据',1,0,1),
('target_spousal_agreement_defense','对方主张协议无效或被撤销','病历/诊断证明/鉴定结论（如涉及重大疾病）',2,0,1),
('target_spousal_agreement_defense','有证据材料可补强','公证书/登记材料/协议文本原件线索',1,0,1),
('target_spousal_agreement_defense','有证据材料可补强','转账回单/履行证据/支付凭证',2,0,1),
('target_spousal_agreement_defense','约定内容明确','合同/协议文本/条款页/签署页',1,0,1),
('target_spousal_agreement_defense','约定内容明确','登记/公证材料（如有）',2,0,1),

-- 20 - cohab property
('target_cohab_property_partition','是否存在同居关系','同住证明/租房合同/照片视频',1,0,1),
('target_cohab_property_partition','是否存在同居关系','聊天记录/通话短信/沟通证据',2,0,1),
('target_cohab_property_partition','同居期间共同生活或共同投入','转账流水/共同支出消费记录/账户明细',1,0,1),
('target_cohab_property_partition','同居期间共同生活或共同投入','共同购置合同/收条借条/支付凭证',2,0,1),
('target_cohab_property_partition','共同财产范围清晰','房产证/不动产登记信息/车辆登记信息',1,0,1),
('target_cohab_property_partition','共同财产范围清晰','财产清单/账本/资产负债明细',2,0,1),
('target_cohab_property_partition','存在财产分割争议','沟通记录/争议说明/证据清单',1,0,1),
('target_cohab_property_partition','存在财产分割争议','起诉状/材料目录/聊天记录',2,0,1),

-- 20 - cohab child custody
('target_cohab_child_custody','是否存在子女','出生证明/户口簿/亲属关系材料',1,0,1),
('target_cohab_child_custody','是否存在子女','学校/培训/医疗票据（支出证据）',2,0,1),
('target_cohab_child_custody','子女主要由一方抚养','学校/医疗/生活照护记录',1,0,1),
('target_cohab_child_custody','子女主要由一方抚养','沟通记录/生活照顾证据',2,0,1),
('target_cohab_child_custody','对方拒绝或未支付抚养费','转账流水/欠付清单/支付明细',1,0,1),
('target_cohab_child_custody','对方拒绝或未支付抚养费','聊天记录/催告录音/执行线索',2,0,1),

-- 21 paternity confirm
('target_paternity_confirm','存在亲子关系争议','亲子鉴定结论/相关鉴定材料',1,0,1),
('target_paternity_confirm','存在亲子关系争议','聊天记录/身份争议说明',2,0,1),
('target_paternity_confirm','请求确认亲子关系','出生证明/户口簿/亲属关系材料',1,0,1),
('target_paternity_confirm','请求确认亲子关系','亲子鉴定结论支持主张',2,0,1),
('target_paternity_confirm','亲子鉴定结论支持主张','亲子鉴定结论/检测报告/证据材料',1,0,1),
('target_paternity_confirm','亲子鉴定结论支持主张','出生证明/户口/亲属关系证明',2,0,1),

-- 21 paternity confirm evidence
('target_paternity_confirm_evidence','亲子鉴定结论支持主张','亲子鉴定结论/检测报告',1,0,1),
('target_paternity_confirm_evidence','亲子鉴定结论支持主张','户口簿/出生证明（配合核验）',2,0,1),
('target_paternity_confirm_evidence','有出生证明/户口簿或亲属关系证明','出生证明/户口簿/亲属关系证明',1,0,1),
('target_paternity_confirm_evidence','有出生证明/户口簿或亲属关系证明','家庭登记/身份材料',2,0,1),
('target_paternity_confirm_evidence','有证据材料可补强','证据清单/材料目录/调取线索',1,0,1),
('target_paternity_confirm_evidence','有证据材料可补强','聊天记录/签收记录/转账回单',2,0,1),

-- 21 paternity disclaimer
('target_paternity_disclaimer','存在亲子关系争议','亲子鉴定结论/相关鉴定材料',1,0,1),
('target_paternity_disclaimer','存在亲子关系争议','聊天记录/身份争议说明',2,0,1),
('target_paternity_disclaimer','请求否认亲子关系','户口簿/出生证明/亲属关系材料',1,0,1),
('target_paternity_disclaimer','请求否认亲子关系','亲子鉴定结论支持否认主张',2,0,1),
('target_paternity_disclaimer','亲子鉴定结论支持否认方主张','亲子鉴定结论/检测报告/证据材料',1,0,1),
('target_paternity_disclaimer','亲子鉴定结论支持否认方主张','出生证明/户口/亲属关系证明',2,0,1),

-- 21 paternity disclaimer evidence
('target_paternity_disclaimer_evidence','亲子鉴定结论支持否认方主张','亲子鉴定结论/检测报告',1,0,1),
('target_paternity_disclaimer_evidence','亲子鉴定结论支持否认方主张','户口簿/出生证明（配合核验）',2,0,1),
('target_paternity_disclaimer_evidence','有出生证明/户口簿或亲属关系证明','出生证明/户口簿/亲属关系证明',1,0,1),
('target_paternity_disclaimer_evidence','有出生证明/户口簿或亲属关系证明','家庭登记/身份材料',2,0,1),
('target_paternity_disclaimer_evidence','有证据材料可补强','证据清单/材料目录/调取线索',1,0,1),
('target_paternity_disclaimer_evidence','有证据材料可补强','聊天记录/签收记录/转账回单',2,0,1),

-- 23 sibling support
('target_sibling_support_fee_claim','存在扶养义务关系','亲属关系证明/户口簿/登记材料',1,0,1),
('target_sibling_support_fee_claim','存在扶养义务关系','亲属关系材料/村居委证明',2,0,1),
('target_sibling_support_fee_claim','被扶养人生活困难','病历/诊断证明/失能证明/医疗票据',1,0,1),
('target_sibling_support_fee_claim','被扶养人生活困难','生活困难证明/低保证明/支出清单',2,0,1),
('target_sibling_support_fee_claim','扶养人收入能力明确','收入证明/工资流水/社保公积金',1,0,1),
('target_sibling_support_fee_claim','扶养人收入能力明确','银行流水/经营收入证明',2,0,1),
('target_sibling_support_fee_claim','拒绝履行或未足额支付','聊天记录/录音/转账记录',1,0,1),
('target_sibling_support_fee_claim','拒绝履行或未足额支付','催告记录/支付明细/欠付清单',2,0,1),

-- 23 change
('target_sibling_support_change','主张变更扶养关系','沟通记录/协商函/新安排证据',1,0,1),
('target_sibling_support_change','主张变更扶养关系','起诉状/证据清单/材料目录',2,0,1),
('target_sibling_support_change','变更原因属于法定情形','病历/诊断证明/鉴定结论（如涉及能力变化）',1,0,1),
('target_sibling_support_change','变更原因属于法定情形','生活困难证明/收入变化证据',2,0,1),
('target_sibling_support_change','被扶养人生活困难','医疗/失能证明/费用清单',1,0,1),
('target_sibling_support_change','被扶养人生活困难','支出凭证/账本/生活费用材料',2,0,1),

-- 25 adoption
('target_adoption_confirm','请求确认收养关系','收养登记/户口簿/登记材料',1,0,1),
('target_adoption_confirm','请求确认收养关系','收养协议/照顾记录（如有）',2,0,1),
('target_adoption_confirm','是否已办理收养登记','登记材料/户口簿/收养证明',1,0,1),
('target_adoption_confirm','是否已办理收养登记','登记记录/公证或申请文书（如有）',2,0,1),
('target_adoption_confirm','有证据材料可补强','证据清单/材料目录/调取线索',1,0,1),
('target_adoption_confirm','有证据材料可补强','聊天记录/照顾记录/转账回单',2,0,1),

('target_adoption_dissolve','请求解除收养关系','沟通记录/聊天记录/录音',1,0,1),
('target_adoption_dissolve','请求解除收养关系','解除请求材料/证据清单/起诉状',2,0,1),
('target_adoption_dissolve','存在解除原因线索','拒绝履行/矛盾证据/聊天记录',1,0,1),
('target_adoption_dissolve','存在解除原因线索','照顾不尽/转账不足/支付明细',2,0,1),
('target_adoption_dissolve','有证据材料可补强','证据清单/材料目录/调取线索',1,0,1),
('target_adoption_dissolve','有证据材料可补强','收养协议/登记材料（如有）',2,0,1),

-- 26 guardianship
('target_guardianship_assign','需要确定或变更监护人','申请材料/法院文书/登记材料',1,0,1),
('target_guardianship_assign','需要确定或变更监护人','沟通记录/请求说明',2,0,1),
('target_guardianship_assign','被监护人无或限制民事行为能力','病历/诊断证明/鉴定结论/失能证明',1,0,1),
('target_guardianship_assign','被监护人无或限制民事行为能力','护理证明/医疗费用材料',2,0,1),
('target_guardianship_assign','有医学鉴定或诊断证据','病历/诊断证明/鉴定结论',1,0,1),
('target_guardianship_assign','有医学鉴定或诊断证据','医疗票据/费用清单',2,0,1),
('target_guardianship_assign','请求指定或变更监护人','申请文书/证据清单/材料目录',1,0,1),
('target_guardianship_assign','请求指定或变更监护人','登记/合同式材料（如有）',2,0,1),

('target_guardianship_evidence','有证据材料可补强','证据清单/申请文书线索',1,0,1),
('target_guardianship_evidence','有证据材料可补强','聊天记录/沟通记录/转账回单',2,0,1),
('target_guardianship_evidence','当前监护人不适合或不履行','聊天记录/录音/沟通障碍证据',1,0,1),
('target_guardianship_evidence','当前监护人不适合或不履行','照护不到位/费用支付不足证据',2,0,1),
('target_guardianship_evidence','请求指定或变更监护人','申请材料/证据清单/材料目录',1,0,1),
('target_guardianship_evidence','请求指定或变更监护人','登记或司法材料（如有）',2,0,1),

-- 27 visitation
('target_visitation_fix','为非直接抚养方','探望请求说明/沟通记录',1,0,1),
('target_visitation_fix','为非直接抚养方','聊天记录/短信/录音',2,0,1),
('target_visitation_fix','存在拒绝探望或障碍','拒绝探望证据/聊天记录/报警记录',1,0,1),
('target_visitation_fix','存在拒绝探望或障碍','视频/照片/监控记录',2,0,1),
('target_visitation_fix','请求法院明确探望方式时间','起诉状/证据清单/材料目录',1,0,1),
('target_visitation_fix','请求法院明确探望方式时间','执行安排说明/沟通记录',2,0,1),

('target_visitation_evidence','存在探望安排协议或文书','探望协议/判决文书/登记材料',1,0,1),
('target_visitation_evidence','存在探望安排协议或文书','律师函/催告函/协议文本',2,0,1),
('target_visitation_evidence','有探望实施或沟通记录','聊天记录/通话短信/视频录音',1,0,1),
('target_visitation_evidence','有探望实施或沟通记录','探望实施记录/照片视频',2,0,1),
('target_visitation_evidence','请求法院明确探望方式时间','起诉状/证据清单/材料目录',1,0,1),
('target_visitation_evidence','请求法院明确探望方式时间','探望安排文书/登记材料（如有）',2,0,1),

-- 28 family partition
('target_family_partition_plan','家庭共同生活或共同置办财产','同住证据/共同生活证据/聊天记录',1,0,1),
('target_family_partition_plan','家庭共同生活或共同置办财产','共同消费记录/转账流水',2,0,1),
('target_family_partition_plan','共同财产范围清晰','财产清单/账本/房产证/不动产登记信息',1,0,1),
('target_family_partition_plan','共同财产范围清晰','资产负债清单/登记凭证',2,0,1),
('target_family_partition_plan','存在分割争议','沟通记录/争议说明/证据清单',1,0,1),
('target_family_partition_plan','存在分割争议','起诉状/材料目录/聊天记录',2,0,1),
('target_family_partition_plan','请求分割/析产','协议/起诉状/证据清单/材料目录',1,0,1),
('target_family_partition_plan','请求分割/析产','登记/合同式材料（如有）',2,0,1),

('target_family_partition_evidence','共同财产范围清晰','财产清单/账本/资产负债明细',1,0,1),
('target_family_partition_evidence','共同财产范围清晰','房产证/不动产登记信息',2,0,1),
('target_family_partition_evidence','有不动产或财产登记证据','房产证/不动产登记信息/车辆登记',1,0,1),
('target_family_partition_evidence','有不动产或财产登记证据','合同/登记凭证/权属材料',2,0,1),
('target_family_partition_evidence','有财产清单/账本/沟通记录','账本/清单/支付凭证/合同文本',1,0,1),
('target_family_partition_evidence','有财产清单/账本/沟通记录','聊天记录/录音/沟通证明',2,0,1);

-- -------------------------
-- 6) Step1 judge（规则与结论）
-- -------------------------
-- 为避免重复/冲突：清理本脚本影响的 cause_code 对应 Step1 规则与结论
DELETE FROM rule_judge_rule_conclusion
WHERE rule_id IN (
  'r_in_marriage_property_division_init',
  'r_post_divorce_damage_liability_init',
  'r_marriage_invalid_init',
  'r_marriage_annulment_init',
  'r_spousal_property_agreement_init',
  'r_cohabitation_init',
  'r_paternity_confirmation_init',
  'r_paternity_disclaimer_init',
  'r_sibling_support_init',
  'r_adoption_init',
  'r_guardianship_init',
  'r_visitation_init',
  'r_family_partition_init'
);
DELETE FROM rule_judge_rule
WHERE cause_code IN (
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
);
DELETE FROM rule_judge_conclusion
WHERE conclusion_id IN (
  'c_in_marriage_property_division_initial',
  'c_post_divorce_damage_liability_initial',
  'c_marriage_invalid_initial',
  'c_marriage_annulment_initial',
  'c_spousal_property_agreement_initial',
  'c_cohabitation_initial',
  'c_paternity_confirmation_initial',
  'c_paternity_disclaimer_initial',
  'c_sibling_support_initial',
  'c_adoption_initial',
  'c_guardianship_initial',
  'c_visitation_initial',
  'c_family_partition_initial'
);

INSERT INTO rule_judge_conclusion (
  conclusion_id, type, result, reason, level, law_refs_json,
  final_item, final_result, final_detail, enabled
)
VALUES
('c_in_marriage_property_division_initial','conclusion','婚内夫妻财产分割可进入裁判分析','存在婚内共同财产争议及证据线索时，可进入实体审查并形成分割/处置方案。','important','[\"law_1087\",\"law_1092\"]','婚内财产分割','建议继续补强藏匿转移、挥霍处置与医疗紧急支出证据。','围绕范围清晰与交易/登记证据组织证成。',1),
('c_post_divorce_damage_liability_initial','conclusion','离婚后损害责任有证据补强空间','过错侵害事实线索与后果损害要件具备时，可形成精神损害/经济损失赔偿证成。','important','[\"law_1079\",\"law_1087\"]','损害责任审查入口','建议按“过错-后果-请求范围”补强聊天/病历/费用清单。','重点固定电子证据与损失计算依据。',1),
('c_marriage_invalid_initial','conclusion','婚姻无效可进入实体确认与返还审查','无效原因线索与请求确认成立时，可组织无效确认及财产返还/安排的证据链。','important','[\"law_1079\",\"law_1087\"]','婚姻无效确认','建议补强无效原因与结婚登记/身份材料证据。','同时整理共同财产与子女抚养安排线索。',1),
('c_marriage_annulment_initial','conclusion','撤销婚姻可进入原因与后果安排审查','存在撤销原因线索且有证据补强时，可组织撤销请求及撤销后财产返还/子女安排。','important','[\"law_1079\",\"law_1087\"]','撤销婚姻审查入口','建议补强胁迫/欺诈/重大疾病隐瞒的证据。','同时整理撤销后的财产与子女抚养需求证据。',1),
('c_spousal_property_agreement_initial','conclusion','夫妻财产约定纠纷可主张有效并履行（或应对无效抗辩）','协议存在、约定明确且未履行/争议履行时，可形成有效并履行的证成。','important','[\"law_1087\",\"law_1092\"]','协议有效与履行/抗辩','建议补强协议文本、公证/登记与催告履行证据。','如对方主张无效/被撤销，补强签署真实与履行证据。',1),
('c_cohabitation_initial','conclusion','同居关系财产与子女安排可进入裁判分析','同居投入与财产争议并存在抚养问题时，可组织财产析产与抚养费/照护安排证据补强。','important','[\"law_1087\",\"law_1084\"]','同居析产与抚养审查','建议补强同住证据、转账流水、孩子生活照护与支付拒绝线索。','围绕财产范围清晰与证据链条组织证成。',1),
('c_paternity_confirmation_initial','conclusion','亲子确认请求具备证据补强方向','亲子争议与鉴定结论支持时，可组织亲子确认请求的证据补强。','important','[\"law_1084\"]','亲子确认审查入口','建议提交亲子鉴定结论、出生/户籍/亲属关系材料及证据清单。','如无鉴定结论，先补强鉴定可用材料。',1),
('c_paternity_disclaimer_initial','conclusion','亲子否认请求具备证据补强方向','亲子争议与鉴定结论支持否认主张时，可组织否认请求的证据补强。','important','[\"law_1084\"]','亲子否认审查入口','建议提交亲子鉴定结论、出生/户籍/亲属关系材料及证据清单。','同时整理争议形成沟通记录。',1),
('c_sibling_support_initial','conclusion','扶养纠纷可进入扶养义务要件审查','被扶养人生活困难、扶养人能力与拒绝履行/不足时，可组织扶养费给付或变更证成。','important','[\"law_1067\"]','扶养义务审查入口','建议补强亲属关系、生活困难、收入能力与拒绝履行证据。','必要时补强变更原因属于法定情形材料。',1),
('c_adoption_initial','conclusion','收养关系可进入确认或解除审查','存在收养事实/登记且有证据补强时，可形成确认收养关系或解除收养关系的证据链。','important','[\"law_1084\"]','收养确认/解除审查入口','建议补强收养登记材料、照顾记录与解除原因线索。','如无登记，补强长期事实维持证据。',1),
('c_guardianship_initial','conclusion','监护权指定/变更可进入实体审查','被监护人无/限制能力与医学鉴定证据具备时，可形成指定/变更监护人请求。','important','[\"law_1084\"]','监护权审查入口','建议补强鉴定/诊断证据与申请文书材料。','如现任监护不适合或不履行，补强对应事实证据。',1),
('c_visitation_initial','conclusion','探望权纠纷可进入明确探望安排审查','非直接抚养方存在拒绝探望/障碍且有探望请求时，可组织明确探望方式与时间的证成。','important','[\"law_1084\"]','探望权审查入口','建议补强拒绝探望证据、沟通记录与探望安排文书。','形成可执行的时间/方式/安排证据链。',1),
('c_family_partition_initial','conclusion','分家析产可进入财产范围与分割证据审查','同堂共同生活并存在财产争议时，可组织共同财产范围认定与析产分割证成。','important','[\"law_1087\",\"law_1092\"]','析产分割审查入口','建议补强财产清单/账本、登记证据与资金来源。','如存在转移/不当处分，补强对应流水与沟通证据。',1)
;

-- 规则（condition_json 用 {}，保证规则命中从而返回结论结构；完整证据追问由 Step2 承担）
INSERT INTO rule_judge_rule (
  rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled
)
VALUES
('r_in_marriage_property_division_init','in_marriage_property_division_dispute','婚内财产分割入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"婚姻关系已存续且未离婚\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"存在婚内共同财产争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在藏匿转移共同财产线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"共同财产范围清晰\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在挥霍家产或恶意处置\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在重大医疗支出或紧急治疗需求\",\"cmp\":\"eq\",\"value\":true}]}]}',1),
('r_post_divorce_damage_liability_init','post_divorce_damage_liability_dispute','离婚后损害责任入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"离婚事实已生效\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"存在婚内严重过错或侵害事实线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在精神损害或经济损失后果\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"明确请求赔偿范围\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有具体损失或治疗费用/收入损失线索\",\"cmp\":\"eq\",\"value\":true}]}]}',1),
('r_marriage_invalid_init','marriage_invalid_dispute','婚姻无效入口判断',NULL,'与',NULL,10,'{\"op\":\"or\",\"children\":[{\"fact\":\"存在无效婚姻原因线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求确认婚姻无效\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有证据材料可补强\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_marriage_annulment_init','marriage_annulment_dispute','撤销婚姻入口判断',NULL,'与',NULL,10,'{\"op\":\"or\",\"children\":[{\"fact\":\"存在撤销原因线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求撤销婚姻\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有证据材料可补强\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_spousal_property_agreement_init','spousal_property_agreement_dispute','夫妻财产约定入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在夫妻财产约定协议\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"约定内容明确\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"协议未履行或争议履行\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求确认协议有效并要求履行\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"对方主张协议无效或被撤销\",\"cmp\":\"eq\",\"value\":true}]}]}',1),
('r_cohabitation_init','cohabitation_dispute','同居关系入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"是否存在同居关系\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"同居期间共同生活或共同投入\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"共同财产范围清晰\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在财产分割争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"对方拒绝或未支付抚养费\",\"cmp\":\"eq\",\"value\":true}]}]}',1),
('r_paternity_confirmation_init','paternity_confirmation_dispute','亲子确认入口判断',NULL,'与',NULL,10,'{\"op\":\"or\",\"children\":[{\"fact\":\"存在亲子关系争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求确认亲子关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"亲子鉴定结论支持主张\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_paternity_disclaimer_init','paternity_disclaimer_dispute','亲子否认入口判断',NULL,'与',NULL,10,'{\"op\":\"or\",\"children\":[{\"fact\":\"请求否认亲子关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"亲子鉴定结论不支持主张\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"亲子鉴定结论支持否认方主张\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_sibling_support_init','sibling_support_dispute','扶养纠纷入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在扶养义务关系\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"被扶养人生活困难\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"拒绝履行或未足额支付\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"主张变更扶养关系\",\"cmp\":\"eq\",\"value\":true}]}]}',1),
('r_adoption_init','adoption_dispute','收养关系入口判断',NULL,'与',NULL,10,'{\"op\":\"or\",\"children\":[{\"fact\":\"请求确认收养关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求解除收养关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有证据材料可补强\",\"cmp\":\"eq\",\"value\":true}]}',1),
('r_guardianship_init','guardianship_dispute','监护权入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"需要确定或变更监护人\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"被监护人无或限制民事行为能力\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有医学鉴定或诊断证据\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求指定或变更监护人\",\"cmp\":\"eq\",\"value\":true}]}]}',1),
('r_visitation_init','visitation_dispute','探望权入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"已离婚或已分开\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"为非直接抚养方\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在拒绝探望或障碍\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求法院明确探望方式时间\",\"cmp\":\"eq\",\"value\":true}]}]}',1),
('r_family_partition_init','family_partition_dispute','分家析产入口判断',NULL,'与',NULL,10,'{\"op\":\"and\",\"children\":[{\"fact\":\"家庭共同生活或共同置办财产\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"共同财产范围清晰\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在分割争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求分割/析产\",\"cmp\":\"eq\",\"value\":true}]}]}',1);


INSERT IGNORE INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order)
VALUES
('r_in_marriage_property_division_init','c_in_marriage_property_division_initial',1),
('r_post_divorce_damage_liability_init','c_post_divorce_damage_liability_initial',1),
('r_marriage_invalid_init','c_marriage_invalid_initial',1),
('r_marriage_annulment_init','c_marriage_annulment_initial',1),
('r_spousal_property_agreement_init','c_spousal_property_agreement_initial',1),
('r_cohabitation_init','c_cohabitation_initial',1),
('r_paternity_confirmation_init','c_paternity_confirmation_initial',1),
('r_paternity_disclaimer_init','c_paternity_disclaimer_initial',1),
('r_sibling_support_init','c_sibling_support_initial',1),
('r_adoption_init','c_adoption_initial',1),
('r_guardianship_init','c_guardianship_initial',1),
('r_visitation_init','c_visitation_initial',1),
('r_family_partition_init','c_family_partition_initial',1);

SET FOREIGN_KEY_CHECKS = 1;

