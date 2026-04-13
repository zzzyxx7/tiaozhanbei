package com.shangfaduxing.rulebackend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "rule.wechat.miniapp")
public class RuleWeChatProperties {

    /**
     * 与小程序 project.config.json 中 appid 一致；可公开。
     */
    private String appId = "";

    /**
     * 仅服务端保存，勿提交仓库。
     */
    private String secret = "";

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId == null ? "" : appId;
    }

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret == null ? "" : secret;
    }

    public boolean isConfigured() {
        return !appId.isBlank() && !secret.isBlank();
    }
}
