package com.fashionstudio.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;

@Service
public class JwtService {

	private final SecretKey signingKey;
	private final long expirationMinutes;

	public JwtService(
			@Value("${app.jwt.secret}") String secret,
			@Value("${app.jwt.expiration-minutes}") long expirationMinutes
	) {
		this.signingKey = Keys.hmacShaKeyFor(secretKeyBytes(secret));
		this.expirationMinutes = expirationMinutes;
	}

	public String generateToken(String subject) {
		Instant now = Instant.now();
		Instant exp = now.plus(expirationMinutes, ChronoUnit.MINUTES);

		return Jwts.builder()
				.setSubject(subject)
				.setIssuedAt(Date.from(now))
				.setExpiration(Date.from(exp))
				.signWith(signingKey, SignatureAlgorithm.HS256)
				.compact();
	}

	public Jws<Claims> parseToken(String token) {
		return Jwts.parserBuilder()
				.setSigningKey(signingKey)
				.build()
				.parseClaimsJws(token);
	}

	private static byte[] secretKeyBytes(String secret) {
		try {
			return Decoders.BASE64.decode(secret);
		} catch (Exception ignored) {
			// ignore
		}

		try {
			return Decoders.BASE64URL.decode(secret);
		} catch (Exception ignored) {
			// ignore
		}

		return secret.getBytes(StandardCharsets.UTF_8);
	}
}
