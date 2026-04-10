package com.shangfaduxing.rulebackend.model;

import java.util.List;
import java.util.Map;

public class AiPrefillRequest {
    private String causeCode;
    private String userText;
    private Map<String, Object> existingAnswers;
    private String provider;
    private List<String> targetKeys;

    public String getCauseCode() {
        return causeCode;
    }

    public void setCauseCode(String causeCode) {
        this.causeCode = causeCode;
    }

    public String getUserText() {
        return userText;
    }

    public void setUserText(String userText) {
        this.userText = userText;
    }

    public Map<String, Object> getExistingAnswers() {
        return existingAnswers;
    }

    public void setExistingAnswers(Map<String, Object> existingAnswers) {
        this.existingAnswers = existingAnswers;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public List<String> getTargetKeys() {
        return targetKeys;
    }

    public void setTargetKeys(List<String> targetKeys) {
        this.targetKeys = targetKeys;
    }
}
