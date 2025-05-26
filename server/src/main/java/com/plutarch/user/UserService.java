package com.plutarch.user;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService{

    private final IUserRepository userRepository;

    private final ModelMapper modelMapper;

    @Autowired
    public UserService(IUserRepository userRepository, ModelMapper modelMapper) {
        this.userRepository = userRepository;
        this.modelMapper = modelMapper;
    }

 
    public List<UserDto> getAllUsers() {
        return userRepository.findAll().stream()
                .map(user -> new UserDto(
                        user.getId(),
                        user.getUsername(),
                        user.getPassword(),
                        user.getEmail(),
                        user.getFirstName(),
                        user.getLastName()))
                .toList();
    }

    public UserDto getUserById(Long id) {
        UserEntity user = userRepository.findById(id)
        .orElse(null);
        
        if (user == null) {
            return null; 
        }

        return new UserDto(
            user.getId(),
            user.getUsername(),
            user.getPassword(),
            user.getEmail(),
            user.getFirstName(),
            user.getLastName()
        );
    }

    // public UserEntity createUser(UserDto dto) {
    //     UserEntity userEntity = convertToEntity(dto);
    //     return userRepository.save(userEntity);
    // }

    // public UserEntity updateUser(Long id, UserDto dto) {
    //     UserEntity existingUser = userRepository.findById(id)
    //             .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
    //     modelMapper.map(dto, existingUser);

    //     return userRepository.save(existingUser);
    // }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
    
}
