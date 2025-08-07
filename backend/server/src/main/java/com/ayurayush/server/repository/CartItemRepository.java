package com.ayurayush.server.repository;

import com.ayurayush.server.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    List<CartItem> findByUserId(Long userId);
    List<CartItem> findByUserIdAndProductId(Long userId, Long productId);
    
    @Transactional
    void deleteByUserIdAndProductId(Long userId, Long productId);
}
