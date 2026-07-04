/**
 * 任务数据访问层（MyBatis Mapper，包含任务的增删改查及多维度关联查询）
 */
package org.example.zixuan.mapper;

import org.apache.ibatis.annotations.*;
import org.example.zixuan.model.Task;
import java.util.List;

@Mapper
public interface TaskMapper {

    @Insert("INSERT INTO tasks (position_id, student_id, title, description, location, file_path, status, deadline) " +
            "VALUES (#{positionId}, #{studentId}, #{title}, #{description}, #{location}, #{filePath}, #{status}, #{deadline})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Task task);

    @Update("UPDATE tasks SET title=#{title}, description=#{description}, location=#{location}, " +
            "file_path=#{filePath}, position_id=#{positionId}, student_id=#{studentId}, status=#{status}, deadline=#{deadline} WHERE id=#{id}")
    int update(Task task);

    @Delete("DELETE FROM tasks WHERE id = #{id}")
    int delete(int id);

    // XML: JOIN queries
    Task findById(int id);
    List<Task> findByStudent(int studentId);
    List<Task> findByPosition(int positionId);
    List<Task> findByTeacher(int teacherId);
}
