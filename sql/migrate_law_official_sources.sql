USE rule_engine_db;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS rule_law_source (
  law_id VARCHAR(64) PRIMARY KEY,
  source_name VARCHAR(255) NOT NULL,
  source_url VARCHAR(1000) NOT NULL,
  note VARCHAR(500) NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

REPLACE INTO rule_law_source (law_id, source_name, source_url, note) VALUES
('law_1042', '中华人民共和国民法典（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准'),
('law_jshj_5', '婚姻家庭编司法解释（最高法）', 'https://www.court.gov.cn/', '请核对最新司法解释版本'),
('law_1079', '中华人民共和国民法典（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准'),
('law_1084', '中华人民共和国民法典（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准'),
('law_1087', '中华人民共和国民法典（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准'),
('law_1092', '中华人民共和国民法典（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准'),
('law_injury_14', '工伤保险条例（中国政府网）', 'https://www.gov.cn/', '请以最新条例版本条文为准'),
('law_injury_30', '工伤保险条例（中国政府网）', 'https://www.gov.cn/', '请以最新条例版本条文为准'),
('law_injury_33', '工伤保险条例（中国政府网）', 'https://www.gov.cn/', '请以最新条例版本条文为准'),
('law_injury_37', '工伤保险条例（中国政府网）', 'https://www.gov.cn/', '请以最新条例版本条文为准'),
('law_labor_44', '中华人民共和国劳动法（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准'),
('law_contract_30', '中华人民共和国劳动合同法（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准'),
('law_contract_31', '中华人民共和国劳动合同法（全国人大网）', 'https://www.npc.gov.cn/', '请以最新公布版本条文为准');
