package com.ayurayush.server.repository;

import com.ayurayush.server.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    
    List<Appointment> findByUserIdOrderByAppointmentDateDesc(Long userId);
    
    List<Appointment> findByStatus(String status);
    
    @Query("SELECT a FROM Appointment a WHERE a.appointmentDate BETWEEN :startDate AND :endDate")
    List<Appointment> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                     @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT a FROM Appointment a WHERE a.doctorId = :doctorId AND a.status = 'SCHEDULED'")
    List<Appointment> findScheduledByDoctorId(@Param("doctorId") Long doctorId);
    
    @Query("SELECT a FROM Appointment a WHERE a.user.id = :userId AND a.status = 'COMPLETED'")
    List<Appointment> findCompletedByUserId(@Param("userId") Long userId);
}
