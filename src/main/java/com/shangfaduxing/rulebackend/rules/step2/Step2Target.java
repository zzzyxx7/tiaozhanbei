package com.shangfaduxing.rulebackend.rules.step2;

import java.util.List;
import java.util.Map;

public class Step2Target {
    private final String targetId;
    private final String title;
    private final String desc;
    private final List<String> legalRefs;
    private final List<RequiredFact> requiredFacts;
    private final Map<String, List<String>> evidenceMap;

    public Step2Target(String targetId,
                       String title,
                       String desc,
                       List<String> legalRefs,
                       List<RequiredFact> requiredFacts,
                       Map<String, List<String>> evidenceMap) {
        this.targetId = targetId;
        this.title = title;
        this.desc = desc;
        this.legalRefs = legalRefs;
        this.requiredFacts = requiredFacts;
        this.evidenceMap = evidenceMap;
    }

    public String getTargetId() {
        return targetId;
    }

    public String getTitle() {
        return title;
    }

    public String getDesc() {
        return desc;
    }

    public List<String> getLegalRefs() {
        return legalRefs;
    }

    public List<RequiredFact> getRequiredFacts() {
        return requiredFacts;
    }

    public Map<String, List<String>> getEvidenceMap() {
        return evidenceMap;
    }

    public static class RequiredFact {
        private final String key;
        private final String label;

        public RequiredFact(String key, String label) {
            this.key = key;
            this.label = label;
        }

        public String getKey() {
            return key;
        }

        public String getLabel() {
            return label;
        }
    }
}

