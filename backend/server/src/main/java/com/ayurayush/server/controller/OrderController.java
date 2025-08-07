package com.ayurayush.server.controller;

import com.ayurayush.server.dto.OrderRequest;
import com.ayurayush.server.entity.Order;
import com.ayurayush.server.entity.OrderItem;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.repository.OrderRepository;
import com.ayurayush.server.repository.OrderItemRepository;
import com.ayurayush.server.repository.UserRepository;
import com.ayurayush.server.repository.ProductRepository;
import com.ayurayush.server.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private OrderItemRepository orderItemRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ProductRepository productRepository;
    
    @Autowired
    private OrderService orderService;

    @PostMapping("/checkout")
    public ResponseEntity<?> createOrder(@RequestBody OrderRequest orderRequest) {
        try {
            // Validate user exists
            Optional<User> userOpt = userRepository.findById(orderRequest.getUserId());
            if (userOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("User not found");
            }

            // Check if user has already purchased 3 products (business rule)
            Long userOrderCount = orderRepository.countByUserId(orderRequest.getUserId());
            if (userOrderCount >= 3) {
                return ResponseEntity.badRequest().body("Maximum purchase limit reached (3 products per user)");
            }

            Order order = orderService.createOrder(orderRequest);
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating order: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Order>> getUserOrders(@PathVariable Long userId) {
        List<Order> orders = orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<Order> getOrderById(@PathVariable Long orderId) {
        Optional<Order> order = orderRepository.findById(orderId);
        return order.map(ResponseEntity::ok)
                   .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{orderId}/items")
    public ResponseEntity<List<OrderItem>> getOrderItems(@PathVariable Long orderId) {
        List<OrderItem> items = orderItemRepository.findByOrderId(orderId);
        return ResponseEntity.ok(items);
    }

    @GetMapping("/purchase-history/{userId}")
    public ResponseEntity<List<Order>> getPurchaseHistory(@PathVariable Long userId) {
        List<Order> completedOrders = orderRepository.findCompletedOrdersByUserId(userId);
        return ResponseEntity.ok(completedOrders);
    }

    // Admin endpoints
    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Order>> getAllOrders() {
        List<Order> orders = orderRepository.findAll();
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/admin/status/{status}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Order>> getOrdersByStatus(@PathVariable String status) {
        List<Order> orders = orderRepository.findByStatus(status);
        return ResponseEntity.ok(orders);
    }

    @PutMapping("/admin/{orderId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateOrderStatus(@PathVariable Long orderId, @RequestParam String status) {
        Optional<Order> orderOpt = orderRepository.findById(orderId);
        if (orderOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Order order = orderOpt.get();
        order.setStatus(status);
        orderRepository.save(order);
        return ResponseEntity.ok(order);
    }

    @DeleteMapping("/admin/{orderId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> reverseOrder(@PathVariable Long orderId) {
        try {
            orderService.reverseOrder(orderId);
            return ResponseEntity.ok("Order reversed successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error reversing order: " + e.getMessage());
        }
    }

    @GetMapping("/admin/sales-report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getSalesReport(@RequestParam(required = false) String startDate,
                                          @RequestParam(required = false) String endDate) {
        try {
            return ResponseEntity.ok(orderService.generateSalesReport(startDate, endDate));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error generating sales report: " + e.getMessage());
        }
    }

    @GetMapping("/admin/tax-report")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getTaxReport(@RequestParam(required = false) String startDate,
                                        @RequestParam(required = false) String endDate) {
        try {
            return ResponseEntity.ok(orderService.generateTaxReport(startDate, endDate));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error generating tax report: " + e.getMessage());
        }
    }
}
