package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shangfaduxing.rulebackend.config.RuleAuthJwtProperties;
import com.shangfaduxing.rulebackend.config.RuleWeChatProperties;
import com.shangfaduxing.rulebackend.model.AuthMeResponse;
import com.shangfaduxing.rulebackend.model.WeChatLoginResponse;
import com.shangfaduxing.rulebackend.model.wx.WxCode2SessionResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import java.util.UUID;

@Service
public class WechatMiniAppAuthService {

    private static final String CODE2SESSION = "https://api.weixin.qq.com/sns/jscode2session";

    private final RuleWeChatProperties weChatProps;
    private final RuleAuthJwtProperties jwtProps;
    private final JwtTokenService jwtTokenService;
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(8))
            .build();

    public WechatMiniAppAuthService(
            RuleWeChatProperties weChatProps,
            RuleAuthJwtProperties jwtProps,
            JwtTokenService jwtTokenService,
            JdbcTemplate jdbcTemplate,
            ObjectMapper objectMapper
    ) {
        this.weChatProps = weChatProps;
        this.jwtProps = jwtProps;
        this.jwtTokenService = jwtTokenService;
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public WeChatLoginResponse loginByCode(String code) {
        WeChatLoginResponse out = new WeChatLoginResponse();
        if (code == null || code.isBlank()) {
            out.setSuccess(false);
            out.setMessage("code 不能为空");
            return out;
        }
        if (!jwtProps.isConfigured()) {
            out.setSuccess(false);
            out.setMessage("服务端未配置 RULE_AUTH_JWT_SECRET（至少 32 字符）");
            return out;
        }
        if (!weChatProps.isConfigured()) {
            out.setSuccess(false);
            out.setMessage("服务端未配置 WECHAT_MINIAPP_APP_ID / WECHAT_MINIAPP_SECRET");
            return out;
        }

        WxCode2SessionResponse wx;
        try {
            wx = exchangeCode(code.trim());
        } catch (Exception e) {
            out.setSuccess(false);
            out.setMessage("请求微信登录接口失败: " + e.getMessage());
            return out;
        }

        if (wx.isError()) {
            out.setSuccess(false);
            out.setMessage("微信返回错误: " + (wx.getErrmsg() != null ? wx.getErrmsg() : "")
                    + (wx.getErrcode() != null ? " (" + wx.getErrcode() + ")" : ""));
            return out;
        }
        if (wx.getOpenid() == null || wx.getOpenid().isBlank()) {
            out.setSuccess(false);
            out.setMessage("微信未返回 openid");
            return out;
        }

        String appId = weChatProps.getAppId().trim();
        String openid = wx.getOpenid().trim();
        String unionid = wx.getUnionid() != null && !wx.getUnionid().isBlank() ? wx.getUnionid().trim() : null;

        String userId = findUserIdByWx(appId, openid);
        if (userId == null) {
            userId = UUID.randomUUID().toString();
            jdbcTemplate.update(
                    "INSERT INTO rule_user_profile(user_id, wx_app_id, wx_openid, wx_unionid) VALUES(?,?,?,?)",
                    userId, appId, openid, unionid
            );
        } else if (unionid != null) {
            jdbcTemplate.update(
                    "UPDATE rule_user_profile SET wx_unionid=? WHERE user_id=? AND (wx_unionid IS NULL OR wx_unionid='')",
                    unionid, userId
            );
        }

        String token = jwtTokenService.createToken(userId);
        out.setSuccess(true);
        out.setMessage("登录成功");
        out.setUserId(userId);
        out.setToken(token);
        out.setExpiresInSeconds(jwtProps.getExpireSeconds());
        return out;
    }

    public AuthMeResponse me(String authorizationHeader) {
        AuthMeResponse r = new AuthMeResponse();
        var uidOpt = jwtTokenService.parseUserId(authorizationHeader);
        if (uidOpt.isEmpty()) {
            r.setSuccess(false);
            r.setMessage("无效或缺失 Authorization: Bearer <token>");
            return r;
        }
        String userId = uidOpt.get();
        List<String> names = jdbcTemplate.query(
                "SELECT nickname FROM rule_user_profile WHERE user_id=? LIMIT 1",
                (rs, i) -> rs.getString(1),
                userId
        );
        if (names.isEmpty()) {
            r.setSuccess(false);
            r.setMessage("用户不存在");
            return r;
        }
        r.setSuccess(true);
        r.setUserId(userId);
        r.setNickname(names.get(0));
        r.setMessage("ok");
        return r;
    }

    private String findUserIdByWx(String appId, String openid) {
        List<String> ids = jdbcTemplate.query(
                "SELECT user_id FROM rule_user_profile WHERE wx_app_id=? AND wx_openid=? LIMIT 1",
                (rs, i) -> rs.getString(1),
                appId, openid
        );
        return ids.isEmpty() ? null : ids.get(0);
    }

    private WxCode2SessionResponse exchangeCode(String code) throws Exception {
        String appId = URLEncoder.encode(weChatProps.getAppId().trim(), StandardCharsets.UTF_8);
        String secret = URLEncoder.encode(weChatProps.getSecret().trim(), StandardCharsets.UTF_8);
        String js = URLEncoder.encode(code, StandardCharsets.UTF_8);
        String url = CODE2SESSION + "?appid=" + appId + "&secret=" + secret + "&js_code=" + js + "&grant_type=authorization_code";
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(15))
                .GET()
                .build();
        HttpResponse<String> res = httpClient.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (res.statusCode() != 200) {
            throw new IllegalStateException("HTTP " + res.statusCode());
        }
        return objectMapper.readValue(res.body(), WxCode2SessionResponse.class);
    }
}
