package com.ayurayush.server.service;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Random;

@Service
public class OtpService {

    private final Map<String, String> phoneOtpMap = new ConcurrentHashMap<>();
    private final Random random = new Random();

    public String generateOtp(String phone) {
        String otp = String.format("%06d", random.nextInt(1000000));
        phoneOtpMap.put(phone, otp);
        System.out.println("Generated OTP for phone " + phone + ": " + otp); // Log to console for dev
        return otp;
    }

    public boolean validateOtp(String phone, String otp) {
        return otp.equals(phoneOtpMap.get(phone));
    }

    public void clearOtp(String phone) {
        phoneOtpMap.remove(phone);
    }
}

