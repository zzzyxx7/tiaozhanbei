package com.shangfaduxing.rulebackend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "rule.auth.jwt")
public class RuleAuthJwtProperties {

    /**
     * HS256 密钥，建议至少 32 字节随机串；通过环境变量注入。
     */
    private String secret = "";

    /**
     * Access Token 有效期（秒），默认 7 天。
     */
    private long expireSeconds = 604800L;

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret == null ? "" : secret;
    }

    public long getExpireSeconds() {
        return expireSeconds;
    }

    public void setExpireSeconds(long expireSeconds) {
        this.expireSeconds = expireSeconds;
    }

    public boolean isConfigured() {
        return secret != null && secret.length() >= 32;
    }
}
