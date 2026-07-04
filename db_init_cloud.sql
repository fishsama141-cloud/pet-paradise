-- 云数据库初始化（不用 CREATE DATABASE 和 USE，云服务商已给你建好库）
-- 直接执行建表和插入即可

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    number VARCHAR(50) DEFAULT NULL COMMENT '学号/工号',
    password VARCHAR(255) NOT NULL,
    role ENUM('student', 'teacher') NOT NULL DEFAULT 'student',
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    class_name VARCHAR(50) DEFAULT NULL COMMENT '班级',
    resume_path VARCHAR(255) DEFAULT NULL COMMENT '简历文件路径',
    course_schedule_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 岗位表
CREATE TABLE IF NOT EXISTS positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    requirements TEXT,
    location VARCHAR(200),
    max_students INT DEFAULT 1,
    teacher_id INT NOT NULL,
    status ENUM('open', 'closed') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 申请表
CREATE TABLE IF NOT EXISTS applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    position_id INT NOT NULL,
    student_id INT NOT NULL,
    reason TEXT,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 排班表
CREATE TABLE IF NOT EXISTS schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    position_id INT NOT NULL,
    student_id INT NOT NULL,
    week_day VARCHAR(20) NOT NULL,
    time_slot VARCHAR(50) NOT NULL,
    location VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 任务表
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    position_id INT NOT NULL,
    student_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    deadline DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Cookie自动登录令牌表
CREATE TABLE IF NOT EXISTS login_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 测试数据（密码均为 123456 的 MD5 加密）
INSERT IGNORE INTO users (username, number, password, role, name, email) VALUES
('teacher1', 'T001', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '张老师', 'teacher1@school.edu.cn'),
('student1', 'S001', 'e10adc3949ba59abbe56e057f20f883e', 'student', '李同学', 'student1@school.edu.cn'),
('student2', 'S002', 'e10adc3949ba59abbe56e057f20f883e', 'student', '王同学', 'student2@school.edu.cn');
