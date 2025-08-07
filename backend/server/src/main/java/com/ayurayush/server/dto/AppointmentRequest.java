package com.ayurayush.server.dto;

import java.time.LocalDateTime;

public class AppointmentRequest {
    private Long userId;
    private Long orderId;
    private LocalDateTime appointmentDate;
    private Integer durationMinutes;
    private String notes;
    private Long doctorId;

    public AppointmentRequest() {}

    public AppointmentRequest(Long userId, Long orderId, LocalDateTime appointmentDate, 
                            Integer durationMinutes, String notes, Long doctorId) {
        this.userId = userId;
        this.orderId = orderId;
        this.appointmentDate = appointmentDate;
        this.durationMinutes = durationMinutes;
        this.notes = notes;
        this.doctorId = doctorId;
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public LocalDateTime getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(LocalDateTime appointmentDate) { this.appointmentDate = appointmentDate; }

    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Long getDoctorId() { return doctorId; }
    public void setDoctorId(Long doctorId) { this.doctorId = doctorId; }
}
