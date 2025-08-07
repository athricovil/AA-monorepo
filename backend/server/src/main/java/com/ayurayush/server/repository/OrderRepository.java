package com.ayurayush.server.repository;

import com.ayurayush.server.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    List<Order> findByUserIdOrderByCreatedAtDesc(Long userId);
    
    Optional<Order> findByOrderNumber(String orderNumber);
    
    @Query("SELECT o FROM Order o WHERE o.status = :status")
    List<Order> findByStatus(@Param("status") String status);
    
    @Query("SELECT o FROM Order o WHERE o.paymentStatus = :paymentStatus")
    List<Order> findByPaymentStatus(@Param("paymentStatus") String paymentStatus);
    
    @Query("SELECT COUNT(o) FROM Order o WHERE o.user.id = :userId")
    Long countByUserId(@Param("userId") Long userId);
    
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId AND o.status = 'COMPLETED'")
    List<Order> findCompletedOrdersByUserId(@Param("userId") Long userId);
}
