package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.JudgeRequest;
import com.shangfaduxing.rulebackend.model.JudgeResponse;
import com.shangfaduxing.rulebackend.model.Step2PlanRequest;
import com.shangfaduxing.rulebackend.model.Step2PlanResponse;
import com.shangfaduxing.rulebackend.service.RuleCenterService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 裁判推理接口（第一步 + 第二步占位）
 *
 * 说明：
 * 当前只是骨架实现，返回一个固定的占位结果，方便你先把
 * 小程序和后端的 HTTP 通路打通。后续可以逐步把
 * shangfaduxing/utils/engine.js 中的规则迁移到这里的 service 层。
 */
@RestController
@RequestMapping("/api/rule")
public class RuleController {

    private final RuleCenterService ruleCenterService;

    public RuleController(RuleCenterService ruleCenterService) {
        this.ruleCenterService = ruleCenterService;
    }

    @PostMapping(value = "/judge", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public JudgeResponse judge(@RequestBody JudgeRequest request) {
        return ruleCenterService.judge(request.getCauseCode(), request.getAnswers());
    }

    @PostMapping(value = "/step2", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public Step2PlanResponse step2(@RequestBody Step2PlanRequest request) {
        return ruleCenterService.step2(request.getCauseCode(), request.getAnswers(), request.getTargetId());
    }
}

