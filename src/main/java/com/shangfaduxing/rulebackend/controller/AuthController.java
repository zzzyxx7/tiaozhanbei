package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.AuthMeResponse;
import com.shangfaduxing.rulebackend.model.WeChatLoginRequest;
import com.shangfaduxing.rulebackend.model.WeChatLoginResponse;
import com.shangfaduxing.rulebackend.service.AuthAvatarStorageService;
import com.shangfaduxing.rulebackend.service.WechatMiniAppAuthService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/rule/auth")
public class AuthController {

    private final WechatMiniAppAuthService wechatMiniAppAuthService;
    private final AuthAvatarStorageService authAvatarStorageService;

    public AuthController(WechatMiniAppAuthService wechatMiniAppAuthService, AuthAvatarStorageService authAvatarStorageService) {
        this.wechatMiniAppAuthService = wechatMiniAppAuthService;
        this.authAvatarStorageService = authAvatarStorageService;
    }

    @PostMapping(value = "/wechat/login", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public WeChatLoginResponse wechatLogin(@RequestBody WeChatLoginRequest request) {
        if (request == null) {
            WeChatLoginResponse r = new WeChatLoginResponse();
            r.setSuccess(false);
            r.setMessage("请求体不能为空");
            return r;
        }
        return wechatMiniAppAuthService.loginByCode(request);
    }

    @PostMapping(value = "/wechat/login", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public WeChatLoginResponse wechatLoginWithAvatar(
            @RequestParam("code") String code,
            @RequestParam(value = "nickname", required = false) String nickname,
            @RequestParam(value = "avatarFile", required = false) MultipartFile avatarFile,
            HttpServletRequest request
    ) {
        WeChatLoginRequest payload = new WeChatLoginRequest();
        payload.setCode(code);
        payload.setNickname(nickname);
        if (avatarFile != null && !avatarFile.isEmpty()) {
            try {
                payload.setAvatarUrl(authAvatarStorageService.storeAvatarAndBuildUrl(avatarFile, request));
            } catch (Exception e) {
                WeChatLoginResponse r = new WeChatLoginResponse();
                r.setSuccess(false);
                r.setMessage("头像上传失败: " + e.getMessage());
                return r;
            }
        }
        return wechatMiniAppAuthService.loginByCode(payload);
    }

    @GetMapping(value = "/me", produces = MediaType.APPLICATION_JSON_VALUE)
    public AuthMeResponse me(@RequestHeader(value = "Authorization", required = false) String authorization) {
        return wechatMiniAppAuthService.me(authorization);
    }

    @GetMapping("/avatar/{filename}")
    public ResponseEntity<Resource> avatar(@PathVariable("filename") String filename) {
        try {
            Resource r = authAvatarStorageService.loadAvatar(filename);
            if (r == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok()
                    .contentType(authAvatarStorageService.detectMediaType(filename))
                    .body(r);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }
}
