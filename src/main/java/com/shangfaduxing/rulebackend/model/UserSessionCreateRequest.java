package com.shangfaduxing.rulebackend.model;

public class UserSessionCreateRequest {
    private String userId;
    private String causeCode;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getCauseCode() {
        return causeCode;
    }

    public void setCauseCode(String causeCode) {
        this.causeCode = causeCode;
    }
}
