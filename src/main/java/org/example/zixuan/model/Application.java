/**
 * 申请实体类，表示学生对某个岗位的报名申请，包含申请理由、审核状态及学生与岗位的关联信息。
 */
package org.example.zixuan.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class Application implements Serializable {
    private int id;
    private int positionId;
    private int studentId;
    private String reason;
    private String status;      // pending / approved / rejected
    private Timestamp appliedAt;

    // 关联字段
    private String positionTitle;
    private String studentName;
    private String studentNumber;
    private String studentClassName;
    private String studentEmail;
    private String studentPhone;

    // 附件列表
    private List<ApplicationFile> files;

    public Application() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getAppliedAt() { return appliedAt; }
    public void setAppliedAt(Timestamp appliedAt) { this.appliedAt = appliedAt; }

    public String getPositionTitle() { return positionTitle; }
    public void setPositionTitle(String positionTitle) { this.positionTitle = positionTitle; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentNumber() { return studentNumber; }
    public void setStudentNumber(String studentNumber) { this.studentNumber = studentNumber; }

    public String getStudentClassName() { return studentClassName; }
    public void setStudentClassName(String studentClassName) { this.studentClassName = studentClassName; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getStudentPhone() { return studentPhone; }
    public void setStudentPhone(String studentPhone) { this.studentPhone = studentPhone; }

    public List<ApplicationFile> getFiles() { return files; }
    public void setFiles(List<ApplicationFile> files) { this.files = files; }
}
