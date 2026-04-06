package com.fashionstudio.repository;

import com.fashionstudio.model.Client;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ClientRepository extends JpaRepository<Client, UUID> {
	List<Client> findAllByUserIdOrderByCreatedAtDesc(UUID userId);
	Optional<Client> findByIdAndUserId(UUID id, UUID userId);
}
