<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.util.DBUtil,java.sql.*" %>
<%
    String key = request.getParameter("key");
    if (!"pets2026".equals(key)) {
        out.println("<h2>需要正确的 key 参数</h2>");
        return;
    }
    try (Connection conn = DBUtil.getConnection();
         Statement stmt = conn.createStatement()) {
        stmt.execute("DROP TABLE IF EXISTS activity_log");
        stmt.execute("DROP TABLE IF EXISTS user_foods");
        stmt.execute("DROP TABLE IF EXISTS user_regions");
        stmt.execute("DROP TABLE IF EXISTS pets");
        stmt.execute("DROP TABLE IF EXISTS users");

        stmt.execute("CREATE TABLE users (id VARCHAR(36) PRIMARY KEY, username VARCHAR(50) UNIQUE NOT NULL, password VARCHAR(100) NOT NULL, email VARCHAR(100), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        stmt.execute("CREATE TABLE pets (id VARCHAR(36) PRIMARY KEY, user_id VARCHAR(36) NOT NULL, name VARCHAR(50) NOT NULL, species VARCHAR(50) NOT NULL, emoji VARCHAR(10), region VARCHAR(50), description TEXT, level INT DEFAULT 1, experience INT DEFAULT 0, hunger INT DEFAULT 70, mood INT DEFAULT 70, affinity INT DEFAULT 0, bond INT DEFAULT 0, personality VARCHAR(20) DEFAULT '活泼', rarity VARCHAR(20) DEFAULT 'common', last_interaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP, adopted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        stmt.execute("CREATE TABLE activity_log (id INT AUTO_INCREMENT PRIMARY KEY, pet_id VARCHAR(36) NOT NULL, message VARCHAR(500), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        stmt.execute("CREATE TABLE user_foods (user_id VARCHAR(36) NOT NULL, food_name VARCHAR(50) NOT NULL, food_emoji VARCHAR(10), quantity INT DEFAULT 0, PRIMARY KEY (user_id, food_name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        stmt.execute("CREATE TABLE user_regions (id INT AUTO_INCREMENT PRIMARY KEY, user_id VARCHAR(36) NOT NULL, region_id VARCHAR(50) NOT NULL, unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY uk_user_region (user_id, region_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        out.println("<h2>数据库已重置</h2><p>关闭此页面，回到首页重新注册即可。</p>");
    } catch (SQLException e) {
        out.println("<h2>重置出错: " + e.getMessage() + "</h2>");
    }
%>
