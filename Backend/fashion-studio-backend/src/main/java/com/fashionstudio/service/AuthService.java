package com.fashionstudio.service;

import com.fashionstudio.dto.auth.AuthResponse;
import com.fashionstudio.dto.auth.LoginRequest;
import com.fashionstudio.dto.auth.SignupRequest;
import com.fashionstudio.model.User;
import com.fashionstudio.repository.UserRepository;
import com.fashionstudio.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;

	public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
		this.userRepository = userRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtService = jwtService;
	}

	@Transactional
	public AuthResponse signup(SignupRequest req) {
		if (userRepository.existsByEmail(req.email())) {
			throw new IllegalArgumentException("Cet email est déjà utilisé");
		}

		User user = new User();
		user.setNom(req.nom());
		user.setAtelier(req.atelier());
		user.setEmail(req.email().toLowerCase());
		user.setPassword(passwordEncoder.encode(req.password()));

		User saved = userRepository.save(user);
		String token = jwtService.generateToken(saved.getEmail());

		return new AuthResponse(token, saved.getId(), saved.getNom(), saved.getEmail(), saved.getAtelier());
	}

	@Transactional(readOnly = true)
	public AuthResponse login(LoginRequest req) {
		User user = userRepository.findByEmail(req.email().toLowerCase())
				.orElseThrow(() -> new IllegalArgumentException("Email ou mot de passe incorrect"));

		if (!passwordEncoder.matches(req.password(), user.getPassword())) {
			throw new IllegalArgumentException("Email ou mot de passe incorrect");
		}

		String token = jwtService.generateToken(user.getEmail());
		return new AuthResponse(token, user.getId(), user.getNom(), user.getEmail(), user.getAtelier());
	}
}
