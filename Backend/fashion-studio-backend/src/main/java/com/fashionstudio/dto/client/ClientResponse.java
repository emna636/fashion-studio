package com.fashionstudio.dto.client;

import java.time.Instant;
import java.util.UUID;

public record ClientResponse(
		UUID id,
		String prenom,
		String nom,
		String telephone,
		String email,
		Integer taille,
		Integer poitrine,
		Integer tourDeTaille,
		Integer hanches,
		Instant createdAt
) {
}
