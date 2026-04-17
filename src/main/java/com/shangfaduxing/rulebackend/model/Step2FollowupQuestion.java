package com.shangfaduxing.rulebackend.model;

import java.util.List;

/**
 * Step2 证据类问题选“是”后的详细追问。
 */
public class Step2FollowupQuestion {
    private String questionId;
    private String question;
    private String answerType; // text | number | choice
    private List<String> options;
    private String legalPurpose; // 该追问的法律证明目的
    private boolean required;

    public Step2FollowupQuestion() {
    }

    public Step2FollowupQuestion(String questionId, String question, String answerType, List<String> options, String legalPurpose, boolean required) {
        this.questionId = questionId;
        this.question = question;
        this.answerType = answerType;
        this.options = options;
        this.legalPurpose = legalPurpose;
        this.required = required;
    }

    public String getQuestionId() {
        return questionId;
    }

    public void setQuestionId(String questionId) {
        this.questionId = questionId;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getAnswerType() {
        return answerType;
    }

    public void setAnswerType(String answerType) {
        this.answerType = answerType;
    }

    public List<String> getOptions() {
        return options;
    }

    public void setOptions(List<String> options) {
        this.options = options;
    }

    public String getLegalPurpose() {
        return legalPurpose;
    }

    public void setLegalPurpose(String legalPurpose) {
        this.legalPurpose = legalPurpose;
    }

    public boolean isRequired() {
        return required;
    }

    public void setRequired(boolean required) {
        this.required = required;
    }
}

