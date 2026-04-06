package com.fashionstudio.dto.client;

import jakarta.validation.constraints.NotBlank;

public record ClientRequest(
		@NotBlank(message = "Le prénom est obligatoire") String prenom,
		@NotBlank(message = "Le nom est obligatoire") String nom,
		@NotBlank(message = "Le téléphone est obligatoire") String telephone,
		String email,
		Integer taille,
		Integer poitrine,
		Integer tourDeTaille,
		Integer hanches
) {
}
