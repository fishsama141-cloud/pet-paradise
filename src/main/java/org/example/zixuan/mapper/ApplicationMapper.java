/**
 * 申请数据访问层（MyBatis Mapper，包含申请记录的增删改查及状态管理）
 */
package org.example.zixuan.mapper;

import org.apache.ibatis.annotations.*;
import org.example.zixuan.model.Application;
import java.util.List;

@Mapper
public interface ApplicationMapper {

    @Insert("INSERT INTO applications (position_id, student_id, reason, status) " +
            "VALUES (#{positionId}, #{studentId}, #{reason}, 'pending')")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Application application);

    @Update("UPDATE applications SET status = #{status} WHERE id = #{id}")
    int updateStatus(@Param("id") int id, @Param("status") String status);

    @Delete("DELETE FROM applications WHERE id = #{id}")
    int delete(int id);

    @Select("SELECT COUNT(*) FROM applications WHERE student_id = #{studentId} AND position_id = #{positionId}")
    int countByStudentAndPosition(@Param("studentId") int studentId, @Param("positionId") int positionId);

    // XML: JOIN queries
    Application findById(int id);
    List<Application> findByStudent(int studentId);
    List<Application> findByPosition(int positionId);
    List<Application> findApprovedByPosition(int positionId);
}
