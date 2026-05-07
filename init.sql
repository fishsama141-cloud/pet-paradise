-- ============================================
-- 宠物乐园 (Pet Paradise) 数据库初始化脚本
-- ============================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 宠物表（精简属性：亲密度/默契度/性格）
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
    cleanliness INT DEFAULT 70,
    affinity INT DEFAULT 0,
    bond INT DEFAULT 0,
    personality VARCHAR(20) DEFAULT '活泼',
    last_interaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    adopted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 活动日志表
CREATE TABLE IF NOT EXISTS activity_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id VARCHAR(36) NOT NULL,
    message VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
