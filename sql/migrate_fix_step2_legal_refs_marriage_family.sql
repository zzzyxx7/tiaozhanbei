USE rule_engine_db;
SET NAMES utf8mb4;

-- 修复婚姻家事 Step2 目标法条错配
-- 适用场景：历史脚本已执行，导致 target 法条映射串案由

START TRANSACTION;

-- 1) 婚姻无效：不应使用离婚/财产分割法条
DELETE FROM rule_step2_target_legal_ref
WHERE target_id IN ('target_invalid_marriage_confirm', 'target_invalid_marriage_property_return');

INSERT INTO rule_step2_target_legal_ref (target_id, law_id, sort_order) VALUES
('target_invalid_marriage_confirm', 'law_1051', 1),
('target_invalid_marriage_confirm', 'law_1052', 2),
('target_invalid_marriage_confirm', 'law_1054', 3),
('target_invalid_marriage_property_return', 'law_1051', 1),
('target_invalid_marriage_property_return', 'law_1054', 2);

-- 2) 亲子确认/否认：使用亲子关系与举证妨碍法条
DELETE FROM rule_step2_target_legal_ref
WHERE target_id IN (
  'target_paternity_confirm',
  'target_paternity_confirm_evidence',
  'target_paternity_disclaimer',
  'target_paternity_disclaimer_evidence'
);

INSERT INTO rule_step2_target_legal_ref (target_id, law_id, sort_order) VALUES
('target_paternity_confirm', 'law_1073', 1),
('target_paternity_confirm', 'law_81', 2),
('target_paternity_confirm_evidence', 'law_1073', 1),
('target_paternity_confirm_evidence', 'law_81', 2),
('target_paternity_disclaimer', 'law_1073', 1),
('target_paternity_disclaimer', 'law_81', 2),
('target_paternity_disclaimer_evidence', 'law_1073', 1),
('target_paternity_disclaimer_evidence', 'law_81', 2);

-- 3) 探望权：应使用探望权法条
DELETE FROM rule_step2_target_legal_ref
WHERE target_id IN ('target_visitation_fix', 'target_visitation_evidence');

INSERT INTO rule_step2_target_legal_ref (target_id, law_id, sort_order) VALUES
('target_visitation_fix', 'law_1086', 1),
('target_visitation_evidence', 'law_1086', 1);

-- 4) 兜底：确保案由法条也包含对应核心法条（避免 step2 交集过滤后为空）
INSERT IGNORE INTO rule_cause_law (cause_code, law_id, sort_order) VALUES
('marriage_invalid_dispute', 'law_1051', 1),
('marriage_invalid_dispute', 'law_1052', 2),
('marriage_invalid_dispute', 'law_1054', 3),
('paternity_confirmation_dispute', 'law_1073', 1),
('paternity_confirmation_dispute', 'law_81', 2),
('paternity_disclaimer_dispute', 'law_1073', 1),
('paternity_disclaimer_dispute', 'law_81', 2),
('visitation_dispute', 'law_1086', 1);

COMMIT;

