package com.shangfaduxing.rulebackend.model;

import java.util.List;
import java.util.Map;

public class PrefillWizardResponse {
    private boolean success;
    private String message;
    private String causeCode;
    private boolean fallback;
    private String provider;
    private Map<String, Object> mergedAnswers;
    private List<AiSuggestionItem> suggestions;
    private List<String> stage1Keys;
    private List<String> stage2Keys;
    private List<Map<String, Object>> stage1QuestionGroups;
    private List<Map<String, Object>> stage2QuestionGroups;

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

    public String getCauseCode() {
        return causeCode;
    }

    public void setCauseCode(String causeCode) {
        this.causeCode = causeCode;
    }

    public boolean isFallback() {
        return fallback;
    }

    public void setFallback(boolean fallback) {
        this.fallback = fallback;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public Map<String, Object> getMergedAnswers() {
        return mergedAnswers;
    }

    public void setMergedAnswers(Map<String, Object> mergedAnswers) {
        this.mergedAnswers = mergedAnswers;
    }

    public List<AiSuggestionItem> getSuggestions() {
        return suggestions;
    }

    public void setSuggestions(List<AiSuggestionItem> suggestions) {
        this.suggestions = suggestions;
    }

    public List<String> getStage1Keys() {
        return stage1Keys;
    }

    public void setStage1Keys(List<String> stage1Keys) {
        this.stage1Keys = stage1Keys;
    }

    public List<String> getStage2Keys() {
        return stage2Keys;
    }

    public void setStage2Keys(List<String> stage2Keys) {
        this.stage2Keys = stage2Keys;
    }

    public List<Map<String, Object>> getStage1QuestionGroups() {
        return stage1QuestionGroups;
    }

    public void setStage1QuestionGroups(List<Map<String, Object>> stage1QuestionGroups) {
        this.stage1QuestionGroups = stage1QuestionGroups;
    }

    public List<Map<String, Object>> getStage2QuestionGroups() {
        return stage2QuestionGroups;
    }

    public void setStage2QuestionGroups(List<Map<String, Object>> stage2QuestionGroups) {
        this.stage2QuestionGroups = stage2QuestionGroups;
    }
}

