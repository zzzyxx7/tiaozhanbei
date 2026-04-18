package com.shangfaduxing.rulebackend;

import com.shangfaduxing.rulebackend.config.RuleAuthJwtProperties;
import com.shangfaduxing.rulebackend.config.RuleAuthAvatarProperties;
import com.shangfaduxing.rulebackend.config.RuleAliOssProperties;
import com.shangfaduxing.rulebackend.config.RuleWeChatProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties({
        RuleWeChatProperties.class,
        RuleAuthJwtProperties.class,
        RuleAuthAvatarProperties.class,
        RuleAliOssProperties.class
})
public class RuleBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(RuleBackendApplication.class, args);
    }
}

