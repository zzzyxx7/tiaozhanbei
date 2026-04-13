package com.shangfaduxing.rulebackend.model;

import java.util.List;

public class CauseCategory {
    private String categoryCode;
    private String categoryName;
    private List<CauseItem> causes;

    public CauseCategory() {
    }

    public CauseCategory(String categoryCode, String categoryName, List<CauseItem> causes) {
        this.categoryCode = categoryCode;
        this.categoryName = categoryName;
        this.causes = causes;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public List<CauseItem> getCauses() {
        return causes;
    }

    public void setCauses(List<CauseItem> causes) {
        this.causes = causes;
    }
}

