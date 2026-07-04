/**
 * 处理登录、注册和登出相关的页面导航与表单提交
 */
package org.example.zixuan.controller;

import jakarta.servlet.http.Cookie;
import java.net.URLDecoder;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.zixuan.model.User;
import org.example.zixuan.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
public class AuthController {

    @Autowired
    private UserService userService;

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    @PostMapping("/login")
    public String login(@RequestParam("name") String name,
                        @RequestParam("number") String number,
                        @RequestParam("password") String password,
                        @RequestParam("role") String role,
                        @RequestParam(name = "remember", required = false) String remember,
                        HttpSession session,
                        HttpServletResponse response,
                        Model model) {
        if (name == null || name.trim().isEmpty()
                || number == null || number.trim().isEmpty()) {
            model.addAttribute("error", "姓名和学号/工号不能为空！");
            return "login";
        }
        User user = userService.loginByRole(name.trim(), number.trim(), password, role);
        if (user != null) {
            session.setAttribute("user", user);
            if ("on".equals(remember)) {
                String token = userService.generateAutoLoginToken(user.getId());
                Cookie cookie = new Cookie("autoLoginToken",
                        URLEncoder.encode(token, StandardCharsets.UTF_8));
                cookie.setMaxAge(60 * 60 * 24 * 7);
                cookie.setPath("/");
                response.addCookie(cookie);
            }
            return "redirect:/app";
        }
        model.addAttribute("error", "姓名、学号/工号或密码错误！");
        model.addAttribute("loginRole", role);
        return "login";
    }

    @PostMapping("/register")
    public String register(@RequestParam("password") String password,
                           @RequestParam("confirmPassword") String confirmPassword,
                           @RequestParam("name") String name,
                           @RequestParam("number") String number,
                           @RequestParam(name = "role", required = false, defaultValue = "student") String role,
                           @RequestParam(name = "email", required = false) String email,
                           @RequestParam(name = "phone", required = false) String phone,
                           @RequestParam(name = "className", required = false) String className,
                           Model model) {
        if (password == null || password.trim().isEmpty() ||
                name == null || name.trim().isEmpty() ||
                number == null || number.trim().isEmpty()) {
            model.addAttribute("error", "必填项不能为空！");
            return "register";
        }
        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "两次密码输入不一致！");
            return "register";
        }
        if (password.length() < 6) {
            model.addAttribute("error", "密码长度不能少于6位！");
            return "register";
        }

        User user = new User();
        user.setUsername((name.trim() + number.trim()));
        user.setNumber(number.trim());
        user.setPassword(password);
        user.setName(name.trim());
        user.setRole(role);
        user.setEmail(email != null ? email.trim() : "");
        user.setPhone(phone != null ? phone.trim() : "");
        user.setClassName(className != null ? className.trim() : "");

        if (userService.register(user)) {
            model.addAttribute("success", "注册成功，请登录！");
            return "login";
        } else {
            model.addAttribute("error", "注册失败，用户名可能已存在！");
            return "register";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request, HttpServletResponse response) {
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
        return "redirect:/login.jsp";
    }
}
