package com.shangfaduxing.rulebackend.model;

import java.util.List;
import java.util.Map;

/**
 * 与小程序 utils/engine.js 的 judge() 返回结构尽量对齐：
 * success/message/facts/activatedPaths/conclusions/finalResults/lawsApplied/step2
 */
public class JudgeResponse {
    private boolean success;
    private String message;
    private String detail;

    private Map<String, Object> answers;
    private Map<String, Object> facts;

    private List<ActivatedPath> activatedPaths;
    private List<Conclusion> conclusions;
    private List<FinalResultItem> finalResults;
    private List<Law> lawsApplied;

    private Step2Meta step2;

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

    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }

    public Map<String, Object> getAnswers() {
        return answers;
    }

    public void setAnswers(Map<String, Object> answers) {
        this.answers = answers;
    }

    public Map<String, Object> getFacts() {
        return facts;
    }

    public void setFacts(Map<String, Object> facts) {
        this.facts = facts;
    }

    public List<ActivatedPath> getActivatedPaths() {
        return activatedPaths;
    }

    public void setActivatedPaths(List<ActivatedPath> activatedPaths) {
        this.activatedPaths = activatedPaths;
    }

    public List<Conclusion> getConclusions() {
        return conclusions;
    }

    public void setConclusions(List<Conclusion> conclusions) {
        this.conclusions = conclusions;
    }

    public List<FinalResultItem> getFinalResults() {
        return finalResults;
    }

    public void setFinalResults(List<FinalResultItem> finalResults) {
        this.finalResults = finalResults;
    }

    public List<Law> getLawsApplied() {
        return lawsApplied;
    }

    public void setLawsApplied(List<Law> lawsApplied) {
        this.lawsApplied = lawsApplied;
    }

    public Step2Meta getStep2() {
        return step2;
    }

    public void setStep2(Step2Meta step2) {
        this.step2 = step2;
    }
}

