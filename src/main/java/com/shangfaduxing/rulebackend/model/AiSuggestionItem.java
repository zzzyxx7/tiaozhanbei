package com.shangfaduxing.rulebackend.model;

public class AiSuggestionItem {
    private String key;
    private Object value;
    private Double confidence;
    private String reason;

    public AiSuggestionItem() {
    }

    public AiSuggestionItem(String key, Object value, Double confidence, String reason) {
        this.key = key;
        this.value = value;
        this.confidence = confidence;
        this.reason = reason;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public Object getValue() {
        return value;
    }

    public void setValue(Object value) {
        this.value = value;
    }

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}
