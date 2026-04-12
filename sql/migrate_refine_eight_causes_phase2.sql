-- 八类案由深化（第二阶段）：补充与劳动争议处理、经济补偿、共同债务、离婚后财产、
-- 一至六级伤残及工伤认定程序等相关的权威条文，并扩展案由—法条、Step2—法条关联。
-- 依赖：已执行 migrate_refine_eight_causes_official_law_text.sql（或库内已有对应 rule_law 主键）。
-- 条文来源：法律及行政法规公开文本；解释（一）条文与法释〔2020〕22号公开版本一致。
--
-- 与 migrate_refine_eight_causes_official_law_text.sql 首部「后续维护约定」一致：法条须可核对，不臆造。

USE rule_engine_db;
SET NAMES utf8mb4;

-- ========== 劳动争议调解仲裁法 ==========
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
(
  'law_labor_arbitration_2',
  '中华人民共和国劳动争议调解仲裁法',
  '第二条',
  '适用范围',
  '中华人民共和国境内的用人单位与劳动者发生的下列劳动争议，适用本法：\n（一）因确认劳动关系发生的争议；\n（二）因订立、履行、变更、解除和终止劳动合同发生的争议；\n（三）因除名、辞退和辞职、离职发生的争议；\n（四）因工作时间、休息休假、社会保险、福利、培训以及劳动保护发生的争议；\n（五）因劳动报酬、工伤医疗费、经济补偿或者赔偿金等发生的争议；\n（六）法律、法规规定的其他劳动争议。',
  NOW()
),
(
  'law_labor_arbitration_5',
  '中华人民共和国劳动争议调解仲裁法',
  '第五条',
  '劳动争议处理的基本方式',
  '发生劳动争议，当事人不愿协商、协商不成或者达成和解协议后不履行的，可以向调解组织申请调解；不愿调解、调解不成或者达成调解协议后不履行的，可以向劳动争议仲裁委员会申请仲裁；对仲裁裁决不服的，除本法另有规定的外，可以向人民法院提起诉讼。',
  NOW()
),
(
  'law_labor_arbitration_27',
  '中华人民共和国劳动争议调解仲裁法',
  '第二十七条',
  '申请仲裁的时效',
  '劳动争议申请仲裁的时效期间为一年。仲裁时效期间从当事人知道或者应当知道其权利被侵害之日起计算。\n前款规定的仲裁时效，因当事人一方向对方当事人主张权利，或者向有关部门请求权利救济，或者对方当事人同意履行义务而中断。从中断时起，仲裁时效期间重新计算。\n因不可抗力或者有其他正当理由，当事人不能在本条第一款规定的仲裁时效期间申请仲裁的，仲裁时效中止。从中止时效的原因消除之日起，仲裁时效期间继续计算。\n劳动关系存续期间因拖欠劳动报酬发生争议的，劳动者申请仲裁不受本条第一款规定的仲裁时效期间的限制；但是，劳动关系终止的，应当自劳动关系终止之日起一年内提出。',
  NOW()
)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), article = VALUES(article), summary = VALUES(summary), text = VALUES(text), updated_at = VALUES(updated_at);

-- ========== 劳动合同法：劳动者解除（含欠薪等）与经济补偿 ==========
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
(
  'law_contract_38',
  '中华人民共和国劳动合同法',
  '第三十八条',
  '劳动者可以解除劳动合同的情形',
  '用人单位有下列情形之一的，劳动者可以解除劳动合同：\n（一）未按照劳动合同约定提供劳动保护或者劳动条件的；\n（二）未及时足额支付劳动报酬的；\n（三）未依法为劳动者缴纳社会保险费的；\n（四）用人单位的规章制度违反法律、法规的规定，损害劳动者权益的；\n（五）因本法第二十六条第一款规定的情形致使劳动合同无效的；\n（六）法律、行政法规规定劳动者可以解除劳动合同的其他情形。\n用人单位以暴力、威胁或者非法限制人身自由的手段强迫劳动者劳动的，或者用人单位违章指挥、强令冒险作业危及劳动者人身安全的，劳动者可以立即解除劳动合同，不需事先告知用人单位。',
  NOW()
),
(
  'law_contract_46',
  '中华人民共和国劳动合同法',
  '第四十六条',
  '用人单位应当向劳动者支付经济补偿的情形',
  '有下列情形之一的，用人单位应当向劳动者支付经济补偿：\n（一）劳动者依照本法第三十八条规定解除劳动合同的；\n（二）用人单位依照本法第三十六条规定向劳动者提出解除劳动合同并与劳动者协商一致解除劳动合同的；\n（三）用人单位依照本法第四十条规定解除劳动合同的；\n（四）用人单位依照本法第四十一条第一款规定解除劳动合同的；\n（五）除用人单位维持或者提高劳动合同约定条件续订劳动合同，劳动者不同意续订的情形外，依照本法第四十四条第一项规定终止固定期限劳动合同的；\n（六）依照本法第四十四条第四项、第五项规定终止劳动合同的；\n（七）法律、行政法规规定的其他情形。',
  NOW()
),
(
  'law_contract_47',
  '中华人民共和国劳动合同法',
  '第四十七条',
  '经济补偿的计算标准',
  '经济补偿按劳动者在本单位工作的年限，每满一年支付一个月工资的标准向劳动者支付。六个月以上不满一年的，按一年计算；不满六个月的，向劳动者支付半个月工资的经济补偿。\n劳动者月工资高于用人单位所在直辖市、设区的市级人民政府公布的本地区上年度职工月平均工资三倍的，向其支付经济补偿的标准按职工月平均工资三倍的数额支付，向其支付经济补偿的年限最高不超过十二年。\n本条所称月工资是指劳动者在劳动合同解除或者终止前十二个月的平均工资。',
  NOW()
)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), article = VALUES(article), summary = VALUES(summary), text = VALUES(text), updated_at = VALUES(updated_at);

-- ========== 民法典：共同债务 ==========
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
(
  'law_1089',
  '中华人民共和国民法典',
  '第一千零八十九条',
  '离婚时夫妻共同债务清偿',
  '离婚时，夫妻共同债务应当共同偿还。共同财产不足清偿或者财产归各自所有的，由双方协议清偿；协议不成的，由人民法院判决。',
  NOW()
)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), article = VALUES(article), summary = VALUES(summary), text = VALUES(text), updated_at = VALUES(updated_at);

-- ========== 婚姻家庭编解释（一）法释〔2020〕22号 ==========
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
(
  'law_jsyi_69',
  '最高人民法院关于适用《中华人民共和国民法典》婚姻家庭编的解释（一）（法释〔2020〕22号）',
  '第六十九条',
  '附协议离婚条件的财产债务处理协议效力',
  '当事人达成的以协议离婚或者到人民法院调解离婚为条件的财产以及债务处理协议，如果双方离婚未成，一方在离婚诉讼中反悔的，人民法院应当认定该财产以及债务处理协议没有生效，并根据实际情况依照民法典第一千零八十七条和第一千零八十九条的规定判决。',
  NOW()
),
(
  'law_jsyi_84',
  '最高人民法院关于适用《中华人民共和国民法典》婚姻家庭编的解释（一）（法释〔2020〕22号）',
  '第八十四条',
  '依据第一千零九十二条再次分割财产的诉讼时效',
  '当事人依据民法典第一千零九十二条的规定向人民法院提起诉讼，请求再次分割夫妻共同财产的诉讼时效期间为三年，从当事人发现之日起计算。',
  NOW()
)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), article = VALUES(article), summary = VALUES(summary), text = VALUES(text), updated_at = VALUES(updated_at);

-- ========== 工伤保险条例：认定申请、一至六级伤残待遇 ==========
INSERT INTO rule_law (id, name, article, summary, text, updated_at) VALUES
(
  'law_injury_17',
  '工伤保险条例（2010年修订）',
  '第十七条',
  '工伤认定申请时限与责任',
  '职工发生事故伤害或者按照职业病防治法规定被诊断、鉴定为职业病，所在单位应当自事故伤害发生之日或者被诊断、鉴定为职业病之日起30日内，向统筹地区社会保险行政部门提出工伤认定申请。遇有特殊情况，经报社会保险行政部门同意，申请时限可以适当延长。\n用人单位未按前款规定提出工伤认定申请的，工伤职工或者其近亲属、工会组织在事故伤害发生之日或者被诊断、鉴定为职业病之日起1年内，可以直接向用人单位所在地统筹地区社会保险行政部门提出工伤认定申请。\n按照本条第一款规定应当由省级社会保险行政部门进行工伤认定的事项，根据属地原则由用人单位所在地的设区的市级社会保险行政部门办理。\n用人单位未在本条第一款规定的时限内提交工伤认定申请，在此期间发生符合本条例规定的工伤待遇等有关费用由该用人单位负担。',
  NOW()
),
(
  'law_injury_35',
  '工伤保险条例（2010年修订）',
  '第三十五条',
  '一级至四级伤残的工伤保险待遇',
  '职工因工致残被鉴定为一级至四级伤残的，保留劳动关系，退出工作岗位，享受以下待遇：\n（一）从工伤保险基金按伤残等级支付一次性伤残补助金，标准为：一级伤残为27个月的本人工资，二级伤残为25个月的本人工资，三级伤残为23个月的本人工资，四级伤残为21个月的本人工资；\n（二）从工伤保险基金按月支付伤残津贴，标准为：一级伤残为本人工资的90%，二级伤残为本人工资的85%，三级伤残为本人工资的80%，四级伤残为本人工资的75%。伤残津贴实际金额低于当地最低工资标准的，由工伤保险基金补足差额；\n（三）工伤职工达到退休年龄并办理退休手续后，停发伤残津贴，按照国家有关规定享受基本养老保险待遇。基本养老保险待遇低于伤残津贴的，由工伤保险基金补足差额。\n（四）由用人单位和职工个人以伤残津贴为基数，缴纳基本医疗保险费。',
  NOW()
),
(
  'law_injury_36',
  '工伤保险条例（2010年修订）',
  '第三十六条',
  '五级至六级伤残的工伤保险待遇',
  '职工因工致残被鉴定为五级、六级伤残的，享受以下待遇：\n（一）从工伤保险基金按伤残等级支付一次性伤残补助金，标准为：五级伤残为18个月的本人工资，六级伤残为16个月的本人工资；\n（二）保留与用人单位的劳动关系，由用人单位安排适当工作。难以安排工作的，由用人单位按月发给伤残津贴，标准为：五级伤残为本人工资的70%，六级伤残为本人工资的60%，并由用人单位按照规定为其缴纳应缴纳的各项社会保险费。伤残津贴实际金额低于当地最低工资标准的，由用人单位补足差额。\n经工伤职工本人提出，该职工可以与用人单位解除或者终止劳动关系，由工伤保险基金支付一次性工伤医疗补助金，由用人单位支付一次性伤残就业补助金。一次性工伤医疗补助金和一次性伤残就业补助金的具体标准由省、自治区、直辖市人民政府规定。',
  NOW()
)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), article = VALUES(article), summary = VALUES(summary), text = VALUES(text), updated_at = VALUES(updated_at);

-- ========== 案由与法条（在既有 sort 之后继续编号，INSERT IGNORE 防重复） ==========
INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order) VALUES
('labor_unpaid_wages', 'law_labor_arbitration_2', 10),
('labor_unpaid_wages', 'law_labor_arbitration_5', 11),
('labor_unpaid_wages', 'law_labor_arbitration_27', 12),
('labor_unpaid_wages', 'law_contract_38', 13),
('labor_unpaid_wages', 'law_contract_46', 14),
('labor_unpaid_wages', 'law_contract_47', 15),
('labor_no_contract', 'law_labor_arbitration_2', 10),
('labor_no_contract', 'law_labor_arbitration_5', 11),
('labor_no_contract', 'law_labor_arbitration_27', 12),
('labor_illegal_termination', 'law_contract_46', 10),
('labor_illegal_termination', 'law_contract_47', 11),
('labor_illegal_termination', 'law_labor_arbitration_5', 12),
('labor_illegal_termination', 'law_labor_arbitration_27', 13),
('labor_overtime_pay', 'law_labor_arbitration_5', 10),
('labor_overtime_pay', 'law_labor_arbitration_27', 11),
('labor_injury_compensation', 'law_injury_17', 10),
('labor_injury_compensation', 'law_injury_35', 11),
('labor_injury_compensation', 'law_injury_36', 12),
('labor_injury_compensation', 'law_labor_arbitration_5', 13),
('divorce_dispute', 'law_1089', 10),
('divorce_dispute', 'law_jsyi_69', 11),
('post_divorce_property', 'law_jsyi_69', 10),
('post_divorce_property', 'law_jsyi_84', 11),
('post_divorce_property', 'law_1089', 12);

-- ========== Step2 目标与法条补强（与既有 sort_order 并存，高序号避免冲突） ==========
INSERT IGNORE INTO rule_step2_target_legal_ref (target_id, law_id, sort_order) VALUES
('target_labor_unpaid_wages_full_payment', 'law_labor_arbitration_5', 10),
('target_labor_unpaid_wages_full_payment', 'law_labor_arbitration_27', 11),
('target_labor_unpaid_wages_overtime', 'law_labor_arbitration_27', 10),
('target_labor_unpaid_wages_overtime', 'law_labor_44', 11),
('target_labor_unpaid_wages_termination_compensation', 'law_contract_38', 10),
('target_labor_unpaid_wages_termination_compensation', 'law_contract_46', 11),
('target_labor_unpaid_wages_termination_compensation', 'law_contract_47', 12),
('target_labor_unpaid_wages_termination_compensation', 'law_labor_arbitration_5', 13),
('target_labor_unpaid_wages_additional_compensation', 'law_labor_arbitration_5', 10),
('target_labor_no_contract_double_wage', 'law_labor_arbitration_2', 10),
('target_labor_no_contract_double_wage', 'law_labor_arbitration_5', 11),
('target_labor_no_contract_double_wage', 'law_labor_arbitration_27', 12),
('target_labor_no_contract_sign_contract', 'law_labor_arbitration_5', 10),
('target_labor_no_contract_open_term', 'law_labor_arbitration_5', 10),
('target_illegal_termination_compensation', 'law_contract_46', 10),
('target_illegal_termination_compensation', 'law_contract_47', 11),
('target_illegal_termination_compensation', 'law_labor_arbitration_5', 12),
('target_illegal_termination_compensation', 'law_labor_arbitration_27', 13),
('target_illegal_termination_reinstatement', 'law_labor_arbitration_5', 10),
('target_illegal_termination_wage_gap', 'law_contract_46', 10),
('target_illegal_termination_wage_gap', 'law_contract_47', 11),
('target_illegal_termination_revoke_decision', 'law_labor_arbitration_5', 10),
('target_add_labor_overtime_workday', 'law_labor_arbitration_27', 10),
('target_add_labor_overtime_workday', 'law_contract_30', 11),
('target_add_labor_overtime_restday', 'law_labor_arbitration_27', 10),
('target_add_labor_overtime_holiday', 'law_labor_arbitration_27', 10),
('target_add_labor_injury_recognition', 'law_injury_17', 10),
('target_add_labor_injury_recognition', 'law_labor_arbitration_5', 11),
('target_add_labor_injury_medical', 'law_injury_17', 10),
('target_add_labor_injury_disability', 'law_injury_35', 10),
('target_add_labor_injury_disability', 'law_injury_36', 11),
('target_add_labor_injury_disability', 'law_injury_37', 12),
('target_add_divorce_general_property', 'law_1089', 10),
('target_add_divorce_general_property', 'law_jsyi_69', 11),
('target_add_post_divorce_redistribute', 'law_1089', 10),
('target_add_post_divorce_agreement_enforce', 'law_jsyi_69', 10),
('target_add_post_divorce_agreement_enforce', 'law_1087', 11),
('target_add_post_divorce_conceal_penalty', 'law_jsyi_84', 10),
('target_add_post_divorce_conceal_penalty', 'law_1092', 11);