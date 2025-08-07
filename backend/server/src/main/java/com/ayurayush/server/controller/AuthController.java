package com.ayurayush.server.controller;

import com.ayurayush.server.dto.JwtResponse;
import com.ayurayush.server.dto.LoginRequest;
import com.ayurayush.server.dto.SignupRequest;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.repository.UserRepository;
import com.ayurayush.server.security.JwtUtils;
import com.ayurayush.server.service.OtpService;
import com.ayurayush.server.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthenticationManager authenticationManager;
    private final UserService userService;
    private final JwtUtils jwtUtils;
    private final OtpService otpService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthController(AuthenticationManager authenticationManager,
                         UserService userService,
                         JwtUtils jwtUtils,
                         OtpService otpService,
                         UserRepository userRepository,
                         PasswordEncoder passwordEncoder) {
        this.authenticationManager = authenticationManager;
        this.userService = userService;
        this.jwtUtils = jwtUtils;
        this.otpService = otpService;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signUpRequest) {
        if (userService.existsByUsername(signUpRequest.getUsername())) {
            return ResponseEntity.badRequest().body("Error: Username is already taken!");
        }
        if (signUpRequest.getPhone() != null && userService.existsByPhone(signUpRequest.getPhone())) {
            return ResponseEntity.badRequest().body("Error: Phone number is already registered!");
        }

        User user = new User();
        user.setUsername(signUpRequest.getUsername());
        user.setPassword(passwordEncoder.encode(signUpRequest.getPassword()));
        user.setPhone(signUpRequest.getPhone());
        user.setWhatsapp(signUpRequest.getWhatsapp());
        user.setPhoneVerified(false);
        user.setRole("USER");

        userService.save(user);
        return ResponseEntity.ok("User registered successfully!");
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String jwt = jwtUtils.generateJwtToken(userDetails);
        User user = userRepository.findByUsername(userDetails.getUsername()).orElse(null);
        Long userId = user != null ? user.getId() : null;
        return ResponseEntity.ok(new JwtResponse(jwt, userDetails.getUsername(), "Bearer", userId));
    }

    @PostMapping("/otp-request")
    public ResponseEntity<?> requestOtp(@RequestParam String phone) {
        if (!userRepository.existsByPhone(phone)) {
            return ResponseEntity.badRequest().body("Phone number not registered");
        }
        String otp = otpService.generateOtp(phone);
        System.out.println("OTP for " + phone + " is " + otp); // For dev only
        return ResponseEntity.ok("OTP sent to " + phone);
    }

    @PostMapping("/otp-login")
    public ResponseEntity<?> otpLogin(@RequestParam String phone, @RequestParam String otp) {
        if (!otpService.validateOtp(phone, otp)) {
            return ResponseEntity.status(401).body("Invalid or expired OTP");
        }

        User user = userRepository.findByPhone(phone).orElse(null);
        if (user == null) return ResponseEntity.status(404).body("User not found");

        UserDetails userDetails = org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword()) // required by builder, but not checked
                .roles(user.getRole())
                .build();

        String jwt = jwtUtils.generateJwtToken(userDetails);
        return ResponseEntity.ok(new JwtResponse(jwt, user.getUsername(), "Bearer", user.getId()));
    }
}

