package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.*;
import org.example.pets.dao.PetDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/help")
public class HelpServlet extends HttpServlet {
    private PetDAO petDAO;

    @Override public void init() {
        petDAO = new PetDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        try {
            List<Pet> userPets = petDAO.getPetsByUserId(user.getId());
            req.setAttribute("userPets", userPets);
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
        }

        req.getRequestDispatcher("/help.jsp").forward(req, resp);
    }
}
