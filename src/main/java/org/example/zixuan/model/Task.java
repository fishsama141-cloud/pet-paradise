/**
 * 任务实体类，表示教师发布给学生的具体工作任务，包含任务标题、描述、地点、附件、截止日期及完成状态。
 */
package org.example.zixuan.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonFormat;

public class Task implements Serializable {
    private int id;
    private int positionId;
    private int studentId;
    private String title;
    private String description;
    private String location;    // 任务地点
    private String filePath;    // 附件路径
    private String status;      // pending / in_progress / completed
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date deadline;
    private Timestamp createdAt;

    // 关联字段
    private String positionTitle;
    private String studentName;

    public Task() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getDeadline() { return deadline; }
    public void setDeadline(Date deadline) { this.deadline = deadline; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getPositionTitle() { return positionTitle; }
    public void setPositionTitle(String positionTitle) { this.positionTitle = positionTitle; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
}
