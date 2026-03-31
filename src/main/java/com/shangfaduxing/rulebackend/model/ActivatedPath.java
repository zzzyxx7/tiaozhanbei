package com.shangfaduxing.rulebackend.model;

import java.util.List;

public class ActivatedPath {
    private String name;
    private List<String> conditions;
    private String calc;
    private String lawRef;

    public ActivatedPath() {}

    public ActivatedPath(String name, List<String> conditions, String calc, String lawRef) {
        this.name = name;
        this.conditions = conditions;
        this.calc = calc;
        this.lawRef = lawRef;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<String> getConditions() {
        return conditions;
    }

    public void setConditions(List<String> conditions) {
        this.conditions = conditions;
    }

    public String getCalc() {
        return calc;
    }

    public void setCalc(String calc) {
        this.calc = calc;
    }

    public String getLawRef() {
        return lawRef;
    }

    public void setLawRef(String lawRef) {
        this.lawRef = lawRef;
    }
}

