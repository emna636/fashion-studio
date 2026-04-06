package com.fashionstudio.service;

import com.fashionstudio.dto.design.DesignRequest;
import com.fashionstudio.dto.design.DesignResponse;
import com.fashionstudio.exception.ResourceNotFoundException;
import com.fashionstudio.model.Design;
import com.fashionstudio.model.User;
import com.fashionstudio.repository.DesignRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class DesignService {

	private final DesignRepository designRepository;
	private final CurrentUserService currentUserService;

	public DesignService(DesignRepository designRepository, CurrentUserService currentUserService) {
		this.designRepository = designRepository;
		this.currentUserService = currentUserService;
	}

	@Transactional(readOnly = true)
	public List<DesignResponse> list() {
		User user = currentUserService.requireUser();
		return designRepository.findAllByUserIdOrderByCreatedAtDesc(user.getId()).stream()
				.map(DesignService::toResponse)
				.toList();
	}

	@Transactional(readOnly = true)
	public DesignResponse get(UUID id) {
		User user = currentUserService.requireUser();
		Design design = designRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Design introuvable"));
		return toResponse(design);
	}

	@Transactional
	public DesignResponse create(DesignRequest req) {
		User user = currentUserService.requireUser();
		Design design = new Design();
		design.setUser(user);
		apply(design, req);
		return toResponse(designRepository.save(design));
	}

	@Transactional
	public DesignResponse update(UUID id, DesignRequest req) {
		User user = currentUserService.requireUser();
		Design design = designRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Design introuvable"));
		apply(design, req);
		return toResponse(designRepository.save(design));
	}

	@Transactional
	public void delete(UUID id) {
		User user = currentUserService.requireUser();
		Design design = designRepository.findByIdAndUserId(id, user.getId())
				.orElseThrow(() -> new ResourceNotFoundException("Design introuvable"));
		designRepository.delete(design);
	}

	private static void apply(Design design, DesignRequest req) {
		design.setNom(req.nom());
		design.setDescription(req.description());
		design.setType(req.type());
		design.setPrix(req.prix());
		design.setImageUrl(req.imageUrl());
	}

	private static DesignResponse toResponse(Design d) {
		return new DesignResponse(
				d.getId(),
				d.getNom(),
				d.getDescription(),
				d.getType(),
				d.getPrix(),
				d.getImageUrl(),
				d.getCreatedAt()
		);
	}
}
