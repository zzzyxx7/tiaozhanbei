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
    // 完整版增强字段（向后兼容，前端可按需使用）
    private Integer totalFactCount;
    private Integer provedFactCount;
    private Integer unprovedFactCount;
    private Double proveRate;
    private List<Step2ActionItem> actionPlan;
    private List<String> riskWarnings;
    private List<String> handlingPath;

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

    public Integer getTotalFactCount() {
        return totalFactCount;
    }

    public void setTotalFactCount(Integer totalFactCount) {
        this.totalFactCount = totalFactCount;
    }

    public Integer getProvedFactCount() {
        return provedFactCount;
    }

    public void setProvedFactCount(Integer provedFactCount) {
        this.provedFactCount = provedFactCount;
    }

    public Integer getUnprovedFactCount() {
        return unprovedFactCount;
    }

    public void setUnprovedFactCount(Integer unprovedFactCount) {
        this.unprovedFactCount = unprovedFactCount;
    }

    public Double getProveRate() {
        return proveRate;
    }

    public void setProveRate(Double proveRate) {
        this.proveRate = proveRate;
    }

    public List<Step2ActionItem> getActionPlan() {
        return actionPlan;
    }

    public void setActionPlan(List<Step2ActionItem> actionPlan) {
        this.actionPlan = actionPlan;
    }

    public List<String> getRiskWarnings() {
        return riskWarnings;
    }

    public void setRiskWarnings(List<String> riskWarnings) {
        this.riskWarnings = riskWarnings;
    }

    public List<String> getHandlingPath() {
        return handlingPath;
    }

    public void setHandlingPath(List<String> handlingPath) {
        this.handlingPath = handlingPath;
    }
}

