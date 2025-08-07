package com.ayurayush.server.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ayurayush.server.entity.User;

import java.util.Optional;


public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);

    boolean existsByUsername(String username);
    
    Optional<User> findByPhone(String phone);
    boolean existsByPhone(String phone);
}
