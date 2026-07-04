/**
 * 申请附件数据访问层（MyBatis Mapper，管理申请所关联的上传文件）
 */
package org.example.zixuan.mapper;

import org.apache.ibatis.annotations.*;
import org.example.zixuan.model.ApplicationFile;
import java.util.List;

@Mapper
public interface ApplicationFileMapper {

    @Insert("INSERT INTO application_files (application_id, file_name, file_path) " +
            "VALUES (#{applicationId}, #{fileName}, #{filePath})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(ApplicationFile file);

    @Select("SELECT * FROM application_files WHERE application_id = #{applicationId}")
    List<ApplicationFile> findByApplicationId(int applicationId);

    @Delete("DELETE FROM application_files WHERE id = #{id}")
    int delete(int id);
}
