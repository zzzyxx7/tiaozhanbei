-- 微信小程序登录：为 rule_user_profile 增加微信标识（与 user_id 并存，user_id 仍为主业务键）
USE rule_engine_db;
SET NAMES utf8mb4;

ALTER TABLE rule_user_profile
  ADD COLUMN wx_app_id VARCHAR(32) NULL COMMENT '小程序 AppID' AFTER user_id,
  ADD COLUMN wx_openid VARCHAR(64) NULL COMMENT '微信 openid' AFTER wx_app_id,
  ADD COLUMN wx_unionid VARCHAR(64) NULL COMMENT '微信 unionid（可选）' AFTER wx_openid;

-- 同一小程序下 openid 唯一
ALTER TABLE rule_user_profile
  ADD UNIQUE KEY uk_wx_app_openid (wx_app_id, wx_openid);
