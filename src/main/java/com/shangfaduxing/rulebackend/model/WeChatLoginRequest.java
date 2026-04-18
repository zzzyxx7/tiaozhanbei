package com.shangfaduxing.rulebackend.model;

/**
 * 小程序 wx.login 取得的临时登录凭证。
 */
public class WeChatLoginRequest {

    private String code;
    /** 小程序昵称填写等组件得到的昵称，可选 */
    private String nickname;
    /** 小程序头像临时路径或 CDN URL，可选 */
    private String avatarUrl;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }
}
