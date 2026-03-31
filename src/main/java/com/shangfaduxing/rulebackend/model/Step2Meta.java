package com.shangfaduxing.rulebackend.model;

import java.util.List;

public class Step2Meta {
    private List<Step2TargetMeta> targets;
    private List<String> suggestedTargetIds;

    public Step2Meta() {}

    public Step2Meta(List<Step2TargetMeta> targets, List<String> suggestedTargetIds) {
        this.targets = targets;
        this.suggestedTargetIds = suggestedTargetIds;
    }

    public List<Step2TargetMeta> getTargets() {
        return targets;
    }

    public void setTargets(List<Step2TargetMeta> targets) {
        this.targets = targets;
    }

    public List<String> getSuggestedTargetIds() {
        return suggestedTargetIds;
    }

    public void setSuggestedTargetIds(List<String> suggestedTargetIds) {
        this.suggestedTargetIds = suggestedTargetIds;
    }
}

