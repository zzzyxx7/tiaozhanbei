package com.shangfaduxing.rulebackend.model;

import java.util.Map;

/**
 * /api/rule/step2 请求体：小程序传 answers + 目标 targetId。
 */
public class Step2PlanRequest {
    private Map<String, Object> answers;
    private String targetId;

    public Map<String, Object> getAnswers() {
        return answers;
    }

    public void setAnswers(Map<String, Object> answers) {
        this.answers = answers;
    }

    public String getTargetId() {
        return targetId;
    }

    public void setTargetId(String targetId) {
        this.targetId = targetId;
    }
}

