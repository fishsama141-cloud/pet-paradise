package org.example.pets.bean;

import java.io.Serializable;
import java.util.*;

public class Pet implements Serializable {
    private String id;
    private String name;
    private String species;
    private String emoji;
    private String region;
    private String description;
    private int level;
    private int experience;
    private int hunger;
    private int mood;
    private int affinity;      // 亲密度：与主人的关系深浅
    private int bond;          // 默契度：配合程度
    private String personality; // 性格：活泼/胆小/温顺
    private String rarity;      // common / uncommon / rare
    private Date lastInteraction;
    private List<String> activityLog;
    private Date adoptedAt;

    public Pet() {
        this.id = UUID.randomUUID().toString();
        this.activityLog = new ArrayList<>();
        this.lastInteraction = new Date();
        this.adoptedAt = new Date();
        this.personality = "活泼";
    }

    public Pet(String name, String species, String emoji, String region, String description) {
        this();
        this.name = name;
        this.species = species;
        this.emoji = emoji;
        this.region = region;
        this.description = description;
        this.level = 1;
        this.experience = 0;
        this.hunger = 70;
        this.mood = 70;
        this.affinity = 10;
        this.bond = 5;
        addLog("欢迎" + name + "加入你的宠物大家庭！");
    }

    // --- Interaction methods ---

    /**
     * 喂食（食物系统）。根据宠物对该食物的偏好产生不同效果：
     * 喜欢：饱食+20 亲密度+5
     * 普通：饱食+10
     * 厌恶：饱食+5 亲密度-5
     * 亲密度加成：亲密度越高，喂食恢复的饱食度越多（最高+50%）
     */
    public void feed(String foodName, String foodEmoji, String preference) {
        int hungerGain;
        int affinityChange;
        String reaction;
        switch (preference) {
            case "like" -> {
                hungerGain = 20; affinityChange = 5;
                reaction = foodEmoji + " " + foodName + "是" + name + "最喜欢的食物！吃得开心极了~";
            }
            case "dislike" -> {
                hungerGain = 5; affinityChange = -5;
                reaction = foodEmoji + " " + foodName + "……" + name + "皱起了眉头，不太喜欢这个味道……";
            }
            default -> {
                hungerGain = 10; affinityChange = 0;
                reaction = foodEmoji + " " + foodName + "味道还行，" + name + "平静地吃完了。";
            }
        }
        // 亲密度加成：80+=1.5x, 50+=1.3x, 30+=1.15x
        double affBonus = affinity >= 80 ? 0.5 : affinity >= 50 ? 0.3 : affinity >= 30 ? 0.15 : 0;
        hungerGain = (int)(hungerGain * (1 + affBonus));
        hunger = Math.min(100, hunger + hungerGain);
        affinity = Math.max(0, Math.min(100, affinity + affinityChange));
        mood = Math.min(100, mood + 3);
        lastInteraction = new Date();
        String bonusText = affBonus > 0 ? "（亲密度加成+" + (int)(affBonus*100) + "%）" : "";
        String affix = affinityChange > 0 ? " 亲密度+" + affinityChange : affinityChange < 0 ? " 亲密度" + affinityChange : "";
        addLog(reaction + " 饱食+" + hungerGain + bonusText + affix);
    }

    /** 玩耍：提升默契 */
    public void play() {
        mood = Math.min(100, mood + 20);
        hunger = Math.max(0, hunger - 10);
        bond = Math.min(100, bond + 8);
        affinity = Math.min(100, affinity + 3);
        lastInteraction = new Date();
        addLog("⚽ 玩耍愉快！心情+20 默契+8");
    }

    /** 探险未遇到动物时获得奖励 */
    public void onExploreReward(int exp, int aff, int bnd) {
        gainExp(exp);
        affinity = Math.min(100, affinity + aff);
        bond = Math.min(100, bond + bnd);
        lastInteraction = new Date();
        addLog("🗺️ 探险归来！EXP+" + exp + " 亲密度+" + aff + " 默契+" + bnd);
    }

    /** 卡牌对局中使用正确卡牌 */
    public void onCorrectCard() {
        bond = Math.min(100, bond + 5);
        addLog("🤝 配合默契！默契+5");
    }

    public void gainExp(int amount) {
        experience += amount;
        int newLevel = experience / 100 + 1;
        if (newLevel > level) {
            level = newLevel;
            affinity = Math.min(100, affinity + 5);
            bond = Math.min(100, bond + 3);
            addLog("🎉 升级了！" + name + "升到" + level + "级！亲密度和默契提升！");
        }
    }

    public void decay() {
        if (lastInteraction == null) {
            lastInteraction = new Date();
            return;
        }
        Date now = new Date();
        long diffHours = (now.getTime() - lastInteraction.getTime()) / (1000 * 60 * 60);
        if (diffHours > 0) {
            hunger = Math.max(0, hunger - (int)(diffHours * 5));
            mood = Math.max(0, mood - (int)(diffHours * 3));
            // 惩罚机制：状态过低会降低亲密度
            int affPenalty = 0;
            if (hunger <= 15) {
                affPenalty += (int)(diffHours * 2);
                addLog("&#x1F356; 饥肠辘辘，" + name + "对你的疏忽感到失望……");
            }
            if (mood <= 20) {
                affPenalty += (int)(diffHours * 2);
                addLog("&#x1F61E; 心情低落，" + name + "觉得被冷落了……");
            }
            if (affPenalty > 0) {
                affinity = Math.max(0, affinity - affPenalty);
            }
        }
    }

    public void addLog(String msg) {
        String timeStr = new java.text.SimpleDateFormat("HH:mm:ss").format(new Date());
        activityLog.add(0, "[" + timeStr + "] " + msg);
        if (activityLog.size() > 30) activityLog.remove(30);
    }

    /** 根据性格返回卡牌效果加成 */
    public double getCardBonus(String cardType) {
        return switch (personality) {
            case "活泼" -> cardType.equals("play") || cardType.equals("approach") ? 1.2 : 1.0;
            case "胆小" -> cardType.equals("observe") || cardType.equals("soothe") ? 1.2 : 1.0;
            case "温顺" -> cardType.equals("feed") || cardType.equals("soothe") ? 1.2 : 1.0;
            default -> 1.0;
        };
    }

    // --- Getters / Setters ---

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }

    public String getEmoji() { return emoji; }
    public void setEmoji(String emoji) { this.emoji = emoji; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }

    public int getExperience() { return experience; }
    public void setExperience(int experience) { this.experience = experience; }

    public int getHunger() { return hunger; }
    public void setHunger(int hunger) { this.hunger = hunger; }

    public int getMood() { return mood; }
    public void setMood(int mood) { this.mood = mood; }

    public int getAffinity() { return affinity; }
    public void setAffinity(int affinity) { this.affinity = affinity; }

    public int getBond() { return bond; }
    public void setBond(int bond) { this.bond = bond; }

    public String getPersonality() { return personality; }
    public void setPersonality(String personality) { this.personality = personality; }

    public String getRarity() { return rarity; }
    public void setRarity(String rarity) { this.rarity = rarity; }

    /** 从 PetSpecies 动态查找稀有度，保证和世界地图一致 */
    public String getRarityLabel() {
        String actualRarity = rarity;
        // 优先从 PetSpecies 权威数据源查找
        for (PetSpecies sp : PetSpecies.ALL) {
            if (sp.getName().equals(this.species)) {
                actualRarity = sp.getRarity();
                break;
            }
        }
        if (actualRarity == null) return "";
        return switch (actualRarity) {
            case "common" -> "⭐ 常见";
            case "uncommon" -> "⭐⭐ 稀有";
            case "rare" -> "🌟🌟🌟 极稀有";
            default -> "";
        };
    }

    public Date getLastInteraction() { return lastInteraction; }
    public void setLastInteraction(Date lastInteraction) { this.lastInteraction = lastInteraction; }

    public Date getAdoptedAt() { return adoptedAt; }
    public void setAdoptedAt(Date adoptedAt) { this.adoptedAt = adoptedAt; }

    public List<String> getActivityLog() { return activityLog; }

    public int getExpToNextLevel() { return level * 100 - experience; }
}
