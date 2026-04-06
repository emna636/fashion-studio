package com.fashionstudio.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record SignupRequest(
		@NotBlank(message = "Le nom est obligatoire") String nom,
		@NotBlank(message = "L'atelier est obligatoire") String atelier,
		@NotBlank(message = "L'email est obligatoire") @Email(message = "Email invalide") String email,
		@NotBlank(message = "Le mot de passe est obligatoire") String password
) {
}
