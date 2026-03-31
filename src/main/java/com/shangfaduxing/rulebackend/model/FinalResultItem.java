package com.shangfaduxing.rulebackend.model;

public class FinalResultItem {
    private String item;
    private String result;
    private String detail;

    public FinalResultItem() {}

    public FinalResultItem(String item, String result, String detail) {
        this.item = item;
        this.result = result;
        this.detail = detail;
    }

    public String getItem() {
        return item;
    }

    public void setItem(String item) {
        this.item = item;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }
}

