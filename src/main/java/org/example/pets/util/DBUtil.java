package org.example.pets.util;

import java.sql.*;

public class DBUtil {
    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        String dbUrl = System.getenv("DB_URL");
        if (dbUrl != null && !dbUrl.isEmpty()) {
            URL = dbUrl;
        } else {
            String host = envFirst("DB_HOST", "MYSQLHOST", "localhost");
            String port = envFirst("DB_PORT", "MYSQLPORT", "3306");
            String name = envFirst("DB_NAME", "MYSQLDATABASE", "pets_game");
            URL = "jdbc:mysql://" + host + ":" + port + "/" + name
                + "?connectTimeout=10000&socketTimeout=15000"
                + "&useSSL=false&allowPublicKeyRetrieval=true"
                + "&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8"
                + "&connectionCollation=utf8mb4_unicode_ci";
        }
        USER = envFirst("DB_USER", "MYSQLUSER", "root");
        PASSWORD = envFirst("DB_PASSWORD", "MYSQLPASSWORD", "");
    }

    private static String envFirst(String... keys) {
        for (String k : keys) {
            String v = System.getenv(k);
            if (v != null && !v.isEmpty()) return v;
        }
        return keys[keys.length - 1]; // last arg is the fallback value
    }

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL驱动加载失败", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
}
