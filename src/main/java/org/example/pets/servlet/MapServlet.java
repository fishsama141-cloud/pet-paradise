package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.*;
import org.example.pets.dao.PetDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/map")
public class MapServlet extends HttpServlet {
    private PetDAO petDAO;
    private static final Random RAND = new Random();

    @Override public void init() {
        petDAO = new PetDAO();
        try { petDAO.ensureRegionTable(); } catch (SQLException ignored) {}
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        try {
            List<Pet> userPets = petDAO.getPetsByUserId(user.getId());
            user.setPets(userPets);

            Set<String> unlockedIds = petDAO.getUnlockedRegionIds(user.getId());
            // Auto-unlock first region if never set (migration safety)
            if (unlockedIds.isEmpty() && !userPets.isEmpty()) {
                Pet firstPet = userPets.get(0);
                String firstRegionId = regionIdForName(firstPet.getRegion());
                petDAO.unlockRegion(user.getId(), firstRegionId);
                unlockedIds.add(firstRegionId);
            }

            List<PetSpecies.RegionDef> unlockedRegions = new ArrayList<>();
            List<PetSpecies.RegionDef> lockedRegions = new ArrayList<>();
            for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
                if (unlockedIds.contains(rd.id())) unlockedRegions.add(rd);
                else lockedRegions.add(rd);
            }

            // Can unlock more?
            boolean canUnlock = false;
            String unlockReqText = "";
            if (!lockedRegions.isEmpty()) {
                canUnlock = PetSpecies.canUnlockNewRegion(userPets, unlockedIds.size());
                unlockReqText = PetSpecies.getUnlockRequirementsText(unlockedIds.size());
            }

            // Pass encounter results from session
            HttpSession session = req.getSession();
            String encounterResult = (String) session.getAttribute("encounterResult");
            if (encounterResult != null) {
                req.setAttribute("encounterResult", encounterResult);
                session.removeAttribute("encounterResult");
            }
            String newRegionMsg = (String) session.getAttribute("newRegionMsg");
            if (newRegionMsg != null) {
                req.setAttribute("newRegionMsg", newRegionMsg);
                session.removeAttribute("newRegionMsg");
            }

            req.setAttribute("unlockedRegions", unlockedRegions);
            req.setAttribute("lockedRegions", lockedRegions);
            List<PetSpecies.RegionDef> sortedRegions = new ArrayList<>();
            sortedRegions.addAll(unlockedRegions);
            sortedRegions.addAll(lockedRegions);
            req.setAttribute("allRegions", sortedRegions);
            req.setAttribute("userPets", userPets);
            req.setAttribute("userPetCount", userPets.size());
            req.setAttribute("unlockedCount", unlockedIds.size());
            req.setAttribute("canUnlock", canUnlock);
            req.setAttribute("unlockReqText", unlockReqText);
            req.setAttribute("unlockedRegionIds", unlockedIds);
            req.getRequestDispatcher("/map.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/map.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/map");
            return;
        }
        try {
            switch (action) {
                case "explore" -> startAdventure(req, resp, user);
                case "choice" -> processChoice(req, resp, user);
                case "attitude" -> processAttitude(req, resp, user);
                case "adopt" -> handleAdopt(req, resp, user);
                case "unlock_region" -> handleUnlockRegion(req, resp, user);
                default -> resp.sendRedirect(req.getContextPath() + "/map");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
            req.getRequestDispatcher("/map.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("[MapServlet] POST error: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            req.getSession().setAttribute("encounterResult",
                "互动出错：" + e.getClass().getSimpleName() + " - " + e.getMessage());
            req.getSession().removeAttribute("encounter");
            req.getSession().removeAttribute("encounterSpecies");
            req.getSession().removeAttribute("encounterRegion");
            resp.sendRedirect(req.getContextPath() + "/map");
        }
    }

    // ==================== Unlock Region ====================

    private void handleUnlockRegion(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {
        String regionId = req.getParameter("region");
        List<Pet> userPets = petDAO.getPetsByUserId(user.getId());
        Set<String> unlockedIds = petDAO.getUnlockedRegionIds(user.getId());
        int unlockedCount = unlockedIds.size();

        if (unlockedIds.contains(regionId)) {
            req.getSession().setAttribute("encounterResult", "⚠️ 该区域已解锁！");
            resp.sendRedirect(req.getContextPath() + "/map");
            return;
        }

        if (!PetSpecies.canUnlockNewRegion(userPets, unlockedCount)) {
            req.getSession().setAttribute("encounterResult",
                "🔒 解锁条件不足！" + PetSpecies.getUnlockRequirementsText(unlockedCount));
            resp.sendRedirect(req.getContextPath() + "/map");
            return;
        }

        petDAO.unlockRegion(user.getId(), regionId);
        PetSpecies.RegionDef rd = PetSpecies.getRegionById(regionId);
        String name = rd != null ? rd.name() : regionId;
        req.getSession().setAttribute("newRegionMsg",
            "🗺️ 新区域「" + name + "」已解锁！带上你的宠物伙伴去探索吧！");
        resp.sendRedirect(req.getContextPath() + "/map");
    }

    // ==================== Adventure Engine ====================

    private void startAdventure(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {
        String region = req.getParameter("region");
        String companionId = req.getParameter("companionId");
        List<Pet> userPets = petDAO.getPetsByUserId(user.getId());
        int maxLevel = userPets.stream().mapToInt(p -> { p.decay(); return p.getLevel(); }).max().orElse(0);

        // Validate region unlock
        Set<String> unlockedIds = petDAO.getUnlockedRegionIds(user.getId());
        if (!unlockedIds.contains(region)) {
            req.setAttribute("exploreError", "🔒 此区域尚未解锁！");
            forwardToMap(req, resp, user, unlockedIds);
            return;
        }

        // Validate companion pet
        Pet companion = null;
        if (companionId != null && !companionId.isEmpty()) {
            companion = petDAO.getPetById(companionId);
        }
        if (companion == null) {
            // Fallback: use first pet
            companion = userPets.isEmpty() ? null : userPets.get(0);
        }
        if (companion == null) {
            req.setAttribute("exploreError", "你需要至少一只宠物才能探索！");
            forwardToMap(req, resp, user, unlockedIds);
            return;
        }

        List<PetSpecies> available = PetSpecies.getByRegion(region, maxLevel);
        if (available.isEmpty()) {
            req.setAttribute("exploreError",
                "你的最高等级宠物 Lv." + maxLevel + " 不足以探索此区域，需要提升等级。");
            forwardToMap(req, resp, user, unlockedIds);
            return;
        }

        String scenario = pickScenario(region);
        HttpSession session = req.getSession();
        session.setAttribute("advRegion", region);
        session.setAttribute("advRegionName", getRegionName(region));
        session.setAttribute("advScenario", scenario);
        session.setAttribute("advStep", 0);
        session.setAttribute("advMaxLevel", maxLevel);
        session.setAttribute("advAvailable", available);
        session.setAttribute("advCompanionId", companion.getId());
        session.setAttribute("advCompanionName", companion.getName());
        session.setAttribute("advCompanionEmoji", companion.getEmoji());

        req.setAttribute("regionName", getRegionName(region));
        req.setAttribute("step", getScenarioStep(scenario, 0, null));
        req.setAttribute("stepIndex", 0);
        req.setAttribute("companion", companion);
        req.getRequestDispatcher("/adventure.jsp").forward(req, resp);
    }

    private void processChoice(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {
        HttpSession session = req.getSession();
        String scenario = (String) session.getAttribute("advScenario");
        String region = (String) session.getAttribute("advRegion");
        Integer stepIdxObj = (Integer) session.getAttribute("advStep");
        String choice = req.getParameter("choice");
        String companionId = (String) session.getAttribute("advCompanionId");
        if (scenario == null || region == null || stepIdxObj == null) {
            resp.sendRedirect(req.getContextPath() + "/map"); return;
        }
        int stepIdx = stepIdxObj;

        List<PetSpecies> available = (List<PetSpecies>) session.getAttribute("advAvailable");
        int nextStep = stepIdx + 1;
        session.setAttribute("advStep", nextStep);

        AdventureStep step = getScenarioStep(scenario, nextStep, choice);
        if (step == null) {
            Pet companion = null;
            try { if (companionId != null) companion = petDAO.getPetById(companionId); } catch (SQLException ignored) {}
            resolveAdventure(req, resp, session, region, choice, available, companion);
        } else {
            Pet companion = null;
            try { if (companionId != null) companion = petDAO.getPetById(companionId); } catch (SQLException ignored) {}
            req.setAttribute("regionName", getRegionName(region));
            req.setAttribute("step", step);
            req.setAttribute("stepIndex", nextStep);
            req.setAttribute("companion", companion);
            req.getRequestDispatcher("/adventure.jsp").forward(req, resp);
        }
    }

    private void resolveAdventure(HttpServletRequest req, HttpServletResponse resp,
                                  HttpSession session, String region, String finalChoice,
                                  List<PetSpecies> available, Pet companion)
            throws ServletException, IOException {
        String scenario = (String) session.getAttribute("advScenario");
        String regionName = (String) session.getAttribute("advRegionName");
        session.removeAttribute("advScenario");
        session.removeAttribute("advStep");
        session.removeAttribute("advRegion");
        session.removeAttribute("advRegionName");
        session.removeAttribute("advAvailable");
        session.removeAttribute("advCompanionId");
        session.removeAttribute("advCompanionName");
        session.removeAttribute("advCompanionEmoji");

        User user = (User) session.getAttribute("user");

        // Check natural unlock — 8% chance if companion is Lv.8+
        boolean naturalUnlock = false;
        PetSpecies.RegionDef naturalUnlockRegion = null;
        if (companion != null && companion.getLevel() >= 8 && RAND.nextInt(100) < 8) {
            try {
                Set<String> unlocked = petDAO.getUnlockedRegionIds(user.getId());
                List<PetSpecies.RegionDef> stillLocked = new ArrayList<>();
                for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
                    if (!unlocked.contains(rd.id())) stillLocked.add(rd);
                }
                if (!stillLocked.isEmpty()) {
                    // "Brave" choices have higher chance of triggering the natural unlock
                    boolean isBraveChoice = finalChoice != null && (
                        finalChoice.contains("brave") || finalChoice.contains("climb")
                        || finalChoice.contains("dive") || finalChoice.contains("deep"));
                    if (isBraveChoice) {
                        naturalUnlockRegion = stillLocked.get(RAND.nextInt(stillLocked.size()));
                        naturalUnlock = true;
                        petDAO.unlockRegion(user.getId(), naturalUnlockRegion.id());
                    }
                }
            } catch (SQLException ignored) {}
        }

        // 70% chance to encounter an animal
        if (RAND.nextInt(100) < 70) {
            PetSpecies found = pickWeightedSpecies(region, user.getId());
            WildEncounter encounter = new WildEncounter(found, companion);
            session.setAttribute("encounter", encounter);
            session.setAttribute("encounterSpecies", found);
            session.setAttribute("encounterRegion", region);

            req.setAttribute("encounter", encounter);
            req.setAttribute("species", found);
            req.setAttribute("regionName", getRegionName(region));
            req.setAttribute("companion", companion);
            req.getRequestDispatcher("/encounter.jsp").forward(req, resp);
        } else {
            // No encounter — EXP/food rewards
            boolean isBrave = finalChoice != null && (
                finalChoice.contains("brave") || finalChoice.contains("climb")
                || finalChoice.contains("dive") || finalChoice.contains("deep"));

            int expReward = 20 + RAND.nextInt(16);
            int affReward = isBrave ? 8 : 5;
            int bndReward = isBrave ? 6 : 3;

            // Companion bonus
            if (companion != null && isBrave) {
                int extraExp = (int)(companion.getLevel() * 0.5);
                expReward += extraExp;
            }

            try {
                // EXP & stats only go to the companion pet
                if (companion != null) {
                    companion.onExploreReward(expReward, affReward, bndReward);
                    petDAO.updatePet(companion);
                    for (String log : companion.getActivityLog()) {
                        petDAO.addActivityLog(companion.getId(), log);
                    }
                }

                // Award 1-2 random foods
                List<FoodDef> regionFoods = FoodDef.getFoodsByRegion(regionName);
                StringBuilder foodMsg = new StringBuilder();
                if (!regionFoods.isEmpty() && user != null) {
                    int count = 1 + RAND.nextInt(2);
                    for (int i = 0; i < count; i++) {
                        FoodDef food = regionFoods.get(RAND.nextInt(regionFoods.size()));
                        petDAO.addFood(user.getId(), food.getName(), food.getEmoji(), 1);
                        if (i > 0) foodMsg.append("、");
                        foodMsg.append(food.getEmoji()).append(food.getName());
                    }
                }

                StringBuilder resultMsg = new StringBuilder();
                resultMsg.append("🌄 没有遇到野生动物，但").append(regionName).append("的风景令人心旷神怡！\n");
                if (!foodMsg.isEmpty()) resultMsg.append("🎁 获得食物：").append(foodMsg).append("\n");
                resultMsg.append("📈 ")
                    .append(companion != null ? companion.getEmoji() + companion.getName() : "同行宠物")
                    .append(" EXP+").append(expReward)
                    .append(" 亲密度+").append(affReward).append(" 默契+").append(bndReward);
                if (companion != null) resultMsg.append("\n🐾 同行伙伴 ").append(companion.getEmoji())
                    .append(companion.getName()).append(" 陪你一起探索！");

                if (naturalUnlock && naturalUnlockRegion != null) {
                    resultMsg.append("\n\n🌟 特殊事件！").append(companion != null ? companion.getEmoji() + companion.getName() : "你的宠物")
                        .append("在探险中发现了通往「").append(naturalUnlockRegion.emoji())
                        .append(naturalUnlockRegion.name()).append("」的秘密通道！新区域已解锁！");
                    session.setAttribute("newRegionMsg",
                        "🌟 " + (companion != null ? companion.getEmoji() + companion.getName() : "你的宠物")
                        + "在「" + regionName + "」探险中发现了通往「" + naturalUnlockRegion.emoji()
                        + naturalUnlockRegion.name() + "」的秘密通道！");
                }

                session.setAttribute("encounterResult", resultMsg.toString());
            } catch (SQLException e) {
                session.setAttribute("encounterResult", "探险结束，但保存时出了问题：" + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/map");
        }
    }

    /** Process an attitude action during wild animal encounter */
    private void processAttitude(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {
        HttpSession session = req.getSession();
        WildEncounter encounter = (WildEncounter) session.getAttribute("encounter");
        PetSpecies species = (PetSpecies) session.getAttribute("encounterSpecies");
        String region = (String) session.getAttribute("encounterRegion");

        System.out.println("[MapServlet] processAttitude called. encounter=" + (encounter != null ? encounter.getAnimalName() : "null") +
            " species=" + (species != null ? species.getName() : "null") + " region=" + region);

        if (encounter == null || species == null) {
            System.out.println("[MapServlet] processAttitude: encounter or species is null, redirecting to /map");
            resp.sendRedirect(req.getContextPath() + "/map");
            return;
        }

        String attName = req.getParameter("attitude");
        System.out.println("[MapServlet] processAttitude: attName=" + attName);

        if (attName == null || attName.isEmpty()) {
            System.out.println("[MapServlet] processAttitude: attName is null/empty, redirecting to /map");
            resp.sendRedirect(req.getContextPath() + "/map");
            return;
        }

        WildEncounter.Attitude att = null;
        try { att = WildEncounter.Attitude.valueOf(attName); }
        catch (IllegalArgumentException e) {
            System.out.println("[MapServlet] processAttitude: invalid attitude '" + attName + "'");
        }
        if (att == null) {
            resp.sendRedirect(req.getContextPath() + "/map");
            return;
        }
        System.out.println("[MapServlet] processAttitude: parsed attitude=" + att.name());

        // Companion is already stored in the encounter from construction
        Pet companion = null;
        String companionId = (String) session.getAttribute("advCompanionId");
        if (companionId != null) {
            try { companion = petDAO.getPetById(companionId); } catch (SQLException ignored) {}
        }

        try {
            encounter.useAttitude(att);
            System.out.println("[MapServlet] useAttitude success. isOver=" + encounter.isOver() +
                " success=" + encounter.isSuccess() + " rounds=" + encounter.getRoundsUsed());
        } catch (Exception e) {
            System.err.println("[MapServlet] useAttitude failed: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            req.getSession().setAttribute("encounterResult",
                "互动出错：" + e.getClass().getSimpleName() + " - " + e.getMessage());
            session.removeAttribute("encounter");
            session.removeAttribute("encounterSpecies");
            session.removeAttribute("encounterRegion");
            resp.sendRedirect(req.getContextPath() + "/map");
            return;
        }

        if (encounter.isOver()) {
            if (encounter.isSuccess()) {
                int[] stats = species.rollStats();
                req.setAttribute("species", species);
                req.setAttribute("rolledStats", stats);
                req.setAttribute("regionName", getRegionName(region));
                req.setAttribute("encounterFeedback", encounter.getLastFeedback());
                req.setAttribute("companion", companion);
                req.getRequestDispatcher("/adopt.jsp").forward(req, resp);
            } else {
                session.removeAttribute("encounter");
                session.removeAttribute("encounterSpecies");
                session.removeAttribute("encounterRegion");
                session.removeAttribute("advCompanionId");
                session.removeAttribute("advCompanionName");
                session.removeAttribute("advCompanionEmoji");
                String endReason = encounter.getEndReason();
                String hint = encounter.getFailureHint();
                String failMsg = encounter.getAnimalEmoji() + " " + endReason;
                if (hint != null && !hint.isEmpty()) failMsg += "\n" + hint;
                req.getSession().setAttribute("encounterResult", failMsg);
                resp.sendRedirect(req.getContextPath() + "/map");
            }
        } else {
            req.setAttribute("encounter", encounter);
            req.setAttribute("species", species);
            req.setAttribute("regionName", getRegionName(region));
            req.setAttribute("companion", companion);
            req.getRequestDispatcher("/encounter.jsp").forward(req, resp);
        }
    }

    private void handleAdopt(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {
        HttpSession session = req.getSession();
        String choice = req.getParameter("choice");

        String region = (String) session.getAttribute("encounterRegion");
        String regionName = getRegionName(region != null ? region : "east_asia");

        List<Pet> userPets = petDAO.getPetsByUserId(user.getId());
        int expReward = 25 + RAND.nextInt(16);

        // Get companion pet
        Pet companion = null;
        String companionId = (String) session.getAttribute("advCompanionId");
        if (companionId != null) {
            for (Pet p : userPets) if (p.getId().equals(companionId)) { companion = p; break; }
        }
        if (companion == null && !userPets.isEmpty()) companion = userPets.get(0);

        // EXP only goes to companion pet
        if (companion != null) {
            companion.gainExp(expReward);
            petDAO.updatePet(companion);
        }

        // Award foods
        List<FoodDef> regionFoods = FoodDef.getFoodsByRegion(regionName);
        String foodRewardMsg = "";
        if (!regionFoods.isEmpty()) {
            int count = 1 + RAND.nextInt(2);
            StringBuilder fb = new StringBuilder();
            for (int i = 0; i < count; i++) {
                FoodDef food = regionFoods.get(RAND.nextInt(regionFoods.size()));
                petDAO.addFood(user.getId(), food.getName(), food.getEmoji(), 1);
                if (i > 0) fb.append("、");
                fb.append(food.getEmoji()).append(food.getName());
            }
            foodRewardMsg = "\n🎁 获得食物：" + fb;
        }

        String companionLabel = companion != null ? companion.getEmoji() + companion.getName() : "同行宠物";

        if ("release".equals(choice)) {
            // Affinity/bond blessing goes to ALL pets (natural blessing)
            for (Pet p : userPets) {
                p.setAffinity(Math.min(100, p.getAffinity() + 12));
                p.setBond(Math.min(100, p.getBond() + 3));
                p.addLog("🌿 放生野生动物，获得自然祝福！亲密度+12 默契+3");
                petDAO.updatePet(p);
                for (String log : p.getActivityLog()) {
                    petDAO.addActivityLog(p.getId(), log);
                }
            }
            session.removeAttribute("encounter");
            session.removeAttribute("encounterSpecies");
            session.removeAttribute("encounterRegion");
            session.removeAttribute("advCompanionId");
            session.removeAttribute("advCompanionName");
            session.removeAttribute("advCompanionEmoji");
            session.setAttribute("adoptSuccess",
                "🌿 你选择了放生！大自然是所有生命的家。" + companionLabel + " EXP+" + expReward + "，全体宠物亲密度+12。" + foodRewardMsg);
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Adopt
        if (petDAO.getPetCountByUserId(user.getId()) >= 20) {
            session.removeAttribute("encounter");
            session.removeAttribute("encounterSpecies");
            session.removeAttribute("encounterRegion");
            session.setAttribute("adoptSuccess",
                "⚠️ 你的宠物伙伴已达上限(20只)！请放生一些宠物后再来收养新的伙伴。");
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String petName = req.getParameter("name");
        String speciesName = req.getParameter("species");

        if (petName == null || petName.trim().isEmpty()) petName = speciesName;
        PetSpecies sp = null;
        for (PetSpecies s : PetSpecies.ALL) { if (s.getName().equals(speciesName)) { sp = s; break; } }

        Pet pet;
        if (sp != null) { pet = sp.createPet(petName.trim()); }
        else { pet = new Pet(petName.trim(), speciesName, req.getParameter("emoji"), regionName, req.getParameter("description")); }

        WildEncounter enc = (WildEncounter) session.getAttribute("encounter");
        if (enc != null && sp != null) {
            pet.setAffinity(15 + enc.getTrust() / 5);
            pet.setBond(10 + enc.getTrust() / 10);
        }

        petDAO.addPet(user.getId(), pet);
        for (String log : pet.getActivityLog()) { petDAO.addActivityLog(pet.getId(), log); }

        // Bond bonus to existing pets
        for (Pet ep : userPets) {
            if (!ep.getId().equals(pet.getId())) {
                ep.setBond(Math.min(100, ep.getBond() + 8));
                ep.addLog("🤝 新伙伴" + pet.getName() + "加入！默契+8");
                petDAO.updatePet(ep);
                for (String log : ep.getActivityLog()) {
                    petDAO.addActivityLog(ep.getId(), log);
                }
            }
        }

        // Check unlock condition — tell user if they can now unlock a new region
        List<Pet> updatedPets = petDAO.getPetsByUserId(user.getId());
        Set<String> unlockedIds = petDAO.getUnlockedRegionIds(user.getId());
        String unlockHint = "";
        if (PetSpecies.canUnlockNewRegion(updatedPets, unlockedIds.size())) {
            unlockHint = "\n💡 你已满足解锁条件！前往世界地图选择新区域解锁吧！";
        }

        session.removeAttribute("encounter");
        session.removeAttribute("encounterSpecies");
        session.removeAttribute("encounterRegion");
        session.removeAttribute("advCompanionId");
        session.removeAttribute("advCompanionName");
        session.removeAttribute("advCompanionEmoji");

        req.getSession().setAttribute("adoptSuccess",
            "🎉 冒险归来！你成功收养了「" + pet.getName() + "」(" + pet.getSpecies() + ")！全体宠物EXP+" + expReward + "，默契+8。" + foodRewardMsg + unlockHint);
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    // ==================== Forward helper ====================

    private void forwardToMap(HttpServletRequest req, HttpServletResponse resp, User user, Set<String> unlockedIds)
            throws ServletException, IOException {
        try {
            List<Pet> userPets = petDAO.getPetsByUserId(user.getId());
            List<PetSpecies.RegionDef> unlockedRegions = new ArrayList<>();
            List<PetSpecies.RegionDef> lockedRegions = new ArrayList<>();
            for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
                if (unlockedIds.contains(rd.id())) unlockedRegions.add(rd);
                else lockedRegions.add(rd);
            }
            boolean canUnlock = !lockedRegions.isEmpty() && PetSpecies.canUnlockNewRegion(userPets, unlockedIds.size());
            req.setAttribute("unlockedRegions", unlockedRegions);
            req.setAttribute("lockedRegions", lockedRegions);
            List<PetSpecies.RegionDef> sortedRegions = new ArrayList<>();
            sortedRegions.addAll(unlockedRegions);
            sortedRegions.addAll(lockedRegions);
            req.setAttribute("allRegions", sortedRegions);
            req.setAttribute("userPets", userPets);
            req.setAttribute("userPetCount", userPets.size());
            req.setAttribute("unlockedCount", unlockedIds.size());
            req.setAttribute("canUnlock", canUnlock);
            req.setAttribute("unlockReqText", PetSpecies.getUnlockRequirementsText(unlockedIds.size()));
            req.setAttribute("unlockedRegionIds", unlockedIds);
        } catch (SQLException ignored) {}
        req.getRequestDispatcher("/map.jsp").forward(req, resp);
    }

    // ==================== Adventure Scenarios ====================

    private AdventureStep getScenarioStep(String scenario, int stepIdx, String prev) {
        return switch (scenario) {
            case "east_bamboo" -> eastBamboo(stepIdx, prev);
            case "east_mountain" -> eastMountain(stepIdx, prev);
            case "east_temple" -> eastTemple(stepIdx, prev);
            case "amazon_canopy" -> amazonCanopy(stepIdx, prev);
            case "amazon_river" -> amazonRiver(stepIdx, prev);
            case "amazon_ruins" -> amazonRuins(stepIdx, prev);
            case "africa_savanna" -> africaSavanna(stepIdx, prev);
            case "africa_waterhole" -> africaWaterhole(stepIdx, prev);
            case "africa_migration" -> africaMigration(stepIdx, prev);
            case "aus_desert" -> ausDesert(stepIdx, prev);
            case "aus_forest" -> ausForest(stepIdx, prev);
            case "aus_reef" -> ausReef(stepIdx, prev);
            case "arctic_blizzard" -> arcticBlizzard(stepIdx, prev);
            case "arctic_iceberg" -> arcticIceberg(stepIdx, prev);
            case "arctic_cave" -> arcticCave(stepIdx, prev);
            case "ocean_trench" -> oceanTrench(stepIdx, prev);
            case "ocean_reef" -> oceanReef(stepIdx, prev);
            case "ocean_vent" -> oceanVent(stepIdx, prev);
            default -> null;
        };
    }

    private String pickScenario(String region) {
        int r = RAND.nextInt(3);
        return switch (region) {
            case "east_asia" -> r == 0 ? "east_bamboo" : r == 1 ? "east_mountain" : "east_temple";
            case "amazon" -> r == 0 ? "amazon_canopy" : r == 1 ? "amazon_river" : "amazon_ruins";
            case "africa" -> r == 0 ? "africa_savanna" : r == 1 ? "africa_waterhole" : "africa_migration";
            case "australia" -> r == 0 ? "aus_desert" : r == 1 ? "aus_forest" : "aus_reef";
            case "arctic" -> r == 0 ? "arctic_blizzard" : r == 1 ? "arctic_iceberg" : "arctic_cave";
            case "deep_ocean" -> r == 0 ? "ocean_trench" : r == 1 ? "ocean_reef" : "ocean_vent";
            default -> "east_bamboo";
        };
    }

    // ============================================
    // EAST ASIA (3 scenarios)
    // ============================================

    private AdventureStep eastBamboo(int step, String prev) {
        if (step == 0) return new AdventureStep("🎋 竹林深处",
            "你走进四川的一片古老竹林，雾气弥漫，空气中飘着竹叶的清香。脚下的竹叶沙沙作响。前面有一个岔路口：左边是一条小溪，右边是一片更密的竹林。",
            List.of(AC("💧 沿着小溪走", "east_stream"),
                    AC("🎋 钻进密竹林", "east_dense"),
                    AC("🪨 爬上旁边的岩石远眺", "east_climb")));
        if ("east_stream".equals(prev)) return new AdventureStep("溪边奇遇",
            "小溪清澈见底，溪边的石头上有几处爪印。你蹲下细看时，对岸的竹丛摇了摇。",
            List.of(AC("🤝 悄悄涉水过溪", "east_approach"),
                    AC("🍎 在溪边放下苹果后等待", "east_wait")), true);
        if ("east_dense".equals(prev)) return new AdventureStep("密林深处",
            "密竹林中光线昏暗，你几乎要放弃时，一大片竹叶从上方飘落。抬头一看——",
            List.of(AC("👀 慢慢地抬头仰望", "east_approach"),
                    AC("🤫 屏住呼吸保持不动", "east_freeze")), true);
        if ("east_climb".equals(prev)) return new AdventureStep("岩石之上",
            "站在岩石上视野豁然开朗，整片竹海在风中摇曳。远处一棵老松树上有个巢穴。",
            List.of(AC("🔭 仔细观察老松树", "east_approach"),
                    AC("🏃 下岩石向老松树跑去", "east_brave")), true);
        return null;
    }

    private AdventureStep eastMountain(int step, String prev) {
        if (step == 0) return new AdventureStep("⛰️ 雪山脚下",
            "海拔三千米的高山上空气稀薄但纯净。一条蜿蜒的小路通向一片杜鹃花海，旁边有个被藤蔓半掩的山洞。",
            List.of(AC("🌸 走向杜鹃花海", "east_flowers"),
                    AC("🕳️ 探索山洞", "east_cave"),
                    AC("🔔 敲击路边的古钟", "east_bell")));
        if ("east_flowers".equals(prev)) return new AdventureStep("花海之中",
            "杜鹃花丛中传来窸窣声。一朵特别大的花后面藏着一个小小的身影，似乎受伤了。",
            List.of(AC("🩹 轻轻靠近帮助它", "east_approach"), AC("🍯 从包里拿出蜂蜜", "east_gift")), true);
        if ("east_cave".equals(prev)) return new AdventureStep("山洞之中",
            "洞内温暖干燥，地上铺着干草和松针。洞壁上画着古老的动物图腾。",
            List.of(AC("🕯️ 点亮火把深入探索", "east_brave"), AC("🧎 在山洞中静静坐下", "east_wait")), true);
        if ("east_bell".equals(prev)) return new AdventureStep("古钟回响",
            "钟声在山谷间回荡。远处传来了回应——不是回声，是一声动物的啼叫！",
            List.of(AC("🏃 朝声音方向跑去", "east_brave"), AC("🎶 再敲一下钟", "east_approach")), true);
        return null;
    }

    private AdventureStep eastTemple(int step, String prev) {
        if (step == 0) return new AdventureStep("🏯 深山古寺",
            "云雾缭绕的山顶有一座废弃的古寺。石阶上长满了青苔，庭院中的石灯笼已不再亮起。院中一棵千年银杏树下，落叶铺成了金色地毯。",
            List.of(AC("🍂 走到银杏树下", "et_tree"),
                    AC("🚪 推开寺庙的木门", "et_door"),
                    AC("🪨 探索寺后的石林", "et_stone")));
        if ("et_tree".equals(prev)) return new AdventureStep("银杏树下",
            "金黄的银杏叶飘落如雨。树根处有个小洞，洞口散落着一些坚果壳。洞里有什么在动。",
            List.of(AC("🌰 在洞口放一把坚果", "east_gift"),
                    AC("🤫 安静地在树下等待", "east_wait")), true);
        if ("et_door".equals(prev)) return new AdventureStep("古寺之内",
            "寺院内佛像前，一只狐狸正卧在蒲团上，琥珀色的眼睛静静看着你。它似乎不害怕，只是好奇。",
            List.of(AC("🤲 缓缓走向蒲团旁坐下", "east_approach"),
                    AC("🍯 从背包里拿出蜂蜜", "east_gift")), true);
        if ("et_stone".equals(prev)) return new AdventureStep("石林迷踪",
            "石林中怪石嶙峋，每块石头都像一种动物。你注意到一道石缝中卡着什么东西——是一块破旧的布。",
            List.of(AC("🧗 翻过巨石一探究竟", "east_brave"),
                    AC("🔍 仔细查看石缝", "east_approach")), true);
        return null;
    }

    // ============================================
    // AMAZON (3 scenarios)
    // ============================================

    private AdventureStep amazonCanopy(int step, String prev) {
        if (step == 0) return new AdventureStep("🌴 雨林树冠",
            "藤蔓编织的天空之路在头顶延伸。巨型树蕨的叶片上滴着露水，猴群的叫声从远处传来。一棵巨大的巴西坚果树耸立在面前。",
            List.of(AC("🧗 攀爬巴西坚果树", "amz_climb"),
                    AC("🌿 沿着藤蔓桥深入", "amz_vine"),
                    AC("👂 循着猴群叫声", "amz_monkey")));
        if ("amz_climb".equals(prev)) return new AdventureStep("树冠之上",
            "爬到树顶，整片雨林尽收眼底。头顶的枝桠间有个用树枝搭成的巢，色彩鲜艳的羽毛散落四周。",
            List.of(AC("🪺 探头看巢穴", "amz_approach"), AC("🤲 伸出手掌以示友好", "amz_brave")), true);
        if ("amz_vine".equals(prev)) return new AdventureStep("藤蔓迷宫",
            "你沿着藤蔓来到一棵开满奇异花朵的树前。花的香气浓郁甜美，引来许多小动物。",
            List.of(AC("🌸 在花树下坐下等待", "amz_approach"), AC("🍯 摘一朵花品尝花蜜", "amz_taste")), true);
        if ("amz_monkey".equals(prev)) return new AdventureStep("密林喧闹",
            "猴群在你头顶的树枝间跳跃。它们似乎不害怕你，一只胆大的猴子朝你丢了一颗野果。",
            List.of(AC("🤝 接住野果并道谢", "amz_approach"), AC("🍌 拿出随身带的香蕉回应", "amz_gift")), true);
        return null;
    }

    private AdventureStep amazonRiver(int step, String prev) {
        if (step == 0) return new AdventureStep("🌊 亚马孙河畔",
            "宽阔的河面在阳光下泛着金光。岸边的泥滩上有许多新鲜的脚印。一只凯门鳄懒洋洋地趴在岸边晒太阳。",
            List.of(AC("🚣 砍竹子做筏子渡河", "amz_raft"),
                    AC("👣 追踪泥滩上的脚印", "amz_track"),
                    AC("🐊 绕开凯门鳄沿河走", "amz_walk")));
        if ("amz_raft".equals(prev)) return new AdventureStep("河中漂流",
            "竹筏顺流而下。水面上跃起一群粉红色的河豚！它们围在竹筏旁边，似乎在和你玩耍。",
            List.of(AC("🤲 伸手轻触水面", "amz_approach"), AC("🐟 往水里丢些鱼干", "amz_feed")), true);
        if ("amz_track".equals(prev)) return new AdventureStep("追踪大猫",
            "脚印很大，是猫科动物的。它们通向河岸的一棵大榕树下。树下有一堆吃剩的猎物。",
            List.of(AC("🔍 在榕树周围小心搜索", "amz_brave"), AC("🧎 躲在灌木后观察", "amz_hide")), true);
        if ("amz_walk".equals(prev)) return new AdventureStep("河岸漫步",
            "沿河走到一处水流平缓的河湾。水面上的睡莲叶间，有什么东西在静静漂浮。",
            List.of(AC("🤲 涉水靠近", "amz_approach"), AC("🪷 采一朵睡莲", "amz_pick")), true);
        return null;
    }

    private AdventureStep amazonRuins(int step, String prev) {
        if (step == 0) return new AdventureStep("🏛️ 失落遗迹",
            "藤蔓掩映中露出一座古老的石质建筑。墙壁上刻着未知文明的图案——美洲豹、巨蛇、长羽毛的龙。石门前有一块松动的石板。",
            List.of(AC("🏗️ 撬开松动的石板", "amz_brave"),
                    AC("🔍 研究墙壁上的图案", "amz_study"),
                    AC("🌿 清理藤蔓寻找侧门", "amz_clear")));
        if ("amz_brave".equals(prev)) return new AdventureStep("地下秘道",
            "石板下是一条黑暗的秘道。你点亮手电走进去，墙壁上画满了精美的动物壁画。秘道尽头有光——是另一个出口！",
            List.of(AC("🏃 向光亮处跑去", "amz_approach"),
                    AC("🖼️ 停下来细看动物壁画", "amz_study")), true);
        if ("amz_study".equals(prev)) return new AdventureStep("图案之谜",
            "你发现图案讲述了一个故事：美洲豹是丛林的守护者，而长羽毛的龙是天空的使者。图案中的动物眼睛都指向同一个方向。",
            List.of(AC("👣 朝动物眼睛指的方向走", "amz_approach"),
                    AC("📝 记下图案内容", "amz_hide")), true);
        if ("amz_clear".equals(prev)) return new AdventureStep("侧门发现",
            "藤蔓后面果然有一扇石侧门！门没有锁，轻轻一推就开了。门后的空间里长满发光的蘑菇。",
            List.of(AC("🍄 走进发光蘑菇的房间", "amz_approach"),
                    AC("🔦 用光照向蘑菇深处", "amz_brave")), true);
        return null;
    }

    // ============================================
    // AFRICA (3 scenarios)
    // ============================================

    private AdventureStep africaSavanna(int step, String prev) {
        if (step == 0) return new AdventureStep("🦁 金色草原",
            "一望无际的稀树草原上，金合欢树撑开绿色的伞盖。远处扬起尘土——是迁徙的兽群。秃鹫在热气流中盘旋。",
            List.of(AC("🏃 奔向迁徙的兽群", "afr_run"),
                    AC("🌳 走向那棵最大的金合欢树", "afr_tree"),
                    AC("🥾 登上白蚁丘远眺", "afr_mound")));
        if ("afr_run".equals(prev)) return new AdventureStep("兽群之中",
            "斑马和角马在你身边奔涌而过，蹄声如雷。兽群边缘有一只年幼的动物似乎掉了队。",
            List.of(AC("🤝 慢慢走近落单的动物", "afr_approach"), AC("🧎 蹲下降低自己的威胁感", "afr_kneel")), true);
        if ("afr_tree".equals(prev)) return new AdventureStep("金合欢树下",
            "巨大的金合欢树下散落着被啃过的树枝。抬头看去，高高的树枝上有个优雅的身影。",
            List.of(AC("👋 向上方挥手", "afr_approach"), AC("🍃 摘一些低处的叶子递上去", "afr_offer")), true);
        if ("afr_mound".equals(prev)) return new AdventureStep("白蚁丘上",
            "站在高大的白蚁丘上，360度的草原全景。你注意到远处的一棵树下有一群动物在休息。",
            List.of(AC("🏃 跑向那群动物", "afr_brave"), AC("🔭 看得更仔细些", "afr_approach")), true);
        return null;
    }

    private AdventureStep africaWaterhole(int step, String prev) {
        if (step == 0) return new AdventureStep("💧 草原水潭",
            "干旱季节的水潭是所有动物的生命线。今天水潭边格外安静，只有几只鸟在水边喝水。水面平静如镜。",
            List.of(AC("💧 到水边蹲下喝水", "afr_drink"),
                    AC("🌿 躲进水潭边的芦苇丛", "afr_reed"),
                    AC("🪨 爬到水潭边的大石头上", "afr_rock")));
        if ("afr_drink".equals(prev)) return new AdventureStep("水边来客",
            "你正在喝水时，对岸的灌木丛动了。一只动物也来喝水，它的眼睛在暗处闪闪发亮。",
            List.of(AC("🤝 友好地直视对方", "afr_approach"), AC("💧 退后几步给它空间", "afr_backoff")), true);
        if ("afr_reed".equals(prev)) return new AdventureStep("芦苇丛中",
            "藏在芦苇中的视角很好。你看到水潭边陆续来了好几只不同种类的动物。",
            List.of(AC("📷 悄悄记录这难得的一幕", "afr_observe"), AC("🤫 从芦苇丛中慢慢现身", "afr_approach")), true);
        if ("afr_rock".equals(prev)) return new AdventureStep("巨石之上",
            "爬上大石头后你发现它被太阳晒得暖洋洋的。石头的另一面有动物的爪子磨过的痕迹。",
            List.of(AC("🔍 顺着痕迹寻找", "afr_brave"), AC("🧘 在温暖的岩石上坐下等待", "afr_wait")), true);
        return null;
    }

    private AdventureStep africaMigration(int step, String prev) {
        if (step == 0) return new AdventureStep("🐃 大迁徙之路",
            "百万角马和斑马正在横渡马拉河。鳄鱼在水中等待，天空中的秃鹫盘旋。河对岸是更绿的草原。你站在这壮观的场景前。",
            List.of(AC("🌉 寻找安全的浅滩过河", "afm_ford"),
                    AC("🐃 跟着角马群一起渡河", "afm_brave"),
                    AC("🔭 在高岸上观察迁徙", "afm_watch")));
        if ("afm_ford".equals(prev)) return new AdventureStep("浅滩发现",
            "你找到一处水流平缓的浅滩。水中有一群小河马在打哈欠。岸边的树丛有窸窣声。",
            List.of(AC("🤲 慢慢从浅滩涉水", "afr_approach"),
                    AC("🌿 先检查岸边的树丛", "afr_brave")), true);
        if ("afm_brave".equals(prev)) return new AdventureStep("与角马同行",
            "你勇敢地跟在角马群侧面渡河。河中间的水流湍急，但角马们紧紧靠在一起。对岸的草原上有几只落单的羚羊。",
            List.of(AC("🏃 上岸后朝羚羊群走去", "afr_approach"),
                    AC("🧎 在岸边歇息恢复体力", "afr_wait")), true);
        if ("afm_watch".equals(prev)) return new AdventureStep("高处俯瞰",
            "从高岸上俯瞰，整个迁徙路线尽收眼底。你注意到河下游有一处安静的河湾，几头大象正在那里喝水嬉戏。",
            List.of(AC("🐘 走向大象所在的下游", "afr_approach"),
                    AC("🏃 跑下高岸靠近河湾", "afr_brave")), true);
        return null;
    }

    // ============================================
    // AUSTRALIA (3 scenarios)
    // ============================================

    private AdventureStep ausDesert(int step, String prev) {
        if (step == 0) return new AdventureStep("🏜️ 红色荒漠",
            "澳大利亚内陆的红土沙漠一望无际。巨大的蚁丘像墓碑一样立在红色的土地上。远处有几棵耐旱的桉树。",
            List.of(AC("🌳 走向远处的桉树林", "aus_trees"),
                    AC("🕳️ 查看巨大的蚁丘", "aus_mound"),
                    AC("🧭 朝远处的地平线走去", "aus_horizon")));
        if ("aus_trees".equals(prev)) return new AdventureStep("桉树林",
            "桉树的银色叶子在阳光下泛着蓝灰色的光泽。浓郁的桉树油气味充满空气。树上传来缓慢的动作声。",
            List.of(AC("🐨 抬头寻找声音的来源", "aus_approach"), AC("🍃 靠在树干上等待", "aus_wait")), true);
        if ("aus_mound".equals(prev)) return new AdventureStep("蚁丘之侧",
            "蚁丘旁边有一处阴凉。你注意到沙地上有奇怪的脚印——像鸟又像兽。",
            List.of(AC("👣 追踪奇特的脚印", "aus_brave"), AC("🕳️ 在蚁丘阴影下守候", "aus_hide")), true);
        if ("aus_horizon".equals(prev)) return new AdventureStep("地平线上",
            "你在红土上走了很远。前方出现了一条干涸的河床，河床的沙子里半埋着几个蛋壳。",
            List.of(AC("🥚 小心查看蛋壳", "aus_approach"), AC("🏖️ 沿干河床搜索", "aus_brave")), true);
        return null;
    }

    private AdventureStep ausForest(int step, String prev) {
        if (step == 0) return new AdventureStep("🌿 灌木丛林",
            "澳大利亚东部特有的灌木林，到处都是尖刺的草丛和低矮的树木。一条小溪在灌木中蜿蜒。空气干燥而闷热。",
            List.of(AC("💧 走到溪边查看", "aus_stream"),
                    AC("🌿 拨开草丛深入灌木", "aus_bush"),
                    AC("🕳️ 调查树下的洞穴", "aus_burrow")));
        if ("aus_stream".equals(prev)) return new AdventureStep("溪边",
            "狭窄的溪流中一只鸭嘴兽正在潜水觅食！它用喙在石头下翻找，闭着眼睛完全靠电磁感应。",
            List.of(AC("🤫 安静地坐在溪边观看", "aus_approach"), AC("🪨 往水里丢一颗小石子", "aus_splash")), true);
        if ("aus_bush".equals(prev)) return new AdventureStep("灌木深处",
            "灌木丛后面有一小片空地。空地上有几棵小桉树，树下散落着被啃过的树叶和细小的爪印。",
            List.of(AC("🔍 仔细搜索空地", "aus_approach"), AC("🍃 摇动小桉树的树枝", "aus_shake")), true);
        if ("aus_burrow".equals(prev)) return new AdventureStep("树洞探索",
            "树下的洞穴入口出乎意料地大。洞口有动物的活动痕迹——不是一种，而是好几种。",
            List.of(AC("🔦 打开手电看进去", "aus_brave"), AC("🍓 在洞口放些野果", "aus_gift")), true);
        return null;
    }

    private AdventureStep ausReef(int step, String prev) {
        if (step == 0) return new AdventureStep("🐠 大堡礁边缘",
            "你乘船来到大堡礁。清澈的海水下是五彩的珊瑚世界。海龟在珊瑚间滑翔，小丑鱼在葵中钻进钻出。你戴上了潜水面镜。",
            List.of(AC("🤿 潜入水中探索珊瑚", "aur_dive"),
                    AC("🏝️ 游向旁边的小沙洲岛", "aur_island"),
                    AC("🐢 跟着海龟游", "aur_turtle")));
        if ("aur_dive".equals(prev)) return new AdventureStep("珊瑚花园",
            "珊瑚丛中藏着一个海底小洞穴。一群发光的小鱼在洞穴口进进出出，像极了海底的星星。",
            List.of(AC("🤿 靠近观察洞穴", "aus_approach"),
                    AC("🫧 在洞穴口吐泡泡", "aus_splash")), true);
        if ("aur_island".equals(prev)) return new AdventureStep("沙洲小岛",
            "沙洲上有几棵矮椰子树，树下的沙子里埋着一些贝壳。一群海鸟在岛上休息，其中有只体型特别大的。",
            List.of(AC("🪺 慢慢走向大海鸟", "aus_approach"),
                    AC("🐚 在贝壳堆附近等待", "aus_wait")), true);
        if ("aur_turtle".equals(prev)) return new AdventureStep("海龟向导",
            "海龟游得不快，你轻松跟上了它。它带你到了一片浅水区，那里长满了柔软的海草，几只小海龟正在觅食。",
            List.of(AC("🌿 静静漂浮在海草上方", "aus_approach"),
                    AC("🤿 下潜靠近觅食的小海龟", "aus_brave")), true);
        return null;
    }

    // ============================================
    // ARCTIC (3 scenarios)
    // ============================================

    private AdventureStep arcticBlizzard(int step, String prev) {
        if (step == 0) return new AdventureStep("❄️ 暴风雪中",
            "北极的暴风雪来得毫无征兆。雪花横飞，能见度骤降到几米。隐约前方有个冰洞可以作为避难所。远处有一群驯鹿的剪影。",
            List.of(AC("🕳️ 躲进冰洞避风", "arc_cave"),
                    AC("🦌 追随驯鹿群的方向", "arc_deer"),
                    AC("🧱 用雪块搭一个临时避风墙", "arc_wall")));
        if ("arc_cave".equals(prev)) return new AdventureStep("冰洞之中",
            "冰洞比想象的大，似乎是某种动物的巢穴。地上有几根白色的毛发，不是雪花。",
            List.of(AC("🧎 在冰洞中安静等待风雪过去", "arc_approach"), AC("🔍 深入冰洞探索", "arc_brave")), true);
        if ("arc_deer".equals(prev)) return new AdventureStep("追随驯鹿",
            "风雪中你跟着驯鹿群的脚印来到一个避风的山谷。山谷中有几只在雪地里打滚的小动物。",
            List.of(AC("🤝 慢慢走进山谷", "arc_approach"), AC("👀 在谷口边缘观察", "arc_wait")), true);
        if ("arc_wall".equals(prev)) return new AdventureStep("雪墙之后",
            "你搭好雪墙，风雪在墙外呼啸。你安静地坐着，这时你感觉有什么东西正从雪墙的另一侧靠近。",
            List.of(AC("👀 悄悄探出头查看", "arc_brave"), AC("🤫 保持安静等待它自己出现", "arc_wait")), true);
        return null;
    }

    private AdventureStep arcticIceberg(int step, String prev) {
        if (step == 0) return new AdventureStep("🧊 冰山海崖",
            "巨大的冰山漂浮在冰洋之中，海崖上栖息着成千上万的海鸟。冰面上有新鲜的爪印，很大。一块浮冰正从冰山边缘断裂。",
            List.of(AC("🧊 跳上浮冰漂向冰山", "arc_ice"),
                    AC("🪺 爬上鸟群栖息的海崖", "arc_cliff"),
                    AC("👣 追踪冰上的大爪印", "arc_track")));
        if ("arc_ice".equals(prev)) return new AdventureStep("浮冰漂流",
            "浮冰靠近了冰山的主体。冰沿下的深水中有一个白色的身影正在游泳，速度惊人。",
            List.of(AC("🤲 趴在冰沿伸手入水", "arc_brave"), AC("🐟 从背包里掏出冻鱼", "arc_gift")), true);
        if ("arc_cliff".equals(prev)) return new AdventureStep("海崖之顶",
            "海崖顶上的鸟巢密密麻麻。白色的鸟粪把岩石染成了白色。一只纯白的猛禽正站在最高处。",
            List.of(AC("🦉 与白色猛禽对视", "arc_approach"), AC("🧎 蹲下表示尊敬", "arc_kneel")), true);
        if ("arc_track".equals(prev)) return new AdventureStep("追踪巨兽",
            "巨大的爪印带你到了一处冰裂缝边缘。裂缝下是蓝绿色的冰晶洞，阳光透过冰层折射出梦幻的光芒。",
            List.of(AC("🕳️ 冒险潜入冰晶洞", "arc_brave"), AC("⛏️ 在裂缝边用冰镐凿台阶", "arc_approach")), true);
        return null;
    }

    private AdventureStep arcticCave(int step, String prev) {
        if (step == 0) return new AdventureStep("🕳️ 冰蓝洞穴",
            "你发现了一个被冰覆盖的洞穴入口。洞壁上满是冰晶，折射出蓝绿的光芒。地上散落着一些骨头和皮毛，这里可能是巢穴。",
            List.of(AC("🔦 打着手电深入洞穴", "acc_deep"),
                    AC("🦴 检查地上的骨头", "acc_bones"),
                    AC("🪨 敲击冰壁听声音", "acc_sound")));
        if ("acc_deep".equals(prev)) return new AdventureStep("洞穴深处",
            "越往里走越温暖。洞穴尽头有一个天然的温泉，蒸汽在冰洞中弥漫。温泉边的石头上趴着白色的身影。",
            List.of(AC("🤲 缓缓靠近温泉", "arc_approach"),
                    AC("🧎 在远处安静等待", "arc_wait")), true);
        if ("acc_bones".equals(prev)) return new AdventureStep("猎物痕迹",
            "骨头是新鲜的海豹骨骼，说明这里的猎食者就在附近。你抬头看到洞穴顶部有个小通风口，雪从那里落下。",
            List.of(AC("🔍 守在小通风口下等待", "arc_approach"),
                    AC("🧗 试着攀爬冰壁到通风口", "arc_brave")), true);
        if ("acc_sound".equals(prev)) return new AdventureStep("冰壁回音",
            "冰壁发出空洞的回音——后面有空间！你用冰镐凿开薄冰，发现了一个隐藏的冰室。室内有几只幼崽正在睡觉。",
            List.of(AC("🤫 悄悄后退不打扰幼崽", "arc_backoff"),
                    AC("🤲 远远地看着可爱的幼崽", "arc_approach")), true);
        return null;
    }

    // ============================================
    // DEEP OCEAN (3 scenarios)
    // ============================================

    private AdventureStep oceanTrench(int step, String prev) {
        if (step == 0) return new AdventureStep("🌊 海沟边缘",
            "潜水器下降到数千米深的马里亚纳海沟。窗外一片漆黑，只有探测器的灯光照亮前方的深渊。生物荧光粒子在黑暗中闪烁。",
            List.of(AC("💡 关闭灯光等待生物发光", "ocn_dark"),
                    AC("🤿 释放探测机器人深入", "ocn_probe"),
                    AC("🐟 播放磷虾群的声波", "ocn_sound")));
        if ("ocn_dark".equals(prev)) return new AdventureStep("黑暗中",
            "灯光熄灭后，深海活了过来。星星点点的生物荧光组成了一幅星空般的景象。一团巨大的荧光正向你飘来。",
            List.of(AC("👀 静静看着它靠近", "ocn_approach"), AC("💡 突然打开灯光", "ocn_flash")), true);
        if ("ocn_probe".equals(prev)) return new AdventureStep("机器人的发现",
            "探测机器人传回画面——海沟的岩壁上有一个巨大的洞穴入口，直径超过十米。洞穴里有什么在动。",
            List.of(AC("🤿 驾驶潜水器进入", "ocn_brave"), AC("📡 释放更多探测器", "ocn_approach")), true);
        if ("ocn_sound".equals(prev)) return new AdventureStep("声波回应",
            "播放磷虾群的声波后，远处传来了回应——是鲸歌！低沉而悠远，像整个海洋在歌唱。",
            List.of(AC("🎵 跟随鲸歌的方向", "ocn_brave"), AC("🔊 用低频声波回应", "ocn_approach")), true);
        return null;
    }

    private AdventureStep oceanReef(int step, String prev) {
        if (step == 0) return new AdventureStep("🐠 深海珊瑚礁",
            "这里的珊瑚礁与浅海完全不同——它们不依赖阳光，靠化学合成生存。白色的珊瑚像海底的花园。一群发光的鱼游过。",
            List.of(AC("🤿 潜入珊瑚花园", "ocn_dive"),
                    AC("🪸 采集一些样本观察", "ocn_sample"),
                    AC("🐠 跟随发光的鱼群", "ocn_follow")));
        if ("ocn_dive".equals(prev)) return new AdventureStep("珊瑚花园",
            "珊瑚丛中藏着各种奇异的生物。一只巨大的海龟正趴在珊瑚上打盹，龟壳上长满了小珊瑚。",
            List.of(AC("🐢 轻轻游到海龟旁边", "ocn_approach"), AC("🤲 帮它清理壳上的杂物", "ocn_help")), true);
        if ("ocn_sample".equals(prev)) return new AdventureStep("样本之中",
            "你小心地采集了一点珊瑚样本。样本的缝隙里有一只微小的发光鱿鱼，它喷出一团墨水般的荧光液体后飞速逃开。",
            List.of(AC("🏃 追赶那只小鱿鱼", "ocn_brave"), AC("🔍 顺着荧光液体追踪", "ocn_approach")), true);
        if ("ocn_follow".equals(prev)) return new AdventureStep("跟随荧光",
            "发光的鱼群带你到了礁石的另一侧——一个巨大的海底洞穴。洞穴口闪烁着神秘的蓝色光芒。",
            List.of(AC("🕳️ 慢慢游入洞穴", "ocn_brave"), AC("💡 在洞口照亮四周观察", "ocn_approach")), true);
        return null;
    }

    private AdventureStep oceanVent(int step, String prev) {
        if (step == 0) return new AdventureStep("♨️ 深海热泉",
            "海底热泉喷出黑色的矿物质烟雾，周围的温度比深海其他地方高出几十度。奇异的管虫和盲虾在这片黑暗绿洲中繁衍生息。",
            List.of(AC("🦐 靠近观察盲虾群", "ocv_shrimp"),
                    AC("🌋 探索热泉喷口附近", "ocv_vent"),
                    AC("🧪 用机械臂采集样本", "ocv_sample")));
        if ("ocv_shrimp".equals(prev)) return new AdventureStep("盲虾之群",
            "盲虾密密麻麻地覆盖在岩石上，它们在用鳃过滤热泉中的矿物质。虾群突然散开——有什么东西正在靠近。",
            List.of(AC("👀 保持不动看什么过来了", "ocn_approach"),
                    AC("💡 调亮灯光照亮前方", "ocn_flash")), true);
        if ("ocv_vent".equals(prev)) return new AdventureStep("热泉喷口",
            "接近喷口时温度传感器开始报警。但在这极端环境中，你看到一条白色的鱼正悠然自得地在滚烫的水中游动。",
            List.of(AC("🐟 观察这条耐热的神奇鱼类", "ocn_approach"),
                    AC("🌡️ 冒险把潜水器靠近一些", "ocn_brave")), true);
        if ("ocv_sample".equals(prev)) return new AdventureStep("样本采集",
            "机械臂抓取了一块热泉口的岩石样本。样本上附着了一只小章鱼，它受惊后喷出墨汁——在黑暗中几乎看不见！",
            List.of(AC("🤲 小心地把小章鱼放回去", "ocn_approach"),
                    AC("🧐 仔细查看它喷出的墨汁", "ocn_flash")), true);
        return null;
    }

    // ==================== Helpers ====================

    /** 从全部物种中加权随机选择 — 当前区域权重×3，已解锁区域×1，未解锁×0.4 */
    private PetSpecies pickWeightedSpecies(String currentRegion, String userId) {
        Set<String> unlockedIds;
        try { unlockedIds = petDAO.getUnlockedRegionIds(userId); }
        catch (SQLException e) { unlockedIds = Set.of(currentRegion); }

        double totalWeight = 0;
        double[] weights = new double[PetSpecies.ALL.size()];
        for (int i = 0; i < PetSpecies.ALL.size(); i++) {
            PetSpecies sp = PetSpecies.ALL.get(i);
            double w = sp.getEncounterRate();
            if (sp.getRegionId().equals(currentRegion)) w *= 3.0;
            else if (unlockedIds.contains(sp.getRegionId())) w *= 1.0;
            else w *= 0.4;
            weights[i] = w;
            totalWeight += w;
        }

        double r = RAND.nextDouble() * totalWeight;
        double cumulative = 0;
        for (int i = 0; i < PetSpecies.ALL.size(); i++) {
            cumulative += weights[i];
            if (r <= cumulative) return PetSpecies.ALL.get(i);
        }
        return PetSpecies.ALL.get(PetSpecies.ALL.size() - 1); // fallback
    }

    private String getRegionName(String regionId) {
        PetSpecies.RegionDef rd = PetSpecies.getRegionById(regionId);
        if (rd != null) return rd.name();
        return switch (regionId) {
            case "east_asia" -> "东亚森林"; case "amazon" -> "亚马孙雨林";
            case "africa" -> "非洲稀树草原"; case "australia" -> "澳大利亚内陆";
            case "arctic" -> "北极冰原"; case "deep_ocean" -> "深海世界";
            default -> "未知区域";
        };
    }

    private String regionIdForName(String regionName) {
        for (PetSpecies.RegionDef rd : PetSpecies.REGIONS) {
            if (rd.name().equals(regionName)) return rd.id();
        }
        return "east_asia";
    }

    // ── Inner classes ──

    public static class AdventureStep {
        public final String title, text;
        public final List<AdventureChoice> choices;
        public final boolean isConclusion;
        public AdventureStep(String t, String tx, List<AdventureChoice> c) { this(t, tx, c, false); }
        public AdventureStep(String t, String tx, List<AdventureChoice> c, boolean end) {
            title = t; text = tx; choices = c; isConclusion = end;
        }
    }

    public record AdventureChoice(String label, String value) {}
    private static AdventureChoice AC(String l, String v) { return new AdventureChoice(l, v); }
}
