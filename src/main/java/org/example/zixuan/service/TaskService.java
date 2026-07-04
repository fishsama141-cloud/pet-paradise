/**
 * 任务业务逻辑（任务的增删改查，按学生/岗位/教师维度查询）
 */
package org.example.zixuan.service;

import org.example.zixuan.mapper.TaskMapper;
import org.example.zixuan.model.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TaskService {

    @Autowired
    private TaskMapper taskMapper;

    public boolean create(Task t) { return taskMapper.insert(t) > 0; }
    public boolean update(Task t) { return taskMapper.update(t) > 0; }
    public boolean delete(int id) { return taskMapper.delete(id) > 0; }
    public Task findById(int id) { return taskMapper.findById(id); }
    public List<Task> findByStudent(int studentId) { return taskMapper.findByStudent(studentId); }
    public List<Task> findByPosition(int positionId) { return taskMapper.findByPosition(positionId); }
    public List<Task> findByTeacher(int teacherId) { return taskMapper.findByTeacher(teacherId); }
}
