package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.AuthMeResponse;
import com.shangfaduxing.rulebackend.model.WeChatLoginRequest;
import com.shangfaduxing.rulebackend.model.WeChatLoginResponse;
import com.shangfaduxing.rulebackend.service.WechatMiniAppAuthService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rule/auth")
public class AuthController {

    private final WechatMiniAppAuthService wechatMiniAppAuthService;

    public AuthController(WechatMiniAppAuthService wechatMiniAppAuthService) {
        this.wechatMiniAppAuthService = wechatMiniAppAuthService;
    }

    /**
     * 小程序：wx.login 取得 code 后调用本接口，换取业务 userId 与 JWT。
     */
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

    /**
     * 校验 Bearer Token 并返回当前用户资料（可选，用于调试或「我的」页）。
     */
    @GetMapping(value = "/me", produces = MediaType.APPLICATION_JSON_VALUE)
    public AuthMeResponse me(@RequestHeader(value = "Authorization", required = false) String authorization) {
        return wechatMiniAppAuthService.me(authorization);
    }
}
