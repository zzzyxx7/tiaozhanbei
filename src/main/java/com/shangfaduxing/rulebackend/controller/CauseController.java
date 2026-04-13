package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.CauseCategory;
import com.shangfaduxing.rulebackend.service.RuleCenterService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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

    /**
     * 按前端首页“大类卡片”分组的案由树。
     * 兼容：保留 /causes 扁平列表，新增 /categories 供新前端使用。
     */
    @GetMapping("/categories")
    public List<CauseCategory> categories() {
        return ruleCenterService.categories();
    }

    @GetMapping("/categories/{categoryCode}")
    public CauseCategory category(@PathVariable("categoryCode") String categoryCode) {
        return ruleCenterService.category(categoryCode);
    }
}

