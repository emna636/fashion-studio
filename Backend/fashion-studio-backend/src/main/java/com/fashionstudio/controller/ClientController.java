package com.fashionstudio.controller;

import com.fashionstudio.dto.client.ClientRequest;
import com.fashionstudio.dto.client.ClientResponse;
import com.fashionstudio.service.ClientService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/clients")
public class ClientController {

	private final ClientService clientService;

	public ClientController(ClientService clientService) {
		this.clientService = clientService;
	}

	@GetMapping
	public ResponseEntity<List<ClientResponse>> list() {
		return ResponseEntity.ok(clientService.list());
	}

	@GetMapping("/{id}")
	public ResponseEntity<ClientResponse> get(@PathVariable UUID id) {
		return ResponseEntity.ok(clientService.get(id));
	}

	@PostMapping
	public ResponseEntity<ClientResponse> create(@Valid @RequestBody ClientRequest req) {
		return ResponseEntity.ok(clientService.create(req));
	}

	@PutMapping("/{id}")
	public ResponseEntity<ClientResponse> update(@PathVariable UUID id, @Valid @RequestBody ClientRequest req) {
		return ResponseEntity.ok(clientService.update(id, req));
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> delete(@PathVariable UUID id) {
		clientService.delete(id);
		return ResponseEntity.noContent().build();
	}
}
