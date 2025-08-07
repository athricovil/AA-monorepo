package com.ayurayush.server.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "admin_actions")
public class AdminAction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_user_id", nullable = false)
    private User adminUser;

    @Column(name = "action_type", nullable = false)
    private String actionType;

    @Column(name = "action_details")
    private String actionDetails;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "target_user_id")
    private User targetUser;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "target_order_id")
    private Order targetOrder;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public AdminAction() {}

    public AdminAction(Long id, User adminUser, String actionType, String actionDetails, 
                      User targetUser, Order targetOrder) {
        this.id = id;
        this.adminUser = adminUser;
        this.actionType = actionType;
        this.actionDetails = actionDetails;
        this.targetUser = targetUser;
        this.targetOrder = targetOrder;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getAdminUser() { return adminUser; }
    public void setAdminUser(User adminUser) { this.adminUser = adminUser; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public String getActionDetails() { return actionDetails; }
    public void setActionDetails(String actionDetails) { this.actionDetails = actionDetails; }

    public User getTargetUser() { return targetUser; }
    public void setTargetUser(User targetUser) { this.targetUser = targetUser; }

    public Order getTargetOrder() { return targetOrder; }
    public void setTargetOrder(Order targetOrder) { this.targetOrder = targetOrder; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
