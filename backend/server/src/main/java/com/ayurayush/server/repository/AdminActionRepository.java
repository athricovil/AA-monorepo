package com.ayurayush.server.repository;

import com.ayurayush.server.entity.AdminAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AdminActionRepository extends JpaRepository<AdminAction, Long> {
    
    List<AdminAction> findByAdminUserIdOrderByCreatedAtDesc(Long adminUserId);
    
    List<AdminAction> findByActionType(String actionType);
    
    @Query("SELECT aa FROM AdminAction aa WHERE aa.createdAt BETWEEN :startDate AND :endDate")
    List<AdminAction> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                     @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT aa FROM AdminAction aa WHERE aa.targetUser.id = :targetUserId")
    List<AdminAction> findByTargetUserId(@Param("targetUserId") Long targetUserId);
    
    @Query("SELECT aa FROM AdminAction aa WHERE aa.targetOrder.id = :targetOrderId")
    List<AdminAction> findByTargetOrderId(@Param("targetOrderId") Long targetOrderId);
}
