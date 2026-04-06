package com.fashionstudio.repository;

import com.fashionstudio.model.Commande;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CommandeRepository extends JpaRepository<Commande, UUID> {
	List<Commande> findAllByUserIdOrderByCreatedAtDesc(UUID userId);
	Optional<Commande> findByIdAndUserId(UUID id, UUID userId);
}
