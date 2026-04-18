package com.shangfaduxing.rulebackend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "rule.auth.avatar")
public class RuleAuthAvatarProperties {

    /**
     * 头像文件本地保存目录。
     */
    private String storageDir = "./uploads/avatars";

    /**
     * 可选：头像公网访问前缀，如 https://api.example.com/api/rule/auth/avatar
     */
    private String publicBaseUrl = "";

    /**
     * 头像最大大小（MB）。
     */
    private int maxSizeMb = 5;

    public String getStorageDir() {
        return storageDir;
    }

    public void setStorageDir(String storageDir) {
        this.storageDir = storageDir == null ? "./uploads/avatars" : storageDir;
    }

    public String getPublicBaseUrl() {
        return publicBaseUrl;
    }

    public void setPublicBaseUrl(String publicBaseUrl) {
        this.publicBaseUrl = publicBaseUrl == null ? "" : publicBaseUrl;
    }

    public int getMaxSizeMb() {
        return maxSizeMb;
    }

    public void setMaxSizeMb(int maxSizeMb) {
        this.maxSizeMb = Math.max(maxSizeMb, 1);
    }
}
