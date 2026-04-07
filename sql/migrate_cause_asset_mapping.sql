USE rule_engine_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS rule_cause (
  cause_code VARCHAR(64) PRIMARY KEY,
  cause_name VARCHAR(128) NOT NULL,
  questionnaire_id VARCHAR(128) NOT NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rule_cause_law (
  cause_code VARCHAR(64) NOT NULL,
  law_id VARCHAR(64) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (cause_code, law_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rule_cause_target (
  cause_code VARCHAR(64) NOT NULL,
  target_id VARCHAR(128) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (cause_code, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELETE FROM rule_cause_target
WHERE cause_code IN ('divorce_property', 'labor_unpaid_wages', 'labor_no_contract', 'labor_illegal_termination');
DELETE FROM rule_cause_law
WHERE cause_code IN ('divorce_property', 'labor_unpaid_wages', 'labor_no_contract', 'labor_illegal_termination');
DELETE FROM rule_cause
WHERE cause_code IN ('divorce_property', 'labor_unpaid_wages', 'labor_no_contract', 'labor_illegal_termination');

INSERT INTO rule_cause (cause_code, cause_name, questionnaire_id, enabled) VALUES
('divorce_property', '离婚房产分割纠纷', 'questionnaire_divorce_property_split', 1),
('labor_unpaid_wages', '拖欠工资纠纷', 'questionnaire_labor_unpaid_wages', 1),
('labor_no_contract', '未签劳动合同纠纷', 'questionnaire_labor_no_contract', 1),
('labor_illegal_termination', '违法解除劳动关系纠纷', 'questionnaire_labor_illegal_termination', 1);

INSERT INTO rule_cause_law (cause_code, law_id, sort_order) VALUES
('labor_unpaid_wages', 'law_labor_50', 1),
('labor_unpaid_wages', 'law_contract_30', 2),
('labor_unpaid_wages', 'law_contract_85', 3),
('labor_unpaid_wages', 'law_reg_16', 4),
('labor_no_contract', 'law_contract_10', 1),
('labor_no_contract', 'law_contract_82', 2),
('labor_no_contract', 'law_contract_14', 3),
('labor_illegal_termination', 'law_contract_39', 1),
('labor_illegal_termination', 'law_contract_40', 2),
('labor_illegal_termination', 'law_contract_41', 3),
('labor_illegal_termination', 'law_contract_48', 4),
('labor_illegal_termination', 'law_contract_87', 5);

INSERT INTO rule_cause_target (cause_code, target_id, sort_order) VALUES
('labor_unpaid_wages', 'target_labor_unpaid_wages_full_payment', 1),
('labor_unpaid_wages', 'target_labor_unpaid_wages_overtime', 2),
('labor_unpaid_wages', 'target_labor_unpaid_wages_termination_compensation', 3),
('labor_unpaid_wages', 'target_labor_unpaid_wages_additional_compensation', 4),
('labor_no_contract', 'target_labor_no_contract_double_wage', 1),
('labor_no_contract', 'target_labor_no_contract_sign_contract', 2),
('labor_no_contract', 'target_labor_no_contract_open_term', 3),
('labor_illegal_termination', 'target_illegal_termination_compensation', 1),
('labor_illegal_termination', 'target_illegal_termination_reinstatement', 2),
('labor_illegal_termination', 'target_illegal_termination_wage_gap', 3),
('labor_illegal_termination', 'target_illegal_termination_revoke_decision', 4);

INSERT INTO rule_cause_law (cause_code, law_id, sort_order)
SELECT 'divorce_property', id, ROW_NUMBER() OVER (ORDER BY id)
FROM rule_law
WHERE id LIKE 'law_%'
  AND id NOT IN (
    'law_labor_50','law_contract_30','law_contract_85','law_reg_16',
    'law_contract_10','law_contract_82','law_contract_14',
    'law_contract_39','law_contract_40','law_contract_41','law_contract_48','law_contract_87'
  );

INSERT INTO rule_cause_target (cause_code, target_id, sort_order)
SELECT 'divorce_property', target_id, ROW_NUMBER() OVER (ORDER BY target_id)
FROM rule_step2_target
WHERE target_id NOT LIKE 'target_labor_%'
  AND target_id NOT LIKE 'target_illegal_termination_%';

SET FOREIGN_KEY_CHECKS = 1;
