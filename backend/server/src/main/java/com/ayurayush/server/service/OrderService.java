package com.ayurayush.server.service;

import com.ayurayush.server.dto.OrderRequest;
import com.ayurayush.server.entity.Order;
import com.ayurayush.server.entity.OrderItem;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.entity.Product;
import com.ayurayush.server.repository.OrderRepository;
import com.ayurayush.server.repository.OrderItemRepository;
import com.ayurayush.server.repository.UserRepository;
import com.ayurayush.server.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private OrderItemRepository orderItemRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ProductRepository productRepository;

    @Transactional
    public Order createOrder(OrderRequest orderRequest) {
        // Validate user exists
        Optional<User> userOpt = userRepository.findById(orderRequest.getUserId());
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = userOpt.get();

        // Generate unique order number
        String orderNumber = generateOrderNumber();

        // Calculate total amount
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (OrderRequest.OrderItemRequest itemRequest : orderRequest.getItems()) {
            Optional<Product> productOpt = productRepository.findById(itemRequest.getProductId());
            if (productOpt.isEmpty()) {
                throw new RuntimeException("Product not found: " + itemRequest.getProductId());
            }
            
            Product product = productOpt.get();
            BigDecimal itemTotal = product.getPrice().multiply(BigDecimal.valueOf(itemRequest.getQuantity()));
            totalAmount = totalAmount.add(itemTotal);
        }

        // Create order
        Order order = new Order();
        order.setUser(user);
        order.setOrderNumber(orderNumber);
        order.setTotalAmount(totalAmount);
        order.setStatus("PENDING");
        order.setPaymentStatus("PENDING");
        order.setPaymentMethod(orderRequest.getPaymentMethod());
        order.setShippingAddress(orderRequest.getShippingAddress());
        order.setBillingAddress(orderRequest.getBillingAddress());

        Order savedOrder = orderRepository.save(order);

        // Create order items
        for (OrderRequest.OrderItemRequest itemRequest : orderRequest.getItems()) {
            Product product = productRepository.findById(itemRequest.getProductId()).get();
            
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(savedOrder);
            orderItem.setProductId(itemRequest.getProductId());
            orderItem.setQuantity(itemRequest.getQuantity());
            orderItem.setUnitPrice(product.getPrice());
            orderItem.setTotalPrice(product.getPrice().multiply(BigDecimal.valueOf(itemRequest.getQuantity())));

            orderItemRepository.save(orderItem);
        }

        return savedOrder;
    }

    @Transactional
    public void reverseOrder(Long orderId) {
        Optional<Order> orderOpt = orderRepository.findById(orderId);
        if (orderOpt.isEmpty()) {
            throw new RuntimeException("Order not found");
        }

        Order order = orderOpt.get();
        
        // Check if order can be reversed (not delivered)
        if ("DELIVERED".equals(order.getStatus()) || "COMPLETED".equals(order.getStatus())) {
            throw new RuntimeException("Cannot reverse completed or delivered order");
        }

        // Delete order items
        List<OrderItem> orderItems = orderItemRepository.findByOrderId(orderId);
        orderItemRepository.deleteAll(orderItems);

        // Delete order
        orderRepository.delete(order);
    }

    public Map<String, Object> generateSalesReport(String startDate, String endDate) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDateTime start = startDate != null ? LocalDateTime.parse(startDate + "T00:00:00") : LocalDateTime.now().minusDays(30);
        LocalDateTime end = endDate != null ? LocalDateTime.parse(endDate + "T23:59:59") : LocalDateTime.now();

        List<Order> orders = orderRepository.findAll().stream()
            .filter(order -> !order.getCreatedAt().isBefore(start) && !order.getCreatedAt().isAfter(end))
            .toList();

        BigDecimal totalSales = orders.stream()
            .map(Order::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        long totalOrders = orders.size();
        long completedOrders = orders.stream()
            .filter(order -> "COMPLETED".equals(order.getStatus()))
            .count();

        Map<String, Object> report = new HashMap<>();
        report.put("startDate", start.format(formatter));
        report.put("endDate", end.format(formatter));
        report.put("totalSales", totalSales);
        report.put("totalOrders", totalOrders);
        report.put("completedOrders", completedOrders);
        report.put("orders", orders);

        return report;
    }

    public Map<String, Object> generateTaxReport(String startDate, String endDate) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDateTime start = startDate != null ? LocalDateTime.parse(startDate + "T00:00:00") : LocalDateTime.now().minusDays(30);
        LocalDateTime end = endDate != null ? LocalDateTime.parse(endDate + "T23:59:59") : LocalDateTime.now();

        List<Order> orders = orderRepository.findAll().stream()
            .filter(order -> !order.getCreatedAt().isBefore(start) && !order.getCreatedAt().isAfter(end))
            .filter(order -> "COMPLETED".equals(order.getStatus()))
            .toList();

        BigDecimal totalAmount = orders.stream()
            .map(Order::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calculate GST (assuming 18% GST)
        BigDecimal gstRate = new BigDecimal("0.18");
        BigDecimal totalGST = totalAmount.multiply(gstRate);
        BigDecimal netAmount = totalAmount.subtract(totalGST);

        Map<String, Object> report = new HashMap<>();
        report.put("startDate", start.format(formatter));
        report.put("endDate", end.format(formatter));
        report.put("totalAmount", totalAmount);
        report.put("gstRate", "18%");
        report.put("totalGST", totalGST);
        report.put("netAmount", netAmount);
        report.put("orderCount", orders.size());

        return report;
    }

    private String generateOrderNumber() {
        return "ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
