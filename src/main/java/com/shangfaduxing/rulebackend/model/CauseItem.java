package com.shangfaduxing.rulebackend.model;

public class CauseItem {
    private String causeCode;
    private String causeName;
    private String questionnaireId;

    public CauseItem() {
    }

    public CauseItem(String causeCode, String causeName, String questionnaireId) {
        this.causeCode = causeCode;
        this.causeName = causeName;
        this.questionnaireId = questionnaireId;
    }

    public String getCauseCode() {
        return causeCode;
    }

    public void setCauseCode(String causeCode) {
        this.causeCode = causeCode;
    }

    public String getCauseName() {
        return causeName;
    }

    public void setCauseName(String causeName) {
        this.causeName = causeName;
    }

    public String getQuestionnaireId() {
        return questionnaireId;
    }

    public void setQuestionnaireId(String questionnaireId) {
        this.questionnaireId = questionnaireId;
    }
}

