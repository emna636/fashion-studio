package com.fashionstudio.controller;

import com.fashionstudio.dto.commande.CommandeRequest;
import com.fashionstudio.dto.commande.CommandeResponse;
import com.fashionstudio.service.CommandeService;
import com.fashionstudio.service.FacturePdfService;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/commandes")
public class CommandeController {

	private final CommandeService commandeService;
	private final FacturePdfService facturePdfService;

	public CommandeController(CommandeService commandeService, FacturePdfService facturePdfService) {
		this.commandeService = commandeService;
		this.facturePdfService = facturePdfService;
	}

	@GetMapping
	public ResponseEntity<List<CommandeResponse>> list() {
		return ResponseEntity.ok(commandeService.list());
	}

	@GetMapping("/{id}")
	public ResponseEntity<CommandeResponse> get(@PathVariable UUID id) {
		return ResponseEntity.ok(commandeService.get(id));
	}

	@PostMapping
	public ResponseEntity<CommandeResponse> create(@Valid @RequestBody CommandeRequest req) {
		return ResponseEntity.ok(commandeService.create(req));
	}

	@PutMapping("/{id}")
	public ResponseEntity<CommandeResponse> update(@PathVariable UUID id, @Valid @RequestBody CommandeRequest req) {
		return ResponseEntity.ok(commandeService.update(id, req));
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> delete(@PathVariable UUID id) {
		commandeService.delete(id);
		return ResponseEntity.noContent().build();
	}

	@GetMapping(value = "/{id}/facture.pdf", produces = MediaType.APPLICATION_PDF_VALUE)
	public ResponseEntity<byte[]> facturePdf(
			@PathVariable UUID id,
			@RequestParam(name = "type", required = false) FacturePdfService.FactureType type
	) {
		var commande = commandeService.getEntity(id);
		var remaining = commande.getPrixTotal().subtract(commande.getMontantPaye());
		var resolvedType = type;
		if (resolvedType == null) {
			resolvedType = remaining.signum() <= 0 ? FacturePdfService.FactureType.FACTURE : FacturePdfService.FactureType.PROFORMA;
		}

		byte[] pdf = facturePdfService.generate(commande, resolvedType);
		String filename = (resolvedType == FacturePdfService.FactureType.FACTURE ? "facture" : "proforma") + "-" + id + ".pdf";
		return ResponseEntity.ok()
				.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
				.contentType(MediaType.APPLICATION_PDF)
				.body(pdf);
	}
}
