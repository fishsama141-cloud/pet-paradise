/**
 * 申请附件实体类，表示学生提交申请时上传的文件，包含文件名、文件路径及关联的申请ID。
 */
package org.example.zixuan.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ApplicationFile implements Serializable {
    private int id;
    private int applicationId;
    private String fileName;
    private String filePath;
    private Timestamp createdAt;

    public ApplicationFile() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
