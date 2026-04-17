USE rule_engine_db;
SET NAMES utf8mb4;

-- 说明：修正 Step1 judge 入口规则的 condition_json，避免无条件命中导致前端“答非所问”。
-- 若你已运行过 migrate_marriage_family_add_missing_causes.sql，请再执行本脚本更新已落库的数据。

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"婚姻关系已存续且未离婚\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"存在婚内共同财产争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在藏匿转移共同财产线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"共同财产范围清晰\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在挥霍家产或恶意处置\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在重大医疗支出或紧急治疗需求\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_in_marriage_property_division_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"离婚事实已生效\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"存在婚内严重过错或侵害事实线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在精神损害或经济损失后果\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"明确请求赔偿范围\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有具体损失或治疗费用/收入损失线索\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_post_divorce_damage_liability_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"or\",\"children\":[{\"fact\":\"存在无效婚姻原因线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求确认婚姻无效\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有证据材料可补强\",\"cmp\":\"eq\",\"value\":true}]}'
WHERE rule_id='r_marriage_invalid_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"or\",\"children\":[{\"fact\":\"存在撤销原因线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求撤销婚姻\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有证据材料可补强\",\"cmp\":\"eq\",\"value\":true}]}'
WHERE rule_id='r_marriage_annulment_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"存在夫妻财产约定协议\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"约定内容明确\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"协议未履行或争议履行\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求确认协议有效并要求履行\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"对方主张协议无效或被撤销\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_spousal_property_agreement_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"是否存在同居关系\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"同居期间共同生活或共同投入\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"共同财产范围清晰\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在财产分割争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"对方拒绝或未支付抚养费\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_cohabitation_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"or\",\"children\":[{\"fact\":\"存在亲子关系争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求确认亲子关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"亲子鉴定结论支持主张\",\"cmp\":\"eq\",\"value\":true}]}'
WHERE rule_id='r_paternity_confirmation_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"or\",\"children\":[{\"fact\":\"请求否认亲子关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"亲子鉴定结论不支持主张\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"亲子鉴定结论支持否认方主张\",\"cmp\":\"eq\",\"value\":true}]}'
WHERE rule_id='r_paternity_disclaimer_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"存在扶养义务关系\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"被扶养人生活困难\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"拒绝履行或未足额支付\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"主张变更扶养关系\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_sibling_support_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"or\",\"children\":[{\"fact\":\"请求确认收养关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求解除收养关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有证据材料可补强\",\"cmp\":\"eq\",\"value\":true}]}'
WHERE rule_id='r_adoption_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"需要确定或变更监护人\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"被监护人无或限制民事行为能力\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有医学鉴定或诊断证据\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求指定或变更监护人\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_guardianship_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"已离婚或已分开\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"为非直接抚养方\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在拒绝探望或障碍\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求法院明确探望方式时间\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_visitation_init';

UPDATE rule_judge_rule
SET condition_json='{\"op\":\"and\",\"children\":[{\"fact\":\"家庭共同生活或共同置办财产\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"共同财产范围清晰\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在分割争议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求分割/析产\",\"cmp\":\"eq\",\"value\":true}]}]}'
WHERE rule_id='r_family_partition_init';

