/**
 * 岗位数据访问层（MyBatis Mapper，包含岗位的增删改查及关联查询）
 */
package org.example.zixuan.mapper;

import org.apache.ibatis.annotations.*;
import org.example.zixuan.model.Position;
import java.util.List;

@Mapper
public interface PositionMapper {

    @Insert("INSERT INTO positions (title, department, description, requirements, location, " +
            "max_students, teacher_id, status) VALUES (#{title}, #{department}, #{description}, " +
            "#{requirements}, #{location}, #{maxStudents}, #{teacherId}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Position position);

    @Update("UPDATE positions SET title=#{title}, department=#{department}, " +
            "description=#{description}, requirements=#{requirements}, " +
            "location=#{location}, max_students=#{maxStudents}, status=#{status} WHERE id=#{id}")
    int update(Position position);

    @Delete("DELETE FROM positions WHERE id = #{id}")
    int delete(int id);

    // XML: JOIN + subquery
    Position findById(int id);
    List<Position> findOpen();
    List<Position> findByTeacher(int teacherId);
    List<Position> findAll();
}
