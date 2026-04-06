package com.fashionstudio.dto.paiement;

import com.fashionstudio.model.MethodePaiement;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record PaiementRequest(
		@NotNull(message = "La commande est obligatoire") UUID commandeId,
		@NotNull(message = "Le montant est obligatoire") BigDecimal montant,
		@NotNull(message = "La méthode de paiement est obligatoire") MethodePaiement methodePaiement,
		String notes,
		LocalDate datePaiement
) {
}
