package com.ayurayush.server.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role;

    @Column(unique = true, length = 15)
    private String phone;

    @Column(length = 15)
    private String whatsapp;

    @Column(name = "phone_verified")
    private boolean phoneVerified;

    public User() {}

    public User(Long id, String username, String password, String role, String phone, String whatsapp, boolean phoneVerified) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.role = role;
        this.phone = phone;
        this.whatsapp = whatsapp;
        this.phoneVerified = phoneVerified;
    }

    public static UserBuilder builder() {
        return new UserBuilder();
    }

    public static class UserBuilder {
        private Long id;
        private String username;
        private String password;
        private String role;
        private String phone;
        private String whatsapp;
        private boolean phoneVerified;

        public UserBuilder id(Long id) { this.id = id; return this; }
        public UserBuilder username(String username) { this.username = username; return this; }
        public UserBuilder password(String password) { this.password = password; return this; }
        public UserBuilder role(String role) { this.role = role; return this; }
        public UserBuilder phone(String phone) { this.phone = phone; return this; }
        public UserBuilder whatsapp(String whatsapp) { this.whatsapp = whatsapp; return this; }
        public UserBuilder phoneVerified(boolean phoneVerified) { this.phoneVerified = phoneVerified; return this; }
        public User build() {
            return new User(id, username, password, role, phone, whatsapp, phoneVerified);
        }
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getRole() {
        return role;
    }
    public void setRole(String role) {
        this.role = role;
    }
    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }
    public String getWhatsapp() {
        return whatsapp;
    }
    public void setWhatsapp(String whatsapp) {
        this.whatsapp = whatsapp;
    }
    public boolean isPhoneVerified() {
        return phoneVerified;
    }
    public void setPhoneVerified(boolean phoneVerified) {
        this.phoneVerified = phoneVerified;
    }
}

