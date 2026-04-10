package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.service.RuleCenterService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/rule")
public class CauseController {

    private final RuleCenterService ruleCenterService;

    public CauseController(RuleCenterService ruleCenterService) {
        this.ruleCenterService = ruleCenterService;
    }

    @GetMapping("/causes")
    public List<Map<String, Object>> causes() {
        return ruleCenterService.causes();
    }
}

