USE rule_engine_db;
SET NAMES utf8mb4;

-- ==========================================================
-- 案由大类（用于前端首页“大类卡片”）
-- 说明：
-- 1) 新增 rule_cause_category 表
-- 2) 为 rule_cause 增加 category_code 字段并建立索引
-- 3) 初始化大类与现有案由映射（已完成的 8 个案由会被归类）
-- ==========================================================

CREATE TABLE IF NOT EXISTS rule_cause_category (
  category_code VARCHAR(64) PRIMARY KEY,
  category_name VARCHAR(128) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 为 rule_cause 增加 category_code（兼容已存在/未存在两种情况）
SET @col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'rule_cause'
    AND COLUMN_NAME = 'category_code'
);
SET @stmt := IF(@col_exists = 0,
  'ALTER TABLE rule_cause ADD COLUMN category_code VARCHAR(64) NULL AFTER questionnaire_id',
  'SELECT 1'
);
PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;

-- 索引（按大类拉取案由列表）
SET @idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'rule_cause'
    AND INDEX_NAME = 'idx_rule_cause_category_enabled'
);
SET @stmt := IF(@idx_exists = 0,
  'CREATE INDEX idx_rule_cause_category_enabled ON rule_cause(category_code, enabled, cause_code)',
  'SELECT 1'
);
PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;

-- 初始化大类（先把前端首页的大类都建出来，未接入的小类先为空）
INSERT INTO rule_cause_category (category_code, category_name, sort_order, enabled) VALUES
('marriage_family', '婚姻家庭', 10, 1),
('criminal', '刑事案件', 20, 1),
('labor_injury', '劳动工伤', 30, 1),
('debt_credit', '债权债务', 40, 1),
('medical', '医疗赔偿', 50, 1),
('traffic', '交通事故纠纷', 60, 1),
('housing_property', '房屋物业纠纷', 70, 1),
('other', '其他', 999, 1)
ON DUPLICATE KEY UPDATE
category_name=VALUES(category_name),
sort_order=VALUES(sort_order),
enabled=VALUES(enabled);

-- 现有已完成案由 → 大类映射
UPDATE rule_cause SET category_code='marriage_family'
WHERE cause_code IN ('betrothal_property','divorce_dispute','post_divorce_property');

UPDATE rule_cause SET category_code='labor_injury'
WHERE cause_code IN ('labor_illegal_termination','labor_injury_compensation','labor_no_contract','labor_overtime_pay','labor_unpaid_wages');

-- 兜底：其余已启用但未映射的案由归为 other
UPDATE rule_cause SET category_code='other'
WHERE enabled=1 AND (category_code IS NULL OR category_code='');

