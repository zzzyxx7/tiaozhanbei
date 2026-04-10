USE rule_engine_db;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS rule_case_library (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  cause_code VARCHAR(64) NOT NULL,
  case_no VARCHAR(128) NULL,
  title VARCHAR(255) NOT NULL,
  court VARCHAR(255) NULL,
  judgment_date DATE NULL,
  keywords VARCHAR(500) NULL,
  summary TEXT NULL,
  source_url VARCHAR(500) NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_case_cause_date (cause_code, judgment_date),
  KEY idx_case_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELETE FROM rule_case_library
WHERE cause_code IN ('divorce_property', 'labor_unpaid_wages', 'labor_no_contract', 'labor_illegal_termination');

INSERT INTO rule_case_library (cause_code, case_no, title, court, judgment_date, keywords, summary, source_url, enabled) VALUES
('labor_unpaid_wages', '(2023)京0105民初12345号', '拖欠工资及加班费争议案', '北京市朝阳区人民法院', '2023-10-20', '拖欠工资,加班费,考勤记录', '法院认定劳动关系成立且存在欠薪与加班事实，支持工资及部分加班费请求。', 'https://example.com/case/labor-unpaid-1', 1),
('labor_no_contract', '(2022)沪0104民初54321号', '未签劳动合同双倍工资案', '上海市徐汇区人民法院', '2022-06-18', '未签合同,双倍工资,劳动关系', '劳动者入职超过一个月未签书面合同，法院支持法定区间内双倍工资请求。', 'https://example.com/case/labor-nocontract-1', 1),
('labor_illegal_termination', '(2024)粤0305民初88888号', '违法解除劳动关系赔偿案', '深圳市南山区人民法院', '2024-03-12', '违法解除,赔偿金,工会程序', '单位未履行法定程序且解除理由证据不足，法院认定违法解除并支持赔偿。', 'https://example.com/case/labor-termination-1', 1),
('divorce_property', '(2021)浙0106民初66666号', '离婚房产分割及补偿案', '杭州市西湖区人民法院', '2021-12-09', '离婚,房产分割,共同还贷', '法院结合婚后共同还贷与照顾子女原则，确定房屋归属并判令折价补偿。', 'https://example.com/case/divorce-property-1', 1);
