package org.example.pets.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;

@WebListener
public class DatabaseInitListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        new Thread(() -> {
            String sql = """
                CREATE TABLE IF NOT EXISTS users (
                    id VARCHAR(36) PRIMARY KEY,
                    username VARCHAR(50) UNIQUE NOT NULL,
                    password VARCHAR(100) NOT NULL,
                    email VARCHAR(100),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS pets (
                    id VARCHAR(36) PRIMARY KEY,
                    user_id VARCHAR(36) NOT NULL,
                    name VARCHAR(50) NOT NULL,
                    species VARCHAR(50) NOT NULL,
                    emoji VARCHAR(10),
                    region VARCHAR(50),
                    description TEXT,
                    level INT DEFAULT 1,
                    experience INT DEFAULT 0,
                    hunger INT DEFAULT 70,
                    mood INT DEFAULT 70,
                    affinity INT DEFAULT 0,
                    bond INT DEFAULT 0,
                    personality VARCHAR(20) DEFAULT '活泼',
                    rarity VARCHAR(20) DEFAULT 'common',
                    last_interaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    adopted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS activity_log (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    pet_id VARCHAR(36) NOT NULL,
                    message VARCHAR(500),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS user_foods (
                    user_id VARCHAR(36) NOT NULL,
                    food_name VARCHAR(50) NOT NULL,
                    food_emoji VARCHAR(10),
                    quantity INT DEFAULT 0,
                    PRIMARY KEY (user_id, food_name)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS user_regions (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    user_id VARCHAR(36) NOT NULL,
                    region_id VARCHAR(50) NOT NULL,
                    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE KEY uk_user_region (user_id, region_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
                """;
            try (Connection conn = DBUtil.getConnection();
                 Statement stmt = conn.createStatement()) {
                for (String s : sql.split(";")) {
                    String trimmed = s.trim();
                    if (!trimmed.isEmpty()) stmt.execute(trimmed);
                }
                System.out.println("==> Database tables initialized.");
            } catch (SQLException e) {
                System.err.println("DB init error: " + e.getMessage());
            }
        }, "db-init").start();
    }
}
