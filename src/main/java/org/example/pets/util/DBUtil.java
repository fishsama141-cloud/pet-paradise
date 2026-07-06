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
            USER = envFirst("DB_USER", "MYSQLUSER", "root");
            PASSWORD = envFirst("DB_PASSWORD", "MYSQLPASSWORD", "");
        } else {
            String railUrl = System.getenv("DATABASE_URL");
            if (railUrl != null && !railUrl.isEmpty() && railUrl.startsWith("mysql://")) {
                // Railway DATABASE_URL: mysql://user:pass@host:port/db
                String rest = railUrl.substring("mysql://".length());
                int at = rest.indexOf('@');
                String userInfo = rest.substring(0, at);
                String[] up = userInfo.split(":", 2);
                USER = up[0];
                PASSWORD = up.length > 1 ? up[1] : "";
                String hostPart = rest.substring(at + 1);
                URL = "jdbc:mysql://" + hostPart
                    + "?connectTimeout=10000&socketTimeout=15000"
                    + "&useSSL=false&allowPublicKeyRetrieval=true"
                    + "&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8"
                    + "&connectionCollation=utf8mb4_unicode_ci";
            } else {
                String host = envFirst("DB_HOST", "MYSQLHOST", "localhost");
                String port = envFirst("DB_PORT", "MYSQLPORT", "3306");
                String name = envFirst("DB_NAME", "MYSQLDATABASE", "pets_game");
                URL = "jdbc:mysql://" + host + ":" + port + "/" + name
                    + "?connectTimeout=10000&socketTimeout=15000"
                    + "&useSSL=false&allowPublicKeyRetrieval=true"
                    + "&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8"
                    + "&connectionCollation=utf8mb4_unicode_ci";
                USER = envFirst("DB_USER", "MYSQLUSER", "root");
                PASSWORD = envFirst("DB_PASSWORD", "MYSQLPASSWORD", "123456");
            }
        }
    }

    private static String envFirst(String... keys) {
        for (String k : keys) {
            String v = System.getenv(k);
            if (v != null && !v.isEmpty()) return v;
        }
        return keys[keys.length - 1];
    }

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public static Connection getConnection() throws SQLException {
        System.out.println("==> DB connecting to: " + URL);
        Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("SET SESSION sql_mode = 'NO_ENGINE_SUBSTITUTION'");
        }
        return conn;
    }

    public static void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
}
