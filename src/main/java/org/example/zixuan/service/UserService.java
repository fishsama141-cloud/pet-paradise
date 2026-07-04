/**
 * 用户业务逻辑（注册、登录、个人信息管理、自动登录Token）
 */
package org.example.zixuan.service;

import org.example.zixuan.mapper.UserMapper;
import org.example.zixuan.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.UUID;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    public User login(String username, String password) {
        return userMapper.findByUsernameAndPassword(username, hashPassword(password));
    }

    public User loginByRole(String name, String number, String password, String role) {
        return userMapper.findByNameAndNumberAndPassword(name, number, hashPassword(password), role);
    }

    public boolean register(User user) {
        if (userMapper.findByUsername(user.getUsername()) != null) return false;
        user.setPassword(hashPassword(user.getPassword()));
        return userMapper.insert(user) > 0;
    }

    public User findById(int id) { return userMapper.findById(id); }
    public boolean update(User user) { return userMapper.update(user) > 0; }
    public boolean updatePassword(int id, String pwd) { return userMapper.updatePassword(id, hashPassword(pwd)) > 0; }
    public List<User> findAll() { return userMapper.findAll(); }
    public boolean delete(int id) { return userMapper.delete(id) > 0; }
    public boolean updateSchedulePath(int id, String path) { return userMapper.updateSchedulePath(id, path) > 0; }

    public boolean updateResumePath(int id, String path) { return userMapper.updateResumePath(id, path) > 0; }

    public String generateAutoLoginToken(int userId) {
        String token = UUID.randomUUID().toString().replace("-", "");
        userMapper.insertLoginToken(userId, token);
        return token;
    }

    public User findByToken(String token) {
        return userMapper.findByToken(token);
    }

    public void removeToken(String token) {
        userMapper.deleteToken(token);
    }
}
