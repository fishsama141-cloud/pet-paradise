/**
 * 用户实体类，表示系统中的学生或教师用户，包含学号/工号、角色、班级、简历及课表路径等信息。
 */
package org.example.zixuan.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class User implements Serializable {
    private int id;
    private String username;
    private String number;             // 学号/教师工号
    private String password;
    private String role;               // student / teacher
    private String name;
    private String email;
    private String phone;
    private String className;          // 班级
    private String resumePath;         // 简历文件路径
    private String courseSchedulePath; // 课表文件路径
    private Timestamp createdAt;

    public User() {}

    public User(int id, String username, String password, String role, String name,
                String email, String phone, String courseSchedulePath, Timestamp createdAt) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.role = role;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.courseSchedulePath = courseSchedulePath;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getNumber() { return number; }
    public void setNumber(String number) { this.number = number; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public String getResumePath() { return resumePath; }
    public void setResumePath(String resumePath) { this.resumePath = resumePath; }

    public String getCourseSchedulePath() { return courseSchedulePath; }
    public void setCourseSchedulePath(String courseSchedulePath) { this.courseSchedulePath = courseSchedulePath; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
