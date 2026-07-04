/**
 * 岗位实体类，表示教师发布的助管岗位，包含岗位名称、部门、要求、最大人数、当前状态及已录取学生等信息。
 */
package org.example.zixuan.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class Position implements Serializable {
    private int id;
    private String title;
    private String department;
    private String description;
    private String requirements;
    private String location;
    private int maxStudents;
    private int teacherId;
    private String teacherName;
    private String status;      // open / closed
    private int currentCount;   // 当前已录取人数
    private Timestamp createdAt;
    private transient List<Application> approvedStudents;

    public Position() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getRequirements() { return requirements; }
    public void setRequirements(String requirements) { this.requirements = requirements; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public int getMaxStudents() { return maxStudents; }
    public void setMaxStudents(int maxStudents) { this.maxStudents = maxStudents; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCurrentCount() { return currentCount; }
    public void setCurrentCount(int currentCount) { this.currentCount = currentCount; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<Application> getApprovedStudents() { return approvedStudents; }
    public void setApprovedStudents(List<Application> approvedStudents) { this.approvedStudents = approvedStudents; }
}
