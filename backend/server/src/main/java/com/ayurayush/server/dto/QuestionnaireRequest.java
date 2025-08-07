package com.ayurayush.server.dto;

import java.util.Map;

public class QuestionnaireRequest {
    private Long userId;
    private Long orderId;
    private Map<String, String> questions;
    private Map<String, String> answers;

    public QuestionnaireRequest() {}

    public QuestionnaireRequest(Long userId, Long orderId, Map<String, String> questions, Map<String, String> answers) {
        this.userId = userId;
        this.orderId = orderId;
        this.questions = questions;
        this.answers = answers;
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public Map<String, String> getQuestions() { return questions; }
    public void setQuestions(Map<String, String> questions) { this.questions = questions; }

    public Map<String, String> getAnswers() { return answers; }
    public void setAnswers(Map<String, String> answers) { this.answers = answers; }
}
