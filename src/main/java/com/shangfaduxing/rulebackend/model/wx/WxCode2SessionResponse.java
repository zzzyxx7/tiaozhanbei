package com.shangfaduxing.rulebackend.model.wx;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 微信 <a href="https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/user-login/code2Session.html">code2Session</a> 响应（仅服务端解析）。
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class WxCode2SessionResponse {

    @JsonProperty("errcode")
    private Integer errcode;

    @JsonProperty("errmsg")
    private String errmsg;

    @JsonProperty("openid")
    private String openid;

    @JsonProperty("session_key")
    private String sessionKey;

    @JsonProperty("unionid")
    private String unionid;

    public Integer getErrcode() {
        return errcode;
    }

    public void setErrcode(Integer errcode) {
        this.errcode = errcode;
    }

    public String getErrmsg() {
        return errmsg;
    }

    public void setErrmsg(String errmsg) {
        this.errmsg = errmsg;
    }

    public String getOpenid() {
        return openid;
    }

    public void setOpenid(String openid) {
        this.openid = openid;
    }

    public String getSessionKey() {
        return sessionKey;
    }

    public void setSessionKey(String sessionKey) {
        this.sessionKey = sessionKey;
    }

    public String getUnionid() {
        return unionid;
    }

    public void setUnionid(String unionid) {
        this.unionid = unionid;
    }

    public boolean isError() {
        return errcode != null && errcode != 0;
    }
}
