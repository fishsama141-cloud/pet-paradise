package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.User;
import org.example.pets.dao.UserDAO;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("logout".equals(action)) {
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            req.setAttribute("error", "用户名和密码不能为空");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
            return;
        }

        try {
            if ("login".equals(action)) {
                handleLogin(req, resp, username, password);
            } else if ("register".equals(action)) {
                handleRegister(req, resp, username, password);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp,
                             String username, String password) throws SQLException, ServletException, IOException {
        User user = userDAO.login(username, password);
        if (user != null) {
            req.getSession().setAttribute("user", user);
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } else {
            req.setAttribute("error", "用户名或密码错误");
            req.setAttribute("activeTab", "login");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp,
                                String username, String password) throws SQLException, ServletException, IOException {
        if (userDAO.usernameExists(username)) {
            req.setAttribute("error", "用户名已存在");
            req.setAttribute("activeTab", "register");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
            return;
        }
        String email = req.getParameter("email");
        User user = userDAO.register(username, password, email != null ? email : "");
        req.getSession().setAttribute("user", user);
        resp.sendRedirect(req.getContextPath() + "/quiz");
    }
}
