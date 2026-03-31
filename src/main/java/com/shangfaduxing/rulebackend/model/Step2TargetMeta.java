package com.shangfaduxing.rulebackend.model;

public class Step2TargetMeta {
    private String targetId;
    private String title;
    private String desc;

    public Step2TargetMeta() {}

    public Step2TargetMeta(String targetId, String title, String desc) {
        this.targetId = targetId;
        this.title = title;
        this.desc = desc;
    }

    public String getTargetId() {
        return targetId;
    }

    public void setTargetId(String targetId) {
        this.targetId = targetId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }
}

