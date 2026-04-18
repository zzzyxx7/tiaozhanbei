USE rule_engine_db;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS rule_user_profile (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(128) NOT NULL UNIQUE,
  nickname VARCHAR(128) NULL,
  avatar_url VARCHAR(1024) NULL COMMENT '头像 URL',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rule_user_session (
  session_id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(128) NOT NULL,
  cause_code VARCHAR(64) NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_active_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_user_session (user_id, created_at),
  KEY idx_cause_session (cause_code, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rule_user_submission (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  session_id VARCHAR(64) NOT NULL,
  user_id VARCHAR(128) NOT NULL,
  cause_code VARCHAR(64) NOT NULL,
  answers_json LONGTEXT NOT NULL,
  judge_json LONGTEXT NULL,
  report_markdown LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_user_submission (user_id, created_at),
  KEY idx_session_submission (session_id, created_at),
  KEY idx_cause_submission (cause_code, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
