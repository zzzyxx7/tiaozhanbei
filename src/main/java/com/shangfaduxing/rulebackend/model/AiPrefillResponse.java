package com.shangfaduxing.rulebackend.model;

import java.util.List;
import java.util.Map;

public class AiPrefillResponse {
    private boolean success;
    private String message;
    private String provider;
    private boolean fallback;
    private List<AiSuggestionItem> suggestions;
    private Map<String, Object> mergedAnswers;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public boolean isFallback() {
        return fallback;
    }

    public void setFallback(boolean fallback) {
        this.fallback = fallback;
    }

    public List<AiSuggestionItem> getSuggestions() {
        return suggestions;
    }

    public void setSuggestions(List<AiSuggestionItem> suggestions) {
        this.suggestions = suggestions;
    }

    public Map<String, Object> getMergedAnswers() {
        return mergedAnswers;
    }

    public void setMergedAnswers(Map<String, Object> mergedAnswers) {
        this.mergedAnswers = mergedAnswers;
    }
}
