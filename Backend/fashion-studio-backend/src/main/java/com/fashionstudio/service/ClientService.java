package com.fashionstudio.service;

import com.fashionstudio.dto.client.ClientRequest;
import com.fashionstudio.dto.client.ClientResponse;
import com.fashionstudio.exception.ResourceNotFoundException;
import com.fashionstudio.model.Client;
import com.fashionstudio.model.User;
import com.fashionstudio.repository.ClientRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class ClientService {

	private final ClientRepository clientRepository;
	private final CurrentUserService currentUserService;

	public ClientService(ClientRepository clientRepository, CurrentUserService currentUserService) {
		this.clientRepository = clientRepository;
		this.currentUserService = currentUserService;
	}

	@Transactional(readOnly = true)
	public List<ClientResponse> list() {
		User user = currentUserService.requireUser();
		return clientRepository.findAllByUserIdOrderByCreatedAtDesc(user.getId()).stream()
				.map(ClientService::toResponse)
				.toList();
	}

	@Transactional(readOnly = true)
	public ClientResponse get(UUID id) {
		User user = currentUserService.requireUser();
		Client client = clientRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Client introuvable"));
		return toResponse(client);
	}

	@Transactional
	public ClientResponse create(ClientRequest req) {
		User user = currentUserService.requireUser();
		Client client = new Client();
		client.setUser(user);
		apply(client, req);
		return toResponse(clientRepository.save(client));
	}

	@Transactional
	public ClientResponse update(UUID id, ClientRequest req) {
		User user = currentUserService.requireUser();
		Client client = clientRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Client introuvable"));
		apply(client, req);
		return toResponse(clientRepository.save(client));
	}

	@Transactional
	public void delete(UUID id) {
		User user = currentUserService.requireUser();
		Client client = clientRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Client introuvable"));
		clientRepository.delete(client);
	}

	private static void apply(Client client, ClientRequest req) {
		client.setPrenom(req.prenom());
		client.setNom(req.nom());
		client.setTelephone(req.telephone());
		client.setEmail(req.email());
		client.setTaille(req.taille());
		client.setPoitrine(req.poitrine());
		client.setTourDeTaille(req.tourDeTaille());
		client.setHanches(req.hanches());
	}

	private static ClientResponse toResponse(Client c) {
		return new ClientResponse(
				c.getId(),
				c.getPrenom(),
				c.getNom(),
				c.getTelephone(),
				c.getEmail(),
				c.getTaille(),
				c.getPoitrine(),
				c.getTourDeTaille(),
				c.getHanches(),
				c.getCreatedAt()
		);
	}
}
