/**
 * 注册请求数据传输对象，封装前端注册表单提交的用户名、姓名、学号/工号、密码、角色、邮箱、电话及班级信息。
 */
package org.example.zixuan.dto;

public class RegisterRequest {
    private String username;
    private String name;
    private String number;
    private String password;
    private String confirmPassword;
    private String role;
    private String email;
    private String phone;
    private String className;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getNumber() { return number; }
    public void setNumber(String number) { this.number = number; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
}
