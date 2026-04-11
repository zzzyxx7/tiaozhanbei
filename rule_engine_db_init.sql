-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: rule_engine_db
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `rule_case_library`
--

DROP TABLE IF EXISTS `rule_case_library`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_case_library` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cause_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `case_no` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `court` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `judgment_date` date DEFAULT NULL,
  `keywords` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci,
  `source_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_case_cause_date` (`cause_code`,`judgment_date`),
  KEY `idx_case_enabled` (`enabled`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_case_library`
--

LOCK TABLES `rule_case_library` WRITE;
/*!40000 ALTER TABLE `rule_case_library` DISABLE KEYS */;
INSERT INTO `rule_case_library` VALUES (1,'labor_unpaid_wages','(2023)京0105民初12345号','拖欠工资及加班费争议案','北京市朝阳区人民法院','2023-10-20','拖欠工资,加班费,考勤记录','法院认定劳动关系成立且存在欠薪与加班事实，支持工资及部分加班费请求。','https://example.com/case/labor-unpaid-1',1,'2026-04-07 12:12:56','2026-04-07 12:12:56'),(2,'labor_no_contract','(2022)沪0104民初54321号','未签劳动合同双倍工资案','上海市徐汇区人民法院','2022-06-18','未签合同,双倍工资,劳动关系','劳动者入职超过一个月未签书面合同，法院支持法定区间内双倍工资请求。','https://example.com/case/labor-nocontract-1',1,'2026-04-07 12:12:56','2026-04-07 12:12:56'),(3,'labor_illegal_termination','(2024)粤0305民初88888号','违法解除劳动关系赔偿案','深圳市南山区人民法院','2024-03-12','违法解除,赔偿金,工会程序','单位未履行法定程序且解除理由证据不足，法院认定违法解除并支持赔偿。','https://example.com/case/labor-termination-1',1,'2026-04-07 12:12:56','2026-04-07 12:12:56'),(4,'divorce_property','(2021)浙0106民初66666号','离婚房产分割及补偿案','杭州市西湖区人民法院','2021-12-09','离婚,房产分割,共同还贷','法院结合婚后共同还贷与照顾子女原则，确定房屋归属并判令折价补偿。','https://example.com/case/divorce-property-1',1,'2026-04-07 12:12:56','2026-04-07 12:12:56');
/*!40000 ALTER TABLE `rule_case_library` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_cause`
--

DROP TABLE IF EXISTS `rule_cause`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_cause` (
  `cause_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cause_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `questionnaire_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cause_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_cause`
--

LOCK TABLES `rule_cause` WRITE;
/*!40000 ALTER TABLE `rule_cause` DISABLE KEYS */;
INSERT INTO `rule_cause` VALUES ('betrothal_property','婚约财产纠纷','questionnaire_betrothal_property',1,'2026-04-09 13:22:05'),('divorce_dispute','离婚纠纷','questionnaire_divorce_dispute',1,'2026-04-09 13:22:05'),('labor_illegal_termination','违法解除劳动关系纠纷','questionnaire_labor_illegal_termination',1,'2026-04-07 11:29:49'),('labor_injury_compensation','工伤赔偿纠纷','questionnaire_labor_injury_compensation',1,'2026-04-09 13:22:05'),('labor_no_contract','未签劳动合同纠纷','questionnaire_labor_no_contract',1,'2026-04-07 11:29:49'),('labor_overtime_pay','加班费争议','questionnaire_labor_overtime_pay',1,'2026-04-09 13:22:05'),('labor_unpaid_wages','拖欠工资纠纷','questionnaire_labor_unpaid_wages',1,'2026-04-07 11:29:49'),('post_divorce_property','离婚后财产纠纷','questionnaire_post_divorce_property',1,'2026-04-09 13:22:05');
/*!40000 ALTER TABLE `rule_cause` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_cause_law`
--

DROP TABLE IF EXISTS `rule_cause_law`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_cause_law` (
  `cause_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `law_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`cause_code`,`law_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_cause_law`
--

LOCK TABLES `rule_cause_law` WRITE;
/*!40000 ALTER TABLE `rule_cause_law` DISABLE KEYS */;
INSERT INTO `rule_cause_law` VALUES ('betrothal_property','law_1042',1),('betrothal_property','law_jshj_5',2),('divorce_dispute','law_1079',1),('divorce_dispute','law_1084',2),('divorce_dispute','law_1087',3),('labor_illegal_termination','law_contract_39',1),('labor_illegal_termination','law_contract_40',2),('labor_illegal_termination','law_contract_41',3),('labor_illegal_termination','law_contract_48',4),('labor_illegal_termination','law_contract_87',5),('labor_injury_compensation','law_injury_14',1),('labor_injury_compensation','law_injury_30',2),('labor_injury_compensation','law_injury_33',3),('labor_injury_compensation','law_injury_37',4),('labor_no_contract','law_contract_10',1),('labor_no_contract','law_contract_14',3),('labor_no_contract','law_contract_82',2),('labor_overtime_pay','law_contract_30',3),('labor_overtime_pay','law_contract_31',2),('labor_overtime_pay','law_labor_44',1),('labor_unpaid_wages','law_contract_30',2),('labor_unpaid_wages','law_contract_85',3),('labor_unpaid_wages','law_labor_50',1),('labor_unpaid_wages','law_reg_16',4),('post_divorce_property','law_1087',1),('post_divorce_property','law_1092',2);
/*!40000 ALTER TABLE `rule_cause_law` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_cause_target`
--

DROP TABLE IF EXISTS `rule_cause_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_cause_target` (
  `cause_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`cause_code`,`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_cause_target`
--

LOCK TABLES `rule_cause_target` WRITE;
/*!40000 ALTER TABLE `rule_cause_target` DISABLE KEYS */;
INSERT INTO `rule_cause_target` VALUES ('betrothal_property','target_add_betrothal_no_refund',3),('betrothal_property','target_add_betrothal_refund_full',1),('betrothal_property','target_add_betrothal_refund_partial',2),('divorce_dispute','target_add_divorce_general_custody',2),('divorce_dispute','target_add_divorce_general_judgment',1),('divorce_dispute','target_add_divorce_general_property',3),('labor_illegal_termination','target_illegal_termination_compensation',1),('labor_illegal_termination','target_illegal_termination_reinstatement',2),('labor_illegal_termination','target_illegal_termination_revoke_decision',4),('labor_illegal_termination','target_illegal_termination_wage_gap',3),('labor_injury_compensation','target_add_labor_injury_disability',3),('labor_injury_compensation','target_add_labor_injury_medical',2),('labor_injury_compensation','target_add_labor_injury_recognition',1),('labor_no_contract','target_labor_no_contract_double_wage',1),('labor_no_contract','target_labor_no_contract_open_term',3),('labor_no_contract','target_labor_no_contract_sign_contract',2),('labor_overtime_pay','target_add_labor_overtime_holiday',3),('labor_overtime_pay','target_add_labor_overtime_restday',2),('labor_overtime_pay','target_add_labor_overtime_workday',1),('labor_unpaid_wages','target_labor_unpaid_wages_additional_compensation',4),('labor_unpaid_wages','target_labor_unpaid_wages_full_payment',1),('labor_unpaid_wages','target_labor_unpaid_wages_overtime',2),('labor_unpaid_wages','target_labor_unpaid_wages_termination_compensation',3),('post_divorce_property','target_add_post_divorce_agreement_enforce',3),('post_divorce_property','target_add_post_divorce_conceal_penalty',2),('post_divorce_property','target_add_post_divorce_redistribute',1);
/*!40000 ALTER TABLE `rule_cause_target` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_judge_conclusion`
--

DROP TABLE IF EXISTS `rule_judge_conclusion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_judge_conclusion` (
  `conclusion_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `result` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `level` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'warning',
  `law_refs_json` longtext COLLATE utf8mb4_unicode_ci,
  `final_item` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `final_result` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `final_detail` text COLLATE utf8mb4_unicode_ci,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`conclusion_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_judge_conclusion`
--

LOCK TABLES `rule_judge_conclusion` WRITE;
/*!40000 ALTER TABLE `rule_judge_conclusion` DISABLE KEYS */;
INSERT INTO `rule_judge_conclusion` VALUES ('c_add_betrothal_full','betrothal','可主张全额返还彩礼','满足彩礼给付与法定返还关键要件。','important','[\"law_1042\",\"law_jshj_5\"]','彩礼返还请求','全额返还支持可能性较高','建议重点提交彩礼支付凭证、未登记/困难证明材料。',1,'2026-04-09 13:22:06'),('c_add_betrothal_no_refund','betrothal','存在不返还抗辩空间','已登记并长期共同生活，不返还抗辩空间较大。','warning','[\"law_jshj_5\"]','抗辩方向','可主张不返还或少返还','建议提交共同生活事实与支出证据。',1,'2026-04-09 13:22:06'),('c_add_betrothal_partial','betrothal','可主张部分返还彩礼','存在已登记且共同生活较短等情形，倾向部分返还。','warning','[\"law_jshj_5\"]','彩礼返还请求','部分返还支持可能性较高','建议围绕共同生活时长和财产去向补强证据。',1,'2026-04-09 13:22:06'),('c_add_divorce_custody','divorce','可形成子女抚养优势主张','子女长期随一方生活或另一方存在不利因素。','important','[\"law_1084\"]','抚养诉请','可优先主张直接抚养','建议提交学习生活照料及稳定性材料。',1,'2026-04-09 13:22:06'),('c_add_divorce_judgment','divorce','可请求判决离婚','满足婚姻关系与感情破裂要件。','important','[\"law_1079\"]','离婚诉请','判决离婚支持可能性较高','建议补充分居、冲突、调解失败材料。',1,'2026-04-09 13:22:06'),('c_add_divorce_property','divorce','可同步主张财产债务处理','已涉及共同财产或共同债务处理。','important','[\"law_1087\"]','财产债务诉请','建议一并处理共同财产债务','建议提交资产负债清单与凭证。',1,'2026-04-09 13:22:06'),('c_add_labor_injury_disability','labor_injury','伤残待遇主张有支持可能','已认定伤残且单位拒绝支付待遇。','important','[\"law_injury_37\"]','伤残待遇请求','可主张一次性伤残补助等','建议提交伤残等级结论与拒付证据。',1,'2026-04-09 13:22:06'),('c_add_labor_injury_medical','labor_injury','工伤医疗费用主张有支持可能','存在工伤医疗支出且已申请认定。','important','[\"law_injury_30\"]','医疗待遇请求','可主张工伤医疗费用','建议汇总票据、病历及支付记录。',1,'2026-04-09 13:22:06'),('c_add_labor_injury_recognition','labor_injury','工伤认定主张有支持可能','工伤认定核心前提基本具备。','important','[\"law_injury_14\"]','工伤认定请求','可优先推进工伤认定','建议尽快提交认定申请及事故材料。',1,'2026-04-09 13:22:06'),('c_add_overtime_holiday','labor_overtime','节假日加班费主张有支持可能','存在法定节假日加班且未足额支付。','important','[\"law_labor_44\"]','加班费请求','可主张节假日加班费','建议提交节假日值班及发薪对照材料。',1,'2026-04-09 13:22:06'),('c_add_overtime_restday','labor_overtime','休息日加班费主张有支持可能','存在休息日加班且未补休。','important','[\"law_labor_44\"]','加班费请求','可主张休息日加班费','建议提交排班与补休记录。',1,'2026-04-09 13:22:06'),('c_add_overtime_workday','labor_overtime','工作日加班费主张有支持可能','工作日延时加班事实与欠付事实较明确。','important','[\"law_labor_44\",\"law_contract_31\"]','加班费请求','可主张工作日加班费差额','建议按月整理工时和工资差额。',1,'2026-04-09 13:22:06'),('c_add_post_divorce_agreement','post_divorce','可请求履行离婚协议财产条款','存在协议且财产条款未履行。','important','[\"law_1087\"]','协议履行请求','可请求确认并履行协议','建议提交协议文本与催告记录。',1,'2026-04-09 13:22:06'),('c_add_post_divorce_conceal','post_divorce','可主张隐藏转移财产责任','存在隐藏转移线索且证据较充分。','important','[\"law_1092\"]','责任追究请求','可请求对方少分或不分','建议固定流水、交易、账户证据。',1,'2026-04-09 13:22:06'),('c_add_post_divorce_redistribute','post_divorce','可请求离婚后再次分割财产','存在未分割共同财产且已明确再分割请求。','important','[\"law_1087\"]','再分割请求','具备请求基础','建议整理离婚文书与财产线索。',1,'2026-04-09 13:22:06'),('c_divorce_children_priority','divorce_property','分割时需重点照顾未成年子女利益','案件存在未成年子女长期照顾事实，分割时会强化居住稳定性考量。','important','[\"law_1084\"]','分割倾向','照顾子女利益因素显著','可重点提交抚养现状、学籍居住连续性等材料。',1,'2026-04-07 11:41:45'),('c_divorce_common_property','divorce_property','房产更可能被认定为夫妻共同财产','存在婚后取得、共同还贷或共有登记等共同财产特征。','important','[\"law_1062\",\"law_jsyi_25\",\"law_jsyi_27\"]','财产属性判断','共同财产倾向较高','可围绕分割比例、居住需求、还贷贡献提出具体分割方案。',1,'2026-04-07 11:41:45'),('c_divorce_compensation','divorce_property','可主张折价补偿或份额差异化分配','存在明显贡献差异或登记与还贷不一致情形，具备补偿主张空间。','important','[\"law_1087\",\"law_1088\"]','分割方案','可主张补偿/折价款','建议结合评估价、剩余贷款、历史出资形成可执行方案。',1,'2026-04-07 11:41:45'),('c_divorce_personal_property','divorce_property','房产更可能被认定为一方个人财产','现有事实显示房产取得时间或赠与方式倾向个人财产属性。','warning','[\"law_1063\",\"law_jsyi_26\"]','财产属性判断','个人财产倾向较高','需重点核查婚后增值、共同还贷与产权变动对分割的影响。',1,'2026-04-07 11:41:45'),('c_divorce_precondition','divorce_property','满足离婚房产分割审查前提','已形成合法婚姻关系、离婚状态与房产争议三项基础。','important','[\"law_1062\"]','审查入口','可进入房产分割裁判分析','建议继续补充产权、出资、还贷、子女抚养等证据。',1,'2026-04-07 11:41:45'),('c_labor_no_contract_double','labor_contract','可主张未签书面劳动合同期间双倍工资','入职超过一个月未签劳动合同且有工资支付事实支持。','important','[\"law_contract_10\",\"law_contract_82\"]','双倍工资请求','可主张（符合法定要件）','建议按入职时间线整理证据，核算可主张区间后通过劳动仲裁主张。',1,'2026-04-07 11:41:34'),('c_labor_no_contract_open_term','labor_contract','无固定期限合同请求有支持可能','已明确主张且满足法定条件。','important','[\"law_contract_14\"]','无固定期限合同请求','可主张','建议提交工龄、续签记录等证明满足法定条件。',1,'2026-04-07 11:41:34'),('c_labor_no_contract_sign','labor_contract','可请求单位补签书面劳动合同','劳动关系存续且未签书面合同，补签请求具有正当性。','important','[\"law_contract_10\"]','补签劳动合同请求','可主张','建议先发出书面补签申请并保留送达凭证。',1,'2026-04-07 11:41:34'),('c_labor_termination_illegal','labor_termination','解除行为存在较高概率被认定为违法','解除理由或程序不符合法定要求，或存在特殊保护期内解除风险。','important','[\"law_contract_39\",\"law_contract_40\",\"law_contract_41\",\"law_contract_48\",\"law_contract_87\"]','违法解除判断','可优先主张认定为违法解除','建议围绕解除理由合法性、解除程序合法性、特殊保护期事实整理证据。',1,'2026-04-07 11:41:34'),('c_labor_termination_reinstate','labor_termination','可请求继续履行劳动合同','劳动者已明确提出恢复劳动关系请求。','important','[\"law_contract_48\"]','诉请方向','可请求继续履行劳动合同','如劳动者主张继续履行且用人单位仍可继续履行，可作为主要请求。',1,'2026-04-07 11:41:34'),('c_labor_termination_wage_gap','labor_termination','可主张停工期间工资损失','劳动者已明确提出停工期间工资损失请求。','important','[\"law_contract_87\"]','诉请方向','可主张停工期间工资损失','建议结合停工期间证据材料核算损失并一并主张。',1,'2026-04-07 11:41:34'),('c_labor_unpaid_additional','labor_payment','可进一步主张逾期支付加付赔偿金','欠薪在投诉/催告后仍未改正，符合加付赔偿金主张方向。','important','[\"law_contract_85\",\"law_reg_16\"]','加付赔偿金请求','具备主张基础','建议提交投诉回执、限期支付通知及逾期未支付证明材料。',1,'2026-04-07 11:41:34'),('c_labor_unpaid_core','labor_payment','欠薪请求具有较高支持可能性','已具备劳动关系、劳动提供、欠薪事实及核心证据链。','important','[\"law_labor_50\",\"law_contract_30\",\"law_contract_85\"]','欠薪支付请求','可优先主张足额支付拖欠工资','建议申请劳动仲裁并提交劳动关系、劳动提供、欠薪金额及催要记录等证据。',1,'2026-04-07 11:41:34'),('c_labor_unpaid_overtime','labor_payment','加班费请求具备基础支持条件','已明确加班请求，且有加班事实证据及计算依据。','important','[\"law_contract_30\"]','加班费请求','可一并主张','建议按工作日/休息日/法定节假日分开整理加班证据并核算金额。',1,'2026-04-07 11:41:34'),('c_labor_unpaid_term_comp','labor_contract','解除补偿请求有一定支持可能','存在欠薪，且解除原因与单位违约行为相关。','important','[\"law_contract_85\"]','解除补偿请求','可结合欠薪事实一并主张','建议保留解除前催告记录与解除通知，形成完整时间线。',1,'2026-04-07 11:41:34');
/*!40000 ALTER TABLE `rule_judge_conclusion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_judge_rule`
--

DROP TABLE IF EXISTS `rule_judge_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_judge_rule` (
  `rule_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cause_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rule_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `path_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `calc_expr` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '与',
  `law_ref` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `priority` int NOT NULL DEFAULT '1000',
  `condition_json` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rule_id`),
  KEY `idx_rule_cause_priority` (`cause_code`,`priority`,`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_judge_rule`
--

LOCK TABLES `rule_judge_rule` WRITE;
/*!40000 ALTER TABLE `rule_judge_rule` DISABLE KEYS */;
INSERT INTO `rule_judge_rule` VALUES ('r_add_betrothal_full','betrothal_property','彩礼全额返还路径','彩礼全额返还路径命中','与','law_jshj_5',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在彩礼给付\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在法定返还情形\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"未办理结婚登记\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"给付导致生活困难\",\"cmp\":\"eq\",\"value\":true}]}]}',1,'2026-04-09 13:22:06'),('r_add_betrothal_no_refund','betrothal_property','彩礼不返还抗辩路径','彩礼不返还抗辩路径命中','与','law_jshj_5',30,'{\"op\":\"and\",\"children\":[{\"fact\":\"已办理结婚登记\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"已登记后共同生活\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_betrothal_partial','betrothal_property','彩礼部分返还路径','彩礼部分返还路径命中','与/或','law_jshj_5',20,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在彩礼给付\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"已办理结婚登记\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"共同生活时间较短\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_divorce_custody','divorce_dispute','子女抚养路径','子女抚养路径命中','与','law_1084',20,'{\"op\":\"and\",\"children\":[{\"fact\":\"涉及子女抚养\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"子女长期随一方生活\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"另一方存在不利抚养因素\",\"cmp\":\"eq\",\"value\":true}]}]}',1,'2026-04-09 13:22:06'),('r_add_divorce_judgment','divorce_dispute','离婚判决路径','离婚判决路径命中','与','law_1079',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在合法婚姻关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"感情确已破裂\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_divorce_property','divorce_dispute','财产债务处理路径','财产债务处理路径命中','与/或','law_1087',30,'{\"op\":\"or\",\"children\":[{\"fact\":\"涉及夫妻共同财产\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在共同债务\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"共同财产范围清晰\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_labor_injury_disability','labor_injury_compensation','伤残待遇路径','伤残待遇路径命中','与','law_injury_37',30,'{\"op\":\"and\",\"children\":[{\"fact\":\"已认定伤残等级\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"单位拒绝支付工伤待遇\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_labor_injury_medical','labor_injury_compensation','工伤医疗路径','工伤医疗路径命中','与','law_injury_30',20,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在医疗费用支出\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"已申请或拟申请工伤认定\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_labor_injury_recognition','labor_injury_compensation','工伤认定路径','工伤认定路径命中','与','law_injury_14',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在劳动关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"发生工作时间工作场所事故\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"已申请或拟申请工伤认定\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_overtime_holiday','labor_overtime_pay','节假日加班费路径','节假日加班费路径命中','与','law_labor_44',30,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在法定节假日加班\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"单位未足额支付加班费\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_overtime_restday','labor_overtime_pay','休息日加班费路径','休息日加班费路径命中','与','law_labor_44',20,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在休息日加班\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"休息日未安排补休\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"单位未足额支付加班费\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_overtime_workday','labor_overtime_pay','工作日加班费路径','工作日加班费路径命中','与','law_labor_44',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在劳动关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"主张加班费\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在工作日延时加班\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"单位未足额支付加班费\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_post_divorce_agreement','post_divorce_property','协议履行路径','协议履行路径命中','与','law_1087',30,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在离婚协议\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"离婚协议财产条款未履行\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求执行离婚协议\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_post_divorce_conceal','post_divorce_property','隐藏转移财产路径','隐藏转移财产路径命中','与','law_1092',20,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在隐藏转移财产线索\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有证据证明隐藏转移\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_add_post_divorce_redistribute','post_divorce_property','离婚后再分割路径','离婚后再分割路径命中','与','law_1087',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"离婚事实已生效\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在未分割共同财产\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"请求再次分割\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-09 13:22:06'),('r_divorce_children_priority','divorce_property','未成年子女照顾倾向','照顾子女与女方权益路径命中','与','law_1084',40,'{\"fact\":\"存在未成年子女且由一方长期照顾\",\"cmp\":\"eq\",\"value\":true}',1,'2026-04-07 11:41:45'),('r_divorce_common_property','divorce_property','夫妻共同财产倾向认定','夫妻共同财产路径命中','与/或','law_1062',30,'{\"op\":\"or\",\"children\":[{\"fact\":\"房产属于婚后共同财产\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"房贷主要由夫妻共同收入偿还\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"产权登记存在共有情形\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:45'),('r_divorce_compensation','divorce_property','可主张补偿/折价款','折价补偿路径命中','与/或','law_1087',50,'{\"op\":\"or\",\"children\":[{\"fact\":\"一方主张取得房屋并向对方补偿\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在较大出资差异\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在共同还贷但登记在一方名下\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:45'),('r_divorce_personal_property','divorce_property','个人财产倾向认定','婚前个人财产路径命中','与/或','law_1063',20,'{\"op\":\"or\",\"children\":[{\"fact\":\"房产属于婚前个人财产\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"房产由一方父母明确赠与且登记在其子女名下\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:45'),('r_divorce_precondition','divorce_property','离婚房产分割前置条件成立','离婚房产分割前置条件','与','law_1062',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在合法婚姻关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"婚姻关系已经解除或正在解除\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在房产分割争议\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:45'),('r_labor_no_contract_double','labor_no_contract','未签合同双倍工资成立','未签合同双倍工资要件成立','与','law_contract_82',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在劳动关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"未签书面劳动合同\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"入职月数\",\"cmp\":\"gt\",\"value\":1},{\"fact\":\"已补签劳动合同\",\"cmp\":\"eq\",\"value\":false},{\"fact\":\"有工资支付记录\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:34'),('r_labor_no_contract_open_term','labor_no_contract','无固定期限合同成立',NULL,'与','law_contract_14',30,'{\"op\":\"and\",\"children\":[{\"fact\":\"主张无固定期限合同\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"满足无固定期限条件\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:34'),('r_labor_no_contract_sign','labor_no_contract','补签劳动合同请求成立','补签劳动合同请求路径命中','与','law_contract_10',20,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在劳动关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"未签书面劳动合同\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"主张补签书面合同\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:34'),('r_labor_termination_illegal','labor_illegal_termination','违法解除判断路径','违法解除判断路径命中','与/或','law_contract_48',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在劳动关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"已被解除或辞退\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"解除理由不明确\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"and\",\"children\":[{\"fact\":\"有解除通知\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"解除通知为书面\",\"cmp\":\"eq\",\"value\":false}]},{\"op\":\"and\",\"children\":[{\"fact\":\"解除理由_40\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"提前30日通知或支付代通知金\",\"cmp\":\"eq\",\"value\":false}]},{\"op\":\"and\",\"children\":[{\"fact\":\"解除理由_39\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"单位有严重违纪证据\",\"cmp\":\"eq\",\"value\":false},{\"fact\":\"规章制度已公示且合法\",\"cmp\":\"eq\",\"value\":false}]}]},{\"op\":\"and\",\"children\":[{\"fact\":\"解除理由_41\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"经济性裁员符合法定人数与报告程序\",\"cmp\":\"eq\",\"value\":false}]},{\"fact\":\"单位是否履行工会程序\",\"cmp\":\"eq\",\"value\":false},{\"fact\":\"处于特殊保护期\",\"cmp\":\"eq\",\"value\":true}]}]}',1,'2026-04-07 11:41:34'),('r_labor_termination_reinstatement','labor_illegal_termination','继续履行请求',NULL,'与','law_contract_48',20,'{\"fact\":\"主张继续履行劳动合同\",\"cmp\":\"eq\",\"value\":true}',1,'2026-04-07 11:41:34'),('r_labor_termination_wage_gap','labor_illegal_termination','停工工资请求',NULL,'与','law_contract_87',30,'{\"fact\":\"主张停工期间工资损失\",\"cmp\":\"eq\",\"value\":true}',1,'2026-04-07 11:41:34'),('r_labor_unpaid_additional_comp','labor_unpaid_wages','欠薪逾期支付路径','欠薪逾期支付路径命中','与','law_contract_85',40,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在欠薪\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"已向劳动监察投诉\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"单位逾期仍未支付\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:34'),('r_labor_unpaid_core_strong','labor_unpaid_wages','拖欠工资核心证据链成立','拖欠工资核心事实成立','与+或','law_contract_30',10,'{\"op\":\"and\",\"children\":[{\"fact\":\"存在劳动关系\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"已提供劳动\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在欠薪\",\"cmp\":\"eq\",\"value\":true},{\"op\":\"or\",\"children\":[{\"fact\":\"有工资约定依据\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有考勤或工作记录\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有工资支付记录\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"单位书面承认欠薪\",\"cmp\":\"eq\",\"value\":true}]}]}',1,'2026-04-07 11:41:34'),('r_labor_unpaid_overtime','labor_unpaid_wages','加班费请求要件成立','加班费请求要件路径命中','与','law_contract_30',20,'{\"op\":\"and\",\"children\":[{\"fact\":\"主张加班费\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有加班事实证据\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"有加班工资约定依据\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:34'),('r_labor_unpaid_termination_comp','labor_unpaid_wages','欠薪解除补偿路径','欠薪解除补偿路径命中','与','law_contract_85',30,'{\"op\":\"and\",\"children\":[{\"fact\":\"主张解除补偿\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"存在欠薪\",\"cmp\":\"eq\",\"value\":true},{\"fact\":\"解除原因偏向单位责任\",\"cmp\":\"eq\",\"value\":true}]}',1,'2026-04-07 11:41:34');
/*!40000 ALTER TABLE `rule_judge_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_judge_rule_conclusion`
--

DROP TABLE IF EXISTS `rule_judge_rule_conclusion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_judge_rule_conclusion` (
  `rule_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `conclusion_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`rule_id`,`conclusion_id`),
  KEY `idx_rule_conclusion_sort` (`rule_id`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_judge_rule_conclusion`
--

LOCK TABLES `rule_judge_rule_conclusion` WRITE;
/*!40000 ALTER TABLE `rule_judge_rule_conclusion` DISABLE KEYS */;
INSERT INTO `rule_judge_rule_conclusion` VALUES ('r_add_betrothal_full','c_add_betrothal_full',1),('r_add_betrothal_no_refund','c_add_betrothal_no_refund',1),('r_add_betrothal_partial','c_add_betrothal_partial',1),('r_add_divorce_custody','c_add_divorce_custody',1),('r_add_divorce_judgment','c_add_divorce_judgment',1),('r_add_divorce_property','c_add_divorce_property',1),('r_add_labor_injury_disability','c_add_labor_injury_disability',1),('r_add_labor_injury_medical','c_add_labor_injury_medical',1),('r_add_labor_injury_recognition','c_add_labor_injury_recognition',1),('r_add_overtime_holiday','c_add_overtime_holiday',1),('r_add_overtime_restday','c_add_overtime_restday',1),('r_add_overtime_workday','c_add_overtime_workday',1),('r_add_post_divorce_agreement','c_add_post_divorce_agreement',1),('r_add_post_divorce_conceal','c_add_post_divorce_conceal',1),('r_add_post_divorce_redistribute','c_add_post_divorce_redistribute',1),('r_divorce_children_priority','c_divorce_children_priority',1),('r_divorce_common_property','c_divorce_common_property',1),('r_divorce_compensation','c_divorce_compensation',1),('r_divorce_personal_property','c_divorce_personal_property',1),('r_divorce_precondition','c_divorce_precondition',1),('r_labor_no_contract_double','c_labor_no_contract_double',1),('r_labor_no_contract_open_term','c_labor_no_contract_open_term',1),('r_labor_no_contract_sign','c_labor_no_contract_sign',1),('r_labor_termination_illegal','c_labor_termination_illegal',1),('r_labor_termination_reinstatement','c_labor_termination_reinstate',1),('r_labor_termination_wage_gap','c_labor_termination_wage_gap',1),('r_labor_unpaid_additional_comp','c_labor_unpaid_additional',1),('r_labor_unpaid_core_strong','c_labor_unpaid_core',1),('r_labor_unpaid_overtime','c_labor_unpaid_overtime',1),('r_labor_unpaid_termination_comp','c_labor_unpaid_term_comp',1);
/*!40000 ALTER TABLE `rule_judge_rule_conclusion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_law`
--

DROP TABLE IF EXISTS `rule_law`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_law` (
  `id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `article` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci,
  `text` mediumtext COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rule_law_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_law`
--

LOCK TABLES `rule_law` WRITE;
/*!40000 ALTER TABLE `rule_law` DISABLE KEYS */;
INSERT INTO `rule_law` VALUES ('law_1042','中华人民共和国民法典','第一千零四十二条','禁止借婚姻索取财物','禁止借婚姻索取财物。','2026-04-09 21:22:05'),('law_1062','中华人民共和国民法典','第一千零六十二条','夫妻共同财产认定','夫妻在婚姻关系存续期间所得的下列财产，为夫妻的共同财产，归夫妻共同所有：工资、奖金、劳务报酬；生产、经营、投资的收益；知识产权的收益；继承或者受赠的财产，但是本法第一千零六十三条第三项规定的除外；其他应当归共同所有的财产。','2026-03-31 17:27:25'),('law_1063','中华人民共和国民法典','第一千零六十三条','夫妻一方个人财产认定','下列财产为夫妻一方的个人财产：一方的婚前财产；一方因受到人身损害获得的赔偿或者补偿；遗嘱或者赠与合同中确定只归一方的财产；一方专用的生活用品；其他应当归一方的财产。','2026-03-31 17:27:25'),('law_1076','中华人民共和国民法典','第一千零七十六条','协议离婚','夫妻双方自愿离婚的，应当签订书面离婚协议，并亲自到婚姻登记机关申请离婚登记。离婚协议应当载明双方自愿离婚的意思表示和对子女抚养、财产以及债务处理等事项协商一致的意见。','2026-03-31 17:27:25'),('law_1079','中华人民共和国民法典','第一千零七十九条','诉讼离婚条件','夫妻感情确已破裂，调解无效的，应准予离婚。','2026-04-09 21:22:05'),('law_1084','中华人民共和国民法典','第一千零八十四条','子女抚养','离婚后，子女由一方直接抚养，另一方负担抚养费。','2026-04-09 21:22:05'),('law_1087','中华人民共和国民法典','第一千零八十七条','共同财产分割','离婚时，共同财产由双方协议处理；协议不成由法院判决。','2026-04-09 21:22:05'),('law_1088','中华人民共和国民法典','第一千零八十八条','家务劳动补偿','夫妻一方因抚育子女、照料老年人、协助另一方工作等负担较多义务的，离婚时有权向另一方请求补偿，另一方应当给予补偿。','2026-03-31 17:27:26'),('law_1091','中华人民共和国民法典','第一千零九十一条','离婚损害赔偿','有下列情形之一，导致离婚的，无过错方有权请求损害赔偿：(一)重婚；(二)与他人同居；(三)实施家庭暴力；(四)虐待、遗弃家庭成员；(五)有其他重大过错。','2026-03-31 17:27:26'),('law_1092','中华人民共和国民法典','第一千零九十二条','隐藏转移共同财产责任','一方隐藏、转移共同财产的，离婚分割时可少分或不分。','2026-04-09 21:22:05'),('law_contract_10','中华人民共和国劳动合同法','第十条','建立劳动关系应订立书面劳动合同','建立劳动关系，应当订立书面劳动合同。','2026-04-07 19:21:32'),('law_contract_14','中华人民共和国劳动合同法','第十四条','无固定期限劳动合同情形','符合连续订立合同等法定条件的，可要求无固定期限劳动合同。','2026-04-07 19:21:32'),('law_contract_30','中华人民共和国劳动合同法','第三十条','按约足额支付劳动报酬','用人单位应当按照劳动合同约定和国家规定，向劳动者及时足额支付劳动报酬。','2026-04-07 19:21:32'),('law_contract_31','中华人民共和国劳动合同法','第三十一条','加班安排限制','用人单位应严格执行劳动定额标准，不得强迫或者变相强迫劳动者加班。','2026-04-09 21:22:05'),('law_contract_39','中华人民共和国劳动合同法','第三十九条','过失性解除','劳动者存在严重违纪等法定情形的，用人单位可以解除劳动合同。','2026-04-07 19:21:32'),('law_contract_40','中华人民共和国劳动合同法','第四十条','无过失性解除','用人单位依据法定事由解除劳动合同的，应提前三十日书面通知或支付代通知金。','2026-04-07 19:21:32'),('law_contract_41','中华人民共和国劳动合同法','第四十一条','经济性裁员','经济性裁员应符合法定人数、程序和报告要求。','2026-04-07 19:21:32'),('law_contract_48','中华人民共和国劳动合同法','第四十八条','违法解除后果','违法解除的，劳动者可请求继续履行劳动合同或者请求赔偿金。','2026-04-07 19:21:32'),('law_contract_82','中华人民共和国劳动合同法','第八十二条','未签书面劳动合同双倍工资','超过一个月未签书面劳动合同的，应当支付二倍工资。','2026-04-07 19:21:32'),('law_contract_85','中华人民共和国劳动合同法','第八十五条','未按约支付劳动报酬责任','用人单位未及时足额支付劳动报酬的，由劳动行政部门责令限期支付；逾期不支付的，可责令加付赔偿金。','2026-04-07 19:21:32'),('law_contract_87','中华人民共和国劳动合同法','第八十七条','违法解除赔偿金','违法解除劳动合同的，应按经济补偿标准二倍支付赔偿金。','2026-04-07 19:21:32'),('law_injury_14','工伤保险条例','第十四条','应当认定工伤情形','工作时间、工作场所、因工作原因受伤，应认定工伤。','2026-04-09 21:22:05'),('law_injury_30','工伤保险条例','第三十条','工伤医疗待遇','治疗工伤应享受工伤医疗待遇。','2026-04-09 21:22:05'),('law_injury_33','工伤保险条例','第三十三条','停工留薪期待遇','停工留薪期内原工资福利待遇不变。','2026-04-09 21:22:05'),('law_injury_37','工伤保险条例','第三十七条','伤残待遇','因工伤残可享受一次性伤残补助金等待遇。','2026-04-09 21:22:05'),('law_jser_21','婚姻家庭编解释（二）','第二十一条','家务劳动补偿因素','人民法院在确定家务劳动补偿数额时，应当综合考虑一方负担家务劳动的内容和时间、双方的经济状况、当地一般生活水平等因素。','2026-03-31 17:27:26'),('law_jser_5','婚姻家庭编解释（二）','第五条','短婚赠与可撤销','婚姻关系存续期间，夫妻一方将个人所有的房屋赠与另一方或约定为共有，赠与方在赠与房产变更登记后反悔，请求分割或撤销的，人民法院应综合考虑婚姻存续时间、是否实际共同生活、离婚过错、赠与房产在双方婚姻中的作用等因素，判决赠与方是否有权撤销赠与或请求重新分割。','2026-03-31 17:27:26'),('law_jser_8','婚姻家庭编解释（二）','第八条','父母婚后出资新规','婚姻关系存续期间，一方父母全额出资为夫妻购置房屋，没有约定或者约定不明确的，原则上应认定为对夫妻双方的赠与，但父母明确表示赠与自己子女个人的除外。一方父母部分出资为夫妻购置房屋，夫妻双方以共同财产支付其余房款的，除当事人另有约定外，该房屋为夫妻共同财产，对父母的出资份额可参照相关规定处理。','2026-03-31 17:27:26'),('law_jshj_5','最高人民法院关于适用民法典婚姻家庭编的解释（一）','第五条','彩礼返还规则','请求返还彩礼，符合法定情形的，人民法院应予支持。','2026-04-09 21:22:05'),('law_jsyi_25','婚姻家庭编解释（一）','第二十五条','婚前个人财产婚后收益','婚姻关系存续期间，一方以个人财产投资取得的收益，该收益为夫妻共同财产。','2026-03-31 17:27:26'),('law_jsyi_26','婚姻家庭编解释（一）','第二十六条','个人财产自然增值','夫妻一方个人财产在婚后产生的收益，除孳息和自然增值外，应认定为夫妻共同财产。','2026-03-31 17:27:26'),('law_jsyi_27','婚姻家庭编解释（一）','第二十七条','婚前承租公房','婚前由一方承租、婚后用共同财产购买的房屋，虽房屋权属证书登记在一方名下，但应认定为夫妻共同财产。','2026-03-31 17:27:26'),('law_jsyi_29','婚姻家庭编解释（一）','第二十九条','父母出资购房','当事人结婚前，父母为双方购置房屋出资的，该出资应当认定为对自己子女个人的赠与，但父母明确表示赠与双方的除外。当事人结婚后，父母为双方购置房屋出资的，依照约定处理；没有约定或者约定不明确的，按照民法典第一千零六十二条第一款第四项规定的原则处理。','2026-03-31 17:27:26'),('law_jsyi_32','婚姻家庭编解释（一）','第三十二条','夫妻间赠与撤销','婚前或者婚姻关系存续期间，当事人约定将一方所有的房产赠与另一方或者共有，赠与方在赠与房产变更登记之前撤销赠与，另一方请求判令继续履行的，人民法院可以按照民法典第六百五十八条的规定处理。','2026-03-31 17:27:26'),('law_jsyi_5','婚姻家庭编解释（一）','第五条','彩礼返还','当事人请求返还按照习俗给付的彩礼的，如果查明属于以下情形，人民法院应当予以支持：(一)双方未办理结婚登记手续；(二)双方办理结婚登记手续但确未共同生活；(三)婚前给付并导致给付人生活困难。','2026-03-31 17:27:26'),('law_jsyi_76','婚姻家庭编解释（一）','第七十六条','房屋处置方式','双方对夫妻共同财产中的房屋价值及归属无法达成协议时，人民法院按以下情形分别处理：双方均主张房屋所有权并且同意竞价取得的，应当准许；一方主张房屋所有权的，由评估机构按市场价格对房屋作出评估，取得房屋所有权的一方应当给予另一方相应的补偿；双方均不主张房屋所有权的，根据当事人的申请拍卖、变卖房屋，就所得价款进行分割。','2026-03-31 17:27:26'),('law_jsyi_78','婚姻家庭编解释（一）','第七十八条','婚前按揭房分割','夫妻一方婚前签订不动产买卖合同，以个人财产支付首付款并在银行贷款，婚后用夫妻共同财产还贷，不动产登记于首付款支付方名下的，离婚时该不动产由双方协议处理。协议不成的，人民法院可以判决该不动产归登记一方，尚未归还的贷款为不动产登记一方的个人债务。双方婚后共同还贷支付的款项及其相对应财产增值部分，离婚时应根据民法典第一千零八十七条第一款规定的原则，由不动产登记一方对另一方进行补偿。','2026-03-31 17:27:26'),('law_jsyi_79','婚姻家庭编解释（一）','第七十九条','房改房父母名下','婚姻关系存续期间，双方用夫妻共同财产出资购买以一方父母名义参加房改的房屋，登记在一方父母名下，离婚时另一方主张按照夫妻共同财产对该房屋进行分割的，人民法院不予支持。购买该房屋时的出资，可以作为债权处理。','2026-03-31 17:27:26'),('law_labor_44','中华人民共和国劳动法','第四十四条','加班工资标准','延长工时、休息日加班、法定节假日加班应支付加班工资。','2026-04-09 21:22:05'),('law_labor_50','中华人民共和国劳动法','第五十条','工资应当按月支付','工资应当以货币形式按月支付给劳动者本人，不得克扣或者无故拖欠劳动者的工资。','2026-04-07 19:21:32'),('law_reg_16','工资支付暂行规定','第十六条','克扣、拖欠工资处理','用人单位不得克扣劳动者工资；无故拖欠劳动者工资的，应依法承担责任。','2026-04-07 19:21:32');
/*!40000 ALTER TABLE `rule_law` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_question`
--

DROP TABLE IF EXISTS `rule_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_question` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `questionnaire_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_key` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_key` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer_key` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hint` text COLLATE utf8mb4_unicode_ci,
  `input_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `required` tinyint NOT NULL DEFAULT '0',
  `question_order` int NOT NULL DEFAULT '0',
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `unit` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_questionnaire_questionkey` (`questionnaire_id`,`question_key`),
  KEY `idx_questionnaire_group` (`questionnaire_id`,`group_key`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_question`
--

LOCK TABLES `rule_question` WRITE;
/*!40000 ALTER TABLE `rule_question` DISABLE KEYS */;
INSERT INTO `rule_question` VALUES (1,'questionnaire_divorce_property_split','G0','存在合法婚姻关系','存在合法婚姻关系','双方是否依法办理了结婚登记，存在合法婚姻关系？','须持有结婚证或可查询到有效的婚姻登记记录。','boolean',1,0,1,'2026-03-31 17:25:07',NULL),(2,'questionnaire_divorce_property_split','G0','婚姻关系已经解除或正在解除','婚姻关系已经解除或正在解除','双方是否已经离婚或正在进行离婚诉讼？','包括协议离婚（已领取离婚证）或已向法院提起离婚诉讼。','boolean',1,1,1,'2026-03-31 17:25:07',NULL),(3,'questionnaire_divorce_property_split','G0','存在房产分割争议','存在房产分割争议','双方是否就房屋的归属或价值分割存在争议？','如有一方认为房产应归自己，另一方不同意；或双方对房产价值认定不一致。','boolean',1,2,1,'2026-03-31 17:25:07',NULL),(4,'questionnaire_divorce_property_split','G1','房产购置时间','房产购置时间','该房产是在婚前还是婚后购置的？','以签订购房合同的日期为准，对比结婚登记日期。','choice',1,0,1,'2026-03-31 17:25:07',NULL),(5,'questionnaire_divorce_property_split','G1','房产出资主体','房产出资主体','房产购置的出资主体是谁？','指实际支付房款的人。','choice',1,1,1,'2026-03-31 17:25:07',NULL),(6,'questionnaire_divorce_property_split','G1','房产出资性质','房产出资性质','购房的付款方式是什么？','全款指一次性付清全部房款；按揭指支付首付后银行贷款。','choice',1,2,1,'2026-03-31 17:25:07',NULL),(7,'questionnaire_divorce_property_split','G1','产权登记主体','产权登记主体','房产证（不动产权证）上登记的是谁的名字？','以不动产权证书上记载的权利人为准。','choice',1,3,1,'2026-03-31 17:25:07',NULL),(8,'questionnaire_divorce_property_split','G1','婚后共同还贷','婚后共同还贷','婚后是否使用夫妻共同财产偿还过房贷？','夫妻共同财产包括婚后工资、奖金、经营收益等，也包括住房公积金、住房补贴。','boolean',0,4,1,'2026-03-31 17:25:07',NULL),(9,'questionnaire_divorce_property_split','G1','房产增值类型','房产增值类型','该房产在婚姻存续期间是否存在增值？增值原因是什么？','自然增值指因市场行情上涨带来的增值；投资收益指因装修翻新、出租经营等主动行为带来的增值。','choice',0,5,1,'2026-03-31 17:25:07',NULL),(10,'questionnaire_divorce_property_split','G2','签订离婚协议','签订离婚协议','双方是否签订了合法有效的离婚协议？','离婚协议需双方自愿签订，且内容不违反法律强制性规定。','boolean',0,0,1,'2026-03-31 17:25:07',NULL),(11,'questionnaire_divorce_property_split','G2','协议约定房产分割','协议约定房产分割','离婚协议中是否明确约定了房产的分割方案？','如协议中明确写明房产归谁所有、如何补偿等。','boolean',0,1,1,'2026-03-31 17:25:07',NULL),(12,'questionnaire_divorce_property_split','G2','存在房产赠与约定','存在房产赠与约定','夫妻之间是否存在房产赠与（加名/过户）的约定或承诺？','例如：一方承诺将个人名下房产加上配偶名字，或赠与给配偶。','boolean',0,2,1,'2026-03-31 17:25:07',NULL),(13,'questionnaire_divorce_property_split','G2','赠与完成过户','赠与完成过户','房产赠与是否已经完成了不动产权变更登记（过户）？','以不动产登记中心的变更登记手续是否办理完毕为准。','choice',0,3,1,'2026-03-31 17:25:07',NULL),(14,'questionnaire_divorce_property_split','G2','赠与房产认定为彩礼','赠与房产认定为彩礼','该赠与的房产是否可能被认定为彩礼性质？','判断标准：以缔结婚姻为目的、符合当地彩礼习俗、价值较大且无偿转移、在婚约缔结前后给付。','boolean',0,4,1,'2026-03-31 17:25:07',NULL),(15,'questionnaire_divorce_property_split','G2','双方已办结婚登记','双方已办结婚登记','给付彩礼后双方是否已办理了结婚登记？','仅在房产被认定为彩礼性质时需要回答。','boolean',0,5,1,'2026-03-31 17:25:07',NULL),(16,'questionnaire_divorce_property_split','G2','登记后共同生活','登记后共同生活','办理结婚登记后双方是否实际共同生活？','共同生活指双方以夫妻名义共同居住、共同承担生活开支。','boolean',0,6,1,'2026-03-31 17:25:07',NULL),(17,'questionnaire_divorce_property_split','G2','婚前给付导致生活困难','婚前给付导致生活困难','婚前给付房产（彩礼）是否导致给付方生活困难？','生活困难指依靠个人财产和离婚时分得的财产无法维持当地基本生活水平。','boolean',0,7,1,'2026-03-31 17:25:07',NULL),(18,'questionnaire_divorce_property_split','G2','存在赠与撤销法定情形','存在赠与撤销法定情形','是否存在可以撤销赠与的法定情形？','法定情形包括：受赠人严重侵害赠与人或其近亲属权益；受赠人对赠与人有扶养义务而不履行；受赠人不履行赠与合同约定的义务。','boolean',0,8,1,'2026-03-31 17:25:07',NULL),(19,'questionnaire_divorce_property_split','G3','父母出资时间','父母出资时间','父母出资购房是在子女婚前还是婚后？','以父母实际支付房款的时间为准，对比子女结婚登记日期。','choice',0,0,1,'2026-03-31 17:25:07',NULL),(20,'questionnaire_divorce_property_split','G3','父母出资比例','父母出资比例','父母出资占购房总价的比例？','全额出资指父母支付了全部房款；部分出资指父母仅支付首付或部分房款。','choice',0,1,1,'2026-03-31 17:25:07',NULL),(21,'questionnaire_divorce_property_split','G3','存在书面赠与合同','存在书面赠与合同','父母出资时是否签订了书面赠与合同？','书面赠与合同可明确赠与对象和条件。','boolean',0,2,1,'2026-03-31 17:25:07',NULL),(22,'questionnaire_divorce_property_split','G3','赠与合同归己方子女','赠与合同归己方子女','赠与合同中是否明确只归己方子女个人所有？','需要合同中有明确的文字表述，如\'赠与给我儿子/女儿个人\'。','boolean',0,3,1,'2026-03-31 17:25:07',NULL),(23,'questionnaire_divorce_property_split','G3','赠与合同赠与双方','赠与合同赠与双方','赠与合同中是否明确赠与夫妻双方？','如合同写明\'赠与给儿子和儿媳共同\'。','boolean',0,4,1,'2026-03-31 17:26:08',NULL),(24,'questionnaire_divorce_property_split','G4','婚姻存续时长','婚姻存续时长','婚姻关系存续了多长时间（月）？','从结婚登记之日起算到提起离婚之日。','number',0,0,1,'2026-03-31 17:26:08','个月'),(25,'questionnaire_divorce_property_split','G4','存在过错情形','存在过错情形','一方是否存在以下过错情形？','如有多项请选择最严重的一项。','choice',0,1,1,'2026-03-31 17:26:08',NULL),(26,'questionnaire_divorce_property_split','G4','过错有充分证据','过错有充分证据','上述过错情形是否有充分证据证明？','如报警记录、伤情鉴定、通话录音、微信聊天记录、银行转账记录等。','boolean',0,2,1,'2026-03-31 17:26:08',NULL),(27,'questionnaire_divorce_property_split','G4','主张方为无过错方','主张方为无过错方','提出房产分割主张的一方是否为无过错方？','即要求分割房产的人不是实施过错行为的人。','boolean',0,3,1,'2026-03-31 17:26:08',NULL),(28,'questionnaire_divorce_property_split','G4','存在财产处置不当行为','存在财产处置不当行为','一方是否存在隐藏、转移、变卖、毁损、挥霍夫妻共同财产或伪造债务的行为？','如私自转移房产、变卖后隐匿款项、恶意挥霍大额支出等。','boolean',0,4,1,'2026-03-31 17:26:08',NULL),(29,'questionnaire_divorce_property_split','G4','存在家务劳动超额负担','存在家务劳动超额负担','一方是否因抚育子女、照料老人、协助另一方工作等负担了较多义务？','包括全职照顾家庭、长期独自抚养子女、照顾患病老人等。','boolean',0,5,1,'2026-03-31 17:26:08',NULL),(30,'questionnaire_divorce_property_split','G4','无过错方丧失居住权','无过错方丧失居住权','无过错方是否因对方的过错行为而丧失了房产的居住权？','例如被家暴方赶出家门、无法返回共同住所等。','boolean',0,6,1,'2026-03-31 17:26:08',NULL),(31,'questionnaire_divorce_property_split','G5','婚前承租婚后购买公房','婚前承租婚后购买公房','该房产是否属于婚前由一方承租、婚后以夫妻共同财产购买的公房？','公房指单位分配的公有住房，后通过房改等方式购买产权。','boolean',0,0,1,'2026-03-31 17:26:08',NULL),(32,'questionnaire_divorce_property_split','G5','父母名义房改房','父母名义房改房','该房产是否以一方父母名义参加房改购买、登记在父母名下？','房改房指通过住房制度改革以优惠价格购买的原公有住房。','boolean',0,1,1,'2026-03-31 17:26:08',NULL),(33,'questionnaire_divorce_property_split','G6','双方对房屋价值归属无法协议','双方对房屋价值归属无法协议','双方是否无法就房屋的价值或归属达成一致意见？','如双方都想要房子，或对房屋价值认定差异很大。','boolean',0,0,1,'2026-03-31 17:26:08',NULL),(34,'questionnaire_divorce_property_split','G6','房屋处置意愿','房屋处置意愿','双方对房屋的处置意愿如何？','如果双方已达成协议则不需要回答此题。','choice',0,1,1,'2026-03-31 17:26:08',NULL),(35,'questionnaire_labor_unpaid_wages','LW0','存在劳动关系','存在劳动关系','你与单位之间是否存在劳动关系？',NULL,'boolean',1,1,1,'2026-04-07 19:21:32',NULL),(36,'questionnaire_labor_unpaid_wages','LW0','已提供劳动','已提供劳动','你是否已经实际提供劳动？',NULL,'boolean',1,2,1,'2026-04-07 19:21:32',NULL),(37,'questionnaire_labor_unpaid_wages','LW0','存在欠薪','存在欠薪','单位是否存在拖欠工资的情形？',NULL,'boolean',1,3,1,'2026-04-07 19:21:32',NULL),(38,'questionnaire_labor_unpaid_wages','LW1','入职时间已明确','入职时间已明确','你的入职时间是否可以明确到年月？',NULL,'boolean',0,1,1,'2026-04-07 19:21:32',NULL),(39,'questionnaire_labor_unpaid_wages','LW1','离职时间已明确','离职时间已明确','如已离职，离职时间是否可以明确到年月？',NULL,'boolean',0,2,1,'2026-04-07 19:21:32',NULL),(40,'questionnaire_labor_unpaid_wages','LW1','欠薪金额','欠薪金额','拖欠工资金额大约是多少？',NULL,'number',0,3,1,'2026-04-07 19:21:32','元'),(41,'questionnaire_labor_unpaid_wages','LW1','欠薪时长','欠薪时长','拖欠工资已持续多久？',NULL,'number',0,4,1,'2026-04-07 19:21:32','个月'),(42,'questionnaire_labor_unpaid_wages','LW1','有工资约定依据','有工资约定依据','是否有劳动合同/工资条等工资约定依据？',NULL,'boolean',0,5,1,'2026-04-07 19:21:32',NULL),(43,'questionnaire_labor_unpaid_wages','LW1','有考勤或工作记录','有考勤或工作记录','是否有考勤记录、工作群记录、工作成果等劳动证据？',NULL,'boolean',0,6,1,'2026-04-07 19:21:32',NULL),(44,'questionnaire_labor_unpaid_wages','LW1','有工资支付记录','有工资支付记录','是否有银行流水/工资发放记录？',NULL,'boolean',0,7,1,'2026-04-07 19:21:32',NULL),(45,'questionnaire_labor_unpaid_wages','LW1','有催要工资记录','有催要工资记录','是否有催要工资的聊天记录/短信/录音？',NULL,'boolean',0,8,1,'2026-04-07 19:21:32',NULL),(46,'questionnaire_labor_unpaid_wages','LW1','单位书面承认欠薪','单位书面承认欠薪','单位是否有书面承认欠薪的材料？',NULL,'boolean',0,9,1,'2026-04-07 19:21:32',NULL),(47,'questionnaire_labor_unpaid_wages','LW1','有明确工资周期约定','有明确工资周期约定','是否有明确工资发放周期约定（按月/按周）？',NULL,'boolean',0,10,1,'2026-04-07 19:21:32',NULL),(48,'questionnaire_labor_unpaid_wages','LW2','主张加班费','主张加班费','你是否希望一并主张加班费？',NULL,'boolean',0,1,1,'2026-04-07 19:21:32',NULL),(49,'questionnaire_labor_unpaid_wages','LW2','有加班事实证据','有加班事实证据','是否有加班记录（考勤、审批、聊天等）？',NULL,'boolean',0,2,1,'2026-04-07 19:21:32',NULL),(50,'questionnaire_labor_unpaid_wages','LW2','有加班工资约定依据','有加班工资约定依据','是否有加班工资计算依据（制度/约定）？',NULL,'boolean',0,3,1,'2026-04-07 19:21:32',NULL),(51,'questionnaire_labor_unpaid_wages','LW2','主张解除补偿','主张解除补偿','你是否希望主张解除劳动关系经济补偿？',NULL,'boolean',0,4,1,'2026-04-07 19:21:32',NULL),(52,'questionnaire_labor_unpaid_wages','LW2','解除原因偏向单位责任','解除原因偏向单位责任','解除劳动关系是否主要因单位未及时足额支付劳动报酬？',NULL,'boolean',0,5,1,'2026-04-07 19:21:32',NULL),(53,'questionnaire_labor_unpaid_wages','LW2','已向劳动监察投诉','已向劳动监察投诉','是否已向劳动监察部门投诉欠薪？',NULL,'boolean',0,6,1,'2026-04-07 19:21:32',NULL),(54,'questionnaire_labor_unpaid_wages','LW2','单位逾期仍未支付','单位逾期仍未支付','在催告或责令后单位是否逾期仍未支付？',NULL,'boolean',0,7,1,'2026-04-07 19:21:32',NULL),(55,'questionnaire_labor_no_contract','LN0','存在劳动关系','存在劳动关系','你与单位之间是否存在劳动关系？',NULL,'boolean',1,1,1,'2026-04-07 19:21:32',NULL),(56,'questionnaire_labor_no_contract','LN0','未签书面劳动合同','未签书面劳动合同','你是否未与单位签订书面劳动合同？',NULL,'boolean',1,2,1,'2026-04-07 19:21:32',NULL),(57,'questionnaire_labor_no_contract','LN1','入职月数','入职月数','从入职至今共工作了几个月？',NULL,'number',0,1,1,'2026-04-07 19:21:32','个月'),(58,'questionnaire_labor_no_contract','LN1','已补签劳动合同','已补签劳动合同','后续是否已经补签过劳动合同？',NULL,'boolean',0,2,1,'2026-04-07 19:21:32',NULL),(59,'questionnaire_labor_no_contract','LN1','有工资支付记录','有工资支付记录','是否有工资发放记录（转账、工资条等）？',NULL,'boolean',0,3,1,'2026-04-07 19:21:32',NULL),(60,'questionnaire_labor_no_contract','LN1','有工作管理证据','有工作管理证据','是否有考勤、工作安排、工牌等管理从属性证据？',NULL,'boolean',0,4,1,'2026-04-07 19:21:32',NULL),(61,'questionnaire_labor_no_contract','LN1','单位拒绝签合同','单位拒绝签合同','是否有单位拒绝签订书面合同的沟通记录？',NULL,'boolean',0,5,1,'2026-04-07 19:21:32',NULL),(62,'questionnaire_labor_no_contract','LN2','主张补签书面合同','主张补签书面合同','你是否主张补签书面劳动合同？',NULL,'boolean',0,1,1,'2026-04-07 19:21:32',NULL),(63,'questionnaire_labor_no_contract','LN2','主张无固定期限合同','主张无固定期限合同','你是否主张签订无固定期限劳动合同？',NULL,'boolean',0,2,1,'2026-04-07 19:21:32',NULL),(64,'questionnaire_labor_no_contract','LN2','满足无固定期限条件','满足无固定期限条件','你是否已满足无固定期限劳动合同法定条件？',NULL,'boolean',0,3,1,'2026-04-07 19:21:32',NULL),(65,'questionnaire_labor_illegal_termination','LT0','存在劳动关系','存在劳动关系','你与单位之间是否存在劳动关系？',NULL,'boolean',1,1,1,'2026-04-07 19:21:32',NULL),(66,'questionnaire_labor_illegal_termination','LT0','已被解除或辞退','已被解除或辞退','你是否已被解除劳动合同或辞退？',NULL,'boolean',1,2,1,'2026-04-07 19:21:32',NULL),(67,'questionnaire_labor_illegal_termination','LT1','有解除通知','有解除通知','单位是否向你发出过解除/辞退通知？',NULL,'boolean',0,1,1,'2026-04-07 19:21:32',NULL),(68,'questionnaire_labor_illegal_termination','LT1','解除通知为书面','解除通知为书面','该解除通知是否为书面形式？',NULL,'boolean',0,2,1,'2026-04-07 19:21:32',NULL),(69,'questionnaire_labor_illegal_termination','LT1','解除理由类型','解除理由类型','单位主张的解除理由属于哪一类？',NULL,'select',0,3,1,'2026-04-07 19:21:32',NULL),(70,'questionnaire_labor_illegal_termination','LT1','提前30日通知或支付代通知金','提前30日通知或支付代通知金','如属第40条情形，单位是否提前30日书面通知或支付代通知金？',NULL,'boolean',0,4,1,'2026-04-07 19:21:32',NULL),(71,'questionnaire_labor_illegal_termination','LT1','单位是否履行工会程序','单位是否履行工会程序','单位解除前是否履行通知工会等程序？',NULL,'boolean',0,5,1,'2026-04-07 19:21:32',NULL),(72,'questionnaire_labor_illegal_termination','LT1','规章制度已公示且合法','规章制度已公示且合法','单位依据的规章制度是否经过民主程序并已公示？',NULL,'boolean',0,6,1,'2026-04-07 19:21:32',NULL),(73,'questionnaire_labor_illegal_termination','LT2','处于特殊保护期','处于特殊保护期','解除时你是否处于医疗期/孕期/工伤停工留薪期等特殊保护期？',NULL,'boolean',0,1,1,'2026-04-07 19:21:32',NULL),(74,'questionnaire_labor_illegal_termination','LT2','单位有严重违纪证据','单位有严重违纪证据','单位是否能提供你严重违纪的明确证据？',NULL,'boolean',0,2,1,'2026-04-07 19:21:32',NULL),(75,'questionnaire_labor_illegal_termination','LT2','经济性裁员符合法定人数与报告程序','经济性裁员符合法定人数与报告程序','如属经济性裁员，单位是否满足法定人数与报告程序？',NULL,'boolean',0,3,1,'2026-04-07 19:21:32',NULL),(76,'questionnaire_labor_illegal_termination','LT2','主张继续履行劳动合同','主张继续履行劳动合同','你是否希望优先主张恢复劳动关系（继续履行劳动合同）？',NULL,'boolean',0,4,1,'2026-04-07 19:21:32',NULL),(77,'questionnaire_labor_illegal_termination','LT2','主张停工期间工资损失','主张停工期间工资损失','你是否主张停工期间工资损失（或等待恢复期间损失）？',NULL,'boolean',0,5,1,'2026-04-07 19:21:32',NULL),(78,'questionnaire_betrothal_property','BP1','存在彩礼给付','存在彩礼给付','是否存在彩礼给付？',NULL,'boolean',1,1,1,'2026-04-09 21:22:06',NULL),(79,'questionnaire_betrothal_property','BP1','未办理结婚登记','未办理结婚登记','双方是否未办理结婚登记？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(80,'questionnaire_betrothal_property','BP1','已办理结婚登记','已办理结婚登记','双方是否已办理结婚登记？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(81,'questionnaire_betrothal_property','BP2','已登记后共同生活','已登记后共同生活','登记后是否共同生活较长时间？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(82,'questionnaire_betrothal_property','BP2','共同生活时间较短','共同生活时间较短','共同生活时间是否较短？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(83,'questionnaire_betrothal_property','BP2','给付导致生活困难','给付导致生活困难','彩礼给付是否导致给付方生活困难？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(84,'questionnaire_betrothal_property','BP2','对方存在重大过错','对方存在重大过错','对方是否存在重大过错？',NULL,'boolean',0,4,1,'2026-04-09 21:22:06',NULL),(85,'questionnaire_betrothal_property','BP2','存在法定返还情形','存在法定返还情形','是否存在彩礼返还法定情形？',NULL,'boolean',1,5,1,'2026-04-09 21:22:06',NULL),(86,'questionnaire_betrothal_property','BP2','彩礼金额','彩礼金额','彩礼金额约多少？',NULL,'number',0,6,1,'2026-04-09 21:22:06','元'),(87,'questionnaire_betrothal_property','BP2','共同生活月数','共同生活月数','共同生活约几个月？',NULL,'number',0,7,1,'2026-04-09 21:22:06','月'),(88,'questionnaire_betrothal_property','BP3','有彩礼转账凭证','有彩礼转账凭证','是否有彩礼转账凭证或收条？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(89,'questionnaire_betrothal_property','BP3','有共同生活证据','有共同生活证据','是否有共同生活证据（租房、消费、同住）？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(90,'questionnaire_betrothal_property','BP3','有困难证明材料','有困难证明材料','是否有生活困难证明材料？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(91,'questionnaire_divorce_dispute','DG1','存在合法婚姻关系','存在合法婚姻关系','是否存在合法婚姻关系？',NULL,'boolean',1,1,1,'2026-04-09 21:22:06',NULL),(92,'questionnaire_divorce_dispute','DG1','感情确已破裂','感情确已破裂','是否存在感情确已破裂事实？',NULL,'boolean',1,2,1,'2026-04-09 21:22:06',NULL),(93,'questionnaire_divorce_dispute','DG1','分居满一年','分居满一年','是否存在分居满一年情形？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(94,'questionnaire_divorce_dispute','DG1','存在调解意愿','存在调解意愿','是否仍存在调解意愿？',NULL,'boolean',0,4,1,'2026-04-09 21:22:06',NULL),(95,'questionnaire_divorce_dispute','DG2','涉及子女抚养','涉及子女抚养','是否涉及子女抚养问题？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(96,'questionnaire_divorce_dispute','DG2','子女长期随一方生活','子女长期随一方生活','子女是否长期随一方生活？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(97,'questionnaire_divorce_dispute','DG2','另一方存在不利抚养因素','另一方存在不利抚养因素','另一方是否存在不利抚养因素？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(98,'questionnaire_divorce_dispute','DG2','涉及夫妻共同财产','涉及夫妻共同财产','是否涉及共同财产分割？',NULL,'boolean',0,4,1,'2026-04-09 21:22:06',NULL),(99,'questionnaire_divorce_dispute','DG2','共同财产范围清晰','共同财产范围清晰','共同财产范围是否清晰？',NULL,'boolean',0,5,1,'2026-04-09 21:22:06',NULL),(100,'questionnaire_divorce_dispute','DG2','存在共同债务','存在共同债务','是否存在夫妻共同债务？',NULL,'boolean',0,6,1,'2026-04-09 21:22:06',NULL),(101,'questionnaire_divorce_dispute','DG2','存在家庭暴力或重大过错','存在家庭暴力或重大过错','是否存在家庭暴力或重大过错？',NULL,'boolean',0,7,1,'2026-04-09 21:22:06',NULL),(102,'questionnaire_divorce_dispute','DG3','有分居证据','有分居证据','是否有分居证据（租房合同、居住证明）？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(103,'questionnaire_divorce_dispute','DG3','有家暴或报警记录','有家暴或报警记录','是否有家暴或报警记录？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(104,'questionnaire_divorce_dispute','DG3','有抚养能力材料','有抚养能力材料','是否有稳定收入和抚养能力材料？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(105,'questionnaire_post_divorce_property','PD1','离婚事实已生效','离婚事实已生效','离婚事实是否已生效？',NULL,'boolean',1,1,1,'2026-04-09 21:22:06',NULL),(106,'questionnaire_post_divorce_property','PD1','存在离婚协议','存在离婚协议','是否存在离婚协议？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(107,'questionnaire_post_divorce_property','PD1','离婚协议财产条款未履行','离婚协议财产条款未履行','协议财产条款是否未履行？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(108,'questionnaire_post_divorce_property','PD1','请求再次分割','请求再次分割','是否请求再次分割财产？',NULL,'boolean',1,4,1,'2026-04-09 21:22:06',NULL),(109,'questionnaire_post_divorce_property','PD1','请求执行离婚协议','请求执行离婚协议','是否请求执行离婚协议？',NULL,'boolean',0,5,1,'2026-04-09 21:22:06',NULL),(110,'questionnaire_post_divorce_property','PD2','存在未分割共同财产','存在未分割共同财产','是否存在未分割共同财产？',NULL,'boolean',1,1,1,'2026-04-09 21:22:06',NULL),(111,'questionnaire_post_divorce_property','PD2','新发现财产线索','新发现财产线索','是否新发现财产线索？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(112,'questionnaire_post_divorce_property','PD2','存在隐藏转移财产线索','存在隐藏转移财产线索','是否存在隐藏转移财产线索？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(113,'questionnaire_post_divorce_property','PD2','有证据证明隐藏转移','有证据证明隐藏转移','是否有证据证明隐藏转移？',NULL,'boolean',0,4,1,'2026-04-09 21:22:06',NULL),(114,'questionnaire_post_divorce_property','PD3','有离婚协议原件','有离婚协议原件','是否有离婚协议原件或公证文本？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(115,'questionnaire_post_divorce_property','PD3','有财产交易流水','有财产交易流水','是否有财产交易流水或账户明细？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(116,'questionnaire_post_divorce_property','PD3','有对方名下财产线索','有对方名下财产线索','是否有对方名下新增财产线索？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(117,'questionnaire_labor_injury_compensation','LI1','存在劳动关系','存在劳动关系','是否存在劳动关系？',NULL,'boolean',1,1,1,'2026-04-09 21:22:06',NULL),(118,'questionnaire_labor_injury_compensation','LI1','发生工作时间工作场所事故','发生工作时间工作场所事故','是否在工作时间和工作场所发生事故？',NULL,'boolean',1,2,1,'2026-04-09 21:22:06',NULL),(119,'questionnaire_labor_injury_compensation','LI1','已申请或拟申请工伤认定','已申请或拟申请工伤认定','是否已申请或拟申请工伤认定？',NULL,'boolean',1,3,1,'2026-04-09 21:22:06',NULL),(120,'questionnaire_labor_injury_compensation','LI1','单位已缴纳工伤保险','单位已缴纳工伤保险','单位是否已缴纳工伤保险？',NULL,'boolean',0,4,1,'2026-04-09 21:22:06',NULL),(121,'questionnaire_labor_injury_compensation','LI2','存在医疗费用支出','存在医疗费用支出','是否存在医疗费用支出？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(122,'questionnaire_labor_injury_compensation','LI2','存在停工留薪损失','存在停工留薪损失','是否存在停工留薪损失？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(123,'questionnaire_labor_injury_compensation','LI2','已认定伤残等级','已认定伤残等级','是否已认定伤残等级？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(124,'questionnaire_labor_injury_compensation','LI2','单位拒绝支付工伤待遇','单位拒绝支付工伤待遇','单位是否拒绝支付工伤待遇？',NULL,'boolean',0,4,1,'2026-04-09 21:22:06',NULL),(125,'questionnaire_labor_injury_compensation','LI3','有事故报告或证人证言','有事故报告或证人证言','是否有事故报告或证人证言？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(126,'questionnaire_labor_injury_compensation','LI3','有病历及费用票据','有病历及费用票据','是否有病历和医疗费用票据？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(127,'questionnaire_labor_injury_compensation','LI3','有伤残鉴定文书','有伤残鉴定文书','是否有伤残等级鉴定文书？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(128,'questionnaire_labor_overtime_pay','LO1','存在劳动关系','存在劳动关系','是否存在劳动关系？',NULL,'boolean',1,1,1,'2026-04-09 21:22:06',NULL),(129,'questionnaire_labor_overtime_pay','LO1','主张加班费','主张加班费','是否主张加班费？',NULL,'boolean',1,2,1,'2026-04-09 21:22:06',NULL),(130,'questionnaire_labor_overtime_pay','LO1','单位未足额支付加班费','单位未足额支付加班费','单位是否未足额支付加班费？',NULL,'boolean',1,3,1,'2026-04-09 21:22:06',NULL),(131,'questionnaire_labor_overtime_pay','LO1','月均加班时长','月均加班时长','月均加班时长约多少？',NULL,'number',0,4,1,'2026-04-09 21:22:06','小时'),(132,'questionnaire_labor_overtime_pay','LO2','存在加班事实','存在加班事实','是否存在加班事实？',NULL,'boolean',1,1,1,'2026-04-09 21:22:06',NULL),(133,'questionnaire_labor_overtime_pay','LO2','有加班证据','有加班证据','是否有加班证据（考勤/审批）？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(134,'questionnaire_labor_overtime_pay','LO2','存在工作日延时加班','存在工作日延时加班','是否存在工作日延时加班？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL),(135,'questionnaire_labor_overtime_pay','LO2','存在休息日加班','存在休息日加班','是否存在休息日加班？',NULL,'boolean',0,4,1,'2026-04-09 21:22:06',NULL),(136,'questionnaire_labor_overtime_pay','LO2','休息日未安排补休','休息日未安排补休','休息日加班是否未安排补休？',NULL,'boolean',0,5,1,'2026-04-09 21:22:06',NULL),(137,'questionnaire_labor_overtime_pay','LO2','存在法定节假日加班','存在法定节假日加班','是否存在法定节假日加班？',NULL,'boolean',0,6,1,'2026-04-09 21:22:06',NULL),(138,'questionnaire_labor_overtime_pay','LO3','有完整考勤记录','有完整考勤记录','是否有完整考勤记录（打卡/门禁）？',NULL,'boolean',0,1,1,'2026-04-09 21:22:06',NULL),(139,'questionnaire_labor_overtime_pay','LO3','有加班审批记录','有加班审批记录','是否有加班审批或排班记录？',NULL,'boolean',0,2,1,'2026-04-09 21:22:06',NULL),(140,'questionnaire_labor_overtime_pay','LO3','有工资条与流水对照','有工资条与流水对照','是否有工资条与银行流水对照？',NULL,'boolean',0,3,1,'2026-04-09 21:22:06',NULL);
/*!40000 ALTER TABLE `rule_question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_question_group`
--

DROP TABLE IF EXISTS `rule_question_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_question_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `questionnaire_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_key` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_order` int NOT NULL DEFAULT '0',
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `group_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `group_desc` text COLLATE utf8mb4_unicode_ci,
  `icon` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_questionnaire_group` (`questionnaire_id`,`group_key`),
  KEY `idx_questionnaire_id` (`questionnaire_id`),
  CONSTRAINT `fk_group_questionnaire` FOREIGN KEY (`questionnaire_id`) REFERENCES `rule_questionnaire` (`questionnaire_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_question_group`
--

LOCK TABLES `rule_question_group` WRITE;
/*!40000 ALTER TABLE `rule_question_group` DISABLE KEYS */;
INSERT INTO `rule_question_group` VALUES (1,'questionnaire_divorce_property_split','G0',0,1,'2026-03-31 17:25:07','前置程序确认','确认是否满足离婚房产分割的基本前提条件','⚖️'),(2,'questionnaire_divorce_property_split','G1',1,1,'2026-03-31 17:25:07','房产基础事实','采集房产购置时间、出资来源、登记状态等核心事实','🏠'),(3,'questionnaire_divorce_property_split','G2',2,1,'2026-03-31 17:25:07','协议与赠与','采集离婚协议、房产赠与及彩礼相关事实','📝'),(4,'questionnaire_divorce_property_split','G3',3,1,'2026-03-31 17:25:07','父母出资情况','采集父母出资购房的时间、比例及赠与意思表示','👨‍👩‍👧'),(9,'questionnaire_divorce_property_split','G4',4,1,'2026-03-31 17:26:08','婚姻过错与补偿','采集婚姻存续期间的过错行为与家务劳动情况','⚠️'),(10,'questionnaire_divorce_property_split','G5',5,1,'2026-03-31 17:26:08','特殊房产类型','采集公房、房改房等特殊房产情况','🏢'),(11,'questionnaire_divorce_property_split','G6',6,1,'2026-03-31 17:26:08','房屋处置意见','采集双方对房屋归属和价值的处置意愿','🔑'),(19,'questionnaire_labor_unpaid_wages','LW0',1,1,'2026-04-07 19:21:32','前置事实确认','先确认是否属于拖欠工资纠纷的基本前提','check'),(20,'questionnaire_labor_unpaid_wages','LW1',2,1,'2026-04-07 19:21:32','劳动关系与工资约定','先把劳动关系和工资标准证据补齐','folder'),(21,'questionnaire_labor_unpaid_wages','LW2',3,1,'2026-04-07 19:21:32','延伸请求（可选）','如需主张加班费或解除补偿，补充对应事实','plus'),(22,'questionnaire_labor_no_contract','LN0',1,1,'2026-04-07 19:21:32','前置事实确认','确认是否属于未签劳动合同争议','check'),(23,'questionnaire_labor_no_contract','LN1',2,1,'2026-04-07 19:21:32','关键要件补全','确认用工时长、补签情况及基础证据','folder'),(24,'questionnaire_labor_no_contract','LN2',3,1,'2026-04-07 19:21:32','延伸请求（可选）','补充无固定期限合同等进阶诉请','plus'),(25,'questionnaire_labor_illegal_termination','LT0',1,1,'2026-04-07 19:21:32','前置事实确认','先确认是否属于违法解除劳动争议','check'),(26,'questionnaire_labor_illegal_termination','LT1',2,1,'2026-04-07 19:21:32','解除事实','补充解除通知、解除理由及程序事实','folder'),(27,'questionnaire_labor_illegal_termination','LT2',3,1,'2026-04-07 19:21:32','延伸事实','核对特殊保护期及单位证据情况','plus'),(28,'questionnaire_betrothal_property','BP1',1,1,'2026-04-09 21:22:06','基础事实','确认彩礼给付与登记情况','check'),(29,'questionnaire_betrothal_property','BP2',2,1,'2026-04-09 21:22:06','返还要件','确认法定返还与补强事实','folder'),(30,'questionnaire_betrothal_property','BP3',3,1,'2026-04-09 21:22:06','证据补强','补充支付凭证与共同生活证据','plus'),(31,'questionnaire_divorce_dispute','DG1',1,1,'2026-04-09 21:22:06','离婚前提','确认婚姻关系与感情破裂','check'),(32,'questionnaire_divorce_dispute','DG2',2,1,'2026-04-09 21:22:06','争议范围','确认子女、财产、债务争议','folder'),(33,'questionnaire_divorce_dispute','DG3',3,1,'2026-04-09 21:22:06','证据补强','补充感情破裂与抚养能力证据','plus'),(34,'questionnaire_post_divorce_property','PD1',1,1,'2026-04-09 21:22:06','离婚后前提','确认离婚已生效及请求方向','check'),(35,'questionnaire_post_divorce_property','PD2',2,1,'2026-04-09 21:22:06','财产线索','确认未分割或隐藏转移线索','folder'),(36,'questionnaire_post_divorce_property','PD3',3,1,'2026-04-09 21:22:06','证据补强','补充协议、线索与交易证据','plus'),(37,'questionnaire_labor_injury_compensation','LI1',1,1,'2026-04-09 21:22:06','工伤前提','确认劳动关系与事故事实','check'),(38,'questionnaire_labor_injury_compensation','LI2',2,1,'2026-04-09 21:22:06','待遇项目','确认医疗费/停工留薪/伤残事实','folder'),(39,'questionnaire_labor_injury_compensation','LI3',3,1,'2026-04-09 21:22:06','证据补强','补充事故、病历和鉴定材料','plus'),(40,'questionnaire_labor_overtime_pay','LO1',1,1,'2026-04-09 21:22:06','加班前提','确认劳动关系和主张方向','check'),(41,'questionnaire_labor_overtime_pay','LO2',2,1,'2026-04-09 21:22:06','加班细项','确认工作日/休息日/节假日加班事实','folder'),(42,'questionnaire_labor_overtime_pay','LO3',3,1,'2026-04-09 21:22:06','证据补强','补充考勤、审批和工资对照材料','plus');
/*!40000 ALTER TABLE `rule_question_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_question_option`
--

DROP TABLE IF EXISTS `rule_question_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_question_option` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question_id` bigint NOT NULL,
  `option_value` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_order` int NOT NULL DEFAULT '0',
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_question_option_value` (`question_id`,`option_value`),
  CONSTRAINT `fk_question_option_question` FOREIGN KEY (`question_id`) REFERENCES `rule_question` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_question_option`
--

LOCK TABLES `rule_question_option` WRITE;
/*!40000 ALTER TABLE `rule_question_option` DISABLE KEYS */;
INSERT INTO `rule_question_option` VALUES (1,4,'婚前','婚前购置',0,1,'2026-03-31 17:25:07'),(2,4,'婚后','婚后购置',1,1,'2026-03-31 17:25:07'),(3,5,'一方个人','一方个人出资',0,1,'2026-03-31 17:25:07'),(4,5,'双方共同','双方共同出资',1,1,'2026-03-31 17:25:07'),(5,5,'父母出资','一方父母出资',2,1,'2026-03-31 17:25:07'),(6,5,'双方父母','双方父母共同出资',3,1,'2026-03-31 17:25:07'),(7,6,'全款','全款支付',0,1,'2026-03-31 17:25:07'),(8,6,'按揭','首付+按揭贷款',1,1,'2026-03-31 17:25:07'),(9,7,'出资方个人','出资方个人名下',0,1,'2026-03-31 17:25:07'),(10,7,'配偶','配偶名下',1,1,'2026-03-31 17:25:07'),(11,7,'双方共同','夫妻双方共同名下',2,1,'2026-03-31 17:25:07'),(12,7,'父母名下','出资方父母名下',3,1,'2026-03-31 17:25:07'),(13,9,'无增值','无明显增值',0,1,'2026-03-31 17:25:07'),(14,9,'自然增值','自然增值（市场行情上涨）',1,1,'2026-03-31 17:25:07'),(15,9,'投资收益','投资性收益（经营/出租等）',2,1,'2026-03-31 17:25:07'),(16,13,'未过户','尚未办理变更登记',0,1,'2026-03-31 17:25:07'),(17,13,'已过户','已经办理变更登记',1,1,'2026-03-31 17:25:07'),(18,19,'婚前','婚前出资',0,1,'2026-03-31 17:25:07'),(19,19,'婚后','婚后出资',1,1,'2026-03-31 17:25:07'),(20,20,'全额','全额出资',0,1,'2026-03-31 17:25:07'),(21,20,'部分','部分出资（其余为夫妻共同支付）',1,1,'2026-03-31 17:25:07'),(43,25,'无','不存在过错情形',0,1,'2026-03-31 17:26:08'),(44,25,'重婚','重婚',1,1,'2026-03-31 17:26:08'),(45,25,'同居','与他人同居',2,1,'2026-03-31 17:26:08'),(46,25,'家暴','实施家庭暴力',3,1,'2026-03-31 17:26:08'),(47,25,'虐待遗弃','虐待或遗弃家庭成员',4,1,'2026-03-31 17:26:08'),(48,25,'其他重大过错','其他重大过错',5,1,'2026-03-31 17:26:08'),(49,34,'竞价','双方都想要房子（同意竞价取得）',0,1,'2026-03-31 17:26:08'),(50,34,'评估补偿','一方想要房子，愿意给对方补偿',1,1,'2026-03-31 17:26:08'),(51,34,'拍卖变卖','双方都不要房子，同意卖掉分钱',2,1,'2026-03-31 17:26:08'),(82,69,'article_39','过失性解除（第39条）',1,1,'2026-04-07 19:21:32'),(83,69,'article_40','无过失性解除（第40条）',2,1,'2026-04-07 19:21:32'),(84,69,'article_41','经济性裁员（第41条）',3,1,'2026-04-07 19:21:32'),(85,69,'unknown','无法说明或其他',4,1,'2026-04-07 19:21:32');
/*!40000 ALTER TABLE `rule_question_option` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_question_visibility_rule`
--

DROP TABLE IF EXISTS `rule_question_visibility_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_question_visibility_rule` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question_id` bigint NOT NULL,
  `show_if` tinyint NOT NULL DEFAULT '1',
  `condition_json` json NOT NULL,
  `rule_order` int NOT NULL DEFAULT '0',
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_question_visibility` (`question_id`),
  CONSTRAINT `fk_visibility_question` FOREIGN KEY (`question_id`) REFERENCES `rule_question` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_question_visibility_rule`
--

LOCK TABLES `rule_question_visibility_rule` WRITE;
/*!40000 ALTER TABLE `rule_question_visibility_rule` DISABLE KEYS */;
INSERT INTO `rule_question_visibility_rule` VALUES (1,8,1,'{\"op\": \"eq\", \"value\": \"按揭\", \"answerKey\": \"房产出资性质\"}',0,1,'2026-03-31 17:27:25'),(2,11,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"签订离婚协议\"}',0,1,'2026-03-31 17:27:25'),(3,13,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"存在房产赠与约定\"}',0,1,'2026-03-31 17:27:25'),(4,14,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"存在房产赠与约定\"}',0,1,'2026-03-31 17:27:25'),(5,15,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"赠与房产认定为彩礼\"}',0,1,'2026-03-31 17:27:25'),(6,16,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"双方已办结婚登记\"}',0,1,'2026-03-31 17:27:25'),(7,17,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"赠与房产认定为彩礼\"}',0,1,'2026-03-31 17:27:25'),(8,18,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"存在房产赠与约定\"}',0,1,'2026-03-31 17:27:25'),(9,19,1,'{\"op\": \"eq\", \"value\": \"父母出资\", \"answerKey\": \"房产出资主体\"}',0,1,'2026-03-31 17:27:25'),(10,20,1,'{\"op\": \"eq\", \"value\": \"父母出资\", \"answerKey\": \"房产出资主体\"}',0,1,'2026-03-31 17:27:25'),(11,21,1,'{\"op\": \"eq\", \"value\": \"父母出资\", \"answerKey\": \"房产出资主体\"}',0,1,'2026-03-31 17:27:25'),(12,22,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"存在书面赠与合同\"}',0,1,'2026-03-31 17:27:25'),(13,23,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"存在书面赠与合同\"}',0,1,'2026-03-31 17:27:25'),(14,26,1,'{\"op\": \"neq\", \"notValue\": \"无\", \"answerKey\": \"存在过错情形\"}',0,1,'2026-03-31 17:27:25'),(15,27,1,'{\"op\": \"neq\", \"notValue\": \"无\", \"answerKey\": \"存在过错情形\"}',0,1,'2026-03-31 17:27:25'),(16,30,1,'{\"op\": \"neq\", \"notValue\": \"无\", \"answerKey\": \"存在过错情形\"}',0,1,'2026-03-31 17:27:25'),(17,34,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"双方对房屋价值归属无法协议\"}',0,1,'2026-03-31 17:27:25'),(18,49,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"主张加班费\"}',1,1,'2026-04-07 19:21:32'),(19,50,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"主张加班费\"}',1,1,'2026-04-07 19:21:32'),(20,52,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"主张解除补偿\"}',1,1,'2026-04-07 19:21:32'),(21,64,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"主张无固定期限合同\"}',1,1,'2026-04-07 19:21:32'),(22,68,1,'{\"op\": \"eq\", \"value\": true, \"answerKey\": \"有解除通知\"}',1,1,'2026-04-07 19:21:32'),(23,70,1,'{\"op\": \"eq\", \"value\": \"article_40\", \"answerKey\": \"解除理由类型\"}',1,1,'2026-04-07 19:21:32');
/*!40000 ALTER TABLE `rule_question_visibility_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_questionnaire`
--

DROP TABLE IF EXISTS `rule_questionnaire`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_questionnaire` (
  `questionnaire_id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `version_no` int NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`questionnaire_id`),
  UNIQUE KEY `uk_questionnaire_id` (`questionnaire_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_questionnaire`
--

LOCK TABLES `rule_questionnaire` WRITE;
/*!40000 ALTER TABLE `rule_questionnaire` DISABLE KEYS */;
INSERT INTO `rule_questionnaire` VALUES ('questionnaire_divorce_property_split','离婚房产分割问卷',1,1,'2026-03-31 17:25:07');
/*!40000 ALTER TABLE `rule_questionnaire` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_step2_evidence_type`
--

DROP TABLE IF EXISTS `rule_step2_evidence_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_step2_evidence_type` (
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
) ENGINE=InnoDB AUTO_INCREMENT=147 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_step2_evidence_type`
--

LOCK TABLES `rule_step2_evidence_type` WRITE;
/*!40000 ALTER TABLE `rule_step2_evidence_type` DISABLE KEYS */;
INSERT INTO `rule_step2_evidence_type` VALUES (1,'target_common_property_split','房产购置时间_婚后','购房合同签订时间材料',0,0,1,'2026-03-31 17:27:26'),(2,'target_common_property_split','房产购置时间_婚后','结婚证/婚姻登记信息',1,0,1,'2026-03-31 17:27:26'),(3,'target_common_property_split','房产购置时间_婚后','购房发票/付款凭证',2,0,1,'2026-03-31 17:27:26'),(4,'target_common_property_split','房产购置时间_婚后','其他可证明材料',3,1,1,'2026-03-31 17:27:26'),(5,'target_common_property_split','出资主体_双方共同','银行流水/转账记录',0,0,1,'2026-03-31 17:27:26'),(6,'target_common_property_split','出资主体_双方共同','首付款凭证',1,0,1,'2026-03-31 17:27:26'),(7,'target_common_property_split','出资主体_双方共同','共同还贷记录/还款明细',2,0,1,'2026-03-31 17:27:26'),(8,'target_common_property_split','出资主体_双方共同','公积金缴存与还贷记录',3,0,1,'2026-03-31 17:27:26'),(9,'target_common_property_split','出资主体_双方共同','其他可证明材料',4,1,1,'2026-03-31 17:27:26'),(10,'target_common_property_split','登记_双方共同','不动产权证书',0,0,1,'2026-03-31 17:27:26'),(11,'target_common_property_split','登记_双方共同','不动产登记信息查询结果',1,0,1,'2026-03-31 17:27:26'),(12,'target_common_property_split','登记_双方共同','变更登记（加名）材料',2,0,1,'2026-03-31 17:27:26'),(13,'target_common_property_split','登记_双方共同','其他可证明材料',3,1,1,'2026-03-31 17:27:26'),(14,'target_no_fault_more_share','存在过错情形','报警回执/行政处罚决定',0,0,1,'2026-03-31 17:27:26'),(15,'target_no_fault_more_share','存在过错情形','医院诊断证明/伤情鉴定',1,0,1,'2026-03-31 17:27:26'),(16,'target_no_fault_more_share','存在过错情形','聊天记录/录音录像',2,0,1,'2026-03-31 17:27:26'),(17,'target_no_fault_more_share','存在过错情形','证人证言',3,0,1,'2026-03-31 17:27:26'),(18,'target_no_fault_more_share','存在过错情形','其他可证明材料',4,1,1,'2026-03-31 17:27:26'),(19,'target_no_fault_more_share','过错有充分证据','法院/公安/医院等出具的客观材料',0,0,1,'2026-03-31 17:27:26'),(20,'target_no_fault_more_share','过错有充分证据','公证材料',1,0,1,'2026-03-31 17:27:26'),(21,'target_no_fault_more_share','过错有充分证据','完整时间线的电子证据',2,0,1,'2026-03-31 17:27:26'),(22,'target_no_fault_more_share','过错有充分证据','其他可证明材料',3,1,1,'2026-03-31 17:27:26'),(23,'target_no_fault_more_share','主张方为无过错方','过错事实与主体对应的证据材料',0,0,1,'2026-03-31 17:27:26'),(24,'target_no_fault_more_share','主张方为无过错方','双方陈述/对方自认材料',1,0,1,'2026-03-31 17:27:26'),(25,'target_no_fault_more_share','主张方为无过错方','其他可证明材料',2,1,1,'2026-03-31 17:27:26'),(51,'target_labor_unpaid_wages_full_payment','存在劳动关系','劳动合同',1,0,1,'2026-04-07 19:21:32'),(52,'target_labor_unpaid_wages_full_payment','存在劳动关系','入职登记信息',2,0,1,'2026-04-07 19:21:32'),(53,'target_labor_unpaid_wages_full_payment','存在劳动关系','社保缴纳记录',3,0,1,'2026-04-07 19:21:32'),(54,'target_labor_unpaid_wages_full_payment','已提供劳动','考勤记录',1,0,1,'2026-04-07 19:21:32'),(55,'target_labor_unpaid_wages_full_payment','已提供劳动','工作群记录',2,0,1,'2026-04-07 19:21:32'),(56,'target_labor_unpaid_wages_full_payment','已提供劳动','工作成果材料',3,0,1,'2026-04-07 19:21:32'),(57,'target_labor_unpaid_wages_full_payment','存在欠薪','工资发放明细',1,0,1,'2026-04-07 19:21:32'),(58,'target_labor_unpaid_wages_full_payment','存在欠薪','银行流水',2,0,1,'2026-04-07 19:21:32'),(59,'target_labor_unpaid_wages_full_payment','有工资约定依据','劳动合同',1,0,1,'2026-04-07 19:21:32'),(60,'target_labor_unpaid_wages_full_payment','有工资约定依据','工资条',2,0,1,'2026-04-07 19:21:32'),(61,'target_labor_unpaid_wages_full_payment','有工资约定依据','薪酬制度文件',3,0,1,'2026-04-07 19:21:32'),(62,'target_labor_unpaid_wages_full_payment','有工资支付记录','银行流水',1,0,1,'2026-04-07 19:21:32'),(63,'target_labor_unpaid_wages_full_payment','有工资支付记录','工资转账记录',2,0,1,'2026-04-07 19:21:32'),(64,'target_labor_unpaid_wages_full_payment','有工资支付记录','工资条',3,0,1,'2026-04-07 19:21:32'),(65,'target_labor_unpaid_wages_full_payment','有催要工资记录','微信聊天记录',1,0,1,'2026-04-07 19:21:32'),(66,'target_labor_unpaid_wages_full_payment','有催要工资记录','短信记录',2,0,1,'2026-04-07 19:21:32'),(67,'target_labor_unpaid_wages_full_payment','有催要工资记录','通话录音',3,0,1,'2026-04-07 19:21:32'),(68,'target_labor_unpaid_wages_full_payment','有明确工资周期约定','劳动合同条款',1,0,1,'2026-04-07 19:21:32'),(69,'target_labor_unpaid_wages_full_payment','有明确工资周期约定','薪资制度文件',2,0,1,'2026-04-07 19:21:32'),(70,'target_labor_unpaid_wages_overtime','主张加班费','仲裁请求清单',1,0,1,'2026-04-07 19:21:32'),(71,'target_labor_unpaid_wages_overtime','有加班事实证据','考勤记录',1,0,1,'2026-04-07 19:21:32'),(72,'target_labor_unpaid_wages_overtime','有加班事实证据','加班审批单',2,0,1,'2026-04-07 19:21:32'),(73,'target_labor_unpaid_wages_overtime','有加班事实证据','门禁记录',3,0,1,'2026-04-07 19:21:32'),(74,'target_labor_unpaid_wages_overtime','有加班工资约定依据','公司规章制度',1,0,1,'2026-04-07 19:21:32'),(75,'target_labor_unpaid_wages_overtime','有加班工资约定依据','劳动合同条款',2,0,1,'2026-04-07 19:21:32'),(76,'target_labor_unpaid_wages_termination_compensation','主张解除补偿','解除通知',1,0,1,'2026-04-07 19:21:32'),(77,'target_labor_unpaid_wages_termination_compensation','主张解除补偿','仲裁请求清单',2,0,1,'2026-04-07 19:21:32'),(78,'target_labor_unpaid_wages_termination_compensation','存在欠薪','银行流水',1,0,1,'2026-04-07 19:21:32'),(79,'target_labor_unpaid_wages_termination_compensation','存在欠薪','工资条',2,0,1,'2026-04-07 19:21:32'),(80,'target_labor_unpaid_wages_termination_compensation','解除原因偏向单位责任','催告记录',1,0,1,'2026-04-07 19:21:32'),(81,'target_labor_unpaid_wages_termination_compensation','解除原因偏向单位责任','解除沟通记录',2,0,1,'2026-04-07 19:21:32'),(82,'target_labor_unpaid_wages_additional_compensation','存在欠薪','工资条',1,0,1,'2026-04-07 19:21:32'),(83,'target_labor_unpaid_wages_additional_compensation','存在欠薪','银行流水',2,0,1,'2026-04-07 19:21:32'),(84,'target_labor_unpaid_wages_additional_compensation','已向劳动监察投诉','投诉回执',1,0,1,'2026-04-07 19:21:32'),(85,'target_labor_unpaid_wages_additional_compensation','已向劳动监察投诉','受理通知',2,0,1,'2026-04-07 19:21:32'),(86,'target_labor_unpaid_wages_additional_compensation','单位逾期仍未支付','限期支付通知',1,0,1,'2026-04-07 19:21:32'),(87,'target_labor_unpaid_wages_additional_compensation','单位逾期仍未支付','逾期未支付证明',2,0,1,'2026-04-07 19:21:32'),(88,'target_labor_no_contract_double_wage','存在劳动关系','考勤记录',1,0,1,'2026-04-07 19:21:32'),(89,'target_labor_no_contract_double_wage','存在劳动关系','工作安排聊天记录',2,0,1,'2026-04-07 19:21:32'),(90,'target_labor_no_contract_double_wage','未签书面劳动合同','合同缺失说明',1,0,1,'2026-04-07 19:21:32'),(91,'target_labor_no_contract_double_wage','未签书面劳动合同','沟通记录',2,0,1,'2026-04-07 19:21:32'),(92,'target_labor_no_contract_double_wage','有工资支付记录','银行流水',1,0,1,'2026-04-07 19:21:32'),(93,'target_labor_no_contract_double_wage','有工资支付记录','工资条',2,0,1,'2026-04-07 19:21:32'),(94,'target_labor_no_contract_sign_contract','存在劳动关系','考勤记录',1,0,1,'2026-04-07 19:21:32'),(95,'target_labor_no_contract_sign_contract','存在劳动关系','工牌',2,0,1,'2026-04-07 19:21:32'),(96,'target_labor_no_contract_sign_contract','未签书面劳动合同','合同缺失说明',1,0,1,'2026-04-07 19:21:32'),(97,'target_labor_no_contract_sign_contract','未签书面劳动合同','入职材料',2,0,1,'2026-04-07 19:21:32'),(98,'target_labor_no_contract_sign_contract','主张补签书面合同','书面申请',1,0,1,'2026-04-07 19:21:32'),(99,'target_labor_no_contract_sign_contract','主张补签书面合同','邮件记录',2,0,1,'2026-04-07 19:21:32'),(100,'target_labor_no_contract_open_term','存在劳动关系','劳动关系证明材料',1,0,1,'2026-04-07 19:21:32'),(101,'target_labor_no_contract_open_term','主张无固定期限合同','请求书',1,0,1,'2026-04-07 19:21:32'),(102,'target_labor_no_contract_open_term','满足无固定期限条件','工龄证明',1,0,1,'2026-04-07 19:21:32'),(103,'target_labor_no_contract_open_term','满足无固定期限条件','续签记录',2,0,1,'2026-04-07 19:21:32'),(104,'target_illegal_termination_compensation','存在劳动关系','劳动合同',1,0,1,'2026-04-07 19:21:32'),(105,'target_illegal_termination_compensation','存在劳动关系','社保记录',2,0,1,'2026-04-07 19:21:32'),(106,'target_illegal_termination_compensation','存在劳动关系','工资记录',3,0,1,'2026-04-07 19:21:32'),(107,'target_illegal_termination_compensation','已被解除或辞退','解除通知书',1,0,1,'2026-04-07 19:21:32'),(108,'target_illegal_termination_compensation','已被解除或辞退','辞退聊天记录',2,0,1,'2026-04-07 19:21:32'),(109,'target_illegal_termination_compensation','解除程序或理由存在瑕疵','解除通知内容',1,0,1,'2026-04-07 19:21:32'),(110,'target_illegal_termination_compensation','解除程序或理由存在瑕疵','规章制度',2,0,1,'2026-04-07 19:21:32'),(111,'target_illegal_termination_compensation','解除程序或理由存在瑕疵','工会材料',3,0,1,'2026-04-07 19:21:32'),(112,'target_illegal_termination_reinstatement','存在劳动关系','劳动合同',1,0,1,'2026-04-07 19:21:32'),(113,'target_illegal_termination_reinstatement','存在劳动关系','工资流水',2,0,1,'2026-04-07 19:21:32'),(114,'target_illegal_termination_reinstatement','已被解除或辞退','解除通知书',1,0,1,'2026-04-07 19:21:32'),(115,'target_illegal_termination_reinstatement','主张继续履行劳动合同','仲裁请求书',1,0,1,'2026-04-07 19:21:32'),(116,'target_illegal_termination_reinstatement','主张继续履行劳动合同','复工申请',2,0,1,'2026-04-07 19:21:32'),(117,'target_illegal_termination_wage_gap','存在劳动关系','劳动合同',1,0,1,'2026-04-07 19:21:32'),(118,'target_illegal_termination_wage_gap','存在劳动关系','工资记录',2,0,1,'2026-04-07 19:21:32'),(119,'target_illegal_termination_wage_gap','已被解除或辞退','解除通知',1,0,1,'2026-04-07 19:21:32'),(120,'target_illegal_termination_wage_gap','已被解除或辞退','系统停权记录',2,0,1,'2026-04-07 19:21:32'),(121,'target_illegal_termination_wage_gap','主张停工期间工资损失','工资标准依据',1,0,1,'2026-04-07 19:21:32'),(122,'target_illegal_termination_wage_gap','主张停工期间工资损失','历史工资流水',2,0,1,'2026-04-07 19:21:32'),(123,'target_illegal_termination_revoke_decision','存在劳动关系','劳动合同',1,0,1,'2026-04-07 19:21:32'),(124,'target_illegal_termination_revoke_decision','存在劳动关系','工资流水',2,0,1,'2026-04-07 19:21:32'),(125,'target_illegal_termination_revoke_decision','已被解除或辞退','解除通知',1,0,1,'2026-04-07 19:21:32'),(126,'target_illegal_termination_revoke_decision','解除理由不明确','解除通知内容',1,0,1,'2026-04-07 19:21:32'),(127,'target_illegal_termination_revoke_decision','解除理由不明确','单位说明材料',2,0,1,'2026-04-07 19:21:32'),(128,'target_illegal_termination_revoke_decision','解除通知为书面','书面通知原件',1,0,1,'2026-04-07 19:21:32'),(129,'target_illegal_termination_revoke_decision','解除通知为书面','送达记录',2,0,1,'2026-04-07 19:21:32'),(130,'target_add_betrothal_refund_full','存在彩礼给付','转账记录/收条',1,0,1,'2026-04-09 21:22:06'),(131,'target_add_betrothal_refund_full','存在法定返还情形','未登记或共同生活证据',1,0,1,'2026-04-09 21:22:06'),(132,'target_add_betrothal_refund_full','彩礼金额','支付明细/聊天记录',1,0,1,'2026-04-09 21:22:06'),(133,'target_add_betrothal_refund_partial','共同生活时间较短','共同生活期间证据',1,0,1,'2026-04-09 21:22:06'),(134,'target_add_betrothal_no_refund','已登记后共同生活','登记与共同生活证据',1,0,1,'2026-04-09 21:22:06'),(135,'target_add_divorce_general_judgment','感情确已破裂','分居/报警/矛盾证据',1,0,1,'2026-04-09 21:22:06'),(136,'target_add_divorce_general_custody','子女长期随一方生活','就学与日常照顾证据',1,0,1,'2026-04-09 21:22:06'),(137,'target_add_divorce_general_property','共同财产范围清晰','不动产/存款/负债清单',1,0,1,'2026-04-09 21:22:06'),(138,'target_add_post_divorce_redistribute','存在未分割共同财产','财产线索清单',1,0,1,'2026-04-09 21:22:06'),(139,'target_add_post_divorce_conceal_penalty','有证据证明隐藏转移','流水/交易记录',1,0,1,'2026-04-09 21:22:06'),(140,'target_add_post_divorce_agreement_enforce','离婚协议财产条款未履行','协议与催告记录',1,0,1,'2026-04-09 21:22:06'),(141,'target_add_labor_injury_recognition','发生工作时间工作场所事故','事故记录/证人证言',1,0,1,'2026-04-09 21:22:06'),(142,'target_add_labor_injury_medical','存在医疗费用支出','医疗票据/病历',1,0,1,'2026-04-09 21:22:06'),(143,'target_add_labor_injury_disability','已认定伤残等级','伤残鉴定结论',1,0,1,'2026-04-09 21:22:06'),(144,'target_add_labor_overtime_workday','存在工作日延时加班','考勤/审批/聊天记录',1,0,1,'2026-04-09 21:22:06'),(145,'target_add_labor_overtime_restday','休息日未安排补休','排班/补休记录',1,0,1,'2026-04-09 21:22:06'),(146,'target_add_labor_overtime_holiday','存在法定节假日加班','节假日值班记录',1,0,1,'2026-04-09 21:22:06');
/*!40000 ALTER TABLE `rule_step2_evidence_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_step2_required_fact`
--

DROP TABLE IF EXISTS `rule_step2_required_fact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_step2_required_fact` (
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
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_step2_required_fact`
--

LOCK TABLES `rule_step2_required_fact` WRITE;
/*!40000 ALTER TABLE `rule_step2_required_fact` DISABLE KEYS */;
INSERT INTO `rule_step2_required_fact` VALUES (1,'target_common_property_split','房产购置时间_婚后','房产为婚后购置（或婚姻存续期间取得）',0,1,'2026-03-31 17:27:26'),(2,'target_common_property_split','出资主体_双方共同','存在双方共同出资（或共同财产支付房款）',1,1,'2026-03-31 17:27:26'),(3,'target_common_property_split','登记_双方共同','不动产权登记在夫妻双方名下（或存在加名/共有登记）',2,1,'2026-03-31 17:27:26'),(4,'target_no_fault_more_share','存在过错情形','对方存在重婚/同居/家暴/虐待遗弃/其他重大过错等情形',0,1,'2026-03-31 17:27:26'),(5,'target_no_fault_more_share','过错有充分证据','对过错情形有充分证据证明',1,1,'2026-03-31 17:27:26'),(6,'target_no_fault_more_share','主张方为无过错方','提出主张的一方为无过错方',2,1,'2026-03-31 17:27:26'),(13,'target_labor_unpaid_wages_full_payment','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(14,'target_labor_unpaid_wages_full_payment','已提供劳动','已经实际提供劳动',2,1,'2026-04-07 19:21:32'),(15,'target_labor_unpaid_wages_full_payment','存在欠薪','存在拖欠工资事实',3,1,'2026-04-07 19:21:32'),(16,'target_labor_unpaid_wages_full_payment','有工资约定依据','有工资标准/约定依据',4,1,'2026-04-07 19:21:32'),(17,'target_labor_unpaid_wages_full_payment','有工资支付记录','有工资发放/欠发记录',5,1,'2026-04-07 19:21:32'),(18,'target_labor_unpaid_wages_full_payment','有催要工资记录','有催要工资沟通记录',6,1,'2026-04-07 19:21:32'),(19,'target_labor_unpaid_wages_full_payment','有明确工资周期约定','有明确工资发放周期约定',7,1,'2026-04-07 19:21:32'),(20,'target_labor_unpaid_wages_overtime','主张加班费','明确提出加班费请求',1,1,'2026-04-07 19:21:32'),(21,'target_labor_unpaid_wages_overtime','有加班事实证据','有加班事实证据',2,1,'2026-04-07 19:21:32'),(22,'target_labor_unpaid_wages_overtime','有加班工资约定依据','有加班工资计算依据',3,1,'2026-04-07 19:21:32'),(23,'target_labor_unpaid_wages_termination_compensation','主张解除补偿','明确提出解除补偿请求',1,1,'2026-04-07 19:21:32'),(24,'target_labor_unpaid_wages_termination_compensation','存在欠薪','存在拖欠工资事实',2,1,'2026-04-07 19:21:32'),(25,'target_labor_unpaid_wages_termination_compensation','解除原因偏向单位责任','解除原因与单位欠薪行为相关',3,1,'2026-04-07 19:21:32'),(26,'target_labor_unpaid_wages_additional_compensation','存在欠薪','存在拖欠工资事实',1,1,'2026-04-07 19:21:32'),(27,'target_labor_unpaid_wages_additional_compensation','已向劳动监察投诉','已向劳动监察投诉或正式催告',2,1,'2026-04-07 19:21:32'),(28,'target_labor_unpaid_wages_additional_compensation','单位逾期仍未支付','单位逾期仍未支付',3,1,'2026-04-07 19:21:32'),(29,'target_labor_no_contract_double_wage','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(30,'target_labor_no_contract_double_wage','未签书面劳动合同','超过一个月未签书面劳动合同',2,1,'2026-04-07 19:21:32'),(31,'target_labor_no_contract_double_wage','有工资支付记录','存在工资发放事实',3,1,'2026-04-07 19:21:32'),(32,'target_labor_no_contract_sign_contract','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(33,'target_labor_no_contract_sign_contract','未签书面劳动合同','尚未签订书面劳动合同',2,1,'2026-04-07 19:21:32'),(34,'target_labor_no_contract_sign_contract','主张补签书面合同','已明确请求补签合同',3,1,'2026-04-07 19:21:32'),(35,'target_labor_no_contract_open_term','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(36,'target_labor_no_contract_open_term','主张无固定期限合同','已明确主张无固定期限合同',2,1,'2026-04-07 19:21:32'),(37,'target_labor_no_contract_open_term','满足无固定期限条件','已满足法定条件',3,1,'2026-04-07 19:21:32'),(38,'target_illegal_termination_compensation','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(39,'target_illegal_termination_compensation','已被解除或辞退','已发生解除/辞退事实',2,1,'2026-04-07 19:21:32'),(40,'target_illegal_termination_compensation','解除程序或理由存在瑕疵','解除理由或程序存在违法情形',3,1,'2026-04-07 19:21:32'),(41,'target_illegal_termination_reinstatement','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(42,'target_illegal_termination_reinstatement','已被解除或辞退','已发生解除/辞退事实',2,1,'2026-04-07 19:21:32'),(43,'target_illegal_termination_reinstatement','主张继续履行劳动合同','已明确请求恢复劳动关系',3,1,'2026-04-07 19:21:32'),(44,'target_illegal_termination_wage_gap','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(45,'target_illegal_termination_wage_gap','已被解除或辞退','已发生解除/辞退事实',2,1,'2026-04-07 19:21:32'),(46,'target_illegal_termination_wage_gap','主张停工期间工资损失','已明确主张停工期间工资损失',3,1,'2026-04-07 19:21:32'),(47,'target_illegal_termination_revoke_decision','存在劳动关系','与单位存在劳动关系',1,1,'2026-04-07 19:21:32'),(48,'target_illegal_termination_revoke_decision','已被解除或辞退','已发生解除/辞退事实',2,1,'2026-04-07 19:21:32'),(49,'target_illegal_termination_revoke_decision','解除理由不明确','解除理由不明确或与法条不匹配',3,1,'2026-04-07 19:21:32'),(50,'target_illegal_termination_revoke_decision','解除通知为书面','解除通知书面瑕疵（反向佐证）',4,1,'2026-04-07 19:21:32'),(51,'target_add_betrothal_refund_full','存在彩礼给付','存在彩礼给付事实',1,1,'2026-04-09 21:22:06'),(52,'target_add_betrothal_refund_full','存在法定返还情形','存在彩礼返还法定情形',2,1,'2026-04-09 21:22:06'),(53,'target_add_betrothal_refund_full','彩礼金额','彩礼金额明确',3,1,'2026-04-09 21:22:06'),(54,'target_add_betrothal_refund_partial','存在彩礼给付','存在彩礼给付事实',1,1,'2026-04-09 21:22:06'),(55,'target_add_betrothal_refund_partial','已办理结婚登记','已办理结婚登记',2,1,'2026-04-09 21:22:06'),(56,'target_add_betrothal_refund_partial','共同生活时间较短','共同生活时间较短',3,1,'2026-04-09 21:22:06'),(57,'target_add_betrothal_no_refund','已办理结婚登记','已办理结婚登记',1,1,'2026-04-09 21:22:06'),(58,'target_add_betrothal_no_refund','已登记后共同生活','已登记并长期共同生活',2,1,'2026-04-09 21:22:06'),(59,'target_add_divorce_general_judgment','存在合法婚姻关系','存在合法婚姻关系',1,1,'2026-04-09 21:22:06'),(60,'target_add_divorce_general_judgment','感情确已破裂','感情确已破裂',2,1,'2026-04-09 21:22:06'),(61,'target_add_divorce_general_custody','涉及子女抚养','涉及子女抚养',1,1,'2026-04-09 21:22:06'),(62,'target_add_divorce_general_custody','子女长期随一方生活','子女长期随一方生活',2,1,'2026-04-09 21:22:06'),(63,'target_add_divorce_general_property','涉及夫妻共同财产','涉及夫妻共同财产',1,1,'2026-04-09 21:22:06'),(64,'target_add_divorce_general_property','共同财产范围清晰','共同财产范围清晰',2,1,'2026-04-09 21:22:06'),(65,'target_add_post_divorce_redistribute','离婚事实已生效','离婚事实已生效',1,1,'2026-04-09 21:22:06'),(66,'target_add_post_divorce_redistribute','存在未分割共同财产','存在未分割共同财产',2,1,'2026-04-09 21:22:06'),(67,'target_add_post_divorce_redistribute','请求再次分割','请求再次分割',3,1,'2026-04-09 21:22:06'),(68,'target_add_post_divorce_conceal_penalty','存在隐藏转移财产线索','存在隐藏转移财产线索',1,1,'2026-04-09 21:22:06'),(69,'target_add_post_divorce_conceal_penalty','有证据证明隐藏转移','有证据证明隐藏转移',2,1,'2026-04-09 21:22:06'),(70,'target_add_post_divorce_agreement_enforce','存在离婚协议','存在离婚协议',1,1,'2026-04-09 21:22:06'),(71,'target_add_post_divorce_agreement_enforce','离婚协议财产条款未履行','离婚协议财产条款未履行',2,1,'2026-04-09 21:22:06'),(72,'target_add_labor_injury_recognition','存在劳动关系','存在劳动关系',1,1,'2026-04-09 21:22:06'),(73,'target_add_labor_injury_recognition','发生工作时间工作场所事故','工作时间工作场所事故',2,1,'2026-04-09 21:22:06'),(74,'target_add_labor_injury_recognition','已申请或拟申请工伤认定','已申请或拟申请工伤认定',3,1,'2026-04-09 21:22:06'),(75,'target_add_labor_injury_medical','存在医疗费用支出','存在医疗费用支出',1,1,'2026-04-09 21:22:06'),(76,'target_add_labor_injury_medical','已申请或拟申请工伤认定','已申请或拟申请工伤认定',2,1,'2026-04-09 21:22:06'),(77,'target_add_labor_injury_disability','已认定伤残等级','已认定伤残等级',1,1,'2026-04-09 21:22:06'),(78,'target_add_labor_injury_disability','单位拒绝支付工伤待遇','单位拒绝支付工伤待遇',2,1,'2026-04-09 21:22:06'),(79,'target_add_labor_overtime_workday','存在工作日延时加班','存在工作日延时加班',1,1,'2026-04-09 21:22:06'),(80,'target_add_labor_overtime_workday','单位未足额支付加班费','单位未足额支付加班费',2,1,'2026-04-09 21:22:06'),(81,'target_add_labor_overtime_restday','存在休息日加班','存在休息日加班',1,1,'2026-04-09 21:22:06'),(82,'target_add_labor_overtime_restday','休息日未安排补休','休息日未安排补休',2,1,'2026-04-09 21:22:06'),(83,'target_add_labor_overtime_holiday','存在法定节假日加班','存在法定节假日加班',1,1,'2026-04-09 21:22:06'),(84,'target_add_labor_overtime_holiday','单位未足额支付加班费','单位未足额支付加班费',2,1,'2026-04-09 21:22:06');
/*!40000 ALTER TABLE `rule_step2_required_fact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_step2_target`
--

DROP TABLE IF EXISTS `rule_step2_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_step2_target` (
  `target_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descr` text COLLATE utf8mb4_unicode_ci,
  `enabled` tinyint NOT NULL DEFAULT '1',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`target_id`),
  UNIQUE KEY `uk_step2_target_id` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_step2_target`
--

LOCK TABLES `rule_step2_target` WRITE;
/*!40000 ALTER TABLE `rule_step2_target` DISABLE KEYS */;
INSERT INTO `rule_step2_target` VALUES ('target_add_betrothal_no_refund','抗辩不予返还彩礼','通过共同生活、登记等事实抗辩不返还或少返还。',1,'2026-04-09 21:22:06'),('target_add_betrothal_refund_full','主张全额返还彩礼','围绕法定返还要件及金额证据主张全额返还。',1,'2026-04-09 21:22:06'),('target_add_betrothal_refund_partial','主张部分返还彩礼','在已共同生活或已登记情形下主张部分返还。',1,'2026-04-09 21:22:06'),('target_add_divorce_general_custody','子女抚养方案请求','围绕子女利益与抚养条件提出抚养方案。',1,'2026-04-09 21:22:06'),('target_add_divorce_general_judgment','请求判决离婚','围绕感情破裂事实请求判决离婚。',1,'2026-04-09 21:22:06'),('target_add_divorce_general_property','财产与债务处理方案','围绕共同财产、共同债务提出分割方案。',1,'2026-04-09 21:22:06'),('target_add_labor_injury_disability','主张伤残待遇','针对伤残等级主张补助金等待遇。',1,'2026-04-09 21:22:06'),('target_add_labor_injury_medical','主张工伤医疗费用待遇','围绕医疗费用及票据主张支付。',1,'2026-04-09 21:22:06'),('target_add_labor_injury_recognition','确认工伤并主张工伤待遇','围绕工伤认定与待遇项目组织请求。',1,'2026-04-09 21:22:06'),('target_add_labor_overtime_holiday','主张法定节假日加班费','围绕法定节假日加班主张法定标准加班费。',1,'2026-04-09 21:22:06'),('target_add_labor_overtime_restday','主张休息日加班费','围绕休息日加班且未补休主张加班费。',1,'2026-04-09 21:22:06'),('target_add_labor_overtime_workday','主张工作日延时加班费','围绕工作日延时加班事实与时长主张差额。',1,'2026-04-09 21:22:06'),('target_add_post_divorce_agreement_enforce','请求履行离婚协议财产条款','针对协议未履行请求确认并履行。',1,'2026-04-09 21:22:06'),('target_add_post_divorce_conceal_penalty','追究隐藏转移财产责任','针对隐藏转移财产请求少分或不分。',1,'2026-04-09 21:22:06'),('target_add_post_divorce_redistribute','离婚后再次分割财产','针对未分割财产请求再次分割。',1,'2026-04-09 21:22:06'),('target_common_property_split','争取认定为夫妻共同财产并依法分割','当你希望房产被纳入共同财产范围时，需重点证明婚后取得/共同出资/共同登记等事实。',1,'2026-03-31 17:27:26'),('target_illegal_termination_compensation','主张违法解除赔偿金','重点证明解除缺乏法定事由或程序违法，进而请求二倍赔偿。',1,'2026-04-07 19:21:32'),('target_illegal_termination_reinstatement','请求继续履行劳动合同','在违法解除情形下，优先请求恢复劳动关系并继续履行合同。',1,'2026-04-07 19:21:32'),('target_illegal_termination_revoke_decision','确认解除决定违法并撤销','确认解除决定违法，作为赔偿或恢复劳动关系前置支撑。',1,'2026-04-07 19:21:32'),('target_illegal_termination_wage_gap','主张停工期间工资损失','在解除违法且未及时恢复岗位时，主张停工待岗期间工资等损失。',1,'2026-04-07 19:21:32'),('target_labor_no_contract_double_wage','争取未签合同期间双倍工资','重点证明劳动关系成立、未签合同持续时间及工资支付事实。',1,'2026-04-07 19:21:32'),('target_labor_no_contract_open_term','请求订立无固定期限劳动合同','符合条件时请求订立无固定期限劳动合同。',1,'2026-04-07 19:21:32'),('target_labor_no_contract_sign_contract','请求补签书面劳动合同','在劳动关系持续期间，要求单位补签书面劳动合同。',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_additional_compensation','争取逾期支付加付赔偿金','针对欠薪且经催告/责令后仍不支付的情形，主张加付赔偿金。',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_full_payment','争取尽快足额支付欠薪','重点证成劳动关系、实际劳动及欠薪事实，并补强金额依据。',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_overtime','一并主张加班费','在欠薪之外，主张存在加班且未依法支付加班费。',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_termination_compensation','争取解除劳动关系并主张经济补偿','当单位长期欠薪时，考虑依法解除并主张经济补偿。',1,'2026-04-07 19:21:32'),('target_no_fault_more_share','争取无过错方获得更多份额（照顾无过错方）','当对方存在法定或重大过错且你有证据时，可主张分割时照顾无过错方权益。',1,'2026-03-31 17:27:26');
/*!40000 ALTER TABLE `rule_step2_target` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_step2_target_legal_ref`
--

DROP TABLE IF EXISTS `rule_step2_target_legal_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_step2_target_legal_ref` (
  `target_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `law_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`target_id`,`law_id`),
  KEY `idx_law_id` (`law_id`),
  CONSTRAINT `fk_step2_target_lr_law` FOREIGN KEY (`law_id`) REFERENCES `rule_law` (`id`),
  CONSTRAINT `fk_step2_target_lr_target` FOREIGN KEY (`target_id`) REFERENCES `rule_step2_target` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_step2_target_legal_ref`
--

LOCK TABLES `rule_step2_target_legal_ref` WRITE;
/*!40000 ALTER TABLE `rule_step2_target_legal_ref` DISABLE KEYS */;
INSERT INTO `rule_step2_target_legal_ref` VALUES ('target_add_betrothal_no_refund','law_jshj_5',1,'2026-04-09 21:22:06'),('target_add_betrothal_refund_full','law_1042',1,'2026-04-09 21:22:06'),('target_add_betrothal_refund_full','law_jshj_5',2,'2026-04-09 21:22:06'),('target_add_betrothal_refund_partial','law_jshj_5',1,'2026-04-09 21:22:06'),('target_add_divorce_general_custody','law_1084',1,'2026-04-09 21:22:06'),('target_add_divorce_general_judgment','law_1079',1,'2026-04-09 21:22:06'),('target_add_divorce_general_property','law_1087',1,'2026-04-09 21:22:06'),('target_add_labor_injury_disability','law_injury_37',1,'2026-04-09 21:22:06'),('target_add_labor_injury_medical','law_injury_30',1,'2026-04-09 21:22:06'),('target_add_labor_injury_recognition','law_injury_14',1,'2026-04-09 21:22:06'),('target_add_labor_overtime_holiday','law_labor_44',1,'2026-04-09 21:22:06'),('target_add_labor_overtime_restday','law_labor_44',1,'2026-04-09 21:22:06'),('target_add_labor_overtime_workday','law_contract_31',2,'2026-04-09 21:22:06'),('target_add_labor_overtime_workday','law_labor_44',1,'2026-04-09 21:22:06'),('target_add_post_divorce_agreement_enforce','law_1087',1,'2026-04-09 21:22:06'),('target_add_post_divorce_conceal_penalty','law_1092',1,'2026-04-09 21:22:06'),('target_add_post_divorce_redistribute','law_1087',1,'2026-04-09 21:22:06'),('target_add_post_divorce_redistribute','law_1092',2,'2026-04-09 21:22:06'),('target_common_property_split','law_1062',0,'2026-03-31 17:27:26'),('target_common_property_split','law_1087',0,'2026-03-31 17:27:26'),('target_common_property_split','law_jser_8',0,'2026-03-31 17:27:26'),('target_common_property_split','law_jsyi_27',0,'2026-03-31 17:27:26'),('target_illegal_termination_compensation','law_contract_39',3,'2026-04-07 19:21:32'),('target_illegal_termination_compensation','law_contract_40',4,'2026-04-07 19:21:32'),('target_illegal_termination_compensation','law_contract_41',5,'2026-04-07 19:21:32'),('target_illegal_termination_compensation','law_contract_48',1,'2026-04-07 19:21:32'),('target_illegal_termination_compensation','law_contract_87',2,'2026-04-07 19:21:32'),('target_illegal_termination_reinstatement','law_contract_48',1,'2026-04-07 19:21:32'),('target_illegal_termination_revoke_decision','law_contract_39',1,'2026-04-07 19:21:32'),('target_illegal_termination_revoke_decision','law_contract_40',2,'2026-04-07 19:21:32'),('target_illegal_termination_revoke_decision','law_contract_41',3,'2026-04-07 19:21:32'),('target_illegal_termination_revoke_decision','law_contract_48',4,'2026-04-07 19:21:32'),('target_illegal_termination_wage_gap','law_contract_48',1,'2026-04-07 19:21:32'),('target_illegal_termination_wage_gap','law_contract_87',2,'2026-04-07 19:21:32'),('target_labor_no_contract_double_wage','law_contract_10',1,'2026-04-07 19:21:32'),('target_labor_no_contract_double_wage','law_contract_82',2,'2026-04-07 19:21:32'),('target_labor_no_contract_open_term','law_contract_14',1,'2026-04-07 19:21:32'),('target_labor_no_contract_sign_contract','law_contract_10',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_additional_compensation','law_contract_85',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_additional_compensation','law_reg_16',2,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_full_payment','law_contract_30',2,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_full_payment','law_contract_85',3,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_full_payment','law_labor_50',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_full_payment','law_reg_16',4,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_overtime','law_contract_30',1,'2026-04-07 19:21:32'),('target_labor_unpaid_wages_termination_compensation','law_contract_85',1,'2026-04-07 19:21:32'),('target_no_fault_more_share','law_1087',0,'2026-03-31 17:27:26'),('target_no_fault_more_share','law_1091',0,'2026-03-31 17:27:26');
/*!40000 ALTER TABLE `rule_step2_target_legal_ref` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_user_profile`
--

DROP TABLE IF EXISTS `rule_user_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_user_profile` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nickname` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_user_profile`
--

LOCK TABLES `rule_user_profile` WRITE;
/*!40000 ALTER TABLE `rule_user_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `rule_user_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_user_session`
--

DROP TABLE IF EXISTS `rule_user_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_user_session` (
  `session_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cause_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_active_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`session_id`),
  KEY `idx_user_session` (`user_id`,`created_at`),
  KEY `idx_cause_session` (`cause_code`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_user_session`
--

LOCK TABLES `rule_user_session` WRITE;
/*!40000 ALTER TABLE `rule_user_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `rule_user_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_user_submission`
--

DROP TABLE IF EXISTS `rule_user_submission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_user_submission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `session_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cause_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `answers_json` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `judge_json` longtext COLLATE utf8mb4_unicode_ci,
  `report_markdown` longtext COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_submission` (`user_id`,`created_at`),
  KEY `idx_session_submission` (`session_id`,`created_at`),
  KEY `idx_cause_submission` (`cause_code`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rule_user_submission`
--

LOCK TABLES `rule_user_submission` WRITE;
/*!40000 ALTER TABLE `rule_user_submission` DISABLE KEYS */;
/*!40000 ALTER TABLE `rule_user_submission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'rule_engine_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-11 12:04:45
