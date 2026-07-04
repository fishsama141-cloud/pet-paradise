/**
 * 课程安排业务逻辑（课程安排的增删改查，按学生/岗位/教师维度查询）
 */
package org.example.zixuan.service;

import org.example.zixuan.mapper.ScheduleMapper;
import org.example.zixuan.model.Schedule;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ScheduleService {

    @Autowired
    private ScheduleMapper scheduleMapper;

    public boolean create(Schedule s) { return scheduleMapper.insert(s) > 0; }
    public boolean update(Schedule s) { return scheduleMapper.update(s) > 0; }
    public boolean delete(int id) { return scheduleMapper.delete(id) > 0; }
    public List<Schedule> findByStudent(int studentId) { return scheduleMapper.findByStudent(studentId); }
    public List<Schedule> findByPosition(int positionId) { return scheduleMapper.findByPosition(positionId); }
    public List<Schedule> findByTeacher(int teacherId) { return scheduleMapper.findByTeacher(teacherId); }
}
