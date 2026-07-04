/**
 * 排班实体类，表示学生被录取后安排的执勤时间表，包含星期、时间段、地点及关联的岗位与学生信息。
 */
package org.example.zixuan.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Schedule implements Serializable {
    private int id;
    private int positionId;
    private int studentId;
    private String weekDay;
    private String timeSlot;
    private String location;
    private Timestamp createdAt;

    // 关联字段
    private String positionTitle;
    private String studentName;

    public Schedule() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getWeekDay() { return weekDay; }
    public void setWeekDay(String weekDay) { this.weekDay = weekDay; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getPositionTitle() { return positionTitle; }
    public void setPositionTitle(String positionTitle) { this.positionTitle = positionTitle; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
}
