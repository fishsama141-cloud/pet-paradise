package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.Pet;
import org.example.pets.bean.PetSpecies;
import org.example.pets.bean.User;
import org.example.pets.dao.PetDAO;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {

    private PetDAO petDAO;

    @Override
    public void init() {
        petDAO = new PetDAO();
        // Ensure user_regions table exists
        try { petDAO.ensureRegionTable(); } catch (SQLException ignored) {}
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }
        try {
            if (!petDAO.getPetsByUserId(user.getId()).isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
        }
        req.getRequestDispatcher("/quiz.jsp").forward(req, resp);
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

        String env = req.getParameter("environment");
        String hobby = req.getParameter("hobby");
        String personality = req.getParameter("personality");
        String petName = req.getParameter("petName");

        if (petName == null || petName.trim().isEmpty()) {
            petName = "小可爱";
        }

        // Determine starter pet and initial region based on quiz answers
        Pet starter = determineStarterPet(petName.trim(), env, hobby, personality);
        String initialRegionId = PetSpecies.getRegionIdForEnv(env);

        try {
            petDAO.ensureRegionTable();
            petDAO.addPet(user.getId(), starter);
            for (String log : starter.getActivityLog()) {
                petDAO.addActivityLog(starter.getId(), log);
            }
            // Unlock the initial region
            petDAO.unlockRegion(user.getId(), initialRegionId);

            PetSpecies.RegionDef initRegion = PetSpecies.getRegionById(initialRegionId);
            String regionName = initRegion != null ? initRegion.name() : "初始区域";
            session.setAttribute("adoptSuccess",
                "🎉 恭喜！你获得了初始伙伴「" + starter.getName() + "」(" + starter.getSpecies() + ")！\n"
                + "🗺️ 起始区域「" + regionName + "」已解锁，去世界地图探索吧~");
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/quiz.jsp").forward(req, resp);
        }
    }

    private Pet determineStarterPet(String name, String env, String hobby, String personality) {
        // 根据环境严格对应物种和区域
        String speciesId = switch (env != null ? env : "forest") {
            case "forest" -> switch (personality != null ? personality : "") {
                case "calm"   -> "starter_cat";
                case "smart"  -> "starter_fox";
                default       -> "east_asia_red_panda";
            };
            case "rainforest" -> switch (personality != null ? personality : "") {
                case "calm", "gentle" -> "starter_macaw";
                case "smart"          -> "starter_macaw";
                default               -> "starter_macaw";
            };
            case "grassland" -> switch (hobby != null ? hobby : "") {
                case "reading", "art" -> "starter_rabbit";
                default               -> "starter_dog";
            };
            case "outback" -> switch (personality != null ? personality : "") {
                case "calm", "smart" -> "starter_lizard";
                default              -> "starter_lizard";
            };
            case "ocean" -> switch (personality != null ? personality : "") {
                case "smart", "calm" -> "ocean_turtle";
                default              -> "starter_dolphin";
            };
            case "arctic" -> switch (personality != null ? personality : "") {
                case "calm", "gentle" -> "starter_bear";
                default               -> "arctic_snowy_owl";
            };
            default -> "east_asia_red_panda";
        };

        PetSpecies sp = PetSpecies.getById(speciesId);
        if (sp != null) {
            return sp.createPet(name.trim());
        }
        // Fallback
        Pet fallback = new Pet(name.trim(), "小熊猫", "🐼", "东亚森林", "一只可爱的小熊猫，是你的初始伙伴。");
        fallback.setRarity("common");
        return fallback;
    }
}
