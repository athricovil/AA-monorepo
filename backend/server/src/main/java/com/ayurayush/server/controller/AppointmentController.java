package com.ayurayush.server.controller;

import com.ayurayush.server.dto.AppointmentRequest;
import com.ayurayush.server.entity.Appointment;
import com.ayurayush.server.entity.Order;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.repository.AppointmentRepository;
import com.ayurayush.server.repository.OrderRepository;
import com.ayurayush.server.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {
    
    @Autowired
    private AppointmentRepository appointmentRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private OrderRepository orderRepository;

    @PostMapping("/schedule")
    public ResponseEntity<?> scheduleAppointment(@RequestBody AppointmentRequest request) {
        try {
            // Validate user exists
            Optional<User> userOpt = userRepository.findById(request.getUserId());
            if (userOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("User not found");
            }

            // Validate order exists if provided
            if (request.getOrderId() != null) {
                Optional<Order> orderOpt = orderRepository.findById(request.getOrderId());
                if (orderOpt.isEmpty()) {
                    return ResponseEntity.badRequest().body("Order not found");
                }
            }

            // Check if appointment time is in the future
            if (request.getAppointmentDate().isBefore(LocalDateTime.now())) {
                return ResponseEntity.badRequest().body("Appointment date must be in the future");
            }

            // Check for scheduling conflicts
            List<Appointment> conflictingAppointments = appointmentRepository.findByDateRange(
                request.getAppointmentDate().minusMinutes(30),
                request.getAppointmentDate().plusMinutes(request.getDurationMinutes() != null ? request.getDurationMinutes() : 15)
            );

            if (!conflictingAppointments.isEmpty()) {
                return ResponseEntity.badRequest().body("Appointment time slot is not available");
            }

            Appointment appointment = new Appointment();
            appointment.setUser(userOpt.get());
            if (request.getOrderId() != null) {
                appointment.setOrder(orderRepository.findById(request.getOrderId()).get());
            }
            appointment.setAppointmentDate(request.getAppointmentDate());
            appointment.setDurationMinutes(request.getDurationMinutes() != null ? request.getDurationMinutes() : 15);
            appointment.setNotes(request.getNotes());
            appointment.setDoctorId(request.getDoctorId());
            appointment.setStatus("SCHEDULED");

            Appointment savedAppointment = appointmentRepository.save(appointment);
            return ResponseEntity.ok(savedAppointment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error scheduling appointment: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Appointment>> getUserAppointments(@PathVariable Long userId) {
        List<Appointment> appointments = appointmentRepository.findByUserIdOrderByAppointmentDateDesc(userId);
        return ResponseEntity.ok(appointments);
    }

    @GetMapping("/consultation-history/{userId}")
    public ResponseEntity<List<Appointment>> getConsultationHistory(@PathVariable Long userId) {
        List<Appointment> completedAppointments = appointmentRepository.findCompletedByUserId(userId);
        return ResponseEntity.ok(completedAppointments);
    }

    @GetMapping("/{appointmentId}")
    public ResponseEntity<Appointment> getAppointmentById(@PathVariable Long appointmentId) {
        Optional<Appointment> appointment = appointmentRepository.findById(appointmentId);
        return appointment.map(ResponseEntity::ok)
                        .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{appointmentId}/reschedule")
    public ResponseEntity<?> rescheduleAppointment(@PathVariable Long appointmentId, 
                                                 @RequestParam LocalDateTime newDate) {
        Optional<Appointment> appointmentOpt = appointmentRepository.findById(appointmentId);
        if (appointmentOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Appointment appointment = appointmentOpt.get();
        
        // Check if new date is in the future
        if (newDate.isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body("New appointment date must be in the future");
        }

        // Check for scheduling conflicts
        List<Appointment> conflictingAppointments = appointmentRepository.findByDateRange(
            newDate.minusMinutes(30),
            newDate.plusMinutes(appointment.getDurationMinutes())
        );

        if (!conflictingAppointments.isEmpty()) {
            return ResponseEntity.badRequest().body("New appointment time slot is not available");
        }

        appointment.setAppointmentDate(newDate);
        appointment.setStatus("RESCHEDULED");
        Appointment savedAppointment = appointmentRepository.save(appointment);
        return ResponseEntity.ok(savedAppointment);
    }

    @PutMapping("/{appointmentId}/status")
    public ResponseEntity<?> updateAppointmentStatus(@PathVariable Long appointmentId, 
                                                   @RequestParam String status) {
        Optional<Appointment> appointmentOpt = appointmentRepository.findById(appointmentId);
        if (appointmentOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Appointment appointment = appointmentOpt.get();
        appointment.setStatus(status);
        Appointment savedAppointment = appointmentRepository.save(appointment);
        return ResponseEntity.ok(savedAppointment);
    }

    // Admin endpoints
    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Appointment>> getAllAppointments() {
        List<Appointment> appointments = appointmentRepository.findAll();
        return ResponseEntity.ok(appointments);
    }

    @GetMapping("/admin/status/{status}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Appointment>> getAppointmentsByStatus(@PathVariable String status) {
        List<Appointment> appointments = appointmentRepository.findByStatus(status);
        return ResponseEntity.ok(appointments);
    }

    @GetMapping("/admin/doctor/{doctorId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Appointment>> getAppointmentsByDoctor(@PathVariable Long doctorId) {
        List<Appointment> appointments = appointmentRepository.findScheduledByDoctorId(doctorId);
        return ResponseEntity.ok(appointments);
    }

    @DeleteMapping("/admin/{appointmentId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> cancelAppointment(@PathVariable Long appointmentId) {
        Optional<Appointment> appointmentOpt = appointmentRepository.findById(appointmentId);
        if (appointmentOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Appointment appointment = appointmentOpt.get();
        appointment.setStatus("CANCELLED");
        appointmentRepository.save(appointment);
        return ResponseEntity.ok("Appointment cancelled successfully");
    }
}
