USE rule_engine_db;
SET NAMES utf8mb4;

DELETE rc FROM rule_judge_rule_conclusion rc
JOIN rule_judge_rule r ON r.rule_id=rc.rule_id
WHERE r.cause_code IN ('labor_unpaid_wages','labor_no_contract','labor_illegal_termination');
DELETE FROM rule_judge_conclusion
WHERE conclusion_id LIKE 'c_labor_%';
DELETE FROM rule_judge_rule
WHERE cause_code IN ('labor_unpaid_wages','labor_no_contract','labor_illegal_termination');

INSERT INTO rule_judge_rule (rule_id, cause_code, rule_name, path_name, calc_expr, law_ref, priority, condition_json, enabled) VALUES
('r_labor_unpaid_core_strong','labor_unpaid_wages','拖欠工资核心证据链成立','拖欠工资核心事实成立','与+或','law_contract_30',10,
'{"op":"and","children":[{"fact":"存在劳动关系","cmp":"eq","value":true},{"fact":"已提供劳动","cmp":"eq","value":true},{"fact":"存在欠薪","cmp":"eq","value":true},{"op":"or","children":[{"fact":"有工资约定依据","cmp":"eq","value":true},{"fact":"有考勤或工作记录","cmp":"eq","value":true},{"fact":"有工资支付记录","cmp":"eq","value":true},{"fact":"单位书面承认欠薪","cmp":"eq","value":true}]}]}',1),
('r_labor_unpaid_overtime','labor_unpaid_wages','加班费请求要件成立','加班费请求要件路径命中','与','law_contract_30',20,
'{"op":"and","children":[{"fact":"主张加班费","cmp":"eq","value":true},{"fact":"有加班事实证据","cmp":"eq","value":true},{"fact":"有加班工资约定依据","cmp":"eq","value":true}]}',1),
('r_labor_unpaid_termination_comp','labor_unpaid_wages','欠薪解除补偿路径','欠薪解除补偿路径命中','与','law_contract_85',30,
'{"op":"and","children":[{"fact":"主张解除补偿","cmp":"eq","value":true},{"fact":"存在欠薪","cmp":"eq","value":true},{"fact":"解除原因偏向单位责任","cmp":"eq","value":true}]}',1),
('r_labor_unpaid_additional_comp','labor_unpaid_wages','欠薪逾期支付路径','欠薪逾期支付路径命中','与','law_contract_85',40,
'{"op":"and","children":[{"fact":"存在欠薪","cmp":"eq","value":true},{"fact":"已向劳动监察投诉","cmp":"eq","value":true},{"fact":"单位逾期仍未支付","cmp":"eq","value":true}]}',1),
('r_labor_no_contract_double','labor_no_contract','未签合同双倍工资成立','未签合同双倍工资要件成立','与','law_contract_82',10,
'{"op":"and","children":[{"fact":"存在劳动关系","cmp":"eq","value":true},{"fact":"未签书面劳动合同","cmp":"eq","value":true},{"fact":"入职月数","cmp":"gt","value":1},{"fact":"已补签劳动合同","cmp":"eq","value":false},{"fact":"有工资支付记录","cmp":"eq","value":true}]}',1),
('r_labor_no_contract_sign','labor_no_contract','补签劳动合同请求成立','补签劳动合同请求路径命中','与','law_contract_10',20,
'{"op":"and","children":[{"fact":"存在劳动关系","cmp":"eq","value":true},{"fact":"未签书面劳动合同","cmp":"eq","value":true},{"fact":"主张补签书面合同","cmp":"eq","value":true}]}',1),
('r_labor_no_contract_open_term','labor_no_contract','无固定期限合同成立',null,'与','law_contract_14',30,
'{"op":"and","children":[{"fact":"主张无固定期限合同","cmp":"eq","value":true},{"fact":"满足无固定期限条件","cmp":"eq","value":true}]}',1),
('r_labor_termination_illegal','labor_illegal_termination','违法解除判断路径','违法解除判断路径命中','与/或','law_contract_48',10,
'{"op":"and","children":[{"fact":"存在劳动关系","cmp":"eq","value":true},{"fact":"已被解除或辞退","cmp":"eq","value":true},{"op":"or","children":[{"fact":"解除理由不明确","cmp":"eq","value":true},{"op":"and","children":[{"fact":"有解除通知","cmp":"eq","value":true},{"fact":"解除通知为书面","cmp":"eq","value":false}]},{"op":"and","children":[{"fact":"解除理由_40","cmp":"eq","value":true},{"fact":"提前30日通知或支付代通知金","cmp":"eq","value":false}]},{"op":"and","children":[{"fact":"解除理由_39","cmp":"eq","value":true},{"op":"or","children":[{"fact":"单位有严重违纪证据","cmp":"eq","value":false},{"fact":"规章制度已公示且合法","cmp":"eq","value":false}]}]},{"op":"and","children":[{"fact":"解除理由_41","cmp":"eq","value":true},{"fact":"经济性裁员符合法定人数与报告程序","cmp":"eq","value":false}]},{"fact":"单位是否履行工会程序","cmp":"eq","value":false},{"fact":"处于特殊保护期","cmp":"eq","value":true}]}]}',1),
('r_labor_termination_reinstatement','labor_illegal_termination','继续履行请求',null,'与','law_contract_48',20,
'{"fact":"主张继续履行劳动合同","cmp":"eq","value":true}',1),
('r_labor_termination_wage_gap','labor_illegal_termination','停工工资请求',null,'与','law_contract_87',30,
'{"fact":"主张停工期间工资损失","cmp":"eq","value":true}',1);

INSERT INTO rule_judge_conclusion (conclusion_id, type, result, reason, level, law_refs_json, final_item, final_result, final_detail, enabled) VALUES
('c_labor_unpaid_core','labor_payment','欠薪请求具有较高支持可能性','已具备劳动关系、劳动提供、欠薪事实及核心证据链。','important','["law_labor_50","law_contract_30","law_contract_85"]','欠薪支付请求','可优先主张足额支付拖欠工资','建议申请劳动仲裁并提交劳动关系、劳动提供、欠薪金额及催要记录等证据。',1),
('c_labor_unpaid_overtime','labor_payment','加班费请求具备基础支持条件','已明确加班请求，且有加班事实证据及计算依据。','important','["law_contract_30"]','加班费请求','可一并主张','建议按工作日/休息日/法定节假日分开整理加班证据并核算金额。',1),
('c_labor_unpaid_term_comp','labor_contract','解除补偿请求有一定支持可能','存在欠薪，且解除原因与单位违约行为相关。','important','["law_contract_85"]','解除补偿请求','可结合欠薪事实一并主张','建议保留解除前催告记录与解除通知，形成完整时间线。',1),
('c_labor_unpaid_additional','labor_payment','可进一步主张逾期支付加付赔偿金','欠薪在投诉/催告后仍未改正，符合加付赔偿金主张方向。','important','["law_contract_85","law_reg_16"]','加付赔偿金请求','具备主张基础','建议提交投诉回执、限期支付通知及逾期未支付证明材料。',1),
('c_labor_no_contract_double','labor_contract','可主张未签书面劳动合同期间双倍工资','入职超过一个月未签劳动合同且有工资支付事实支持。','important','["law_contract_10","law_contract_82"]','双倍工资请求','可主张（符合法定要件）','建议按入职时间线整理证据，核算可主张区间后通过劳动仲裁主张。',1),
('c_labor_no_contract_sign','labor_contract','可请求单位补签书面劳动合同','劳动关系存续且未签书面合同，补签请求具有正当性。','important','["law_contract_10"]','补签劳动合同请求','可主张','建议先发出书面补签申请并保留送达凭证。',1),
('c_labor_no_contract_open_term','labor_contract','无固定期限合同请求有支持可能','已明确主张且满足法定条件。','important','["law_contract_14"]','无固定期限合同请求','可主张','建议提交工龄、续签记录等证明满足法定条件。',1),
('c_labor_termination_illegal','labor_termination','解除行为存在较高概率被认定为违法','解除理由或程序不符合法定要求，或存在特殊保护期内解除风险。','important','["law_contract_39","law_contract_40","law_contract_41","law_contract_48","law_contract_87"]','违法解除判断','可优先主张认定为违法解除','建议围绕解除理由合法性、解除程序合法性、特殊保护期事实整理证据。',1),
('c_labor_termination_reinstate','labor_termination','可请求继续履行劳动合同','劳动者已明确提出恢复劳动关系请求。','important','["law_contract_48"]','诉请方向','可请求继续履行劳动合同','如劳动者主张继续履行且用人单位仍可继续履行，可作为主要请求。',1),
('c_labor_termination_wage_gap','labor_termination','可主张停工期间工资损失','劳动者已明确提出停工期间工资损失请求。','important','["law_contract_87"]','诉请方向','可主张停工期间工资损失','建议结合停工期间证据材料核算损失并一并主张。',1);

INSERT INTO rule_judge_rule_conclusion (rule_id, conclusion_id, sort_order) VALUES
('r_labor_unpaid_core_strong','c_labor_unpaid_core',1),
('r_labor_unpaid_overtime','c_labor_unpaid_overtime',1),
('r_labor_unpaid_termination_comp','c_labor_unpaid_term_comp',1),
('r_labor_unpaid_additional_comp','c_labor_unpaid_additional',1),
('r_labor_no_contract_double','c_labor_no_contract_double',1),
('r_labor_no_contract_sign','c_labor_no_contract_sign',1),
('r_labor_no_contract_open_term','c_labor_no_contract_open_term',1),
('r_labor_termination_illegal','c_labor_termination_illegal',1),
('r_labor_termination_reinstatement','c_labor_termination_reinstate',1),
('r_labor_termination_wage_gap','c_labor_termination_wage_gap',1);
