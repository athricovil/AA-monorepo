package com.ayurayush.server.controller;

import com.ayurayush.server.dto.ProductReviewRequest;
import com.ayurayush.server.entity.ProductReview;
import com.ayurayush.server.entity.Product;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.repository.ProductReviewRepository;
import com.ayurayush.server.repository.ProductRepository;
import com.ayurayush.server.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/reviews")
public class ProductReviewController {
    
    @Autowired
    private ProductReviewRepository productReviewRepository;
    
    @Autowired
    private ProductRepository productRepository;
    
    @Autowired
    private UserRepository userRepository;

    @PostMapping("/submit")
    public ResponseEntity<?> submitReview(@RequestBody ProductReviewRequest request) {
        try {
            // Validate product exists
            Optional<Product> productOpt = productRepository.findById(request.getProductId());
            if (productOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Product not found");
            }

            // Validate user exists
            Optional<User> userOpt = userRepository.findById(request.getUserId());
            if (userOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("User not found");
            }

            // Validate rating is between 1 and 5
            if (request.getRating() < 1 || request.getRating() > 5) {
                return ResponseEntity.badRequest().body("Rating must be between 1 and 5");
            }

            // Check if user has already reviewed this product
            List<ProductReview> existingReviews = productReviewRepository.findByProductId(request.getProductId());
            boolean hasReviewed = existingReviews.stream()
                .anyMatch(review -> review.getUser().getId().equals(request.getUserId()));
            
            if (hasReviewed) {
                return ResponseEntity.badRequest().body("User has already reviewed this product");
            }

            ProductReview review = new ProductReview();
            review.setProduct(productOpt.get());
            review.setUser(userOpt.get());
            review.setRating(request.getRating());
            review.setReviewText(request.getReviewText());
            review.setApproved(false); // Requires admin approval

            ProductReview savedReview = productReviewRepository.save(review);
            return ResponseEntity.ok(savedReview);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error submitting review: " + e.getMessage());
        }
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<ProductReview>> getProductReviews(@PathVariable Long productId) {
        List<ProductReview> approvedReviews = productReviewRepository.findApprovedByProductId(productId);
        return ResponseEntity.ok(approvedReviews);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ProductReview>> getUserReviews(@PathVariable Long userId) {
        List<ProductReview> reviews = productReviewRepository.findByUserId(userId);
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/{reviewId}")
    public ResponseEntity<ProductReview> getReviewById(@PathVariable Long reviewId) {
        Optional<ProductReview> review = productReviewRepository.findById(reviewId);
        return review.map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
    }

    // Admin endpoints
    @GetMapping("/admin/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ProductReview>> getPendingReviews() {
        List<ProductReview> pendingReviews = productReviewRepository.findByIsApproved(false);
        return ResponseEntity.ok(pendingReviews);
    }

    @PutMapping("/admin/{reviewId}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> approveReview(@PathVariable Long reviewId) {
        Optional<ProductReview> reviewOpt = productReviewRepository.findById(reviewId);
        if (reviewOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ProductReview review = reviewOpt.get();
        review.setApproved(true);
        ProductReview savedReview = productReviewRepository.save(review);

        // Update product average rating
        updateProductRating(review.getProduct().getId());

        return ResponseEntity.ok(savedReview);
    }

    @DeleteMapping("/admin/{reviewId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> rejectReview(@PathVariable Long reviewId) {
        Optional<ProductReview> reviewOpt = productReviewRepository.findById(reviewId);
        if (reviewOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ProductReview review = reviewOpt.get();
        productReviewRepository.delete(review);
        return ResponseEntity.ok("Review rejected and deleted");
    }

    @GetMapping("/admin/product/{productId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ProductReview>> getAllProductReviews(@PathVariable Long productId) {
        List<ProductReview> allReviews = productReviewRepository.findByProductId(productId);
        return ResponseEntity.ok(allReviews);
    }

    private void updateProductRating(Long productId) {
        Double averageRating = productReviewRepository.getAverageRatingByProductId(productId);
        if (averageRating != null) {
            Optional<Product> productOpt = productRepository.findById(productId);
            if (productOpt.isPresent()) {
                Product product = productOpt.get();
                product.setRating(BigDecimal.valueOf(averageRating));
                productRepository.save(product);
            }
        }
    }
}
