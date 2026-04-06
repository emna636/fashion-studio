package com.fashionstudio.dto.auth;

import java.util.UUID;

public record AuthResponse(
		String token,
		UUID userId,
		String nom,
		String email,
		String atelier
) {
}
