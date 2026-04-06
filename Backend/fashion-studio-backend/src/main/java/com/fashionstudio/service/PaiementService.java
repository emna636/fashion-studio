package com.fashionstudio.service;

import com.fashionstudio.dto.paiement.PaiementRequest;
import com.fashionstudio.dto.paiement.PaiementResponse;
import com.fashionstudio.exception.ResourceNotFoundException;
import com.fashionstudio.model.Commande;
import com.fashionstudio.model.CommandeStatut;
import com.fashionstudio.model.Paiement;
import com.fashionstudio.model.User;
import com.fashionstudio.repository.CommandeRepository;
import com.fashionstudio.repository.PaiementRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
public class PaiementService {

	private final PaiementRepository paiementRepository;
	private final CommandeRepository commandeRepository;
	private final CurrentUserService currentUserService;

	public PaiementService(PaiementRepository paiementRepository, CommandeRepository commandeRepository, CurrentUserService currentUserService) {
		this.paiementRepository = paiementRepository;
		this.commandeRepository = commandeRepository;
		this.currentUserService = currentUserService;
	}

	@Transactional(readOnly = true)
	public List<PaiementResponse> list() {
		User user = currentUserService.requireUser();
		return paiementRepository.findAllByCommandeUserIdOrderByCreatedAtDesc(user.getId()).stream()
				.map(PaiementService::toResponse)
				.toList();
	}

	@Transactional(readOnly = true)
	public PaiementResponse get(UUID id) {
		User user = currentUserService.requireUser();
		Paiement paiement = paiementRepository.findByIdAndCommandeUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Paiement introuvable"));
		return toResponse(paiement);
	}

	@Transactional
	public PaiementResponse create(PaiementRequest req) {
		User user = currentUserService.requireUser();
		Commande commande = commandeRepository.findByIdAndUserId(req.commandeId(), user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Commande introuvable"));
		validateRemainingAmount(commande, req.montant(), null);

		Paiement paiement = new Paiement();
		paiement.setCommande(commande);
		apply(paiement, req);
		Paiement saved = paiementRepository.save(paiement);
		recomputeCommandeMontantPaye(commande);
		return toResponse(saved);
	}

	@Transactional
	public PaiementResponse update(UUID id, PaiementRequest req) {
		User user = currentUserService.requireUser();
		Paiement paiement = paiementRepository.findByIdAndCommandeUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Paiement introuvable"));

		Commande commande = commandeRepository.findByIdAndUserId(req.commandeId(), user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Commande introuvable"));
		validateRemainingAmount(commande, req.montant(), paiement);

		paiement.setCommande(commande);
		apply(paiement, req);
		Paiement saved = paiementRepository.save(paiement);
		recomputeCommandeMontantPaye(commande);
		return toResponse(saved);
	}

	@Transactional
	public void delete(UUID id) {
		User user = currentUserService.requireUser();
		Paiement paiement = paiementRepository.findByIdAndCommandeUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Paiement introuvable"));
		Commande commande = paiement.getCommande();
		paiementRepository.delete(paiement);
		recomputeCommandeMontantPaye(commande);
	}

	private static void apply(Paiement paiement, PaiementRequest req) {
		paiement.setMontant(req.montant());
		paiement.setMethodePaiement(req.methodePaiement());
		paiement.setNotes(req.notes());
		paiement.setDatePaiement(req.datePaiement() == null ? LocalDate.now() : req.datePaiement());
	}

	private static PaiementResponse toResponse(Paiement p) {
		return new PaiementResponse(
				p.getId(),
				p.getCommande().getId(),
				p.getMontant(),
				p.getMethodePaiement(),
				p.getNotes(),
				p.getDatePaiement(),
				p.getCreatedAt()
		);
	}

	private void recomputeCommandeMontantPaye(Commande commande) {
		BigDecimal totalPaid = paiementRepository.sumMontantByCommandeId(commande.getId());
		commande.setMontantPaye(totalPaid);
		final boolean fullyPaid = totalPaid.compareTo(commande.getPrixTotal()) >= 0;
		if (fullyPaid && commande.getStatut() != CommandeStatut.LIVRE) {
			commande.setStatut(CommandeStatut.PAYE);
		} else if (!fullyPaid && commande.getStatut() == CommandeStatut.PAYE) {
			commande.setStatut(CommandeStatut.EN_COURS);
		}
		commandeRepository.save(commande);
	}

	private void validateRemainingAmount(Commande commande, BigDecimal newMontant, Paiement existing) {
		if (newMontant == null || newMontant.compareTo(BigDecimal.ZERO) < 0) {
			throw new IllegalArgumentException("Le montant doit être positif");
		}

		BigDecimal alreadyPaid = paiementRepository.sumMontantByCommandeId(commande.getId());
		if (existing != null && existing.getMontant() != null) {
			alreadyPaid = alreadyPaid.subtract(existing.getMontant());
			if (alreadyPaid.compareTo(BigDecimal.ZERO) < 0) {
				alreadyPaid = BigDecimal.ZERO;
			}
		}

		BigDecimal remaining = commande.getPrixTotal().subtract(alreadyPaid);
		if (newMontant.compareTo(remaining) > 0) {
			throw new IllegalArgumentException("Le montant ne peut pas dépasser le reste à payer: " + remaining + " DH");
		}
	}
}
