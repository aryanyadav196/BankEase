package com.bankease.backend.repository;

import com.bankease.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;
import com.bankease.backend.entity.Role;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    List<User> findByActiveFalseAndRoleIn(
            List<Role> roles
    );
}
