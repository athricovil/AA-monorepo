package com.ayurayush.server;

import javax.crypto.SecretKey;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Encoders;
import io.jsonwebtoken.security.Keys;

@SpringBootApplication
@EntityScan("com.ayurayush.server.entity")
@EnableJpaRepositories("com.ayurayush.server.repository")
@ComponentScan("com.ayurayush.server")
public class ServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ServerApplication.class, args);

//         Optional: Uncomment if you want to generate a JWT signing key
//         SecretKey key = Keys.secretKeyFor(SignatureAlgorithm.HS512);
//         String base64Key = Encoders.BASE64.encode(key.getEncoded());
//         System.out.println("Generated base64 key: " + base64Key);
    }
}

