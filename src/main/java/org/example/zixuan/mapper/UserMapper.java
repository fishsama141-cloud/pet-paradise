/**
 * 用户数据访问层（MyBatis Mapper，包含用户CRUD、登录验证及Token管理）
 */
package org.example.zixuan.mapper;

import org.apache.ibatis.annotations.*;
import org.example.zixuan.model.User;
import java.util.List;

@Mapper
public interface UserMapper {

    @Select("SELECT * FROM users WHERE id = #{id}")
    User findById(int id);

    @Select("SELECT * FROM users WHERE username = #{username}")
    User findByUsername(String username);

    @Select("SELECT * FROM users WHERE username = #{username} AND password = #{password}")
    User findByUsernameAndPassword(@Param("username") String username, @Param("password") String password);

    @Select("SELECT * FROM users WHERE name = #{name} AND number = #{number} AND password = #{password} AND role = #{role}")
    User findByNameAndNumberAndPassword(@Param("name") String name, @Param("number") String number,
                                        @Param("password") String password, @Param("role") String role);

    @Select("SELECT * FROM users")
    List<User> findAll();

    @Insert("INSERT INTO users (username, number, password, role, name, email, phone, class_name) " +
            "VALUES (#{username}, #{number}, #{password}, #{role}, #{name}, #{email}, #{phone}, #{className})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(User user);

    @Update("UPDATE users SET name=#{name}, email=#{email}, phone=#{phone}, class_name=#{className}, number=#{number} WHERE id=#{id}")
    int update(User user);

    @Update("UPDATE users SET resume_path = #{path} WHERE id = #{id}")
    int updateResumePath(@Param("id") int id, @Param("path") String path);

    @Update("UPDATE users SET password = #{password} WHERE id = #{id}")
    int updatePassword(@Param("id") int id, @Param("password") String password);

    @Update("UPDATE users SET course_schedule_path = #{path} WHERE id = #{id}")
    int updateSchedulePath(@Param("id") int id, @Param("path") String path);

    @Delete("DELETE FROM users WHERE id = #{id}")
    int delete(int id);

    // login_token operations (XML implementation)
    int insertLoginToken(@Param("userId") int userId, @Param("token") String token);
    User findByToken(String token);
    int deleteToken(String token);
}
