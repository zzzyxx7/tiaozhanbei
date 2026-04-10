package com.shangfaduxing.rulebackend.model;

public class UserJudgeSaveResponse {
    private boolean success;
    private String sessionId;
    private Long submissionId;
    private JudgeResponse judge;
    private String reportMarkdown;
    private String message;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public Long getSubmissionId() {
        return submissionId;
    }

    public void setSubmissionId(Long submissionId) {
        this.submissionId = submissionId;
    }

    public JudgeResponse getJudge() {
        return judge;
    }

    public void setJudge(JudgeResponse judge) {
        this.judge = judge;
    }

    public String getReportMarkdown() {
        return reportMarkdown;
    }

    public void setReportMarkdown(String reportMarkdown) {
        this.reportMarkdown = reportMarkdown;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
