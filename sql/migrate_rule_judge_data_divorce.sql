USE rule_engine_db;
SET NAMES utf8mb4;

DELETE rc FROM rule_judge_rule_conclusion rc
JOIN rule_judge_rule r ON r.rule_id=rc.rule_id
WHERE r.cause_code='divorce_property';
DELETE FROM rule_judge_conclusion WHERE conclusion_id LIKE 'c_divorce_%';
DELETE FROM rule_judge_rule WHERE cause_code='divorce_property';

INSERT INTO rule_judge_rule (rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled) VALUES
('r_divorce_precondition','divorce_property','离婚房产分割前置条件成立','离婚房产分割前置条件','与','law_1062',10,
'{"op":"and","children":[{"fact":"存在合法婚姻关系","cmp":"eq","value":true},{"fact":"婚姻关系已经解除或正在解除","cmp":"eq","value":true},{"fact":"存在房产分割争议","cmp":"eq","value":true}]}',1),
('r_divorce_personal_property','divorce_property','个人财产倾向认定','婚前个人财产路径命中','与/或','law_1063',20,
'{"op":"or","children":[{"fact":"房产属于婚前个人财产","cmp":"eq","value":true},{"fact":"房产由一方父母明确赠与且登记在其子女名下","cmp":"eq","value":true}]}',1),
('r_divorce_common_property','divorce_property','夫妻共同财产倾向认定','夫妻共同财产路径命中','与/或','law_1062',30,
'{"op":"or","children":[{"fact":"房产属于婚后共同财产","cmp":"eq","value":true},{"fact":"房贷主要由夫妻共同收入偿还","cmp":"eq","value":true},{"fact":"产权登记存在共有情形","cmp":"eq","value":true}]}',1),
('r_divorce_children_priority','divorce_property','未成年子女照顾倾向','照顾子女与女方权益路径命中','与','law_1084',40,
'{"fact":"存在未成年子女且由一方长期照顾","cmp":"eq","value":true}',1),
('r_divorce_compensation','divorce_property','可主张补偿/折价款','折价补偿路径命中','与/或','law_1087',50,
'{"op":"or","children":[{"fact":"一方主张取得房屋并向对方补偿","cmp":"eq","value":true},{"fact":"存在较大出资差异","cmp":"eq","value":true},{"fact":"存在共同还贷但登记在一方名下","cmp":"eq","value":true}]}',1);

INSERT INTO rule_judge_conclusion (conclusion_id, type, result, reason, level, law_refs_json, final_item, final_result, final_detail, enabled) VALUES
('c_divorce_precondition','divorce_property','满足离婚房产分割审查前提','已形成合法婚姻关系、离婚状态与房产争议三项基础。','important','["law_1062"]','审查入口','可进入房产分割裁判分析','建议继续补充产权、出资、还贷、子女抚养等证据。',1),
('c_divorce_personal_property','divorce_property','房产更可能被认定为一方个人财产','现有事实显示房产取得时间或赠与方式倾向个人财产属性。','warning','["law_1063","law_jsyi_26"]','财产属性判断','个人财产倾向较高','需重点核查婚后增值、共同还贷与产权变动对分割的影响。',1),
('c_divorce_common_property','divorce_property','房产更可能被认定为夫妻共同财产','存在婚后取得、共同还贷或共有登记等共同财产特征。','important','["law_1062","law_jsyi_25","law_jsyi_27"]','财产属性判断','共同财产倾向较高','可围绕分割比例、居住需求、还贷贡献提出具体分割方案。',1),
('c_divorce_children_priority','divorce_property','分割时需重点照顾未成年子女利益','案件存在未成年子女长期照顾事实，分割时会强化居住稳定性考量。','important','["law_1084"]','分割倾向','照顾子女利益因素显著','可重点提交抚养现状、学籍居住连续性等材料。',1),
('c_divorce_compensation','divorce_property','可主张折价补偿或份额差异化分配','存在明显贡献差异或登记与还贷不一致情形，具备补偿主张空间。','important','["law_1087","law_1088"]','分割方案','可主张补偿/折价款','建议结合评估价、剩余贷款、历史出资形成可执行方案。',1);

INSERT INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order) VALUES
('r_divorce_precondition','c_divorce_precondition',1),
('r_divorce_personal_property','c_divorce_personal_property',1),
('r_divorce_common_property','c_divorce_common_property',1),
('r_divorce_children_priority','c_divorce_children_priority',1),
('r_divorce_compensation','c_divorce_compensation',1);
