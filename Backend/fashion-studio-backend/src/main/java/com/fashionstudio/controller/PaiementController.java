package com.fashionstudio.controller;

import com.fashionstudio.dto.paiement.PaiementRequest;
import com.fashionstudio.dto.paiement.PaiementResponse;
import com.fashionstudio.service.PaiementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/paiements")
public class PaiementController {

	private final PaiementService paiementService;

	public PaiementController(PaiementService paiementService) {
		this.paiementService = paiementService;
	}

	@GetMapping
	public ResponseEntity<List<PaiementResponse>> list() {
		return ResponseEntity.ok(paiementService.list());
	}

	@GetMapping("/{id}")
	public ResponseEntity<PaiementResponse> get(@PathVariable UUID id) {
		return ResponseEntity.ok(paiementService.get(id));
	}

	@PostMapping
	public ResponseEntity<PaiementResponse> create(@Valid @RequestBody PaiementRequest req) {
		return ResponseEntity.ok(paiementService.create(req));
	}

	@PutMapping("/{id}")
	public ResponseEntity<PaiementResponse> update(@PathVariable UUID id, @Valid @RequestBody PaiementRequest req) {
		return ResponseEntity.ok(paiementService.update(id, req));
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> delete(@PathVariable UUID id) {
		paiementService.delete(id);
		return ResponseEntity.noContent().build();
	}
}
