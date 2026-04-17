package com.shangfaduxing.rulebackend.model;

import java.util.List;

/**
 * 第二步：证据清单项。
 */
public class Step2EvidenceChecklistItem {
    private String fact;
    private String label;
    private List<String> evidenceTypes;
    private List<Step2EvidenceHowToItem> evidenceHowTo;
    private List<Step2FollowupQuestion> followupQuestions;

    private boolean otherOption; // 是否包含“其他可证明材料”

    public Step2EvidenceChecklistItem() {}

    public Step2EvidenceChecklistItem(
            String fact,
            String label,
            List<String> evidenceTypes,
            List<Step2EvidenceHowToItem> evidenceHowTo,
            List<Step2FollowupQuestion> followupQuestions,
            boolean otherOption
    ) {
        this.fact = fact;
        this.label = label;
        this.evidenceTypes = evidenceTypes;
        this.evidenceHowTo = evidenceHowTo;
        this.followupQuestions = followupQuestions;
        this.otherOption = otherOption;
    }

    public String getFact() {
        return fact;
    }

    public void setFact(String fact) {
        this.fact = fact;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public List<String> getEvidenceTypes() {
        return evidenceTypes;
    }

    public void setEvidenceTypes(List<String> evidenceTypes) {
        this.evidenceTypes = evidenceTypes;
    }

    public List<Step2EvidenceHowToItem> getEvidenceHowTo() {
        return evidenceHowTo;
    }

    public void setEvidenceHowTo(List<Step2EvidenceHowToItem> evidenceHowTo) {
        this.evidenceHowTo = evidenceHowTo;
    }

    public List<Step2FollowupQuestion> getFollowupQuestions() {
        return followupQuestions;
    }

    public void setFollowupQuestions(List<Step2FollowupQuestion> followupQuestions) {
        this.followupQuestions = followupQuestions;
    }

    public boolean isOtherOption() {
        return otherOption;
    }

    public void setOtherOption(boolean otherOption) {
        this.otherOption = otherOption;
    }
}

