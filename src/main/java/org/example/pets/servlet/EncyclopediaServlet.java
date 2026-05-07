package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.*;
import org.example.pets.dao.PetDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/encyclopedia")
public class EncyclopediaServlet extends HttpServlet {
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
            user.setPets(userPets);

            // Collected species names
            Set<String> collectedSpecies = new HashSet<>();
            for (Pet p : userPets) {
                collectedSpecies.add(p.getSpecies());
            }

            // Collected food names
            Set<String> ownedFoods = new HashSet<>();
            for (String[] f : petDAO.getUserFoods(user.getId())) {
                ownedFoods.add(f[0]);
            }

            // Group species by region
            Map<String, List<PetSpecies>> regionSpecies = new LinkedHashMap<>();
            for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
                List<PetSpecies> list = new ArrayList<>();
                for (PetSpecies sp : PetSpecies.ALL) {
                    if (sp.getRegionId().equals(rd.id())) {
                        list.add(sp);
                    }
                }
                regionSpecies.put(rd.id(), list);
            }

            // Group foods by region
            Map<String, List<FoodDef>> regionFoods = new LinkedHashMap<>();
            for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
                regionFoods.put(rd.id(), new ArrayList<>());
            }
            for (FoodDef f : FoodDef.ALL) {
                for (String rn : f.getRegions()) {
                    String rid = regionNameToId(rn);
                    if (rid != null) {
                        regionFoods.get(rid).add(f);
                    }
                }
            }

            req.setAttribute("collectedSpecies", collectedSpecies);
            req.setAttribute("ownedFoods", ownedFoods);
            req.setAttribute("regionSpecies", regionSpecies);
            req.setAttribute("regionFoods", regionFoods);
            req.setAttribute("allRegions", PetSpecies.REGIONS);
            req.setAttribute("allSpecies", PetSpecies.ALL);
            req.setAttribute("allFoods", FoodDef.ALL);
            req.getRequestDispatcher("/encyclopedia.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/encyclopedia.jsp").forward(req, resp);
        }
    }

    private String regionNameToId(String name) {
        for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
            if (rd.name().equals(name)) return rd.id();
        }
        // some food regions use old names
        return switch (name) {
            case "东亚森林", "翠绿森林" -> "east_asia";
            case "亚马孙雨林" -> "amazon";
            case "非洲稀树草原", "阳光草原" -> "africa";
            case "澳大利亚内陆" -> "australia";
            case "北极冰原", "北极" -> "arctic";
            case "深海世界", "蔚蓝海洋" -> "deep_ocean";
            default -> null;
        };
    }
}
