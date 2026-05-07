package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.*;
import org.example.pets.dao.PetDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/pet")
public class PetServlet extends HttpServlet {

    private PetDAO petDAO;

    @Override
    public void init() {
        petDAO = new PetDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        String action = req.getParameter("action");
        String petId = req.getParameter("petId");

        try {
            if ("interact".equals(action) && petId != null) {
                Pet pet = petDAO.getPetById(petId);
                if (pet != null) {
                    pet.decay();
                    List<String> logs = petDAO.getActivityLog(petId);
                    pet.getActivityLog().clear();
                    pet.getActivityLog().addAll(logs);
                    req.setAttribute("pet", pet);

                    // Load food inventory for feed UI
                    List<String[]> foods = petDAO.getUserFoods(user.getId());
                    req.setAttribute("foodInventory", foods);
                    req.setAttribute("favFood", FoodDef.getFavoriteFood(pet.getSpecies()));
                    req.setAttribute("disFood", FoodDef.getDislikedFood(pet.getSpecies()));
                    req.setAttribute("petCount", petDAO.getPetCountByUserId(user.getId()));
                }
                req.getRequestDispatcher("/interact.jsp").forward(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        String action = req.getParameter("action");
        String petId = req.getParameter("petId");

        try {
            if ("feed".equals(action) || "play".equals(action)) {
                handleInteraction(req, resp, user, petId, action);
            } else if ("release".equals(action)) {
                handleRelease(req, resp, user, petId);
            } else if ("adopt".equals(action)) {
                handleAdopt(req, resp, user);
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
        }
    }

    private void handleInteraction(HttpServletRequest req, HttpServletResponse resp,
                                   User user, String petId, String action)
            throws SQLException, ServletException, IOException {
        Pet pet = petDAO.getPetById(petId);
        if (pet == null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        pet.decay();

        String foodName = req.getParameter("foodName");
        String foodEmoji = req.getParameter("foodEmoji");
        if ("feed".equals(action) && foodName != null && !foodName.isEmpty()) {
            // 消耗食物
            petDAO.consumeFood(user.getId(), foodName);
            String pref = FoodDef.checkPreference(pet.getSpecies(), foodName);
            pet.feed(foodName, foodEmoji != null ? foodEmoji : "🍖", pref);
        } else if ("feed".equals(action)) {
            req.setAttribute("error", "请选择一个食物！");
        } else if ("play".equals(action)) {
            pet.play();
        }

        petDAO.updatePet(pet);

        // Save activity log to DB
        for (String log : pet.getActivityLog()) {
            petDAO.addActivityLog(petId, log);
        }

        // Reload logs from DB
        List<String> logs = petDAO.getActivityLog(petId);
        pet.getActivityLog().clear();
        pet.getActivityLog().addAll(logs);

        // Reload food inventory
        List<String[]> foods = petDAO.getUserFoods(user.getId());
        req.setAttribute("foodInventory", foods);
        req.setAttribute("favFood", FoodDef.getFavoriteFood(pet.getSpecies()));
        req.setAttribute("disFood", FoodDef.getDislikedFood(pet.getSpecies()));

        req.setAttribute("pet", pet);
        req.setAttribute("petCount", petDAO.getPetCountByUserId(user.getId()));
        req.setAttribute("success", "feed".equals(action) ? "喂食成功！" : action + " 成功！");
        req.getRequestDispatcher("/interact.jsp").forward(req, resp);
    }

    private void handleRelease(HttpServletRequest req, HttpServletResponse resp,
                                User user, String petId)
            throws SQLException, ServletException, IOException {
        Pet pet = petDAO.getPetById(petId);
        if (pet == null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Don't allow releasing the last pet
        int count = petDAO.getPetCountByUserId(user.getId());
        if (count <= 1) {
            req.setAttribute("pet", pet);
            req.setAttribute("petCount", count);
            req.setAttribute("error", "你只有这一只宠物伙伴了，不能放生最后一只哦！");
            req.getRequestDispatcher("/interact.jsp").forward(req, resp);
            return;
        }

        String petName = pet.getName();
        String petEmoji = pet.getEmoji();
        petDAO.deletePet(petId);

        // Give bonuses to remaining pets
        List<Pet> remaining = petDAO.getPetsByUserId(user.getId());
        for (Pet p : remaining) {
            p.setAffinity(Math.min(100, p.getAffinity() + 8));
            p.setBond(Math.min(100, p.getBond() + 5));
            p.addLog("🌿 你放生了" + petName + "，获得了自然的祝福！亲密度+8 默契+5");
            petDAO.updatePet(p);
            for (String log : p.getActivityLog()) {
                petDAO.addActivityLog(p.getId(), log);
            }
        }

        req.getSession().setAttribute("adoptSuccess",
            "🌿 你放生了「" + petEmoji + " " + petName + "」，希望它在广阔天地里自由快乐！其他伙伴获得了祝福：亲密度+8，默契+5。");
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private void handleAdopt(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {
        String name = req.getParameter("name");
        String species = req.getParameter("species");
        String emoji = req.getParameter("emoji");
        String region = req.getParameter("region");
        String desc = req.getParameter("description");

        if (name == null || name.trim().isEmpty()) {
            name = species;
        }

        Pet pet = new Pet(name.trim(), species, emoji, region, desc);
        petDAO.addPet(user.getId(), pet);
        for (String log : pet.getActivityLog()) {
            petDAO.addActivityLog(pet.getId(), log);
        }

        req.getSession().setAttribute("adoptSuccess", "恭喜！你成功收养了 " + name + "！");
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }
}
