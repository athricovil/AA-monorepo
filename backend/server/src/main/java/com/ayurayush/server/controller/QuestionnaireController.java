package com.ayurayush.server.controller;

import com.ayurayush.server.dto.QuestionnaireRequest;
import com.ayurayush.server.entity.Questionnaire;
import com.ayurayush.server.entity.Order;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.repository.QuestionnaireRepository;
import com.ayurayush.server.repository.OrderRepository;
import com.ayurayush.server.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/questionnaires")
public class QuestionnaireController {
    
    @Autowired
    private QuestionnaireRepository questionnaireRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping("/submit")
    public ResponseEntity<?> submitQuestionnaire(@RequestBody QuestionnaireRequest request) {
        try {
            // Validate user exists
            Optional<User> userOpt = userRepository.findById(request.getUserId());
            if (userOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("User not found");
            }

            // Validate order exists
            Optional<Order> orderOpt = orderRepository.findById(request.getOrderId());
            if (orderOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Order not found");
            }

            // Check if questionnaire already exists for this order
            Optional<Questionnaire> existingQuestionnaire = questionnaireRepository.findByOrderId(request.getOrderId());
            if (existingQuestionnaire.isPresent()) {
                return ResponseEntity.badRequest().body("Questionnaire already submitted for this order");
            }

            // Convert questions and answers to JSON strings
            String questionsJson = objectMapper.writeValueAsString(request.getQuestions());
            String answersJson = objectMapper.writeValueAsString(request.getAnswers());

            Questionnaire questionnaire = new Questionnaire();
            questionnaire.setUser(userOpt.get());
            questionnaire.setOrder(orderOpt.get());
            questionnaire.setQuestions(questionsJson);
            questionnaire.setAnswers(answersJson);

            Questionnaire savedQuestionnaire = questionnaireRepository.save(questionnaire);
            return ResponseEntity.ok(savedQuestionnaire);
        } catch (JsonProcessingException e) {
            return ResponseEntity.badRequest().body("Error processing questionnaire data: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error submitting questionnaire: " + e.getMessage());
        }
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<Questionnaire> getQuestionnaireByOrderId(@PathVariable Long orderId) {
        Optional<Questionnaire> questionnaire = questionnaireRepository.findByOrderId(orderId);
        return questionnaire.map(ResponseEntity::ok)
                          .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Questionnaire>> getUserQuestionnaires(@PathVariable Long userId) {
        List<Questionnaire> questionnaires = questionnaireRepository.findByUserId(userId);
        return ResponseEntity.ok(questionnaires);
    }

    @GetMapping("/{questionnaireId}")
    public ResponseEntity<Questionnaire> getQuestionnaireById(@PathVariable Long questionnaireId) {
        Optional<Questionnaire> questionnaire = questionnaireRepository.findById(questionnaireId);
        return questionnaire.map(ResponseEntity::ok)
                          .orElse(ResponseEntity.notFound().build());
    }
}
