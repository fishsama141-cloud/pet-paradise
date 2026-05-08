package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.*;
import org.example.pets.dao.PetDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private PetDAO petDAO;

    /** Habitat zone definitions */
    public record HabitatZone(String id, String name, String emoji, String color,
                               int topPct, int leftPct, List<String> regionNames) {}

    public static final List<HabitatZone> ZONES = List.of(
        new HabitatZone("east_asia", "东亚森林", "🏯", "#4CAF50", 40, 72,
            List.of("东亚森林")),
        new HabitatZone("amazon", "亚马孙雨林", "🌴", "#2E7D32", 58, 28,
            List.of("亚马孙雨林")),
        new HabitatZone("africa", "非洲稀树草原", "🦁", "#F57C00", 50, 52,
            List.of("非洲稀树草原")),
        new HabitatZone("australia", "澳大利亚内陆", "🦘", "#FF9800", 72, 78,
            List.of("澳大利亚内陆")),
        new HabitatZone("arctic", "北极冰原", "🧊", "#90CAF9", 12, 48,
            List.of("北极冰原")),
        new HabitatZone("deep_ocean", "深海世界", "🌊", "#1565C0", 65, 10,
            List.of("深海世界"))
    );

    @Override
    public void init() {
        petDAO = new PetDAO();
        try { petDAO.ensureRegionTable(); } catch (SQLException ignored) {}
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

        try {
            List<Pet> pets = petDAO.getPetsByUserId(user.getId());
            user.setPets(pets);

            if (pets.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/quiz");
                return;
            }

            // Auto-migrate: if user has pets but no unlocked regions
            Set<String> unlockedRegionIds = petDAO.getUnlockedRegionIds(user.getId());
            if (unlockedRegionIds.isEmpty()) {
                Pet firstPet = pets.get(0);
                String regionId = getRegionIdForName(firstPet.getRegion());
                petDAO.unlockRegion(user.getId(), regionId);
                unlockedRegionIds.add(regionId);
            }

            String adoptSuccess = (String) session.getAttribute("adoptSuccess");
            if (adoptSuccess != null) {
                req.setAttribute("success", adoptSuccess);
                session.removeAttribute("adoptSuccess");
            }
            String newRegionMsg = (String) session.getAttribute("newRegionMsg");
            if (newRegionMsg != null) {
                req.setAttribute("newRegionMsg", newRegionMsg);
                session.removeAttribute("newRegionMsg");
            }

            // Build zone → pets mapping
            Map<String, List<Pet>> zonePets = new LinkedHashMap<>();
            for (HabitatZone zone : ZONES) {
                zonePets.put(zone.id(), new ArrayList<>());
            }
            for (Pet pet : pets) {
                pet.decay();
                String zoneId = findZoneForRegion(pet.getRegion());
                zonePets.computeIfAbsent(zoneId, k -> new ArrayList<>()).add(pet);
            }

            req.setAttribute("pets", pets);
            req.setAttribute("zonePets", zonePets);
            req.setAttribute("zones", ZONES);
            req.setAttribute("petCount", pets.size());
            req.setAttribute("maxPets", 20);
            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
        }
    }

    private String findZoneForRegion(String region) {
        if (region == null) return "east_asia";
        for (HabitatZone zone : ZONES) {
            if (zone.regionNames().contains(region)) return zone.id();
        }
        return "east_asia";
    }

    private String getRegionIdForName(String regionName) {
        for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
            if (rd.name().equals(regionName)) return rd.id();
        }
        return "east_asia";
    }
}
