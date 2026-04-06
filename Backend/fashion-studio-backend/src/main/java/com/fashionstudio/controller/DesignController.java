package com.fashionstudio.controller;

import com.fashionstudio.dto.design.DesignRequest;
import com.fashionstudio.dto.design.DesignResponse;
import com.fashionstudio.service.DesignService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/designs")
public class DesignController {

	private final DesignService designService;

	public DesignController(DesignService designService) {
		this.designService = designService;
	}

	@GetMapping
	public ResponseEntity<List<DesignResponse>> list() {
		return ResponseEntity.ok(designService.list());
	}

	@GetMapping("/{id}")
	public ResponseEntity<DesignResponse> get(@PathVariable UUID id) {
		return ResponseEntity.ok(designService.get(id));
	}

	@PostMapping
	public ResponseEntity<DesignResponse> create(@Valid @RequestBody DesignRequest req) {
		return ResponseEntity.ok(designService.create(req));
	}

	@PutMapping("/{id}")
	public ResponseEntity<DesignResponse> update(@PathVariable UUID id, @Valid @RequestBody DesignRequest req) {
		return ResponseEntity.ok(designService.update(id, req));
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> delete(@PathVariable UUID id) {
		designService.delete(id);
		return ResponseEntity.noContent().build();
	}
}
