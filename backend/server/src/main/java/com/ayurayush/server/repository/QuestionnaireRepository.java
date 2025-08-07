package com.ayurayush.server.repository;

import com.ayurayush.server.entity.Questionnaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuestionnaireRepository extends JpaRepository<Questionnaire, Long> {
    
    Optional<Questionnaire> findByOrderId(Long orderId);
    
    List<Questionnaire> findByUserId(Long userId);
}
