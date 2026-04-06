package com.fashionstudio.service;

import com.fashionstudio.model.User;
import com.fashionstudio.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class CurrentUserService {

	private final UserRepository userRepository;

	public CurrentUserService(UserRepository userRepository) {
		this.userRepository = userRepository;
	}

	public User requireUser() {
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();
		if (auth == null || auth.getName() == null) {
			throw new IllegalArgumentException("Utilisateur non authentifié");
		}
		return userRepository.findByEmail(auth.getName())
				.orElseThrow(() -> new IllegalArgumentException("Utilisateur non authentifié"));
	}
}
