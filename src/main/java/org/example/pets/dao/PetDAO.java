package org.example.pets.dao;

import org.example.pets.bean.Pet;
import org.example.pets.util.DBUtil;

import java.sql.*;
import java.util.*;

public class PetDAO {

    public void addPet(String userId, Pet pet) throws SQLException {
        String sql = "INSERT INTO pets (id, user_id, name, species, emoji, region, description, " +
                "level, experience, hunger, mood, affinity, bond, personality, rarity) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setPetFields(ps, pet, userId, 1);
            ps.executeUpdate();
        }
    }

    public List<Pet> getPetsByUserId(String userId) throws SQLException {
        List<Pet> pets = new ArrayList<>();
        String sql = "SELECT * FROM pets WHERE user_id = ? ORDER BY adopted_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    pets.add(mapPet(rs));
                }
            }
        }
        return pets;
    }

    public Pet getPetById(String petId) throws SQLException {
        String sql = "SELECT * FROM pets WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, petId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapPet(rs);
            }
        }
        return null;
    }

    public void updatePet(Pet pet) throws SQLException {
        String sql = "UPDATE pets SET level=?, experience=?, hunger=?, mood=?, " +
                "affinity=?, bond=?, personality=?, rarity=?, last_interaction=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pet.getLevel());
            ps.setInt(2, pet.getExperience());
            ps.setInt(3, pet.getHunger());
            ps.setInt(4, pet.getMood());
            ps.setInt(5, pet.getAffinity());
            ps.setInt(6, pet.getBond());
            ps.setString(7, pet.getPersonality());
            ps.setString(8, pet.getRarity() != null ? pet.getRarity() : "common");
            ps.setTimestamp(9, new Timestamp(pet.getLastInteraction().getTime()));
            ps.setString(10, pet.getId());
            ps.executeUpdate();
        }
    }

    public void addActivityLog(String petId, String message) throws SQLException {
        String sql = "INSERT INTO activity_log (pet_id, message) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, petId);
            ps.setString(2, message);
            ps.executeUpdate();
        }
    }

    public int getPetCountByUserId(String userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM pets WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public void deletePet(String petId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM activity_log WHERE pet_id = ?")) {
                ps.setString(1, petId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM pets WHERE id = ?")) {
                ps.setString(1, petId);
                ps.executeUpdate();
            }
        }
    }

    public List<String> getActivityLog(String petId) throws SQLException {
        List<String> logs = new ArrayList<>();
        String sql = "SELECT message FROM activity_log WHERE pet_id = ? ORDER BY created_at DESC LIMIT 30";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, petId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) logs.add(rs.getString("message"));
            }
        }
        return logs;
    }

    private Pet mapPet(ResultSet rs) throws SQLException {
        Pet pet = new Pet();
        pet.setId(rs.getString("id"));
        pet.setName(rs.getString("name"));
        pet.setSpecies(rs.getString("species"));
        pet.setEmoji(rs.getString("emoji"));
        pet.setRegion(rs.getString("region"));
        pet.setDescription(rs.getString("description"));
        pet.setLevel(rs.getInt("level"));
        pet.setExperience(rs.getInt("experience"));
        pet.setHunger(rs.getInt("hunger"));
        pet.setMood(rs.getInt("mood"));
        pet.setAffinity(rs.getInt("affinity"));
        pet.setBond(rs.getInt("bond"));
        pet.setPersonality(rs.getString("personality"));
        pet.setRarity(rs.getString("rarity"));
        pet.setLastInteraction(rs.getTimestamp("last_interaction"));
        pet.setAdoptedAt(rs.getTimestamp("adopted_at"));
        return pet;
    }

    private void setPetFields(PreparedStatement ps, Pet pet, String userId, int idx) throws SQLException {
        ps.setString(idx++, pet.getId());
        ps.setString(idx++, userId);
        ps.setString(idx++, pet.getName());
        ps.setString(idx++, pet.getSpecies());
        ps.setString(idx++, pet.getEmoji());
        ps.setString(idx++, pet.getRegion());
        ps.setString(idx++, pet.getDescription());
        ps.setInt(idx++, pet.getLevel());
        ps.setInt(idx++, pet.getExperience());
        ps.setInt(idx++, pet.getHunger());
        ps.setInt(idx++, pet.getMood());
        ps.setInt(idx++, pet.getAffinity());
        ps.setInt(idx++, pet.getBond());
        ps.setString(idx++, pet.getPersonality());
        ps.setString(idx++, pet.getRarity() != null ? pet.getRarity() : "common");
    }

    // ==================== 食物库存 ====================

    /** 获得食物（已有则叠加数量） */
    public void addFood(String userId, String foodName, String foodEmoji, int qty) throws SQLException {
        String sql = "INSERT INTO user_foods (user_id, food_name, food_emoji, quantity) VALUES (?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE quantity = quantity + ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, foodName);
            ps.setString(3, foodEmoji);
            ps.setInt(4, qty);
            ps.setInt(5, qty);
            ps.executeUpdate();
        }
    }

    /** 消耗一个食物，数量-1，数量归零则删除行。返回剩余数量 */
    public int consumeFood(String userId, String foodName) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE user_foods SET quantity = quantity - 1 WHERE user_id = ? AND food_name = ? AND quantity > 0")) {
                ps.setString(1, userId);
                ps.setString(2, foodName);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM user_foods WHERE user_id = ? AND food_name = ? AND quantity <= 0")) {
                ps.setString(1, userId);
                ps.setString(2, foodName);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT quantity FROM user_foods WHERE user_id = ? AND food_name = ?")) {
                ps.setString(1, userId);
                ps.setString(2, foodName);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /** 获取用户所有食物 */
    public List<String[]> getUserFoods(String userId) throws SQLException {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT food_name, food_emoji, quantity FROM user_foods WHERE user_id = ? ORDER BY food_name";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{rs.getString("food_name"), rs.getString("food_emoji"), String.valueOf(rs.getInt("quantity"))});
                }
            }
        }
        return list;
    }

    // ==================== 区域解锁管理 ====================

    /** 确保 user_regions 表存在 */
    public void ensureRegionTable() throws SQLException {
        String sql = "CREATE TABLE IF NOT EXISTS user_regions ("
            + "id INT AUTO_INCREMENT PRIMARY KEY, "
            + "user_id VARCHAR(36) NOT NULL, "
            + "region_id VARCHAR(50) NOT NULL, "
            + "unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
            + "UNIQUE KEY uk_user_region (user_id, region_id))";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    /** 为用户解锁一个区域 */
    public void unlockRegion(String userId, String regionId) throws SQLException {
        String sql = "INSERT IGNORE INTO user_regions (user_id, region_id) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, regionId);
            ps.executeUpdate();
        }
    }

    /** 获取用户已解锁的区域ID集合 */
    public Set<String> getUnlockedRegionIds(String userId) throws SQLException {
        Set<String> regions = new java.util.LinkedHashSet<>();
        String sql = "SELECT region_id FROM user_regions WHERE user_id = ? ORDER BY unlocked_at";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    regions.add(rs.getString("region_id"));
                }
            }
        }
        return regions;
    }

    /** 获取用户已解锁的区域数量 */
    public int getUnlockedRegionCount(String userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user_regions WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }
}
