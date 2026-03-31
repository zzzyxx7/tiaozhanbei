package com.shangfaduxing.rulebackend.model;

public class Law {
    private String id;
    private String name;
    private String article;
    private String summary;
    private String text;
    private String effectDate;

    public Law() {}

    public Law(String id, String name, String article, String summary, String text, String effectDate) {
        this.id = id;
        this.name = name;
        this.article = article;
        this.summary = summary;
        this.text = text;
        this.effectDate = effectDate;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getArticle() {
        return article;
    }

    public void setArticle(String article) {
        this.article = article;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getEffectDate() {
        return effectDate;
    }

    public void setEffectDate(String effectDate) {
        this.effectDate = effectDate;
    }
}

