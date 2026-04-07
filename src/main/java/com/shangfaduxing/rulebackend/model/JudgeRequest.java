package com.shangfaduxing.rulebackend.model;

import java.util.Map;

/**
 * 小程序传入的 answers 结构（key-value）。
 */
public class JudgeRequest {
    private String causeCode;
    private Map<String, Object> answers;

    public String getCauseCode() {
        return causeCode;
    }

    public void setCauseCode(String causeCode) {
        this.causeCode = causeCode;
    }

    public Map<String, Object> getAnswers() {
        return answers;
    }

    public void setAnswers(Map<String, Object> answers) {
        this.answers = answers;
    }
}

