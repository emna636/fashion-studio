package com.fashionstudio.repository;

import com.fashionstudio.model.Paiement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PaiementRepository extends JpaRepository<Paiement, UUID> {
	List<Paiement> findAllByCommandeUserIdOrderByCreatedAtDesc(UUID userId);
	List<Paiement> findAllByCommandeIdAndCommandeUserIdOrderByCreatedAtDesc(UUID commandeId, UUID userId);
	Optional<Paiement> findByIdAndCommandeUserId(UUID id, UUID userId);

	@Query("select coalesce(sum(p.montant), 0) from Paiement p where p.commande.id = :commandeId")
	BigDecimal sumMontantByCommandeId(UUID commandeId);
}
