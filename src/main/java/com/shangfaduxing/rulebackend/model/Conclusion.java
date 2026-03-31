package com.shangfaduxing.rulebackend.model;

import java.util.List;

public class Conclusion {
    private String type;
    private String result;
    private String reason;
    private List<String> lawRefs;
    private String level;

    public Conclusion() {}

    public Conclusion(String type, String result, String reason, List<String> lawRefs, String level) {
        this.type = type;
        this.result = result;
        this.reason = reason;
        this.lawRefs = lawRefs;
        this.level = level;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public List<String> getLawRefs() {
        return lawRefs;
    }

    public void setLawRefs(List<String> lawRefs) {
        this.lawRefs = lawRefs;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }
}

