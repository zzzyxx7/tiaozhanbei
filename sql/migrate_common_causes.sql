USE rule_engine_db;
SET NAMES utf8mb4;

-- 常见案由配置：用于前端“常见案由 >>>”列表（稳定排序、可配置）

CREATE TABLE IF NOT EXISTS rule_common_cause (
  category_code VARCHAR(64) NOT NULL,
  cause_code VARCHAR(64) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (category_code, cause_code),
  KEY idx_common_category_enabled (category_code, enabled, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 婚姻家庭：先把比赛需要的 5 个入口配置为常见案由（顺序按前端 UI）
INSERT INTO rule_common_cause (category_code, cause_code, sort_order, enabled) VALUES
('marriage_family','divorce_dispute',10,1),
('marriage_family','property_dispute',20,1),
('marriage_family','child_support_dispute',30,1),
('marriage_family','support_dispute',40,1),
('marriage_family','inherit_dispute',50,1)
ON DUPLICATE KEY UPDATE
sort_order=VALUES(sort_order),
enabled=VALUES(enabled);

