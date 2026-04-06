package com.fashionstudio.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.UuidGenerator;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "commandes")
public class Commande {

	@Id
	@GeneratedValue
	@UuidGenerator
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "client_id", nullable = false)
	private Client client;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "design_id", nullable = false)
	private Design design;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private CommandeStatut statut;

	@Column(nullable = false, precision = 12, scale = 2)
	private BigDecimal prixTotal;

	@Column(nullable = false, precision = 12, scale = 2)
	private BigDecimal montantPaye = BigDecimal.ZERO;

	@Column(nullable = false)
	private LocalDate dateCommande;

	@Column(nullable = false)
	private LocalDate dateLivraison;

	@Column(columnDefinition = "text")
	private String notes;

	@Column(nullable = false, updatable = false)
	private Instant createdAt;

	@PrePersist
	void onCreate() {
		this.createdAt = Instant.now();
	}
}
