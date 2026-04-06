package com.fashionstudio.dto.design;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record DesignRequest(
		@NotBlank(message = "Le nom est obligatoire") String nom,
		String description,
		@NotBlank(message = "Le type est obligatoire") String type,
		@NotNull(message = "Le prix est obligatoire") BigDecimal prix,
		String imageUrl
) {
}
