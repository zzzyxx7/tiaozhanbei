package com.shangfaduxing.rulebackend.model;

import java.util.List;

/**
 * 第二步：证据类型的“怎么证成/如何获取”指引。
 */
public class Step2EvidenceHowToItem {
    private String evidenceType;
    private List<String> howTo;

    public Step2EvidenceHowToItem() {
    }

    public Step2EvidenceHowToItem(String evidenceType, List<String> howTo) {
        this.evidenceType = evidenceType;
        this.howTo = howTo;
    }

    public String getEvidenceType() {
        return evidenceType;
    }

    public void setEvidenceType(String evidenceType) {
        this.evidenceType = evidenceType;
    }

    public List<String> getHowTo() {
        return howTo;
    }

    public void setHowTo(List<String> howTo) {
        this.howTo = howTo;
    }
}

