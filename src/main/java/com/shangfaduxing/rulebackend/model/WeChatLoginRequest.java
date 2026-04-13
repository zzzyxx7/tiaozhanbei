package com.shangfaduxing.rulebackend.model;

/**
 * 小程序 wx.login 取得的临时登录凭证。
 */
public class WeChatLoginRequest {

    private String code;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }
}
