package com.ayurayush.server.dto;

public class ProductReviewRequest {
    private Long productId;
    private Long userId;
    private Integer rating;
    private String reviewText;

    public ProductReviewRequest() {}

    public ProductReviewRequest(Long productId, Long userId, Integer rating, String reviewText) {
        this.productId = productId;
        this.userId = userId;
        this.rating = rating;
        this.reviewText = reviewText;
    }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getReviewText() { return reviewText; }
    public void setReviewText(String reviewText) { this.reviewText = reviewText; }
}
