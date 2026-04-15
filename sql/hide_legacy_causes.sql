USE rule_engine_db;
SET NAMES utf8mb4;

-- 隐藏历史案由（不在前端案由列表中展示）
-- 注意：将 enabled 设为 0 后，/api/rule/causes、/api/rule/categories、/api/rule/common-causes 都不会返回该案由；
-- 若仍有客户端/脚本使用该 causeCode，将被视为“不支持/不存在”。

UPDATE rule_cause
SET enabled = 0
WHERE cause_code IN ('betrothal_property');

