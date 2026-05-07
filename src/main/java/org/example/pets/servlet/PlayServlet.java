package org.example.pets.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.pets.bean.Pet;
import org.example.pets.bean.User;
import org.example.pets.dao.PetDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/play")
public class PlayServlet extends HttpServlet {

    private PetDAO petDAO;
    private static final Random RAND = new Random();
    private static final int HUNGER_COST = 8;

    @Override
    public void init() {
        petDAO = new PetDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        String petId = req.getParameter("petId");
        if (petId == null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Clear any lingering RPS session state when entering page fresh
        clearRPSSession(req);

        try {
            Pet pet = petDAO.getPetById(petId);
            if (pet == null) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
            pet.decay();
            List<String> logs = petDAO.getActivityLog(petId);
            pet.getActivityLog().clear();
            pet.getActivityLog().addAll(logs);
            req.setAttribute("pet", pet);
            req.setAttribute("petCount", petDAO.getPetCountByUserId(user.getId()));
        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
        }

        req.getRequestDispatcher("/play.jsp").forward(req, resp);
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

        String petId = req.getParameter("petId");
        String game = req.getParameter("game");

        try {
            Pet pet = petDAO.getPetById(petId);
            if (pet == null) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
            pet.decay();

            // Check hunger
            if (pet.getHunger() < HUNGER_COST) {
                req.setAttribute("pet", pet);
                req.setAttribute("petCount", petDAO.getPetCountByUserId(user.getId()));
                req.setAttribute("error", "🍖 饱食度不足！" + pet.getName() + "需要至少 " + HUNGER_COST + " 点饱食度才能玩耍，当前仅 " + pet.getHunger() + " 点。快去喂食吧~");
                req.getRequestDispatcher("/play.jsp").forward(req, resp);
                return;
            }

            GameResult result = switch (game != null ? game : "rps") {
                case "rps"     -> playRPS(req, pet);
                case "breakout"-> playBreakout(req, pet);
                case "memory"  -> playMemory(req, pet);
                default        -> playRPS(req, pet);
            };

            // Only save to DB if the game round is complete (not mid-RPS)
            if (result.isComplete) {
                petDAO.updatePet(pet);
                for (String log : pet.getActivityLog()) {
                    petDAO.addActivityLog(petId, log);
                }
                List<String> logs = petDAO.getActivityLog(petId);
                pet.getActivityLog().clear();
                pet.getActivityLog().addAll(logs);
            }

            req.setAttribute("pet", pet);
            req.setAttribute("petCount", petDAO.getPetCountByUserId(user.getId()));
            req.setAttribute("game", game);
            req.setAttribute("result", result);
            req.setAttribute("success", result.message);

        } catch (SQLException e) {
            req.setAttribute("error", "数据库错误：" + e.getMessage());
        }

        req.getRequestDispatcher("/play.jsp").forward(req, resp);
    }

    // ==================== Game Logic ====================

    // --- RPS: Best of 3 ---

    private GameResult playRPS(HttpServletRequest req, Pet pet) {
        HttpSession session = req.getSession();
        String playerChoice = req.getParameter("choice");

        String[] choices = {"rock", "scissors", "paper"};
        String[] emojis = {"🪨", "✂️", "📄"};
        String[] names = {"石头", "剪刀", "布"};

        int petIdx = RAND.nextInt(3);
        int playerIdx = switch (playerChoice != null ? playerChoice : "rock") {
            case "rock" -> 0; case "scissors" -> 1; case "paper" -> 2;
            default -> 0;
        };

        // Determine this round's winner
        int roundResult; // 1=player wins, 0=tie, -1=pet wins
        if (playerIdx == petIdx) roundResult = 0;
        else if ((playerIdx == 0 && petIdx == 1) ||
                 (playerIdx == 1 && petIdx == 2) ||
                 (playerIdx == 2 && petIdx == 0)) roundResult = 1;
        else roundResult = -1;

        String playerEmoji = emojis[playerIdx];
        String playerName = names[playerIdx];
        String petEmoji = emojis[petIdx];
        String petName = names[petIdx];

        // Load or init session state
        Integer pWins = (Integer) session.getAttribute("rpsPlayerWins");
        Integer petWins = (Integer) session.getAttribute("rpsPetWins");
        Integer round = (Integer) session.getAttribute("rpsRound");
        @SuppressWarnings("unchecked")
        List<String> history = (List<String>) session.getAttribute("rpsHistory");

        if (pWins == null) {
            pWins = 0; petWins = 0; round = 0; history = new ArrayList<>();
        }

        round++;
        if (roundResult == 1) pWins++;
        else if (roundResult == -1) petWins++;

        String roundEmoji = roundResult == 1 ? "✅" : roundResult == 0 ? "➖" : "❌";
        history.add(roundEmoji + " 第" + round + "局：" + playerEmoji + " " + playerName + " vs " + petEmoji + " " + petName);

        // Check if match is over
        boolean over = pWins >= 2 || petWins >= 2;
        if (!over) {
            // Continue to next round
            session.setAttribute("rpsPlayerWins", pWins);
            session.setAttribute("rpsPetWins", petWins);
            session.setAttribute("rpsRound", round);
            session.setAttribute("rpsHistory", history);

            String msg = "第" + round + "局结束！比分 " + pWins + ":" + petWins + "，再来一局！";
            GameResult gr = new GameResult("rps", msg, playerEmoji + " " + playerName,
                    petEmoji + " " + petName, 0, 0, 0, "mid");
            gr.isComplete = false;
            gr.rpsPlayerWins = pWins;
            gr.rpsPetWins = petWins;
            gr.rpsRound = round;
            gr.rpsHistory = new ArrayList<>(history);
            return gr;
        }

        // Match over — calculate rewards
        boolean playerWon = pWins >= 2;
        int moodGain, bondGain, affGain;
        String outcome;
        if (playerWon) {
            moodGain = 30 + RAND.nextInt(16); bondGain = 15 + RAND.nextInt(11); affGain = 5 + RAND.nextInt(6);
            outcome = "🎉 三局两胜！你以 " + pWins + ":" + petWins + " 赢了！" + pet.getName() + "崇拜地扑进你怀里~";
        } else {
            moodGain = 8 + RAND.nextInt(8); bondGain = 3 + RAND.nextInt(5);
            outcome = "😅 你以 " + pWins + ":" + petWins + " 输了！" + pet.getName() + "得意地跳起了舞~";
            affGain = 0;
        }

        applyRewards(pet, moodGain, bondGain, affGain);
        String logMsg = "🪨 猜拳对决(" + pWins + ":" + petWins + ")：" + String.join(" | ", history);
        pet.addLog(logMsg + "！心情+" + moodGain + " 默契+" + bondGain + (affGain > 0 ? " 亲密度+" + affGain : ""));

        clearRPSSession(req);

        GameResult gr = new GameResult("rps", outcome, "你 " + pWins + ":" + petWins + " " + pet.getName(),
                "", moodGain, bondGain, affGain, playerWon ? "win" : "lose");
        gr.rpsHistory = history;
        gr.rpsPlayerWins = pWins;
        gr.rpsPetWins = petWins;
        gr.rpsRound = round;
        return gr;
    }

    private void clearRPSSession(HttpServletRequest req) {
        HttpSession session = req.getSession();
        session.removeAttribute("rpsPlayerWins");
        session.removeAttribute("rpsPetWins");
        session.removeAttribute("rpsRound");
        session.removeAttribute("rpsHistory");
    }

    // --- Breakout ---

    private GameResult playBreakout(HttpServletRequest req, Pet pet) {
        int bricks;
        try {
            bricks = Integer.parseInt(req.getParameter("bricks"));
        } catch (NumberFormatException e) {
            bricks = 0;
        }
        int total = 30; // 5 rows × 6 columns

        int moodGain, bondGain, affGain;
        String outcome, tier;
        double pct = (double) bricks / total;
        if (pct >= 1.0) {
            moodGain = 28 + RAND.nextInt(8); bondGain = 12 + RAND.nextInt(7); affGain = 5 + RAND.nextInt(5);
            outcome = "🧱 全部打碎！" + pet.getName() + "看得目瞪口呆，太厉害了！";
            tier = "win";
        } else if (pct >= 0.7) {
            moodGain = 18 + RAND.nextInt(8); bondGain = 8 + RAND.nextInt(5); affGain = 3 + RAND.nextInt(3);
            outcome = "👏 打碎了 " + bricks + "/" + total + " 块砖！" + pet.getName() + "为你鼓掌~";
            tier = "tie";
        } else if (pct >= 0.4) {
            moodGain = 10 + RAND.nextInt(6); bondGain = 4 + RAND.nextInt(4); affGain = 1 + RAND.nextInt(2);
            outcome = "🙂 打碎了 " + bricks + "/" + total + " 块砖，还需加油哦~";
            tier = "tie";
        } else {
            moodGain = 4 + RAND.nextInt(5); bondGain = 1 + RAND.nextInt(3);
            outcome = "😅 只打碎了 " + bricks + "/" + total + " 块砖，" + pet.getName() + "用爪子拍了拍你~";
            tier = "lose";
            affGain = 0;
        }

        applyRewards(pet, moodGain, bondGain, affGain);
        pet.addLog("🧱 打砖块：击碎" + bricks + "/" + total + "！心情+" + moodGain + " 默契+" + bondGain + (affGain > 0 ? " 亲密度+" + affGain : ""));

        return new GameResult("breakout", outcome, "🧱 " + bricks + "/" + total, "",
                moodGain, bondGain, affGain, tier);
    }

    // --- Memory Match ---

    private GameResult playMemory(HttpServletRequest req, Pet pet) {
        int pairs;
        try {
            pairs = Integer.parseInt(req.getParameter("pairs"));
        } catch (NumberFormatException e) {
            pairs = 0;
        }

        int moodGain, bondGain, affGain;
        String outcome, tier;
        if (pairs >= 6) {
            moodGain = 28 + RAND.nextInt(8); bondGain = 12 + RAND.nextInt(6); affGain = 5 + RAND.nextInt(4);
            outcome = "🧠 全部配对成功！" + pet.getName() + "为你感到骄傲！";
            tier = "win";
        } else if (pairs >= 4) {
            moodGain = 18 + RAND.nextInt(6); bondGain = 8 + RAND.nextInt(4); affGain = 3 + RAND.nextInt(2);
            outcome = "👏 配对了" + pairs + "对！表现不错，" + pet.getName() + "很开心~";
            tier = "tie";
        } else if (pairs >= 2) {
            moodGain = 10 + RAND.nextInt(5); bondGain = 4 + RAND.nextInt(3); affGain = 1 + RAND.nextInt(2);
            outcome = "🙂 配对了" + pairs + "对，继续加油~";
            tier = "tie";
        } else {
            moodGain = 4 + RAND.nextInt(4); bondGain = 1 + RAND.nextInt(3);
            outcome = "😅 只配对了" + pairs + "对，" + pet.getName() + "用爪子拍了拍你~";
            tier = "lose";
            affGain = 0;
        }

        applyRewards(pet, moodGain, bondGain, affGain);
        pet.addLog("🧠 翻牌对对碰：配对" + pairs + "对！心情+" + moodGain + " 默契+" + bondGain + (affGain > 0 ? " 亲密度+" + affGain : ""));

        return new GameResult("memory", outcome, "🃏 " + pairs + "/6对", "",
                moodGain, bondGain, affGain, tier);
    }

    // --- Helpers ---

    private void applyRewards(Pet pet, int mood, int bond, int affinity) {
        pet.setMood(Math.min(100, pet.getMood() + mood));
        pet.setBond(Math.min(100, pet.getBond() + bond));
        pet.setAffinity(Math.min(100, pet.getAffinity() + affinity));
        pet.setHunger(Math.max(0, pet.getHunger() - HUNGER_COST));
        pet.setLastInteraction(new Date());
    }

    // ==================== GameResult POJO ====================

    public static class GameResult {
        public String game;
        public String message;
        public String playerLabel;
        public String petLabel;
        public int mood;
        public int bond;
        public int affinity;
        public String tier; // win/tie/lose/mid (mid = RPS round not over)
        public boolean isComplete = true; // false during mid-RPS rounds

        // RPS best-of-3 state
        public int rpsPlayerWins;
        public int rpsPetWins;
        public int rpsRound;
        public List<String> rpsHistory;

        public GameResult(String game, String message, String playerLabel, String petLabel,
                          int mood, int bond, int affinity, String tier) {
            this.game = game;
            this.message = message;
            this.playerLabel = playerLabel;
            this.petLabel = petLabel;
            this.mood = mood;
            this.bond = bond;
            this.affinity = affinity;
            this.tier = tier;
        }
    }
}
