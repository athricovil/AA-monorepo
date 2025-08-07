package com.ayurayush.server.controller;

import com.ayurayush.server.entity.Shipping;
import com.ayurayush.server.entity.Order;
import com.ayurayush.server.repository.ShippingRepository;
import com.ayurayush.server.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/shipping")
public class ShippingController {
    
    @Autowired
    private ShippingRepository shippingRepository;
    
    @Autowired
    private OrderRepository orderRepository;

    @GetMapping("/track/{trackingNumber}")
    public ResponseEntity<Shipping> trackShipment(@PathVariable String trackingNumber) {
        Optional<Shipping> shipping = shippingRepository.findByTrackingNumber(trackingNumber);
        return shipping.map(ResponseEntity::ok)
                      .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<Shipping> getShippingByOrderId(@PathVariable Long orderId) {
        Optional<Shipping> shipping = shippingRepository.findByOrderId(orderId);
        return shipping.map(ResponseEntity::ok)
                      .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Shipping>> getShipmentsByStatus(@PathVariable String status) {
        List<Shipping> shipments = shippingRepository.findByStatus(status);
        return ResponseEntity.ok(shipments);
    }

    // Admin endpoints
    @PostMapping("/admin/create")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createShipping(@RequestParam Long orderId,
                                          @RequestParam String trackingNumber,
                                          @RequestParam String carrier,
                                          @RequestParam String shippingAddress) {
        try {
            Optional<Order> orderOpt = orderRepository.findById(orderId);
            if (orderOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Order not found");
            }

            Shipping shipping = new Shipping();
            shipping.setOrder(orderOpt.get());
            shipping.setTrackingNumber(trackingNumber);
            shipping.setCarrier(carrier);
            shipping.setShippingAddress(shippingAddress);
            shipping.setStatus("PENDING");

            Shipping savedShipping = shippingRepository.save(shipping);
            return ResponseEntity.ok(savedShipping);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating shipping: " + e.getMessage());
        }
    }

    @PutMapping("/admin/{shippingId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateShippingStatus(@PathVariable Long shippingId,
                                                @RequestParam String status) {
        Optional<Shipping> shippingOpt = shippingRepository.findById(shippingId);
        if (shippingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Shipping shipping = shippingOpt.get();
        shipping.setStatus(status);

        // Update timestamps based on status
        if ("SHIPPED".equals(status)) {
            shipping.setShippedAt(LocalDateTime.now());
        } else if ("DELIVERED".equals(status)) {
            shipping.setDeliveredAt(LocalDateTime.now());
        }

        Shipping savedShipping = shippingRepository.save(shipping);
        return ResponseEntity.ok(savedShipping);
    }

    @PutMapping("/admin/{shippingId}/tracking")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateTrackingInfo(@PathVariable Long shippingId,
                                              @RequestParam String trackingNumber,
                                              @RequestParam String carrier) {
        Optional<Shipping> shippingOpt = shippingRepository.findById(shippingId);
        if (shippingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Shipping shipping = shippingOpt.get();
        shipping.setTrackingNumber(trackingNumber);
        shipping.setCarrier(carrier);

        Shipping savedShipping = shippingRepository.save(shipping);
        return ResponseEntity.ok(savedShipping);
    }

    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Shipping>> getAllShipments() {
        List<Shipping> shipments = shippingRepository.findAll();
        return ResponseEntity.ok(shipments);
    }

    @GetMapping("/admin/carrier/{carrier}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Shipping>> getShipmentsByCarrier(@PathVariable String carrier) {
        List<Shipping> shipments = shippingRepository.findByCarrier(carrier);
        return ResponseEntity.ok(shipments);
    }
}
