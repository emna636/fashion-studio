package com.fashionstudio.service;

import com.fashionstudio.dto.commande.CommandeRequest;
import com.fashionstudio.dto.commande.CommandeResponse;
import com.fashionstudio.exception.ResourceNotFoundException;
import com.fashionstudio.model.Client;
import com.fashionstudio.model.Commande;
import com.fashionstudio.model.Design;
import com.fashionstudio.model.User;
import com.fashionstudio.repository.ClientRepository;
import com.fashionstudio.repository.CommandeRepository;
import com.fashionstudio.repository.DesignRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class CommandeService {

	private final CommandeRepository commandeRepository;
	private final ClientRepository clientRepository;
	private final DesignRepository designRepository;
	private final CurrentUserService currentUserService;

	public CommandeService(
			CommandeRepository commandeRepository,
			ClientRepository clientRepository,
			DesignRepository designRepository,
			CurrentUserService currentUserService
	) {
		this.commandeRepository = commandeRepository;
		this.clientRepository = clientRepository;
		this.designRepository = designRepository;
		this.currentUserService = currentUserService;
	}

	@Transactional(readOnly = true)
	public List<CommandeResponse> list() {
		User user = currentUserService.requireUser();
		return commandeRepository.findAllByUserIdOrderByCreatedAtDesc(user.getId()).stream()
				.map(CommandeService::toResponse)
				.toList();
	}

	@Transactional(readOnly = true)
	public CommandeResponse get(UUID id) {
		User user = currentUserService.requireUser();
		Commande commande = commandeRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Commande introuvable"));
		return toResponse(commande);
	}

	@Transactional(readOnly = true)
	public Commande getEntity(UUID id) {
		User user = currentUserService.requireUser();
		return commandeRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Commande introuvable"));
	}

	@Transactional
	public CommandeResponse create(CommandeRequest req) {
		User user = currentUserService.requireUser();
		Client client = clientRepository.findByIdAndUserId(req.clientId(), user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Client introuvable"));
		Design design = designRepository.findByIdAndUserId(req.designId(), user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Design introuvable"));
		if (req.montantPaye().compareTo(req.prixTotal()) > 0) {
			throw new IllegalArgumentException("Le montant payé ne peut pas dépasser le prix total");
		}

		Commande commande = new Commande();
		commande.setUser(user);
		commande.setClient(client);
		commande.setDesign(design);
		apply(commande, req);
		return toResponse(commandeRepository.save(commande));
	}

	@Transactional
	public CommandeResponse update(UUID id, CommandeRequest req) {
		User user = currentUserService.requireUser();
		Commande commande = commandeRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Commande introuvable"));
		if (req.montantPaye().compareTo(req.prixTotal()) > 0) {
			throw new IllegalArgumentException("Le montant payé ne peut pas dépasser le prix total");
		}

		Client client = clientRepository.findByIdAndUserId(req.clientId(), user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Client introuvable"));
		Design design = designRepository.findByIdAndUserId(req.designId(), user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Design introuvable"));

		commande.setClient(client);
		commande.setDesign(design);
		apply(commande, req);
		return toResponse(commandeRepository.save(commande));
	}

	@Transactional
	public void delete(UUID id) {
		User user = currentUserService.requireUser();
		Commande commande = commandeRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Commande introuvable"));
		commandeRepository.delete(commande);
	}

	private static void apply(Commande commande, CommandeRequest req) {
		commande.setStatut(req.statut());
		commande.setPrixTotal(req.prixTotal());
		commande.setMontantPaye(req.montantPaye());
		commande.setDateCommande(req.dateCommande());
		commande.setDateLivraison(req.dateLivraison());
		commande.setNotes(req.notes());
	}

	private static CommandeResponse toResponse(Commande c) {
		return new CommandeResponse(
				c.getId(),
				c.getClient().getId(),
				c.getDesign().getId(),
				c.getStatut(),
				c.getPrixTotal(),
				c.getMontantPaye(),
				c.getDateCommande(),
				c.getDateLivraison(),
				c.getNotes(),
				c.getCreatedAt()
		);
	}
}
