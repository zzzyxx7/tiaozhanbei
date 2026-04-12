-- 与 rule_question_group.fk_group_questionnaire 对齐，避免导入 dump 时报
-- ERROR 3780: Referencing column ... and referenced column ... are incompatible.
-- 在「本机」执行一次后再 mysqldump，或在线上已导入失败、需手工修表时执行。
ALTER TABLE rule_questionnaire CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
