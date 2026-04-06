package com.fashionstudio.repository;

import com.fashionstudio.model.Design;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DesignRepository extends JpaRepository<Design, UUID> {
	List<Design> findAllByUserIdOrderByCreatedAtDesc(UUID userId);
	Optional<Design> findByIdAndUserId(UUID id, UUID userId);
}
