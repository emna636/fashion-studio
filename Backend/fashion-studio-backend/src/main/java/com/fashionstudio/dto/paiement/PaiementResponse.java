package com.fashionstudio.dto.paiement;

import com.fashionstudio.model.MethodePaiement;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record PaiementResponse(
		UUID id,
		UUID commandeId,
		BigDecimal montant,
		MethodePaiement methodePaiement,
		String notes,
		LocalDate datePaiement,
		Instant createdAt
) {
}
