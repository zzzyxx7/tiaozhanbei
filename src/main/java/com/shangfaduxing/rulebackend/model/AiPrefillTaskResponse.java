package com.shangfaduxing.rulebackend.model;

public class AiPrefillTaskResponse {
    private boolean success;
    private String message;
    private String taskId;
    private String status; // queued | running | success | failed
    private AiPrefillResponse result;

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

    public String getTaskId() {
        return taskId;
    }

    public void setTaskId(String taskId) {
        this.taskId = taskId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public AiPrefillResponse getResult() {
        return result;
    }

    public void setResult(AiPrefillResponse result) {
        this.result = result;
    }
}

