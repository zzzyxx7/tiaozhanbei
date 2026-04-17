package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.AuthMeResponse;
import com.shangfaduxing.rulebackend.model.WeChatLoginRequest;
import com.shangfaduxing.rulebackend.model.WeChatLoginResponse;
import com.shangfaduxing.rulebackend.service.WechatMiniAppAuthService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rule/auth")
public class AuthController {

    private final WechatMiniAppAuthService wechatMiniAppAuthService;

    public AuthController(WechatMiniAppAuthService wechatMiniAppAuthService) {
        this.wechatMiniAppAuthService = wechatMiniAppAuthService;
    }

    @PostMapping(value = "/wechat/login", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public WeChatLoginResponse wechatLogin(@RequestBody WeChatLoginRequest request) {
        if (request == null) {
            WeChatLoginResponse r = new WeChatLoginResponse();
            r.setSuccess(false);
            r.setMessage("请求体不能为空");
            return r;
        }
        return wechatMiniAppAuthService.loginByCode(request.getCode());
    }

    @GetMapping(value = "/me", produces = MediaType.APPLICATION_JSON_VALUE)
    public AuthMeResponse me(@RequestHeader(value = "Authorization", required = false) String authorization) {
        return wechatMiniAppAuthService.me(authorization);
    }
}
