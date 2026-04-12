-- 若库中从未创建过 Step2 相关表（报错 Table 'rule_engine_db.rule_step2_target' doesn't exist），
-- 先执行本文件创建表结构；再执行 migrate_labor_rules.sql（及按需 migrate_additional_causes.sql）灌入数据。
-- 用法（在服务器 /opt/rule-backend 下）：
--   docker exec -i rule-db mysql -uroot -p"密码" rule_engine_db < sql/bootstrap_step2_tables.sql
--   docker exec -i rule-db mysql -uroot -p"密码" rule_engine_db < sql/migrate_labor_rules.sql

USE rule_engine_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `rule_step2_target` (
  `target_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descr` text COLLATE utf8mb4_unicode_ci,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`target_id`),
  UNIQUE KEY `uk_step2_target_id` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `rule_step2_target_legal_ref` (
  `target_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `law_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`target_id`,`law_id`),
  KEY `idx_law_id` (`law_id`),
  CONSTRAINT `fk_step2_target_lr_law` FOREIGN KEY (`law_id`) REFERENCES `rule_law` (`id`),
  CONSTRAINT `fk_step2_target_lr_target` FOREIGN KEY (`target_id`) REFERENCES `rule_step2_target` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `rule_step2_required_fact` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `target_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fact_key` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `required_order` int NOT NULL DEFAULT '0',
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_target_factkey` (`target_id`,`fact_key`),
  KEY `idx_target_id` (`target_id`),
  CONSTRAINT `fk_step2_required_fact_target` FOREIGN KEY (`target_id`) REFERENCES `rule_step2_target` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `rule_step2_evidence_type` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `target_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fact_key` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `evidence_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `evidence_order` int NOT NULL DEFAULT '0',
  `other_option` tinyint NOT NULL DEFAULT '1',
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_target_fact_evidence` (`target_id`,`fact_key`,`evidence_type`),
  KEY `idx_target_fact` (`target_id`,`fact_key`),
  CONSTRAINT `fk_step2_evidence_target` FOREIGN KEY (`target_id`) REFERENCES `rule_step2_target` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
