-- 用户资料：头像 URL（小程序昵称头像填写组件等返回的临时链接）
USE rule_engine_db;
SET NAMES utf8mb4;

ALTER TABLE rule_user_profile
  ADD COLUMN avatar_url VARCHAR(1024) NULL COMMENT '头像 URL' AFTER nickname;
