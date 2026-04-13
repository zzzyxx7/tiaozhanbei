package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.config.RuleAuthJwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Optional;

@Service
public class JwtTokenService {

    private final RuleAuthJwtProperties props;

    public JwtTokenService(RuleAuthJwtProperties props) {
        this.props = props;
    }

    public String createToken(String userId) {
        long nowMs = System.currentTimeMillis();
        long expMs = nowMs + props.getExpireSeconds() * 1000L;
        return Jwts.builder()
                .subject(userId)
                .issuedAt(new Date(nowMs))
                .expiration(new Date(expMs))
                .signWith(signingKey())
                .compact();
    }

    public Optional<String> parseUserId(String bearerOrRawToken) {
        if (bearerOrRawToken == null || bearerOrRawToken.isBlank()) {
            return Optional.empty();
        }
        String token = bearerOrRawToken.startsWith("Bearer ")
                ? bearerOrRawToken.substring(7).trim()
                : bearerOrRawToken.trim();
        if (token.isEmpty()) {
            return Optional.empty();
        }
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(signingKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            String sub = claims.getSubject();
            return sub == null || sub.isBlank() ? Optional.empty() : Optional.of(sub);
        } catch (JwtException | IllegalArgumentException e) {
            return Optional.empty();
        }
    }

    private SecretKey signingKey() {
        byte[] keyBytes = props.getSecret().getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
