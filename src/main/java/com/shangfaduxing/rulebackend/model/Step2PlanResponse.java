package com.shangfaduxing.rulebackend.model;

import java.util.List;

/**
 * /api/rule/step2 返回：
 * - 法条依据
 * - 必备事实证成清单（proved/unproved）
 * - 未证成事实的证据类型清单
 */
public class Step2PlanResponse {
    private boolean success;
    private String message;
    private String targetId;
    private String targetTitle;
    private String targetDesc;

    private List<Law> legalBasis;
    private List<Step2FactChecklistItem> factChecklist;
    private List<Step2EvidenceChecklistItem> evidenceChecklist;

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

    public String getTargetId() {
        return targetId;
    }

    public void setTargetId(String targetId) {
        this.targetId = targetId;
    }

    public String getTargetTitle() {
        return targetTitle;
    }

    public void setTargetTitle(String targetTitle) {
        this.targetTitle = targetTitle;
    }

    public String getTargetDesc() {
        return targetDesc;
    }

    public void setTargetDesc(String targetDesc) {
        this.targetDesc = targetDesc;
    }

    public List<Law> getLegalBasis() {
        return legalBasis;
    }

    public void setLegalBasis(List<Law> legalBasis) {
        this.legalBasis = legalBasis;
    }

    public List<Step2FactChecklistItem> getFactChecklist() {
        return factChecklist;
    }

    public void setFactChecklist(List<Step2FactChecklistItem> factChecklist) {
        this.factChecklist = factChecklist;
    }

    public List<Step2EvidenceChecklistItem> getEvidenceChecklist() {
        return evidenceChecklist;
    }

    public void setEvidenceChecklist(List<Step2EvidenceChecklistItem> evidenceChecklist) {
        this.evidenceChecklist = evidenceChecklist;
    }
}

