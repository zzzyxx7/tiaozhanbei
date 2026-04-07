USE rule_engine_db;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS rule_judge_rule (
  rule_id VARCHAR(128) PRIMARY KEY,
  cause_code VARCHAR(64) NOT NULL,
  rule_name VARCHAR(255) NOT NULL,
  path_name VARCHAR(255) NULL,
  calc_expr VARCHAR(64) NOT NULL DEFAULT '与',
  law_ref VARCHAR(64) NULL,
  priority INT NOT NULL DEFAULT 1000,
  condition_json LONGTEXT NOT NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_rule_cause_priority (cause_code, priority, enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rule_judge_conclusion (
  conclusion_id VARCHAR(128) PRIMARY KEY,
  type VARCHAR(64) NOT NULL,
  result VARCHAR(255) NOT NULL,
  reason TEXT NULL,
  level VARCHAR(32) NOT NULL DEFAULT 'warning',
  law_refs_json LONGTEXT NULL,
  final_item VARCHAR(255) NULL,
  final_result VARCHAR(255) NULL,
  final_detail TEXT NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rule_judge_rule_conclusion (
  rule_id VARCHAR(128) NOT NULL,
  conclusion_id VARCHAR(128) NOT NULL,
  sort_order INT NOT NULL DEFAULT 1,
  PRIMARY KEY (rule_id, conclusion_id),
  KEY idx_rule_conclusion_sort (rule_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
