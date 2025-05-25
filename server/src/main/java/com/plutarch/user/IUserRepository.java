
package com.plutarch.user;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IUserRepository extends JpaRepository<UserEntity, Long> {
    
    // Custom query methods can be defined here if needed
    UserEntity findByUsername(String username);
    UserEntity findByEmail(String email);
    

    
}
