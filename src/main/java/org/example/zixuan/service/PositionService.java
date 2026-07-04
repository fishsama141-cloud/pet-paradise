/**
 * 岗位业务逻辑（岗位的增删改查、按教师/开放状态查询）
 */
package org.example.zixuan.service;

import org.example.zixuan.mapper.PositionMapper;
import org.example.zixuan.model.Position;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PositionService {

    @Autowired
    private PositionMapper positionMapper;

    public boolean create(Position p) { return positionMapper.insert(p) > 0; }
    public boolean update(Position p) { return positionMapper.update(p) > 0; }
    public boolean delete(int id) { return positionMapper.delete(id) > 0; }
    public Position findById(int id) { return positionMapper.findById(id); }
    public List<Position> findOpen() { return positionMapper.findOpen(); }
    public List<Position> findByTeacher(int teacherId) { return positionMapper.findByTeacher(teacherId); }
    public List<Position> findAll() { return positionMapper.findAll(); }
}
