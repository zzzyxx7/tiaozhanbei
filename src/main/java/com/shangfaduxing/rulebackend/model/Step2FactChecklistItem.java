package com.shangfaduxing.rulebackend.model;

/**
 * 第二步：必备事实清单项。
 */
public class Step2FactChecklistItem {
    private String fact;
    private String label;
    private String status; // "proved" | "unproved"

    public Step2FactChecklistItem() {}

    public Step2FactChecklistItem(String fact, String label, String status) {
        this.fact = fact;
        this.label = label;
        this.status = status;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}

