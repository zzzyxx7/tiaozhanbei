-- 重试专用脚本（Windows 中文环境）
-- 用法：
-- mysql --default-character-set=gbk -u root -p rule_engine_db < migrate_labor_rules_retry.sql
-- 或进入 mysql 后执行：
-- SOURCE D:/code/tiaozhanzhebei/rule-backend/sql/migrate_labor_rules_retry.sql;

CREATE DATABASE IF NOT EXISTS rule_engine_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE rule_engine_db;

-- 关键：你本机当前报错字节是 GBK 流（\xB4\xE6...），
-- 这里按 GBK 接收，再由 MySQL 转成 utf8mb4 入库。
SET NAMES gbk;
SET FOREIGN_KEY_CHECKS = 0;

-- 统一相关表字符集，确保中文列可写
ALTER TABLE rule_law CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_target CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_target_legal_ref CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_required_fact CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_step2_evidence_type CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question_group CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question_option CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE rule_question_visibility_rule CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 直接复用完整迁移脚本内容
SOURCE D:/code/tiaozhanzhebei/rule-backend/sql/migrate_labor_rules.sql;

SET FOREIGN_KEY_CHECKS = 1;
