package com.fashionstudio.dto.commande;

import com.fashionstudio.model.CommandeStatut;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record CommandeResponse(
		UUID id,
		UUID clientId,
		UUID designId,
		CommandeStatut statut,
		BigDecimal prixTotal,
		BigDecimal montantPaye,
		LocalDate dateCommande,
		LocalDate dateLivraison,
		String notes,
		Instant createdAt
) {
}
