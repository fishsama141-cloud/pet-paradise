/**
 * 申请业务逻辑（学生申请岗位、审批状态管理、申请附件管理）
 */
package org.example.zixuan.service;

import org.example.zixuan.mapper.ApplicationFileMapper;
import org.example.zixuan.mapper.ApplicationMapper;
import org.example.zixuan.model.Application;
import org.example.zixuan.model.ApplicationFile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ApplicationService {

    @Autowired
    private ApplicationMapper appMapper;

    @Autowired
    private ApplicationFileMapper fileMapper;

    public boolean apply(Application a) {
        if (appMapper.countByStudentAndPosition(a.getStudentId(), a.getPositionId()) > 0) {
            return false;
        }
        return appMapper.insert(a) > 0;
    }

    public boolean updateStatus(int id, String status) { return appMapper.updateStatus(id, status) > 0; }
    public boolean delete(int id) { return appMapper.delete(id) > 0; }
    public Application findById(int id) { return appMapper.findById(id); }
    public List<Application> findByStudent(int studentId) { return appMapper.findByStudent(studentId); }
    public List<Application> findByPosition(int positionId) { return appMapper.findByPosition(positionId); }
    public List<Application> findApprovedByPosition(int positionId) { return appMapper.findApprovedByPosition(positionId); }

    public boolean saveFile(ApplicationFile file) { return fileMapper.insert(file) > 0; }
    public List<ApplicationFile> getFilesByApplication(int applicationId) { return fileMapper.findByApplicationId(applicationId); }
}
