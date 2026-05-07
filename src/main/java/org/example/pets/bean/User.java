package org.example.pets.bean;

import java.io.Serializable;
import java.util.*;

public class User implements Serializable {
    private String id;
    private String username;
    private String password;
    private String email;
    private List<Pet> pets;
    private Date createdAt;

    public User() {
        this.id = UUID.randomUUID().toString();
        this.pets = new ArrayList<>();
        this.createdAt = new Date();
    }

    public User(String username, String password, String email) {
        this();
        this.username = username;
        this.password = password;
        this.email = email;
    }

    public void addPet(Pet pet) {
        pets.add(pet);
    }

    public Pet getPetById(String petId) {
        for (Pet p : pets) {
            if (p.getId().equals(petId)) return p;
        }
        return null;
    }

    public void removePet(String petId) {
        pets.removeIf(p -> p.getId().equals(petId));
    }

    // --- Getters / Setters ---
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public List<Pet> getPets() { return pets; }
    public void setPets(List<Pet> pets) { this.pets = pets; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
