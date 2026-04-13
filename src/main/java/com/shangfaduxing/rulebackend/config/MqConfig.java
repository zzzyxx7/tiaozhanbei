package com.shangfaduxing.rulebackend.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.QueueBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MqConfig {
    public static final String EXCHANGE = "rule.ai";
    public static final String QUEUE_PREFILL = "rule.ai.prefill";
    public static final String RK_PREFILL = "prefill";

    @Bean
    public DirectExchange ruleAiExchange() {
        return new DirectExchange(EXCHANGE, true, false);
    }

    @Bean
    public Queue aiPrefillQueue() {
        return QueueBuilder.durable(QUEUE_PREFILL).build();
    }

    @Bean
    public Binding aiPrefillBinding(Queue aiPrefillQueue, DirectExchange ruleAiExchange) {
        return BindingBuilder.bind(aiPrefillQueue).to(ruleAiExchange).with(RK_PREFILL);
    }
}

