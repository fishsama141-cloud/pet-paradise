/**
 * 登录请求数据传输对象，封装前端登录表单提交的姓名、学号/工号、密码、角色及记住我参数。
 */
package org.example.zixuan.dto;

public class LoginRequest {
    private String name;
    private String number;
    private String password;
    private String role;
    private String remember;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getNumber() { return number; }
    public void setNumber(String number) { this.number = number; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getRemember() { return remember; }
    public void setRemember(String remember) { this.remember = remember; }
}
