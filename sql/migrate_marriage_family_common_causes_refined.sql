USE rule_engine_db;
SET NAMES utf8mb4;

-- 婚姻家庭最终案由清单（供前端/常见案由统一口径）
-- 12 已合并为：marriage_betrothal_property_dispute
-- 旧码：betrothal_property / property_dispute 仅保留历史兼容，不再作为常见入口。

CREATE TABLE IF NOT EXISTS rule_common_cause (
  category_code VARCHAR(64) NOT NULL,
  cause_code VARCHAR(64) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  enabled TINYINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (category_code, cause_code),
  KEY idx_common_category_enabled (category_code, enabled, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO rule_common_cause (category_code, cause_code, sort_order, enabled) VALUES
('marriage_family','divorce_dispute',10,1),
('marriage_family','marriage_betrothal_property_dispute',20,1),
('marriage_family','child_support_dispute',30,1),
('marriage_family','support_dispute',40,1),
('marriage_family','post_divorce_property',50,1),
('marriage_family','in_marriage_property_division_dispute',60,1),
('marriage_family','post_divorce_damage_liability_dispute',70,1),
('marriage_family','marriage_invalid_dispute',80,1),
('marriage_family','marriage_annulment_dispute',90,1),
('marriage_family','spousal_property_agreement_dispute',100,1),
('marriage_family','cohabitation_dispute',110,1),
('marriage_family','paternity_confirmation_dispute',120,1),
('marriage_family','paternity_disclaimer_dispute',130,1),
('marriage_family','sibling_support_dispute',140,1),
('marriage_family','adoption_dispute',150,1),
('marriage_family','guardianship_dispute',160,1),
('marriage_family','visitation_dispute',170,1),
('marriage_family','family_partition_dispute',180,1)
ON DUPLICATE KEY UPDATE
  sort_order = VALUES(sort_order),
  enabled = VALUES(enabled);

UPDATE rule_common_cause
SET enabled = 0
WHERE category_code = 'marriage_family'
  AND cause_code IN ('betrothal_property', 'property_dispute');

