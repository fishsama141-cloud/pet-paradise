/**
 * 身份认证REST API，处理登录、注册、登出及获取当前用户信息
 */
package org.example.zixuan.controller;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.zixuan.dto.LoginRequest;
import org.example.zixuan.dto.RegisterRequest;
import org.example.zixuan.dto.Result;
import org.example.zixuan.model.User;
import org.example.zixuan.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api")
public class ApiAuthController {

    @Autowired
    private UserService userService;

    @GetMapping("/user/current")
    public Result<User> currentUser(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return Result.fail(401, "未登录");
        }
        return Result.ok(user);
    }

    @PostMapping("/login")
    public Result<User> login(@RequestBody LoginRequest req,
                               HttpSession session,
                               HttpServletResponse response) {
        if (req.getName() == null || req.getName().trim().isEmpty()
                || req.getNumber() == null || req.getNumber().trim().isEmpty()) {
            return Result.fail(400, "姓名和学号/工号不能为空！");
        }
        User user = userService.loginByRole(req.getName().trim(), req.getNumber().trim(),
                req.getPassword(), req.getRole());
        if (user != null) {
            session.setAttribute("user", user);
            if ("on".equals(req.getRemember())) {
                String token = userService.generateAutoLoginToken(user.getId());
                Cookie cookie = new Cookie("autoLoginToken",
                        URLEncoder.encode(token, StandardCharsets.UTF_8));
                cookie.setMaxAge(60 * 60 * 24 * 7);
                cookie.setPath("/");
                response.addCookie(cookie);
            }
            return Result.ok(user);
        }
        return Result.fail(400, "姓名、学号/工号或密码错误！");
    }

    @PostMapping("/register")
    public Result<Void> register(@RequestBody RegisterRequest req) {
        if (req.getPassword() == null || req.getPassword().trim().isEmpty() ||
                req.getName() == null || req.getName().trim().isEmpty() ||
                req.getNumber() == null || req.getNumber().trim().isEmpty()) {
            return Result.fail(400, "必填项不能为空！");
        }
        if (!req.getPassword().equals(req.getConfirmPassword())) {
            return Result.fail(400, "两次密码输入不一致！");
        }
        if (req.getPassword().length() < 6) {
            return Result.fail(400, "密码长度不能少于6位！");
        }

        User user = new User();
        user.setUsername(req.getName().trim() + req.getNumber().trim());
        user.setNumber(req.getNumber().trim());
        user.setPassword(req.getPassword());
        user.setName(req.getName().trim());
        user.setRole(req.getRole() != null ? req.getRole() : "student");
        user.setEmail(req.getEmail() != null ? req.getEmail().trim() : "");
        user.setPhone(req.getPhone() != null ? req.getPhone().trim() : "");
        user.setClassName(req.getClassName() != null ? req.getClassName().trim() : "");

        if (userService.register(user)) {
            return Result.ok("注册成功", null);
        }
        return Result.fail(400, "注册失败，用户名可能已存在！");
    }

    @PostMapping("/logout")
    public Result<Void> logout(HttpServletRequest request, HttpServletResponse response) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("autoLoginToken".equals(cookie.getName())) {
                    String token = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8);
                    userService.removeToken(token);
                    Cookie c = new Cookie("autoLoginToken", "");
                    c.setMaxAge(0);
                    c.setPath("/");
                    response.addCookie(c);
                }
            }
        }
        request.getSession().invalidate();
        return Result.ok(null);
    }
}
