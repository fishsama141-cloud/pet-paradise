/**
 * 课程安排数据访问层（MyBatis Mapper，包含课程安排的增删改查及多维度关联查询）
 */
package org.example.zixuan.mapper;

import org.apache.ibatis.annotations.*;
import org.example.zixuan.model.Schedule;
import java.util.List;

@Mapper
public interface ScheduleMapper {

    @Insert("INSERT INTO schedules (position_id, student_id, week_day, time_slot, location) " +
            "VALUES (#{positionId}, #{studentId}, #{weekDay}, #{timeSlot}, #{location})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Schedule schedule);

    @Update("UPDATE schedules SET position_id=#{positionId}, student_id=#{studentId}, " +
            "week_day=#{weekDay}, time_slot=#{timeSlot}, location=#{location} WHERE id=#{id}")
    int update(Schedule schedule);

    @Delete("DELETE FROM schedules WHERE id = #{id}")
    int delete(int id);

    // XML: JOIN queries
    List<Schedule> findByStudent(int studentId);
    List<Schedule> findByPosition(int positionId);
    List<Schedule> findByTeacher(int teacherId);
}
