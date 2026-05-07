package org.example.pets.bean;

import java.io.Serializable;

public class WildPet implements Serializable {
    private String species;
    private String emoji;
    private String region;
    private String regionName;
    private int requiredLevel;
    private String description;
    private int baseStrength;
    private int baseAgility;
    private int baseIntelligence;
    private int baseCharm;
    private int baseDefense;
    private double encounterRate;

    public WildPet() {}

    public WildPet(String species, String emoji, String region, String regionName,
                   int requiredLevel, String description,
                   int baseStrength, int baseAgility, int baseIntelligence,
                   int baseCharm, int baseDefense, double encounterRate) {
        this.species = species;
        this.emoji = emoji;
        this.region = region;
        this.regionName = regionName;
        this.requiredLevel = requiredLevel;
        this.description = description;
        this.baseStrength = baseStrength;
        this.baseAgility = baseAgility;
        this.baseIntelligence = baseIntelligence;
        this.baseCharm = baseCharm;
        this.baseDefense = baseDefense;
        this.encounterRate = encounterRate;
    }

    // --- Getters ---
    public String getSpecies() { return species; }
    public String getEmoji() { return emoji; }
    public String getRegion() { return region; }
    public String getRegionName() { return regionName; }
    public int getRequiredLevel() { return requiredLevel; }
    public String getDescription() { return description; }
    public int getBaseStrength() { return baseStrength; }
    public int getBaseAgility() { return baseAgility; }
    public int getBaseIntelligence() { return baseIntelligence; }
    public int getBaseCharm() { return baseCharm; }
    public int getBaseDefense() { return baseDefense; }
    public double getEncounterRate() { return encounterRate; }

    public String getRequiredLevelDisplay() {
        return "Lv." + requiredLevel + "+";
    }
}
