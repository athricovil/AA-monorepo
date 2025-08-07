package com.ayurayush.server.repository;

import com.ayurayush.server.entity.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {
    
    List<ProductReview> findByProductId(Long productId);
    
    List<ProductReview> findByUserId(Long userId);
    
    List<ProductReview> findByIsApproved(boolean isApproved);
    
    @Query("SELECT AVG(pr.rating) FROM ProductReview pr WHERE pr.product.id = :productId AND pr.isApproved = true")
    Double getAverageRatingByProductId(@Param("productId") Long productId);
    
    @Query("SELECT pr FROM ProductReview pr WHERE pr.product.id = :productId AND pr.isApproved = true")
    List<ProductReview> findApprovedByProductId(@Param("productId") Long productId);
}
