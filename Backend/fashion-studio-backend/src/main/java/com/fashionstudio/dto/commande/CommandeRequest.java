package com.fashionstudio.dto.commande;

import com.fashionstudio.model.CommandeStatut;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CommandeRequest(
		@NotNull(message = "Le client est obligatoire") UUID clientId,
		@NotNull(message = "Le design est obligatoire") UUID designId,
		@NotNull(message = "Le statut est obligatoire") CommandeStatut statut,
		@NotNull(message = "Le prix total est obligatoire") BigDecimal prixTotal,
		@NotNull(message = "Le montant payé est obligatoire") BigDecimal montantPaye,
		@NotNull(message = "La date de commande est obligatoire") LocalDate dateCommande,
		@NotNull(message = "La date de livraison est obligatoire") LocalDate dateLivraison,
		String notes
) {
}
