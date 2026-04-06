package com.fashionstudio.dto.design;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record DesignResponse(
		UUID id,
		String nom,
		String description,
		String type,
		BigDecimal prix,
		String imageUrl,
		Instant createdAt
) {
}
