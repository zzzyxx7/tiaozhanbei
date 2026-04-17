USE rule_engine_db;
SET NAMES utf8mb4;

-- 目的：把存量婚姻家事案由（divorce_dispute / child_support_dispute / support_dispute / post_divorce_property）
-- 的 Step1 规则与结论精细化到第一梯队；并清理旧的 r_add_* / c_add_* 体系，避免重复或冲突。

-- ==========================================================
-- A) 清理旧规则/结论（仅限这 4 个案由）
-- ==========================================================

DELETE rc FROM rule_judge_rule_conclusion rc
JOIN rule_judge_rule r ON r.rule_id=rc.rule_id
WHERE r.cause_code IN ('divorce_dispute','child_support_dispute','support_dispute','post_divorce_property');

DELETE FROM rule_judge_rule
WHERE cause_code IN ('divorce_dispute','child_support_dispute','support_dispute','post_divorce_property');

DELETE FROM rule_judge_conclusion
WHERE conclusion_id LIKE 'c_add_divorce_%'
   OR conclusion_id LIKE 'c_add_child_support_%'
   OR conclusion_id LIKE 'c_add_support_%'
   OR conclusion_id LIKE 'c_add_post_divorce_%'
   OR conclusion_id LIKE 'c_divorce_dispute_%'
   OR conclusion_id LIKE 'c_child_support_%'
   OR conclusion_id LIKE 'c_support_%'
   OR conclusion_id LIKE 'c_post_divorce_property_%';

-- ==========================================================
-- B) 结论（按“路径分支”拆分）
-- ==========================================================

INSERT INTO rule_judge_conclusion
(conclusion_id,type,result,reason,level,law_refs_json,final_item,final_result,final_detail,enabled)
VALUES
-- divorce_dispute
('c_divorce_dispute_precondition','conclusion','离婚纠纷：具备审查入口','存在合法婚姻关系并已提出离婚主张线索，可进入离婚事由/子女/财产债务的分支审查。','important','["law_1079"]','审查入口','进入离婚纠纷分支分析','建议补齐结婚登记、感情破裂、子女与财产债务线索。',1),
('c_divorce_dispute_breakdown','conclusion','离婚纠纷：感情破裂路径较明确','分居、冲突、调解失败等事实更有利于支持“感情确已破裂”。','important','["law_1079"]','离婚诉请','判决离婚支持度提升','建议按时间线整理分居/冲突/调解材料并固定证据。',1),
('c_divorce_dispute_violence_fault','conclusion','离婚纠纷：家暴/重大过错路径较明确','家暴或重大过错线索清晰时，离婚支持度与衍生请求基础更强。','important','["law_1091","law_1079"]','离婚诉请','可优先走家暴/过错证据链','建议固定报警回执、告诫书、伤情、就医记录等。',1),
('c_divorce_dispute_custody','conclusion','离婚纠纷：子女抚养路径较明确','子女长期随一方生活、另一方存在不利因素或抚养能力对比明确时，抚养请求更有优势。','important','["law_1084"]','抚养诉请','可主张直接抚养/抚养费/探望安排','建议提交就学、照护、收入住房与子女意愿（八周岁以上）材料。',1),
('c_divorce_dispute_property_debt','conclusion','离婚纠纷：财产与债务处理路径较明确','共同财产/共同债务范围越清晰，越利于一次性解决争议。','important','["law_1087","law_1089"]','财产债务诉请','建议同步提出财产债务处理','建议形成资产负债清单并逐项对应证据。',1),
('c_divorce_dispute_need_more_facts','conclusion','离婚纠纷：当前事实不足需先补齐','离婚事由、子女或财产债务的关键事实未形成稳定证据链，易导致结论不稳或答非所问。','warning','["law_1079"]','补强方向','先补齐关键事实再判断路径','建议优先补齐结婚登记、分居/冲突证据、子女抚养现状、财产债务清单。',1),

-- child_support_dispute
('c_child_support_precondition','conclusion','抚养费/变更抚养：具备审查入口','存在亲子关系与抚养费争议线索，可进入抚养费、拖欠补付或变更抚养的分支审查。','important','["law_1085"]','审查入口','进入抚养纠纷分支分析','建议补齐亲子关系材料、既有协议/判决与支付记录。',1),
('c_child_support_claim_fee','conclusion','抚养费：主张支付/补付路径较明确','对方未支付抚养费且基础文书或约定明确时，补付/持续支付主张更稳。','important','["law_1085"]','抚养费请求','可主张支付/补付抚养费','建议固定拖欠记录、催要记录与对方收入能力证据。',1),
('c_child_support_change_amount','conclusion','抚养费：变更数额路径较明确','子女支出或收入能力发生变化、教育医疗等重大支出明确时，变更数额更有依据。','important','["law_1085"]','变更请求','可主张提高/降低抚养费','建议提交支出变化与收入变化证据。',1),
('c_child_support_change_custody','conclusion','变更抚养关系：路径较明确','存在法定变更情形且有利于子女成长证据较充分时，变更抚养主张更有优势。','important','["law_1084"]','变更抚养请求','可主张变更直接抚养','建议提交抚养现状、不利因素及子女意愿材料。',1),

-- support_dispute
('c_support_precondition','conclusion','赡养纠纷：具备审查入口','存在赡养关系与生活困难线索，可进入赡养费、医疗护理与分担安排分支审查。','important','["law_1067"]','审查入口','进入赡养纠纷分支分析','建议补齐亲属关系证明、生活困难与医疗失能材料。',1),
('c_support_fee_claim','conclusion','赡养费：支付请求路径较明确','生活困难事实较明确且对方拒绝履行时，赡养费支付请求更有支持度。','important','["law_1067"]','赡养费请求','可主张按月/定期赡养费','建议提交生活困难、拒绝履行和收入能力材料。',1),
('c_support_medical_disability','conclusion','赡养纠纷：医疗/失能费用路径较明确','医疗失能、护理支出证据越充分，越利于明确赡养金额与支付方式。','important','["law_1067"]','赡养费请求','可围绕医疗护理费用主张','建议汇总病历、票据、护理合同与支付凭证。',1),
('c_support_multi_obligor','conclusion','赡养纠纷：多名赡养人分担路径较明确','赡养人范围与各自收入能力明确时，更利于提出分担方案并落地执行。','important','["law_1067"]','分担方案','可主张多名赡养人分担','建议提交赡养人清单、收入证据与既往分担记录。',1),

-- post_divorce_property
('c_post_divorce_property_precondition','conclusion','离婚后财产：具备审查入口','离婚已生效且存在未分割/隐藏转移/协议履行争议线索，可进入再分割、责任追究或协议履行分支。','important','["law_1087","law_jsyi_84"]','审查入口','进入离婚后财产分支分析','建议补齐离婚文书、财产线索与交易材料。',1),
('c_post_divorce_property_redistribute','conclusion','离婚后财产：再分割路径较明确','存在未分割共同财产且请求方向明确时，可主张离婚后再次分割。','important','["law_1087"]','再分割请求','具备再分割基础','建议整理未分割财产清单与线索来源证据。',1),
('c_post_divorce_property_conceal_penalty','conclusion','离婚后财产：隐藏转移责任路径较明确','隐藏转移线索与交易证据较充分时，可主张少分/不分或追究责任。','important','["law_1092","law_jsyi_84"]','责任追究请求','可主张少分/不分或返还','建议固定流水、交易对手、资产去向及时间线。',1),
('c_post_divorce_property_agreement_enforce','conclusion','离婚后财产：协议履行路径较明确','离婚协议财产条款未履行且文本/催告证据充分时，可主张确认并履行。','important','["law_jsyi_69","law_1087"]','协议履行请求','可主张履行协议条款','建议提交协议原件、公证/登记与履行障碍证据。',1),
('c_post_divorce_property_time_limit_risk','conclusion','离婚后财产：存在发现时间/时效风险需先处理','发现时间不清或可能超过时效时，需要先补强发现节点与中断/中止线索。','warning','["law_jsyi_84"]','风险提示','优先补强发现时间与时效说明','建议固定查询回执、聊天记录、线索形成过程等材料。',1);

-- ==========================================================
-- C) 规则（多分支，避免答非所问）
-- ==========================================================

INSERT INTO rule_judge_rule
(rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled)
VALUES
-- divorce_dispute
('r_divorce_dispute_precondition','divorce_dispute','离婚纠纷前置条件','precondition','与','law_1079',10,
'{"op":"and","children":[{"fact":"存在合法婚姻关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"感情确已破裂","cmp":"eq","value":true},{"fact":"对方不同意离婚或拖延","cmp":"eq","value":true},{"fact":"存在家庭暴力或重大过错","cmp":"eq","value":true}]}]}',1),
('r_divorce_dispute_breakdown','divorce_dispute','离婚纠纷感情破裂路径','support_path','与/或','law_1079',20,
'{"op":"and","children":[{"fact":"存在合法婚姻关系","cmp":"eq","value":true},{"fact":"感情确已破裂","cmp":"eq","value":true},{"op":"or","children":[{"fact":"分居满一年","cmp":"eq","value":true},{"fact":"存在分居事实","cmp":"eq","value":true},{"fact":"有分居证据","cmp":"eq","value":true}]}]}',1),
('r_divorce_dispute_violence_fault','divorce_dispute','离婚纠纷家暴/过错路径','support_path','与/或','law_1091',21,
'{"op":"and","children":[{"fact":"存在家庭暴力或重大过错","cmp":"eq","value":true},{"op":"or","children":[{"fact":"有家暴或报警记录","cmp":"eq","value":true},{"fact":"有家暴或报警记录","cmp":"eq","value":false}]}]}',1),
('r_divorce_dispute_custody','divorce_dispute','离婚纠纷子女抚养路径','custody_path','与/或','law_1084',30,
'{"op":"and","children":[{"fact":"涉及子女抚养","cmp":"eq","value":true},{"op":"or","children":[{"fact":"子女长期随一方生活","cmp":"eq","value":true},{"fact":"另一方存在不利抚养因素","cmp":"eq","value":true},{"fact":"是否存在子女意愿争议","cmp":"eq","value":true},{"fact":"有抚养能力材料","cmp":"eq","value":true}]}]}',1),
('r_divorce_dispute_property_debt','divorce_dispute','离婚纠纷财产债务路径','support_path','与/或','law_1089',40,
'{"op":"or","children":[{"fact":"涉及夫妻共同财产","cmp":"eq","value":true},{"fact":"存在共同债务","cmp":"eq","value":true},{"fact":"共同财产范围清晰","cmp":"eq","value":true},{"fact":"是否存在共同债务争议","cmp":"eq","value":true}]}',1),
('r_divorce_dispute_need_more_facts','divorce_dispute','离婚纠纷补强提示路径','defense_or_exception_path','与/或','law_1079',90,
'{"op":"and","children":[{"fact":"存在合法婚姻关系","cmp":"eq","value":true},{"fact":"感情确已破裂","cmp":"eq","value":false},{"fact":"涉及子女抚养","cmp":"eq","value":false},{"fact":"涉及夫妻共同财产","cmp":"eq","value":false},{"fact":"存在共同债务","cmp":"eq","value":false}]}',1),

-- child_support_dispute
('r_child_support_precondition','child_support_dispute','抚养费/变更抚养前置条件','precondition','与','law_1085',10,
'{"op":"and","children":[{"fact":"存在亲子关系","cmp":"eq","value":true},{"op":"or","children":[{"fact":"对方未支付抚养费","cmp":"eq","value":true},{"fact":"是否主张变更抚养关系","cmp":"eq","value":true},{"fact":"是否存在重大支出变化","cmp":"eq","value":true}]}]}',1),
('r_child_support_claim_fee','child_support_dispute','抚养费主张/补付路径','support_path','与','law_1085',20,
'{"op":"and","children":[{"fact":"存在亲子关系","cmp":"eq","value":true},{"fact":"对方未支付抚养费","cmp":"eq","value":true},{"op":"or","children":[{"fact":"是否有离婚协议或判决","cmp":"eq","value":true},{"fact":"约定抚养费金额","cmp":"eq","value":0}]}]}',1),
('r_child_support_change_amount','child_support_dispute','抚养费变更数额路径','amount_path','与/或','law_1085',30,
'{"op":"and","children":[{"fact":"是否存在重大支出变化","cmp":"eq","value":true},{"op":"or","children":[{"fact":"孩子实际月支出","cmp":"eq","value":0},{"fact":"对方收入水平大致明确","cmp":"eq","value":true}]}]}',1),
('r_child_support_change_custody','child_support_dispute','变更抚养关系路径','custody_path','与/或','law_1084',40,
'{"op":"and","children":[{"fact":"是否主张变更抚养关系","cmp":"eq","value":true},{"fact":"变更原因属于法定情形","cmp":"eq","value":true}]}',1),

-- support_dispute
('r_support_precondition','support_dispute','赡养纠纷前置条件','precondition','与','law_1067',10,
'{"op":"and","children":[{"fact":"存在赡养关系","cmp":"eq","value":true},{"fact":"被赡养人生活困难","cmp":"eq","value":true}]}',1),
('r_support_fee_claim','support_dispute','赡养费支付路径','support_path','与/或','law_1067',20,
'{"op":"and","children":[{"fact":"存在赡养关系","cmp":"eq","value":true},{"fact":"赡养人拒绝履行","cmp":"eq","value":true},{"op":"or","children":[{"fact":"被赡养人月基本支出","cmp":"eq","value":0},{"fact":"赡养人收入能力大致明确","cmp":"eq","value":true}]}]}',1),
('r_support_medical_disability','support_dispute','赡养医疗/失能路径','support_path','与/或','law_1067',21,
'{"op":"and","children":[{"fact":"有医疗或失能证明","cmp":"eq","value":true},{"op":"or","children":[{"fact":"被赡养人生活困难","cmp":"eq","value":true},{"fact":"被赡养人月基本支出","cmp":"eq","value":0}]}]}',1),
('r_support_multi_obligor','support_dispute','赡养多义务人分担路径','arrangement_path','与/或','law_1067',30,
'{"op":"and","children":[{"fact":"是否存在多名赡养人","cmp":"eq","value":true},{"op":"or","children":[{"fact":"赡养人收入能力大致明确","cmp":"eq","value":true},{"fact":"赡养人拒绝履行","cmp":"eq","value":true}]}]}',1),

-- post_divorce_property
('r_post_divorce_property_precondition','post_divorce_property','离婚后财产前置条件','precondition','与','law_1087',10,
'{"op":"and","children":[{"fact":"离婚事实已生效","cmp":"eq","value":true},{"op":"or","children":[{"fact":"存在未分割共同财产","cmp":"eq","value":true},{"fact":"存在隐藏转移财产线索","cmp":"eq","value":true},{"fact":"离婚协议财产条款未履行","cmp":"eq","value":true},{"fact":"新发现财产线索","cmp":"eq","value":true}]}]}',1),
('r_post_divorce_property_redistribute','post_divorce_property','离婚后再分割路径','support_path','与','law_1087',20,
'{"op":"and","children":[{"fact":"存在未分割共同财产","cmp":"eq","value":true},{"fact":"请求再次分割","cmp":"eq","value":true}]}',1),
('r_post_divorce_property_conceal_penalty','post_divorce_property','隐藏转移责任路径','support_path','与/或','law_1092',21,
'{"op":"and","children":[{"fact":"存在隐藏转移财产线索","cmp":"eq","value":true},{"fact":"有证据证明隐藏转移","cmp":"eq","value":true}]}',1),
('r_post_divorce_property_agreement_enforce','post_divorce_property','协议履行路径','support_path','与/或','law_jsyi_69',30,
'{"op":"and","children":[{"fact":"存在离婚协议","cmp":"eq","value":true},{"fact":"离婚协议财产条款未履行","cmp":"eq","value":true},{"fact":"请求执行离婚协议","cmp":"eq","value":true}]}',1),
('r_post_divorce_property_time_limit_risk','post_divorce_property','发现时间/时效风险路径','defense_or_exception_path','与/或','law_jsyi_84',80,
'{"op":"and","children":[{"fact":"新发现财产线索","cmp":"eq","value":true},{"op":"or","children":[{"fact":"发现财产线索时间明确","cmp":"eq","value":false},{"fact":"离婚后已过三年风险","cmp":"eq","value":true}]}]}',1);

-- ==========================================================
-- D) 绑定规则与结论
-- ==========================================================

INSERT INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order) VALUES
('r_divorce_dispute_precondition','c_divorce_dispute_precondition',1),
('r_divorce_dispute_breakdown','c_divorce_dispute_breakdown',1),
('r_divorce_dispute_violence_fault','c_divorce_dispute_violence_fault',1),
('r_divorce_dispute_custody','c_divorce_dispute_custody',1),
('r_divorce_dispute_property_debt','c_divorce_dispute_property_debt',1),
('r_divorce_dispute_need_more_facts','c_divorce_dispute_need_more_facts',1),

('r_child_support_precondition','c_child_support_precondition',1),
('r_child_support_claim_fee','c_child_support_claim_fee',1),
('r_child_support_change_amount','c_child_support_change_amount',1),
('r_child_support_change_custody','c_child_support_change_custody',1),

('r_support_precondition','c_support_precondition',1),
('r_support_fee_claim','c_support_fee_claim',1),
('r_support_medical_disability','c_support_medical_disability',1),
('r_support_multi_obligor','c_support_multi_obligor',1),

('r_post_divorce_property_precondition','c_post_divorce_property_precondition',1),
('r_post_divorce_property_redistribute','c_post_divorce_property_redistribute',1),
('r_post_divorce_property_conceal_penalty','c_post_divorce_property_conceal_penalty',1),
('r_post_divorce_property_agreement_enforce','c_post_divorce_property_agreement_enforce',1),
('r_post_divorce_property_time_limit_risk','c_post_divorce_property_time_limit_risk',1);

