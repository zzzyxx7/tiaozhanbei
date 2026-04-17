USE rule_engine_db;
SET NAMES utf8mb4;

-- 婚姻家庭案由精细化 Step1 规则
-- 原则：
-- 1) 不再停留在单条 *_init。
-- 2) 每个案由至少具备 precondition + support_path + defense_or_exception_path。
-- 3) 题目字段尽量直接作为 facts 使用，优先复用 FactExtractorService fallback。

DELETE rc
FROM rule_judge_rule_conclusion rc
JOIN rule_judge_rule r ON r.rule_id = rc.rule_id
WHERE r.cause_code IN (
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
  'c_in_marriage_property_precondition','c_in_marriage_property_support','c_in_marriage_property_exception',
  'c_post_divorce_damage_precondition','c_post_divorce_damage_support','c_post_divorce_damage_amount','c_post_divorce_damage_exception',
  'c_post_divorce_damage_fault','c_post_divorce_damage_causation',
  'c_marriage_invalid_precondition','c_marriage_invalid_support','c_marriage_invalid_exception','c_marriage_invalid_arrangement',
  'c_marriage_invalid_prior_marriage','c_marriage_invalid_kinship','c_marriage_invalid_underage',
  'c_marriage_annulment_precondition','c_marriage_annulment_support','c_marriage_annulment_exception','c_marriage_annulment_arrangement',
  'c_marriage_annulment_coercion','c_marriage_annulment_disease','c_marriage_annulment_time_bar',
  'c_spousal_agreement_precondition','c_spousal_agreement_support','c_spousal_agreement_defense',
  'c_cohabitation_precondition','c_cohabitation_property_support','c_cohabitation_custody_support','c_cohabitation_exception',
  'c_paternity_confirmation_precondition','c_paternity_confirmation_support','c_paternity_confirmation_obstruction',
  'c_paternity_confirmation_birth_record',
  'c_paternity_disclaimer_precondition','c_paternity_disclaimer_support','c_paternity_disclaimer_obstruction',
  'c_paternity_disclaimer_birth_record',
  'c_sibling_support_precondition','c_sibling_support_fee_support','c_sibling_support_change_support','c_sibling_support_exception',
  'c_adoption_precondition','c_adoption_confirm_support','c_adoption_dissolve_support','c_adoption_exception',
  'c_adoption_registered_confirm','c_adoption_de_facto_confirm','c_adoption_post_dissolve_arrangement',
  'c_guardianship_precondition','c_guardianship_support','c_guardianship_property_support','c_guardianship_subject_qualification','c_guardianship_care_ability',
  'c_visitation_precondition','c_visitation_support','c_visitation_exception','c_visitation_child_will','c_visitation_suspension_risk',
  'c_sibling_support_medical','c_sibling_support_multi_obligor',
  'c_spousal_agreement_validity','c_spousal_agreement_performance',
  'c_in_marriage_property_type_scope','c_in_marriage_property_livelihood_impact',
  'c_cohabitation_contribution_ratio','c_cohabitation_direct_custody',
  'c_family_partition_precondition','c_family_partition_support','c_family_partition_exception','c_family_partition_member_boundary','c_family_partition_registration_source'
);

INSERT INTO rule_judge_conclusion (
  conclusion_id, type, result, reason, level, law_refs_json, final_item, final_result, final_detail, enabled
)
VALUES
('c_in_marriage_property_precondition','conclusion','婚内财产分割已具备审查前提','婚姻关系存续且已出现婚内共同财产争议，可进入婚内析产审查。','important','["law_1087","law_1092"]','婚内财产分割前置','可进入实体分析','继续围绕共同财产范围、转移方式和支出影响补强。',1),
('c_in_marriage_property_support','conclusion','婚内财产分割主张存在支持路径','存在藏匿转移、挥霍或重大医疗紧急需求等情形，具备请求分割或采取保护措施的空间。','important','["law_1087","law_1092"]','婚内财产分割支持路径','支持继续主张','重点固定共同财产范围、转账流水、医疗票据与挥霍细节。',1),
('c_in_marriage_property_exception','conclusion','婚内财产分割需先补强范围与紧迫性','目前仅有一般争议线索，若共同财产范围或紧迫处分理由不清，容易导致请求泛化。','warning','["law_1087"]','婚内财产分割例外路径','需先补强再主张','补充财产清单、争议财产类型及对家庭生活影响。',1),
('c_in_marriage_property_type_scope','conclusion','婚内财产分割中的财产类型与范围路径较明确','争议财产类型、范围边界和转移方式较明确时，更利于形成具体分割请求。','important','["law_1087","law_1092"]','婚内财产范围路径','可细化分割标的','重点整理房产、账户、股权等类型及财产清单。',1),
('c_in_marriage_property_livelihood_impact','conclusion','婚内财产分割中的基本生活受影响路径较明确','重大医疗、挥霍处置已影响家庭基本生活时，紧迫性和保护必要性更强。','important','["law_1087","law_1092"]','婚内财产生活影响路径','可强化紧迫性主张','整理医疗支出、家庭欠费和生活受影响材料。',1),

('c_post_divorce_damage_precondition','conclusion','离婚后损害责任已具备独立审查前提','离婚事实已生效且已出现过错侵害与损害后果线索，可独立进入赔偿审查。','important','["law_1091","law_1079"]','离婚后损害前置','可进入实体分析','继续补强过错类型、程序处理情况和因果关系。',1),
('c_post_divorce_damage_support','conclusion','离婚后损害责任存在支持路径','过错类型、损害后果和因果关系较明确，具备继续主张赔偿的基础。','important','["law_1091","law_1079"]','离婚后损害支持路径','支持继续主张','重点固定聊天、病历、报警记录及离婚阶段未处理事实。',1),
('c_post_divorce_damage_amount','conclusion','赔偿金额与范围可进一步细化','已出现具体费用、持续治疗或误工损失线索，可细化金额计算与项目拆分。','important','["law_1183","law_1179"]','离婚后损害金额路径','可细化赔偿清单','将医疗费、误工费、精神损害抚慰金分别整理。',1),
('c_post_divorce_damage_exception','conclusion','离婚后损害责任可能受既判或处理完毕影响','若损害赔偿已在离婚程序中处理，或因果关系、损失范围不明确，后续主张空间会收窄。','warning','["law_1091"]','离婚后损害例外路径','需先核查程序障碍','核查离婚判决、协议和既往请求处理情况。',1),
('c_post_divorce_damage_fault','conclusion','离婚后损害已形成明确过错识别路径','重婚、与他人同居、家庭暴力或虐待遗弃等过错类型较清晰时，更利于围绕法定过错展开主张。','important','["law_1091"]','离婚后损害过错路径','过错类型较明确','围绕过错类型分别整理聊天、报警、判决或证人证言。',1),
('c_post_divorce_damage_causation','conclusion','离婚后损害的后果与因果链可继续补强','损害后果、持续治疗和误工线索存在时，可进一步强化因果关系和金额计算。','important','["law_1183","law_1179"]','离婚后损害因果路径','可继续补强因果链','围绕病历时间线、复诊记录和误工收入证明整理。',1),

('c_marriage_invalid_precondition','conclusion','婚姻无效纠纷已具备审查入口','存在法定无效事由线索且请求主体较明确，可进入婚姻无效确认审查。','important','["law_1051","law_1052"]','婚姻无效前置','可进入实体分析','先锁定法定无效事由，不再混入非无效原因。',1),
('c_marriage_invalid_support','conclusion','婚姻无效确认存在支持路径','在先婚姻未解除、禁止结婚亲属关系或未达婚龄等法定事由已出现明确指向。','important','["law_1051","law_1052"]','婚姻无效支持路径','支持继续主张','围绕登记、身份、亲属关系和前婚状态固定证据。',1),
('c_marriage_invalid_exception','conclusion','婚姻无效主张需排除错误事由混入','若仅有与他人同居等非无效法定事由线索，容易导致 /judge 答非所问。','warning','["law_1051"]','婚姻无效例外路径','需校正主张方向','区分婚姻无效、撤销婚姻和离婚损害责任。',1),
('c_marriage_invalid_arrangement','conclusion','婚姻无效后的财产与子女安排需同步处理','案件同时涉及财产或未成年子女安排时，应同步组织后果处理方案。','important','["law_1054","law_1084"]','婚姻无效后果路径','同步处理后果安排','补充财产给付、抚养现状与支出材料。',1),
('c_marriage_invalid_prior_marriage','conclusion','婚姻无效中的重婚路径较明确','若能证明在先婚姻未解除又再次登记结婚，婚姻无效主张更聚焦也更稳定。','important','["law_1051"]','婚姻无效重婚路径','优先围绕重婚事实主张','重点提交前婚状态、登记档案和身份信息。',1),
('c_marriage_invalid_kinship','conclusion','婚姻无效中的近亲属关系路径较明确','若能证明属于禁止结婚的亲属关系，婚姻无效将围绕亲属关系认定展开。','important','["law_1051"]','婚姻无效近亲路径','优先围绕亲属关系主张','重点提交户籍、出生和亲属关系材料。',1),
('c_marriage_invalid_underage','conclusion','婚姻无效中的未达婚龄路径较明确','若能证明登记结婚时未达法定婚龄，婚姻无效主张将围绕年龄事实展开。','important','["law_1051","law_1054"]','婚姻无效婚龄路径','优先围绕婚龄事实主张','重点提交身份证、户籍和登记材料。',1),

('c_marriage_annulment_precondition','conclusion','撤销婚姻纠纷已具备审查入口','存在法定撤销事由线索，且已出现撤销请求与期间判断基础。','important','["law_1052","law_1053"]','撤销婚姻前置','可进入实体分析','继续核查胁迫终止时间或知晓疾病时间。',1),
('c_marriage_annulment_support','conclusion','撤销婚姻主张存在支持路径','胁迫结婚或婚前隐瞒重大疾病的线索较明确，撤销请求具备继续主张空间。','important','["law_1052","law_1053"]','撤销婚姻支持路径','支持继续主张','重点固定胁迫过程、病历诊断和时间节点。',1),
('c_marriage_annulment_exception','conclusion','撤销婚姻可能受期间限制影响','若不在法定期间内提出，或知晓时间无法说明，撤销请求风险较高。','warning','["law_1053"]','撤销婚姻例外路径','需先核查时效','围绕知晓时间、胁迫终止时间补充证据。',1),
('c_marriage_annulment_arrangement','conclusion','撤销婚姻后的赔偿、财产和子女安排可并行处理','撤销后若涉及损害赔偿、财产返还或子女抚养安排，可同步设计后果处理路径。','important','["law_1054","law_1084"]','撤销婚姻后果路径','同步处理后果安排','分别整理赔偿、返还和抚养材料。',1),
('c_marriage_annulment_coercion','conclusion','撤销婚姻中的胁迫路径较明确','存在胁迫结婚事实且能说明胁迫终止时间时，撤销请求会更聚焦。','important','["law_1052","law_1053"]','撤销婚姻胁迫路径','优先围绕胁迫主张','提交报警、伤情、录音和时间线证据。',1),
('c_marriage_annulment_disease','conclusion','撤销婚姻中的重大疾病隐瞒路径较明确','婚前隐瞒重大疾病且知晓时间可说明时，撤销请求和损害赔偿都更容易成型。','important','["law_1053"]','撤销婚姻重大疾病路径','优先围绕重大疾病隐瞒主张','整理病历、住院记录、婚前告知缺失材料。',1),
('c_marriage_annulment_time_bar','conclusion','撤销婚姻需优先排查法定期间障碍','如无法证明在法定期间内提出，后续实体争点可能无法展开。','warning','["law_1053"]','撤销婚姻期间障碍路径','需优先核查期间问题','先补知晓时间和立案时间材料。',1),

('c_spousal_agreement_precondition','conclusion','夫妻财产约定纠纷已具备审查入口','存在夫妻财产约定协议且约定内容基本明确，可进入效力与履行审查。','important','["law_1065"]','夫妻财产约定前置','可进入实体分析','继续固定书面文本、签署时间和争议财产类型。',1),
('c_spousal_agreement_support','conclusion','夫妻财产约定存在履行支持路径','协议文本、签署真实及履行争议较明确，具备主张有效并要求履行的空间。','important','["law_1065"]','夫妻财产约定支持路径','支持继续主张','重点补强书面协议、公证登记和催告履行材料。',1),
('c_spousal_agreement_defense','conclusion','夫妻财产约定存在效力抗辩风险','若存在胁迫、欺诈或协议真实性不足等情形，协议效力会成为核心争点。','warning','["law_143","law_148"]','夫妻财产约定抗辩路径','需同步应对效力争议','核查签署过程、自由意思表示和履行行为。',1),

('c_cohabitation_precondition','conclusion','同居关系纠纷已具备审查前提','已存在同居关系及财产或子女争议线索，可进入同居关系实体分析。','important','["law_1042","law_1084"]','同居关系前置','可进入实体分析','继续固定同居起止时间和共同投入情况。',1),
('c_cohabitation_property_support','conclusion','同居财产分割存在支持路径','共同生活、共同购置或一方明显出资较高时，可围绕共有投入主张析产。','important','["law_308","law_309"]','同居财产支持路径','支持继续主张','重点整理共同购置合同、转账流水和出资比例。',1),
('c_cohabitation_custody_support','conclusion','同居关系中的子女抚养安排可同步处理','存在子女、实际照料和费用承担争议时，可同步处理直接抚养与抚养费。','important','["law_1084","law_1085"]','同居子女路径','可同步主张抚养安排','整理出生材料、照料记录和月支出清单。',1),
('c_cohabitation_exception','conclusion','同居纠纷需避免财产和身份关系混同','若同居时间、共同投入或子女安排都不清晰，容易导致主张方向泛化。','warning','["law_1042"]','同居关系例外路径','需先明确争点','先区分财产析产、子女抚养和一般返还请求。',1),
('c_cohabitation_contribution_ratio','conclusion','同居财产中的出资比例与共同购置路径较明确','共同购置房车或大额财物且一方明显高额出资时，更利于细化析产比例。','important','["law_308","law_309"]','同居出资比例路径','可细化财产份额方案','重点整理共同购置合同、出资流水和比例说明。',1),
('c_cohabitation_direct_custody','conclusion','同居子女中的直接抚养与月支出路径较明确','直接抚养主张、现有照料状态和孩子月支出清晰时，更利于形成抚养安排。','important','["law_1084","law_1085"]','同居直接抚养路径','可细化抚养方案','重点整理照料现状、支出清单和支付不足材料。',1),

('c_paternity_confirmation_precondition','conclusion','亲子确认纠纷已具备审查入口','存在亲子关系争议且已形成确认请求或鉴定方向，可进入亲子确认审查。','important','["law_1073"]','亲子确认前置','可进入实体分析','继续固定鉴定结论、出生登记和往来记录。',1),
('c_paternity_confirmation_support','conclusion','亲子确认存在支持路径','鉴定结论、出生登记一致性和怀孕生育期间往来记录对确认主张形成支持。','important','["law_1073"]','亲子确认支持路径','支持继续主张','整理鉴定材料、出生登记和长期抚养证据。',1),
('c_paternity_confirmation_obstruction','conclusion','亲子确认可走举证妨碍路径','对方拒绝配合亲子鉴定或存在举证妨碍时，可强化确认主张的证明评价。','important','["law_81"]','亲子确认举证妨碍路径','可强化证明评价','保留拒检、送达、调查受阻等过程材料。',1),
('c_paternity_confirmation_birth_record','conclusion','亲子确认中的出生登记与生育往来路径较明确','出生登记与确认主张一致，且存在怀孕生育期间往来和长期抚养记录时，确认路径更稳定。','important','["law_1073"]','亲子确认出生登记路径','可强化确认主张','重点整理出生证明、生育往来和共同抚养记录。',1),

('c_paternity_disclaimer_precondition','conclusion','亲子否认纠纷已具备审查入口','存在亲子关系争议且已形成否认请求或鉴定方向，可进入亲子否认审查。','important','["law_1073"]','亲子否认前置','可进入实体分析','继续固定鉴定结论、出生登记和往来记录。',1),
('c_paternity_disclaimer_support','conclusion','亲子否认存在支持路径','鉴定结论、出生登记不一致和怀孕生育期间往来缺失等事实可支持否认主张。','important','["law_1073"]','亲子否认支持路径','支持继续主张','重点整理鉴定报告、登记不一致与生活记录缺失。',1),
('c_paternity_disclaimer_obstruction','conclusion','亲子否认可走举证妨碍路径','对方拒绝配合亲子鉴定或存在举证妨碍时，可强化否认主张的证明评价。','important','["law_81"]','亲子否认举证妨碍路径','可强化证明评价','保留拒检、送达、调查受阻等过程材料。',1),
('c_paternity_disclaimer_birth_record','conclusion','亲子否认中的登记不一致与生活缺失路径较明确','出生登记与否认主张不一致，且共同生活或生育往来证据薄弱时，否认主张更聚焦。','important','["law_1073"]','亲子否认出生登记路径','可强化否认主张','重点整理出生登记不一致和共同生活缺失材料。',1),

('c_sibling_support_precondition','conclusion','扶养纠纷已具备审查入口','已明确扶养义务关系和被扶养人困难状态，可进入扶养义务审查。','important','["law_1075"]','扶养纠纷前置','可进入实体分析','继续核查医疗护理支出、多义务人和金额测算。',1),
('c_sibling_support_fee_support','conclusion','扶养费主张存在支持路径','生活困难、无劳动能力或重大医疗护理支出较明确时，可主张扶养费分担。','important','["law_1075"]','扶养费支持路径','支持继续主张','整理亲属关系、收入能力与月扶养费测算。',1),
('c_sibling_support_change_support','conclusion','扶养安排变更存在支持路径','已有长期照料一方且法定变更原因较明确时，可进一步主张调整扶养安排。','important','["law_1075"]','扶养变更路径','可主张调整安排','补强长期照料事实及其他义务人分担情况。',1),
('c_sibling_support_exception','conclusion','扶养纠纷需先厘清义务人范围与能力','若义务主体、履行能力或困难程度不清，容易导致扶养请求笼统。','warning','["law_1075"]','扶养纠纷例外路径','需先补强基础事实','明确多名义务人、收入水平和既往履行情况。',1),
('c_sibling_support_medical','conclusion','扶养纠纷中的重大医疗护理支出路径较明确','存在重病、失能或长期护理支出时，扶养费请求更适合围绕医疗护理负担展开。','important','["law_1075"]','扶养医疗护理路径','可围绕医疗护理支出主张','重点整理病历、护理费和费用清单。',1),
('c_sibling_support_multi_obligor','conclusion','扶养纠纷中的多义务人分担路径较明确','有多名扶养义务人且已存在长期照料一方时，可进一步细化分担比例和履行方式。','important','["law_1075"]','扶养多义务人路径','可细化分担方案','整理成员范围、照料现状和各自收入能力。',1),

('c_spousal_agreement_validity','conclusion','夫妻财产约定的成立与效力路径较明确','存在书面协议、签署时间清晰且财产范围明确时，协议效力主张更稳定。','important','["law_1065"]','夫妻财产约定效力路径','可继续强化效力主张','重点整理文本、公证登记和财产范围材料。',1),
('c_spousal_agreement_performance','conclusion','夫妻财产约定的履行争议路径较明确','协议已成立但履行存在争议时，可围绕催告、支付和争议标的进一步主张履行。','important','["law_1065"]','夫妻财产约定履行路径','可继续主张履行','重点整理催告记录、转账凭证和财产标的材料。',1),

('c_adoption_precondition','conclusion','收养关系纠纷已具备审查入口','已存在确认或解除收养的明确请求，可进入收养关系审查。','important','["law_1093","law_1115"]','收养纠纷前置','可进入实体分析','继续锁定收养路径类型及共同生活状态。',1),
('c_adoption_confirm_support','conclusion','收养确认存在支持路径','登记收养、事实收养长期维持、送养同意和抚养能力等事实可支持确认主张。','important','["law_1093","law_1105"]','收养确认支持路径','支持继续主张','整理登记材料、送养同意、照顾记录和收入居住材料。',1),
('c_adoption_dissolve_support','conclusion','解除收养存在支持路径','解除原因、长期矛盾或不尽抚养义务等线索较明确，可进入解除收养审查。','important','["law_1115"]','解除收养支持路径','支持继续主张','重点补强解除原因与解除后未成年人安排。',1),
('c_adoption_exception','conclusion','收养纠纷需先区分确认路径与解除路径','若登记、事实收养、解除原因与后续抚养安排混在一起，容易导致请求方向不清。','warning','["law_1093","law_1115"]','收养纠纷例外路径','需先校正主张方向','明确是确认收养还是解除收养，再分别补证。',1),
('c_adoption_registered_confirm','conclusion','收养确认中的登记收养路径较明确','已办理收养登记且有送养同意、抚养能力材料时，确认收养关系路径更稳定。','important','["law_1093","law_1105"]','登记收养路径','优先围绕登记收养主张','重点整理登记材料、送养同意和资格材料。',1),
('c_adoption_de_facto_confirm','conclusion','收养确认中的事实收养路径较明确','虽未登记但长期共同生活、持续照顾和抚养能力较明确时，可围绕事实收养展开主张。','important','["law_1093"]','事实收养路径','可围绕事实收养主张','重点整理共同生活、照顾记录和收入居住材料。',1),
('c_adoption_post_dissolve_arrangement','conclusion','解除收养后的未成年人安排需单独成型','解除收养后如未成年人监护、抚养费和生活安排未明确，后续执行性会明显不足。','important','["law_1115","law_1084"]','解除收养后果路径','需同步细化后续安排','整理监护、抚养费用和生活安置方案。',1),

('c_guardianship_precondition','conclusion','监护权纠纷已具备审查入口','被监护人能力状态和监护请求已基本明确，可进入指定或变更监护人审查。','important','["law_27","law_31"]','监护权前置','可进入实体分析','继续核查主体资格、照护能力和基层组织意见。',1),
('c_guardianship_support','conclusion','监护权指定或变更存在支持路径','申请人主体资格、照护能力和现任监护缺位或不适合情形较明确。','important','["law_27","law_31"]','监护权支持路径','支持继续主张','补强诊断鉴定、照护条件和基层组织意见。',1),
('c_guardianship_property_support','conclusion','监护事项可延伸至财产管理保护路径','若被监护人同时存在财产管理需求，应同步考虑监护范围与财产保护安排。','important','["law_35"]','监护财产路径','可同步主张财产管理','整理财产清单、保管风险和管理需求说明。',1),
('c_guardianship_subject_qualification','conclusion','监护申请人的主体资格路径较明确','申请人顺位、亲属关系和基层组织意见较清晰时，指定或变更监护人的主体基础更稳。','important','["law_27"]','监护主体资格路径','优先围绕主体资格主张','重点整理身份顺位、亲属关系和基层意见材料。',1),
('c_guardianship_care_ability','conclusion','监护申请人的照护能力路径较明确','照护能力、稳定居住和财产管理需求较明确时，更利于形成可执行的监护方案。','important','["law_31","law_35"]','监护照护能力路径','可继续补强监护适格性','整理收入、居住、照护安排和财产管理材料。',1),

('c_visitation_precondition','conclusion','探望权纠纷已具备审查入口','已分开生活且申请方属于非直接抚养一方，可进入探望权安排审查。','important','["law_1086"]','探望权前置','可进入实体分析','继续固定子女年龄、意愿和既有安排。',1),
('c_visitation_support','conclusion','探望权主张存在支持路径','拒绝探望、既有安排不明或需节假日住宿探望时，可进一步明确探望方案。','important','["law_1086"]','探望权支持路径','支持继续主张','细化频率、接送、节假日及住宿安排。',1),
('c_visitation_exception','conclusion','探望权可能受中止风险因素影响','若存在不利于未成年人身心健康的风险线索，探望方式和频率需要收敛设计。','warning','["law_1086"]','探望权例外路径','需控制探望风险','重点核查子女意愿和中止探望风险事实。',1),
('c_visitation_child_will','conclusion','探望权中的子女意愿与既有安排路径较明确','八周岁以上子女意愿明确且既有探望频率较清晰时，更容易形成可执行探望方案。','important','["law_1086"]','探望权子女意愿路径','可细化执行方案','重点整理子女意愿、既有探望频率和接送安排。',1),
('c_visitation_suspension_risk','conclusion','探望权中的中止或限制风险需优先审查','存在不利于未成年人身心健康的风险线索时，探望方式和范围可能被限制。','warning','["law_1086"]','探望权风险审查路径','需先控制探望风险','围绕风险事实、节假日住宿方案和保护措施整理。',1),

('c_family_partition_precondition','conclusion','分家析产纠纷已具备审查入口','共同生活、共同置办财产和析产请求已形成基础，能够进入析产审查。','important','["law_308","law_309"]','分家析产前置','可进入实体分析','继续明确家庭成员范围、登记名义和出资来源。',1),
('c_family_partition_support','conclusion','分家析产主张存在支持路径','财产范围、登记名义、长期占有使用和主要出资来源较清晰时，可进一步主张析产分割。','important','["law_308","law_309"]','分家析产支持路径','支持继续主张','整理财产清单、账本、登记和出资材料。',1),
('c_family_partition_exception','conclusion','分家析产需先澄清成员范围与财产边界','若成员范围、是否已实际分家或财产登记名义不清，易导致析产请求泛化。','warning','["law_308"]','分家析产例外路径','需先补强基础事实','先明确家庭成员、分家状态和占有使用事实。',1),
('c_family_partition_member_boundary','conclusion','分家析产中的成员范围与分家状态路径较明确','家庭成员范围、是否已实际分家和长期占有使用状态明确时，更利于确认析产边界。','important','["law_308"]','分家析产成员边界路径','可细化析产边界','重点整理成员清单、分家证明和占有使用材料。',1),
('c_family_partition_registration_source','conclusion','分家析产中的登记名义与出资来源路径较明确','登记名义、权属材料和主要出资来源较清晰时，更利于细化权利份额。','important','["law_309"]','分家析产权属来源路径','可细化份额主张','重点整理权属证明、转账流水和出资来源材料。',1);

INSERT INTO rule_judge_rule (rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled)
VALUES
-- in_marriage_property_division_dispute
('r_in_marriage_property_precondition','in_marriage_property_division_dispute','婚内财产分割前置条件','precondition','与','law_1087',10,
'{"op":"and","children":[{"fact":"婚姻关系已存续且未离婚","cmp":"eq","value":true},{"fact":"存在婚内共同财产争议","cmp":"eq","value":true}]}',1),
('r_in_marriage_property_support','in_marriage_property_division_dispute','婚内财产分割支持路径','support_path','与/或','law_1092',20,
'{"op":"and","children":[{"fact":"婚姻关系已存续且未离婚","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在藏匿转移共同财产线索","cmp":"eq","value":true},{"fact":"存在挥霍家产或恶意处置","cmp":"eq","value":true},{"fact":"存在重大医疗支出或紧急治疗需求","cmp":"eq","value":true}]},{"op":"or","children":[{"fact":"共同财产范围清晰","cmp":"eq","value":true},{"fact":"争议财产类型明确","cmp":"eq","value":true},{"fact":"转移方式已可说明","cmp":"eq","value":true}]}]}',1),
('r_in_marriage_property_exception','in_marriage_property_division_dispute','婚内财产分割例外路径','defense_or_exception_path','与','law_1087',30,
'{"op":"and","children":[{"fact":"婚姻关系已存续且未离婚","cmp":"eq","value":true},{"fact":"存在婚内共同财产争议","cmp":"eq","value":true},{"fact":"共同财产范围清晰","cmp":"eq","value":false},{"fact":"争议财产类型明确","cmp":"eq","value":false}]}',1),
('r_in_marriage_property_type_scope','in_marriage_property_division_dispute','婚内财产类型范围路径','support_path','与/或','law_1087',21,
'{"op":"and","children":[{"fact":"婚姻关系已存续且未离婚","cmp":"eq","value":true},{"op":"or","children":[{"fact":"争议财产类型明确","cmp":"eq","value":true},{"fact":"共同财产范围清晰","cmp":"eq","value":true},{"fact":"转移方式已可说明","cmp":"eq","value":true}]}]}',1),
('r_in_marriage_property_livelihood_impact','in_marriage_property_division_dispute','婚内财产生活影响路径','arrangement_path','与/或','law_1092',31,
'{"op":"and","children":[{"fact":"婚姻关系已存续且未离婚","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在重大医疗支出或紧急治疗需求","cmp":"eq","value":true},{"fact":"医疗支出金额大致明确","cmp":"eq","value":true},{"fact":"已影响家庭基本生活","cmp":"eq","value":true}]}]}',1),

-- post_divorce_damage_liability_dispute
('r_post_divorce_damage_precondition','post_divorce_damage_liability_dispute','离婚后损害前置条件','precondition','与','law_1091',10,
'{"op":"and","children":[{"fact":"离婚事实已生效","cmp":"eq","value":true},{"fact":"存在婚内严重过错或侵害事实线索","cmp":"eq","value":true},{"fact":"存在精神损害或经济损失后果","cmp":"eq","value":true}]}',1),
('r_post_divorce_damage_support','post_divorce_damage_liability_dispute','离婚后损害支持路径','support_path','与','law_1091',20,
'{"op":"and","children":[{"fact":"离婚事实已生效","cmp":"eq","value":true},{"fact":"赔偿金额或范围明确","cmp":"eq","value":true},{"fact":"存在因果关系材料","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在婚内严重过错或侵害事实线索","cmp":"eq","value":true},{"fact":"存在精神损害或经济损失后果","cmp":"eq","value":true},{"fact":"有具体损失或治疗费用/收入损失线索","cmp":"eq","value":true}]}]}',1),
('r_post_divorce_damage_amount','post_divorce_damage_liability_dispute','离婚后损害金额路径','amount_path','与/或','law_1183',30,
'{"op":"and","children":[{"fact":"赔偿金额或范围明确","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在持续治疗材料","cmp":"eq","value":true},{"fact":"存在误工收入损失材料","cmp":"eq","value":true},{"fact":"有具体损失或治疗费用/收入损失线索","cmp":"eq","value":true}]}]}',1),
('r_post_divorce_damage_exception','post_divorce_damage_liability_dispute','离婚后损害例外路径','defense_or_exception_path','与','law_1091',40,
'{"op":"and","children":[{"fact":"离婚事实已生效","cmp":"eq","value":true},{"op":"or","children":[{"fact":"离婚程序中是否已处理损害赔偿","cmp":"eq","value":"handled_yes"},{"fact":"离婚程序中是否已处理损害赔偿","cmp":"eq","value":"已处理"}]}]}',1),
('r_post_divorce_damage_fault','post_divorce_damage_liability_dispute','离婚后损害过错识别路径','support_path','与/或','law_1091',25,
'{"op":"and","children":[{"fact":"离婚事实已生效","cmp":"eq","value":true},{"op":"or","children":[{"fact":"过错类型","cmp":"eq","value":"bigamy"},{"fact":"过错类型","cmp":"eq","value":"重婚"},{"fact":"过错类型","cmp":"eq","value":"cohabitation"},{"fact":"过错类型","cmp":"eq","value":"与他人同居"},{"fact":"过错类型","cmp":"eq","value":"domestic_violence"},{"fact":"过错类型","cmp":"eq","value":"家庭暴力"},{"fact":"过错类型","cmp":"eq","value":"abuse_abandonment"},{"fact":"过错类型","cmp":"eq","value":"虐待遗弃"},{"fact":"过错类型","cmp":"eq","value":"other_tort"},{"fact":"过错类型","cmp":"eq","value":"其他侵害行为"}]}]}',1),
('r_post_divorce_damage_causation','post_divorce_damage_liability_dispute','离婚后损害因果补强路径','amount_path','与','law_1183',35,
'{"op":"and","children":[{"op":"or","children":[{"fact":"损害后果类型","cmp":"eq","value":"medical"},{"fact":"损害后果类型","cmp":"eq","value":"治疗费用"}]},{"fact":"存在因果关系材料","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在持续治疗材料","cmp":"eq","value":true},{"fact":"存在误工收入损失材料","cmp":"eq","value":true}]}]}',1),

-- marriage_invalid_dispute
('r_marriage_invalid_precondition','marriage_invalid_dispute','婚姻无效前置条件','precondition','与','law_1051',10,
'{"op":"and","children":[{"fact":"请求确认婚姻无效","cmp":"eq","value":true},{"fact":"请求人为利害关系人","cmp":"eq","value":true}]}',1),
('r_marriage_invalid_support','marriage_invalid_dispute','婚姻无效支持路径','support_path','与/或','law_1051',20,
'{"op":"and","children":[{"fact":"请求确认婚姻无效","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在在先婚姻未解除事实","cmp":"eq","value":true},{"fact":"属于禁止结婚亲属关系","cmp":"eq","value":true},{"fact":"结婚时未达法定婚龄","cmp":"eq","value":true},{"fact":"无效事由类型","cmp":"eq","value":"prior_marriage"},{"fact":"无效事由类型","cmp":"eq","value":"存在在先婚姻未解除"},{"fact":"无效事由类型","cmp":"eq","value":"prohibited_kinship"},{"fact":"无效事由类型","cmp":"eq","value":"属于禁止结婚亲属关系"},{"fact":"无效事由类型","cmp":"eq","value":"underage"},{"fact":"无效事由类型","cmp":"eq","value":"结婚时未达法定婚龄"}]},{"fact":"有证据材料可补强","cmp":"eq","value":true}]}',1),
('r_marriage_invalid_exception','marriage_invalid_dispute','婚姻无效例外路径','defense_or_exception_path','与','law_1051',30,
'{"op":"and","children":[{"fact":"请求确认婚姻无效","cmp":"eq","value":true},{"fact":"存在在先婚姻未解除事实","cmp":"eq","value":false},{"fact":"属于禁止结婚亲属关系","cmp":"eq","value":false},{"fact":"结婚时未达法定婚龄","cmp":"eq","value":false}]}',1),
('r_marriage_invalid_arrangement','marriage_invalid_dispute','婚姻无效后果路径','arrangement_path','与/或','law_1054',40,
'{"op":"or","children":[{"fact":"是否同时主张财产处理","cmp":"eq","value":true},{"fact":"是否同时主张子女安排","cmp":"eq","value":true}]}',1),
('r_marriage_invalid_prior_marriage','marriage_invalid_dispute','婚姻无效重婚路径','support_path','与/或','law_1051',21,
'{"op":"and","children":[{"fact":"请求确认婚姻无效","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在在先婚姻未解除事实","cmp":"eq","value":true},{"fact":"无效事由类型","cmp":"eq","value":"prior_marriage"},{"fact":"无效事由类型","cmp":"eq","value":"存在在先婚姻未解除"}]},{"fact":"请求人为利害关系人","cmp":"eq","value":true}]}',1),
('r_marriage_invalid_kinship','marriage_invalid_dispute','婚姻无效近亲路径','support_path','与/或','law_1051',22,
'{"op":"and","children":[{"fact":"请求确认婚姻无效","cmp":"eq","value":true},{"op":"or","children":[{"fact":"属于禁止结婚亲属关系","cmp":"eq","value":true},{"fact":"无效事由类型","cmp":"eq","value":"prohibited_kinship"},{"fact":"无效事由类型","cmp":"eq","value":"属于禁止结婚亲属关系"}]},{"fact":"请求人为利害关系人","cmp":"eq","value":true}]}',1),
('r_marriage_invalid_underage','marriage_invalid_dispute','婚姻无效未达婚龄路径','support_path','与/或','law_1051',23,
'{"op":"and","children":[{"fact":"请求确认婚姻无效","cmp":"eq","value":true},{"op":"or","children":[{"fact":"结婚时未达法定婚龄","cmp":"eq","value":true},{"fact":"无效事由类型","cmp":"eq","value":"underage"},{"fact":"无效事由类型","cmp":"eq","value":"结婚时未达法定婚龄"}]},{"fact":"请求人为利害关系人","cmp":"eq","value":true}]}',1),

-- marriage_annulment_dispute
('r_marriage_annulment_precondition','marriage_annulment_dispute','撤销婚姻前置条件','precondition','与','law_1052',10,
'{"op":"and","children":[{"fact":"请求撤销婚姻","cmp":"eq","value":true},{"fact":"在法定期间内提出撤销请求","cmp":"eq","value":true}]}',1),
('r_marriage_annulment_support','marriage_annulment_dispute','撤销婚姻支持路径','support_path','与/或','law_1052',20,
'{"op":"and","children":[{"fact":"请求撤销婚姻","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在胁迫结婚事实","cmp":"eq","value":true},{"fact":"婚前隐瞒重大疾病","cmp":"eq","value":true},{"fact":"撤销事由类型","cmp":"eq","value":"coercion"},{"fact":"撤销事由类型","cmp":"eq","value":"胁迫结婚"},{"fact":"撤销事由类型","cmp":"eq","value":"concealed_disease"},{"fact":"撤销事由类型","cmp":"eq","value":"婚前隐瞒重大疾病"}]},{"fact":"有证据材料可补强","cmp":"eq","value":true}]}',1),
('r_marriage_annulment_exception','marriage_annulment_dispute','撤销婚姻例外路径','defense_or_exception_path','与/或','law_1053',30,
'{"op":"or","children":[{"fact":"在法定期间内提出撤销请求","cmp":"eq","value":false},{"fact":"知道撤销事由时间明确","cmp":"eq","value":false}]}',1),
('r_marriage_annulment_arrangement','marriage_annulment_dispute','撤销婚姻后果路径','arrangement_path','与/或','law_1054',40,
'{"op":"or","children":[{"fact":"主张撤销后损害赔偿","cmp":"eq","value":true},{"fact":"存在撤销后财产返还问题","cmp":"eq","value":true},{"fact":"存在撤销后子女抚养安排问题","cmp":"eq","value":true}]}',1),
('r_marriage_annulment_coercion','marriage_annulment_dispute','撤销婚姻胁迫路径','support_path','与/或','law_1052',21,
'{"op":"and","children":[{"fact":"请求撤销婚姻","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在胁迫结婚事实","cmp":"eq","value":true},{"fact":"撤销事由类型","cmp":"eq","value":"coercion"},{"fact":"撤销事由类型","cmp":"eq","value":"胁迫结婚"}]},{"fact":"在法定期间内提出撤销请求","cmp":"eq","value":true}]}',1),
('r_marriage_annulment_disease','marriage_annulment_dispute','撤销婚姻重大疾病路径','support_path','与/或','law_1053',22,
'{"op":"and","children":[{"fact":"请求撤销婚姻","cmp":"eq","value":true},{"op":"or","children":[{"fact":"婚前隐瞒重大疾病","cmp":"eq","value":true},{"fact":"撤销事由类型","cmp":"eq","value":"concealed_disease"},{"fact":"撤销事由类型","cmp":"eq","value":"婚前隐瞒重大疾病"}]},{"fact":"在法定期间内提出撤销请求","cmp":"eq","value":true}]}',1),
('r_marriage_annulment_time_bar','marriage_annulment_dispute','撤销婚姻法定期间障碍路径','defense_or_exception_path','与/或','law_1053',31,
'{"op":"or","children":[{"fact":"在法定期间内提出撤销请求","cmp":"eq","value":false},{"fact":"知道撤销事由时间明确","cmp":"eq","value":false}]}',1),

-- spousal_property_agreement_dispute
('r_spousal_agreement_precondition','spousal_property_agreement_dispute','夫妻财产约定前置条件','precondition','与','law_1065',10,
'{"op":"and","children":[{"fact":"存在夫妻财产约定协议","cmp":"eq","value":true},{"fact":"约定内容明确","cmp":"eq","value":true},{"fact":"存在书面协议文本","cmp":"eq","value":true}]}',1),
('r_spousal_agreement_support','spousal_property_agreement_dispute','夫妻财产约定支持路径','support_path','与/或','law_1065',20,
'{"op":"and","children":[{"fact":"请求确认协议有效并要求履行","cmp":"eq","value":true},{"op":"or","children":[{"fact":"协议未履行或争议履行","cmp":"eq","value":true},{"fact":"已办理公证或登记","cmp":"eq","value":true},{"fact":"协议签署时间明确","cmp":"eq","value":true}]}]}',1),
('r_spousal_agreement_defense','spousal_property_agreement_dispute','夫妻财产约定抗辩路径','defense_or_exception_path','与/或','law_143',30,
'{"op":"or","children":[{"fact":"对方主张协议无效或被撤销","cmp":"eq","value":true},{"fact":"存在受胁迫欺诈等效力抗辩","cmp":"eq","value":true}]}',1),
('r_spousal_agreement_validity','spousal_property_agreement_dispute','夫妻财产约定效力路径','support_path','与/或','law_1065',21,
'{"op":"and","children":[{"fact":"存在夫妻财产约定协议","cmp":"eq","value":true},{"fact":"存在书面协议文本","cmp":"eq","value":true},{"op":"or","children":[{"fact":"协议签署时间明确","cmp":"eq","value":true},{"fact":"已办理公证或登记","cmp":"eq","value":true},{"fact":"争议财产类型明确","cmp":"eq","value":true}]}]}',1),
('r_spousal_agreement_performance','spousal_property_agreement_dispute','夫妻财产约定履行路径','support_path','与/或','law_1065',22,
'{"op":"and","children":[{"fact":"请求确认协议有效并要求履行","cmp":"eq","value":true},{"fact":"协议未履行或争议履行","cmp":"eq","value":true},{"op":"or","children":[{"fact":"争议财产类型明确","cmp":"eq","value":true},{"fact":"协议签署时间明确","cmp":"eq","value":true}]}]}',1),

-- cohabitation_dispute
('r_cohabitation_precondition','cohabitation_dispute','同居关系前置条件','precondition','与','law_1042',10,
'{"op":"and","children":[{"fact":"是否存在同居关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在财产分割争议","cmp":"eq","value":true},{"fact":"是否存在子女","cmp":"eq","value":true}]}]}',1),
('r_cohabitation_property_support','cohabitation_dispute','同居财产支持路径','support_path','与/或','law_308',20,
'{"op":"and","children":[{"fact":"是否存在同居关系","cmp":"eq","value":true},{"fact":"存在财产分割争议","cmp":"eq","value":true},{"op":"or","children":[{"fact":"同居期间共同生活或共同投入","cmp":"eq","value":true},{"fact":"共同购置房车或大额财物","cmp":"eq","value":true},{"fact":"一方出资比例明显更高","cmp":"eq","value":true}]},{"op":"or","children":[{"fact":"共同财产范围清晰","cmp":"eq","value":true},{"fact":"同居起止时间明确","cmp":"eq","value":true}]}]}',1),
('r_cohabitation_custody_support','cohabitation_dispute','同居子女支持路径','custody_path','与/或','law_1084',30,
'{"op":"and","children":[{"fact":"是否存在子女","cmp":"eq","value":true},{"op":"or","children":[{"fact":"主张子女直接抚养安排","cmp":"eq","value":true},{"fact":"子女主要由一方抚养","cmp":"eq","value":true},{"fact":"对方拒绝或未支付抚养费","cmp":"eq","value":true},{"fact":"孩子月支出明确","cmp":"eq","value":true}]}]}',1),
('r_cohabitation_exception','cohabitation_dispute','同居关系例外路径','defense_or_exception_path','与','law_1042',40,
'{"op":"and","children":[{"fact":"是否存在同居关系","cmp":"eq","value":true},{"fact":"存在财产分割争议","cmp":"eq","value":true},{"fact":"同居期间共同生活或共同投入","cmp":"eq","value":false},{"fact":"共同财产范围清晰","cmp":"eq","value":false}]}',1),
('r_cohabitation_contribution_ratio','cohabitation_dispute','同居出资比例路径','support_path','与/或','law_308',21,
'{"op":"and","children":[{"fact":"是否存在同居关系","cmp":"eq","value":true},{"fact":"存在财产分割争议","cmp":"eq","value":true},{"op":"or","children":[{"fact":"共同购置房车或大额财物","cmp":"eq","value":true},{"fact":"一方出资比例明显更高","cmp":"eq","value":true},{"fact":"同居起止时间明确","cmp":"eq","value":true}]}]}',1),
('r_cohabitation_direct_custody','cohabitation_dispute','同居直接抚养路径','custody_path','与/或','law_1084',31,
'{"op":"and","children":[{"fact":"是否存在子女","cmp":"eq","value":true},{"op":"or","children":[{"fact":"主张子女直接抚养安排","cmp":"eq","value":true},{"fact":"子女主要由一方抚养","cmp":"eq","value":true},{"fact":"孩子月支出明确","cmp":"eq","value":true}]}]}',1),

-- paternity_confirmation_dispute
('r_paternity_confirmation_precondition','paternity_confirmation_dispute','亲子确认前置条件','precondition','与','law_1073',10,
'{"op":"and","children":[{"fact":"存在亲子关系争议","cmp":"eq","value":true},{"fact":"请求确认亲子关系","cmp":"eq","value":true}]}',1),
('r_paternity_confirmation_support','paternity_confirmation_dispute','亲子确认支持路径','support_path','与/或','law_1073',20,
'{"op":"and","children":[{"fact":"请求确认亲子关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"亲子鉴定结论支持主张","cmp":"eq","value":true},{"fact":"出生登记信息与确认主张一致","cmp":"eq","value":true},{"fact":"存在长期共同生活或抚养记录","cmp":"eq","value":true}]},{"op":"or","children":[{"fact":"存在怀孕生育期间往来记录","cmp":"eq","value":true},{"fact":"有出生证明/户口簿或亲属关系证明","cmp":"eq","value":true}]}]}',1),
('r_paternity_confirmation_obstruction','paternity_confirmation_dispute','亲子确认举证妨碍路径','evidence_obstruction_path','与/或','law_81',30,
'{"op":"or","children":[{"fact":"对方拒绝配合亲子鉴定","cmp":"eq","value":true},{"fact":"存在举证妨碍线索","cmp":"eq","value":true}]}',1),
('r_paternity_confirmation_birth_record','paternity_confirmation_dispute','亲子确认出生登记路径','support_path','与/或','law_1073',25,
'{"op":"and","children":[{"fact":"请求确认亲子关系","cmp":"eq","value":true},{"fact":"出生登记信息与确认主张一致","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在怀孕生育期间往来记录","cmp":"eq","value":true},{"fact":"存在长期共同生活或抚养记录","cmp":"eq","value":true}]}]}',1),

-- paternity_disclaimer_dispute
('r_paternity_disclaimer_precondition','paternity_disclaimer_dispute','亲子否认前置条件','precondition','与','law_1073',10,
'{"op":"and","children":[{"fact":"存在亲子关系争议","cmp":"eq","value":true},{"fact":"请求否认亲子关系","cmp":"eq","value":true}]}',1),
('r_paternity_disclaimer_support','paternity_disclaimer_dispute','亲子否认支持路径','support_path','与/或','law_1073',20,
'{"op":"and","children":[{"fact":"请求否认亲子关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"亲子鉴定结论支持否认方主张","cmp":"eq","value":true},{"fact":"出生登记信息与否认主张不一致","cmp":"eq","value":true}]},{"op":"or","children":[{"fact":"存在怀孕生育期间往来记录","cmp":"eq","value":false},{"fact":"存在长期共同生活或抚养记录","cmp":"eq","value":false},{"fact":"有出生证明/户口簿或亲属关系证明","cmp":"eq","value":true}]}]}',1),
('r_paternity_disclaimer_obstruction','paternity_disclaimer_dispute','亲子否认举证妨碍路径','evidence_obstruction_path','与/或','law_81',30,
'{"op":"or","children":[{"fact":"对方拒绝配合亲子鉴定","cmp":"eq","value":true},{"fact":"存在举证妨碍线索","cmp":"eq","value":true}]}',1),
('r_paternity_disclaimer_birth_record','paternity_disclaimer_dispute','亲子否认出生登记路径','support_path','与/或','law_1073',25,
'{"op":"and","children":[{"fact":"请求否认亲子关系","cmp":"eq","value":true},{"fact":"出生登记信息与否认主张不一致","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在怀孕生育期间往来记录","cmp":"eq","value":false},{"fact":"存在长期共同生活或抚养记录","cmp":"eq","value":false}]}]}',1),

-- sibling_support_dispute
('r_sibling_support_precondition','sibling_support_dispute','扶养纠纷前置条件','precondition','与','law_1075',10,
'{"op":"and","children":[{"fact":"存在扶养义务关系","cmp":"eq","value":true},{"fact":"被扶养人生活困难","cmp":"eq","value":true}]}',1),
('r_sibling_support_fee_support','sibling_support_dispute','扶养费支持路径','support_path','与/或','law_1075',20,
'{"op":"and","children":[{"fact":"存在扶养义务关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"被扶养人无劳动能力或患病","cmp":"eq","value":true},{"fact":"存在重大医疗护理支出","cmp":"eq","value":true},{"fact":"月扶养费金额明确","cmp":"eq","value":true}]},{"op":"or","children":[{"fact":"扶养人收入能力明确","cmp":"eq","value":true},{"fact":"存在多名扶养义务人","cmp":"eq","value":true},{"fact":"已有长期照料一方","cmp":"eq","value":true}]}]}',1),
('r_sibling_support_change_support','sibling_support_dispute','扶养变更支持路径','arrangement_path','与/或','law_1075',30,
'{"op":"and","children":[{"fact":"主张变更扶养关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"变更原因属于法定情形","cmp":"eq","value":true},{"fact":"已有长期照料一方","cmp":"eq","value":true},{"fact":"存在多名扶养义务人","cmp":"eq","value":true}]}]}',1),
('r_sibling_support_exception','sibling_support_dispute','扶养纠纷例外路径','defense_or_exception_path','与','law_1075',40,
'{"op":"and","children":[{"fact":"存在扶养义务关系","cmp":"eq","value":true},{"fact":"扶养人收入能力明确","cmp":"eq","value":false},{"fact":"存在多名扶养义务人","cmp":"eq","value":false},{"fact":"月扶养费金额明确","cmp":"eq","value":false}]}',1),
('r_sibling_support_medical','sibling_support_dispute','扶养医疗护理路径','support_path','与/或','law_1075',21,
'{"op":"and","children":[{"fact":"存在扶养义务关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"被扶养人无劳动能力或患病","cmp":"eq","value":true},{"fact":"存在重大医疗护理支出","cmp":"eq","value":true}]},{"fact":"月扶养费金额明确","cmp":"eq","value":true}]}',1),
('r_sibling_support_multi_obligor','sibling_support_dispute','扶养多义务人路径','arrangement_path','与/或','law_1075',31,
'{"op":"and","children":[{"fact":"存在扶养义务关系","cmp":"eq","value":true},{"fact":"存在多名扶养义务人","cmp":"eq","value":true},{"op":"or","children":[{"fact":"已有长期照料一方","cmp":"eq","value":true},{"fact":"扶养人收入能力明确","cmp":"eq","value":true}]}]}',1),

-- adoption_dispute
('r_adoption_precondition','adoption_dispute','收养纠纷前置条件','precondition','与/或','law_1093',10,
'{"op":"or","children":[{"fact":"请求确认收养关系","cmp":"eq","value":true},{"fact":"请求解除收养关系","cmp":"eq","value":true}]}',1),
('r_adoption_confirm_support','adoption_dispute','收养确认支持路径','support_path','与/或','law_1093',20,
'{"op":"and","children":[{"fact":"请求确认收养关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"是否已办理收养登记","cmp":"eq","value":true},{"fact":"存在事实收养长期维持","cmp":"eq","value":true},{"fact":"收养路径类型","cmp":"eq","value":"registered"},{"fact":"收养路径类型","cmp":"eq","value":"登记收养"},{"fact":"收养路径类型","cmp":"eq","value":"de_facto"},{"fact":"收养路径类型","cmp":"eq","value":"事实收养"}]},{"op":"or","children":[{"fact":"存在送养同意或协议材料","cmp":"eq","value":true},{"fact":"收养人具备长期抚养能力","cmp":"eq","value":true},{"fact":"存在长期共同生活情况","cmp":"eq","value":true}]}]}',1),
('r_adoption_dissolve_support','adoption_dispute','解除收养支持路径','support_path','与/或','law_1115',30,
'{"op":"and","children":[{"fact":"请求解除收养关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在解除原因线索","cmp":"eq","value":true},{"fact":"收养路径类型","cmp":"eq","value":"dissolution"},{"fact":"收养路径类型","cmp":"eq","value":"解除收养"}]},{"op":"or","children":[{"fact":"解除后未成年人抚养安排明确","cmp":"eq","value":true},{"fact":"有证据材料可补强","cmp":"eq","value":true}]}]}',1),
('r_adoption_exception','adoption_dispute','收养纠纷例外路径','defense_or_exception_path','与','law_1093',40,
'{"op":"and","children":[{"fact":"请求确认收养关系","cmp":"eq","value":true},{"fact":"是否已办理收养登记","cmp":"eq","value":false},{"fact":"存在事实收养长期维持","cmp":"eq","value":false},{"fact":"存在送养同意或协议材料","cmp":"eq","value":false}]}',1),
('r_adoption_registered_confirm','adoption_dispute','登记收养确认路径','support_path','与/或','law_1093',21,
'{"op":"and","children":[{"fact":"请求确认收养关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"是否已办理收养登记","cmp":"eq","value":true},{"fact":"收养路径类型","cmp":"eq","value":"registered"},{"fact":"收养路径类型","cmp":"eq","value":"登记收养"}]},{"fact":"存在送养同意或协议材料","cmp":"eq","value":true}]}',1),
('r_adoption_de_facto_confirm','adoption_dispute','事实收养确认路径','support_path','与/或','law_1093',22,
'{"op":"and","children":[{"fact":"请求确认收养关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在事实收养长期维持","cmp":"eq","value":true},{"fact":"收养路径类型","cmp":"eq","value":"de_facto"},{"fact":"收养路径类型","cmp":"eq","value":"事实收养"}]},{"op":"or","children":[{"fact":"存在长期共同生活情况","cmp":"eq","value":true},{"fact":"收养人具备长期抚养能力","cmp":"eq","value":true}]}]}',1),
('r_adoption_post_dissolve_arrangement','adoption_dispute','解除收养后果安排路径','arrangement_path','与/或','law_1115',31,
'{"op":"and","children":[{"fact":"请求解除收养关系","cmp":"eq","value":true},{"fact":"解除后未成年人抚养安排明确","cmp":"eq","value":true}]}',1),

-- guardianship_dispute
('r_guardianship_precondition','guardianship_dispute','监护权前置条件','precondition','与','law_27',10,
'{"op":"and","children":[{"fact":"需要确定或变更监护人","cmp":"eq","value":true},{"fact":"被监护人无或限制民事行为能力","cmp":"eq","value":true}]}',1),
('r_guardianship_support','guardianship_dispute','监护权支持路径','support_path','与/或','law_31',20,
'{"op":"and","children":[{"fact":"请求指定或变更监护人","cmp":"eq","value":true},{"op":"or","children":[{"fact":"有医学鉴定或诊断证据","cmp":"eq","value":true},{"fact":"当前监护人不适合或不履行","cmp":"eq","value":true}]},{"op":"or","children":[{"fact":"申请人主体资格明确","cmp":"eq","value":true},{"fact":"申请人照护能力较强","cmp":"eq","value":true},{"fact":"存在居委村委或民政意见","cmp":"eq","value":true}]}]}',1),
('r_guardianship_property_support','guardianship_dispute','监护财产支持路径','arrangement_path','与/或','law_35',30,
'{"op":"and","children":[{"fact":"请求指定或变更监护人","cmp":"eq","value":true},{"fact":"存在财产管理需求","cmp":"eq","value":true}]}',1),
('r_guardianship_subject_qualification','guardianship_dispute','监护主体资格路径','support_path','与/或','law_27',21,
'{"op":"and","children":[{"fact":"请求指定或变更监护人","cmp":"eq","value":true},{"fact":"申请人主体资格明确","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在居委村委或民政意见","cmp":"eq","value":true},{"fact":"当前监护人不适合或不履行","cmp":"eq","value":true}]}]}',1),
('r_guardianship_care_ability','guardianship_dispute','监护照护能力路径','support_path','与/或','law_31',22,
'{"op":"and","children":[{"fact":"请求指定或变更监护人","cmp":"eq","value":true},{"fact":"申请人照护能力较强","cmp":"eq","value":true},{"op":"or","children":[{"fact":"有医学鉴定或诊断证据","cmp":"eq","value":true},{"fact":"存在财产管理需求","cmp":"eq","value":true}]}]}',1),

-- visitation_dispute
('r_visitation_precondition','visitation_dispute','探望权前置条件','precondition','与','law_1086',10,
'{"op":"and","children":[{"fact":"已离婚或已分开","cmp":"eq","value":true},{"fact":"为非直接抚养方","cmp":"eq","value":true}]}',1),
('r_visitation_support','visitation_dispute','探望权支持路径','support_path','与/或','law_1086',20,
'{"op":"and","children":[{"fact":"请求法院明确探望方式时间","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在拒绝探望或障碍","cmp":"eq","value":true},{"fact":"主张节假日或住宿探望","cmp":"eq","value":true},{"fact":"既有探望频率安排明确","cmp":"eq","value":true},{"fact":"子女有明确探望意愿","cmp":"eq","value":true}]}]}',1),
('r_visitation_exception','visitation_dispute','探望权例外路径','defense_or_exception_path','与/或','law_1086',30,
'{"op":"or","children":[{"fact":"存在中止探望风险线索","cmp":"eq","value":true},{"fact":"子女已满八周岁","cmp":"eq","value":true},{"fact":"子女有明确探望意愿","cmp":"eq","value":false}]}',1),
('r_visitation_child_will','visitation_dispute','探望权子女意愿路径','support_path','与/或','law_1086',21,
'{"op":"and","children":[{"fact":"请求法院明确探望方式时间","cmp":"eq","value":true},{"fact":"子女已满八周岁","cmp":"eq","value":true},{"op":"or","children":[{"fact":"子女有明确探望意愿","cmp":"eq","value":true},{"fact":"既有探望频率安排明确","cmp":"eq","value":true}]}]}',1),
('r_visitation_suspension_risk','visitation_dispute','探望权中止风险路径','defense_or_exception_path','与/或','law_1086',31,
'{"op":"or","children":[{"fact":"存在中止探望风险线索","cmp":"eq","value":true},{"op":"and","children":[{"fact":"主张节假日或住宿探望","cmp":"eq","value":true},{"fact":"子女有明确探望意愿","cmp":"eq","value":false}]}]}',1),

-- family_partition_dispute
('r_family_partition_precondition','family_partition_dispute','分家析产前置条件','precondition','与','law_308',10,
'{"op":"and","children":[{"fact":"家庭共同生活或共同置办财产","cmp":"eq","value":true},{"fact":"请求分割/析产","cmp":"eq","value":true}]}',1),
('r_family_partition_support','family_partition_dispute','分家析产支持路径','support_path','与/或','law_309',20,
'{"op":"and","children":[{"fact":"存在分割争议","cmp":"eq","value":true},{"op":"or","children":[{"fact":"共同财产范围清晰","cmp":"eq","value":true},{"fact":"财产登记名义明确","cmp":"eq","value":true},{"fact":"主要出资来源明确","cmp":"eq","value":true},{"fact":"存在长期占有使用一方","cmp":"eq","value":true}]},{"op":"or","children":[{"fact":"家庭成员范围明确","cmp":"eq","value":true},{"fact":"有不动产或财产登记证据","cmp":"eq","value":true},{"fact":"有财产清单/账本/沟通记录","cmp":"eq","value":true}]}]}',1),
('r_family_partition_exception','family_partition_dispute','分家析产例外路径','defense_or_exception_path','与/或','law_308',30,
'{"op":"or","children":[{"fact":"家庭成员范围明确","cmp":"eq","value":false},{"fact":"财产登记名义明确","cmp":"eq","value":false},{"fact":"已实际分家","cmp":"eq","value":false},{"fact":"共同财产范围清晰","cmp":"eq","value":false}]}',1),
('r_family_partition_member_boundary','family_partition_dispute','分家析产成员边界路径','support_path','与/或','law_308',21,
'{"op":"and","children":[{"fact":"请求分割/析产","cmp":"eq","value":true},{"op":"or","children":[{"fact":"家庭成员范围明确","cmp":"eq","value":true},{"fact":"已实际分家","cmp":"eq","value":true},{"fact":"存在长期占有使用一方","cmp":"eq","value":true}]}]}',1),
('r_family_partition_registration_source','family_partition_dispute','分家析产权属来源路径','support_path','与/或','law_309',22,
'{"op":"and","children":[{"fact":"存在分割争议","cmp":"eq","value":true},{"op":"or","children":[{"fact":"财产登记名义明确","cmp":"eq","value":true},{"fact":"主要出资来源明确","cmp":"eq","value":true},{"fact":"共同财产范围清晰","cmp":"eq","value":true}]}]}',1);

INSERT INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order)
VALUES
('r_in_marriage_property_precondition','c_in_marriage_property_precondition',1),
('r_in_marriage_property_support','c_in_marriage_property_support',1),
('r_in_marriage_property_exception','c_in_marriage_property_exception',1),
('r_in_marriage_property_type_scope','c_in_marriage_property_type_scope',1),
('r_in_marriage_property_livelihood_impact','c_in_marriage_property_livelihood_impact',1),

('r_post_divorce_damage_precondition','c_post_divorce_damage_precondition',1),
('r_post_divorce_damage_support','c_post_divorce_damage_support',1),
('r_post_divorce_damage_fault','c_post_divorce_damage_fault',1),
('r_post_divorce_damage_causation','c_post_divorce_damage_causation',1),
('r_post_divorce_damage_amount','c_post_divorce_damage_amount',1),
('r_post_divorce_damage_exception','c_post_divorce_damage_exception',1),

('r_marriage_invalid_precondition','c_marriage_invalid_precondition',1),
('r_marriage_invalid_support','c_marriage_invalid_support',1),
('r_marriage_invalid_prior_marriage','c_marriage_invalid_prior_marriage',1),
('r_marriage_invalid_kinship','c_marriage_invalid_kinship',1),
('r_marriage_invalid_underage','c_marriage_invalid_underage',1),
('r_marriage_invalid_exception','c_marriage_invalid_exception',1),
('r_marriage_invalid_arrangement','c_marriage_invalid_arrangement',1),

('r_marriage_annulment_precondition','c_marriage_annulment_precondition',1),
('r_marriage_annulment_support','c_marriage_annulment_support',1),
('r_marriage_annulment_coercion','c_marriage_annulment_coercion',1),
('r_marriage_annulment_disease','c_marriage_annulment_disease',1),
('r_marriage_annulment_exception','c_marriage_annulment_exception',1),
('r_marriage_annulment_time_bar','c_marriage_annulment_time_bar',1),
('r_marriage_annulment_arrangement','c_marriage_annulment_arrangement',1),

('r_spousal_agreement_precondition','c_spousal_agreement_precondition',1),
('r_spousal_agreement_support','c_spousal_agreement_support',1),
('r_spousal_agreement_defense','c_spousal_agreement_defense',1),
('r_spousal_agreement_validity','c_spousal_agreement_validity',1),
('r_spousal_agreement_performance','c_spousal_agreement_performance',1),

('r_cohabitation_precondition','c_cohabitation_precondition',1),
('r_cohabitation_property_support','c_cohabitation_property_support',1),
('r_cohabitation_custody_support','c_cohabitation_custody_support',1),
('r_cohabitation_exception','c_cohabitation_exception',1),
('r_cohabitation_contribution_ratio','c_cohabitation_contribution_ratio',1),
('r_cohabitation_direct_custody','c_cohabitation_direct_custody',1),

('r_paternity_confirmation_precondition','c_paternity_confirmation_precondition',1),
('r_paternity_confirmation_support','c_paternity_confirmation_support',1),
('r_paternity_confirmation_birth_record','c_paternity_confirmation_birth_record',1),
('r_paternity_confirmation_obstruction','c_paternity_confirmation_obstruction',1),

('r_paternity_disclaimer_precondition','c_paternity_disclaimer_precondition',1),
('r_paternity_disclaimer_support','c_paternity_disclaimer_support',1),
('r_paternity_disclaimer_birth_record','c_paternity_disclaimer_birth_record',1),
('r_paternity_disclaimer_obstruction','c_paternity_disclaimer_obstruction',1),

('r_sibling_support_precondition','c_sibling_support_precondition',1),
('r_sibling_support_fee_support','c_sibling_support_fee_support',1),
('r_sibling_support_change_support','c_sibling_support_change_support',1),
('r_sibling_support_medical','c_sibling_support_medical',1),
('r_sibling_support_multi_obligor','c_sibling_support_multi_obligor',1),
('r_sibling_support_exception','c_sibling_support_exception',1),

('r_adoption_precondition','c_adoption_precondition',1),
('r_adoption_confirm_support','c_adoption_confirm_support',1),
('r_adoption_registered_confirm','c_adoption_registered_confirm',1),
('r_adoption_de_facto_confirm','c_adoption_de_facto_confirm',1),
('r_adoption_dissolve_support','c_adoption_dissolve_support',1),
('r_adoption_post_dissolve_arrangement','c_adoption_post_dissolve_arrangement',1),
('r_adoption_exception','c_adoption_exception',1),

('r_guardianship_precondition','c_guardianship_precondition',1),
('r_guardianship_support','c_guardianship_support',1),
('r_guardianship_property_support','c_guardianship_property_support',1),
('r_guardianship_subject_qualification','c_guardianship_subject_qualification',1),
('r_guardianship_care_ability','c_guardianship_care_ability',1),

('r_visitation_precondition','c_visitation_precondition',1),
('r_visitation_support','c_visitation_support',1),
('r_visitation_exception','c_visitation_exception',1),
('r_visitation_child_will','c_visitation_child_will',1),
('r_visitation_suspension_risk','c_visitation_suspension_risk',1),

('r_family_partition_precondition','c_family_partition_precondition',1),
('r_family_partition_support','c_family_partition_support',1),
('r_family_partition_exception','c_family_partition_exception',1),
('r_family_partition_member_boundary','c_family_partition_member_boundary',1),
('r_family_partition_registration_source','c_family_partition_registration_source',1);
