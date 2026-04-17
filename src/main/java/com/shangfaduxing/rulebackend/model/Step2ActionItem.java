package com.shangfaduxing.rulebackend.model;

import java.util.List;

/**
 * Step2 完整版：每个未证成要件的行动建议。
 */
public class Step2ActionItem {
    private String fact;
    private String label;
    private String priority; // high | medium | low
    private String provingGoal;
    private List<String> evidenceTypes;
    private List<String> actions;

    public Step2ActionItem() {
    }

    public Step2ActionItem(String fact, String label, String priority, String provingGoal, List<String> evidenceTypes, List<String> actions) {
        this.fact = fact;
        this.label = label;
        this.priority = priority;
        this.provingGoal = provingGoal;
        this.evidenceTypes = evidenceTypes;
        this.actions = actions;
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

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getProvingGoal() {
        return provingGoal;
    }

    public void setProvingGoal(String provingGoal) {
        this.provingGoal = provingGoal;
    }

    public List<String> getEvidenceTypes() {
        return evidenceTypes;
    }

    public void setEvidenceTypes(List<String> evidenceTypes) {
        this.evidenceTypes = evidenceTypes;
    }

    public List<String> getActions() {
        return actions;
    }

    public void setActions(List<String> actions) {
        this.actions = actions;
    }
}

