package com.shangfaduxing.rulebackend.model;

import java.util.Map;

public class PrefillWizardRequest {
    private String causeCode;
    private String exampleText;
    private String provider; // deepseek/openai，可不传
    private Map<String, Object> existingAnswers;
    private Integer stage1Size; // 默认 5
    private Integer stage2Size; // 默认 3

    public String getCauseCode() {
        return causeCode;
    }

    public void setCauseCode(String causeCode) {
        this.causeCode = causeCode;
    }

    public String getExampleText() {
        return exampleText;
    }

    public void setExampleText(String exampleText) {
        this.exampleText = exampleText;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public Map<String, Object> getExistingAnswers() {
        return existingAnswers;
    }

    public void setExistingAnswers(Map<String, Object> existingAnswers) {
        this.existingAnswers = existingAnswers;
    }

    public Integer getStage1Size() {
        return stage1Size;
    }

    public void setStage1Size(Integer stage1Size) {
        this.stage1Size = stage1Size;
    }

    public Integer getStage2Size() {
        return stage2Size;
    }

    public void setStage2Size(Integer stage2Size) {
        this.stage2Size = stage2Size;
    }
}

