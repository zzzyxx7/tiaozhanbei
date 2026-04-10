CREATE TABLE rule_cause (
  cause_code VARCHAR(64) PRIMARY KEY,
  cause_name VARCHAR(128) NOT NULL,
  questionnaire_id VARCHAR(128) NOT NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NULL
);

CREATE TABLE rule_cause_law (
  cause_code VARCHAR(64) NOT NULL,
  law_id VARCHAR(64) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (cause_code, law_id)
);

CREATE TABLE rule_cause_target (
  cause_code VARCHAR(64) NOT NULL,
  target_id VARCHAR(128) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (cause_code, target_id)
);

CREATE TABLE rule_law (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  article VARCHAR(255) NOT NULL,
  summary VARCHAR(1000) NULL,
  text TEXT NULL,
  updated_at TIMESTAMP NULL
);

CREATE TABLE rule_step2_target (
  target_id VARCHAR(128) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  descr VARCHAR(1000) NULL,
  enabled TINYINT NOT NULL DEFAULT 1
);

CREATE TABLE rule_step2_target_legal_ref (
  target_id VARCHAR(128) NOT NULL,
  law_id VARCHAR(64) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (target_id, law_id)
);

CREATE TABLE rule_step2_required_fact (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  target_id VARCHAR(128) NOT NULL,
  fact_key VARCHAR(255) NOT NULL,
  label VARCHAR(255) NOT NULL,
  required_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1
);

CREATE TABLE rule_step2_evidence_type (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  target_id VARCHAR(128) NOT NULL,
  fact_key VARCHAR(255) NOT NULL,
  evidence_type VARCHAR(255) NOT NULL,
  evidence_order INT NOT NULL DEFAULT 0,
  other_option TINYINT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1
);

CREATE TABLE rule_question_group (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  questionnaire_id VARCHAR(128) NOT NULL,
  group_key VARCHAR(64) NOT NULL,
  group_name VARCHAR(255) NOT NULL,
  group_desc VARCHAR(1000) NULL,
  icon VARCHAR(64) NULL,
  group_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1
);

CREATE TABLE rule_question (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  questionnaire_id VARCHAR(128) NOT NULL,
  group_key VARCHAR(64) NOT NULL,
  question_key VARCHAR(255) NOT NULL,
  answer_key VARCHAR(255) NOT NULL,
  label VARCHAR(1000) NOT NULL,
  hint VARCHAR(1000) NULL,
  unit VARCHAR(64) NULL,
  input_type VARCHAR(64) NOT NULL,
  required TINYINT NOT NULL DEFAULT 0,
  question_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1
);

CREATE TABLE rule_question_option (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  question_id BIGINT NOT NULL,
  option_value VARCHAR(255) NOT NULL,
  option_label VARCHAR(255) NOT NULL,
  option_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1
);

CREATE TABLE rule_question_visibility_rule (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  question_id BIGINT NOT NULL,
  show_if TINYINT NOT NULL DEFAULT 1,
  condition_json TEXT NOT NULL,
  rule_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1
);

CREATE TABLE rule_judge_rule (
  rule_id VARCHAR(128) PRIMARY KEY,
  cause_code VARCHAR(64) NOT NULL,
  rule_name VARCHAR(255) NOT NULL,
  path_name VARCHAR(255) NULL,
  calc_expr VARCHAR(64) NOT NULL DEFAULT '与',
  law_ref VARCHAR(64) NULL,
  priority INT NOT NULL DEFAULT 1000,
  condition_json TEXT NOT NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NULL
);

CREATE TABLE rule_judge_conclusion (
  conclusion_id VARCHAR(128) PRIMARY KEY,
  type VARCHAR(64) NOT NULL,
  result VARCHAR(255) NOT NULL,
  reason TEXT NULL,
  level VARCHAR(32) NOT NULL DEFAULT 'warning',
  law_refs_json TEXT NULL,
  final_item VARCHAR(255) NULL,
  final_result VARCHAR(255) NULL,
  final_detail TEXT NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NULL
);

CREATE TABLE rule_judge_rule_conclusion (
  rule_id VARCHAR(128) NOT NULL,
  conclusion_id VARCHAR(128) NOT NULL,
  sort_order INT NOT NULL DEFAULT 1,
  PRIMARY KEY (rule_id, conclusion_id)
);

