package org.example.pets.bean;

import java.util.*;

/**
 * 互动高潮事件系统 (Bond Event System)
 * 当野生动物情绪达到阈值时，动物主动发起更深层互动。
 * 这不是小游戏——是动物行为的具象化，是关系突破的关键时刻。
 */
public class BondEvent {

    // ==================== 事件类型 ====================

    public enum EventType {
        SLOW_APPROACH("缓慢接近", "它停下脚步，回头看你——这是在等你靠近。",
            "按住「前进」慢慢靠近，它回头时立刻松手！"),
        RHYTHM_SYNC("节奏同步", "它突然做出一个有节奏的动作，仿佛在邀请你。",
            "看准时机，跟着它的节奏点击光点！"),
        GENTLE_OFFER("温柔投喂", "它犹豫地看了看你手中的食物，又看了看你。",
            "等它放松警惕的那一刻，把握时机递出食物！"),
        FOLLOW_MOVEMENT("跟随移动", "它开始慢慢移动，如果你跟得太远就会失去它的兴趣。",
            "移动光标保持与它的距离，不远不近刚刚好！"),
        STEADY_BREATH("呼吸同步", "它停下来，呼吸变得缓慢。这是信任的邀请。",
            "按住吸气、松开呼气，与它的呼吸节奏同步！"),
        GAZE_LOCK("凝视对视", "它的目光锁定了你。这一刻，谁先移开谁就输了信任。",
            "光标保持在它的视线范围内，不要移开目光！");

        public final String name, scene, instruction;
        EventType(String n, String s, String i) { name = n; scene = s; instruction = i; }
    }

    // ==================== 事件实例字段 ====================

    private final EventType type;
    private final String animalName;
    private final String animalEmoji;
    private final int difficulty;       // 1=easy, 2=medium, 3=hard
    private int timingWindow;           // base timing window in ms, modified by traits
    private int maxMistakes;            // max mistakes allowed
    private int phases;                 // number of phases/rounds
    private int speed;                  // relative speed multiplier (100=normal)
    private int zoneSize;               // hit zone size for gaze/follow
    private boolean bonusPhase;         // extra phase for big success chance

    // Trait modifiers
    private String traitModifierText;   // description of how trait affects this event

    // ==================== 触发条件映射 ====================

    /**
     * 根据动物原型选择最合适的 Bond 事件类型
     */
    public static EventType selectFor(WildEncounter.Archetype arch, Random rng) {
        return switch (arch) {
            case CAUTIOUS -> rng.nextBoolean()
                ? EventType.SLOW_APPROACH : EventType.STEADY_BREATH;
            case CURIOUS -> rng.nextBoolean()
                ? EventType.RHYTHM_SYNC : EventType.FOLLOW_MOVEMENT;
            case BOLD -> rng.nextBoolean()
                ? EventType.GAZE_LOCK : EventType.RHYTHM_SYNC;
            case GENTLE -> rng.nextBoolean()
                ? EventType.GENTLE_OFFER : EventType.SLOW_APPROACH;
            case PLAYFUL -> rng.nextBoolean()
                ? EventType.RHYTHM_SYNC : EventType.FOLLOW_MOVEMENT;
            case MYSTERIOUS -> {
                int r = rng.nextInt(3);
                yield switch (r) {
                    case 0 -> EventType.GAZE_LOCK;
                    case 1 -> EventType.STEADY_BREATH;
                    default -> EventType.RHYTHM_SYNC;
                };
            }
        };
    }

    /**
     * 检查是否满足触发条件
     */
    public static boolean shouldTrigger(WildEncounter enc) {
        int sec = enc.getSecurity();
        int interest = enc.getInterest();
        int pressure = enc.getPressure();
        int trust = enc.getTrust();
        WildEncounter.Archetype arch = enc.getArchetype();

        return switch (arch) {
            case CAUTIOUS -> sec >= 35 && pressure <= 40 && enc.getRoundsUsed() >= 1;
            case CURIOUS -> interest >= 40 && sec >= 20;
            case BOLD -> trust >= 15 && pressure <= 55 && enc.getRoundsUsed() >= 1;
            case GENTLE -> trust >= 20 && sec >= 25 && pressure <= 50;
            case PLAYFUL -> interest >= 45 && pressure <= 45;
            case MYSTERIOUS -> trust >= 20 && enc.getRoundsUsed() >= 2;
        };
    }

    // ==================== 构造 ====================

    public BondEvent(EventType type, String animalName, String animalEmoji,
                     int rarityTier, CompanionTrait companionTrait, int companionBond) {
        this.type = type;
        this.animalName = animalName;
        this.animalEmoji = animalEmoji;

        // 稀有度决定基础难度: common=1, uncommon=2, rare=3
        this.difficulty = Math.max(1, Math.min(3, rarityTier));

        // 设置基础参数
        setBaseParams();

        // 应用同伴特性修改
        if (companionTrait != null) {
            applyTraitModifiers(companionTrait, companionBond);
        }
    }

    private void setBaseParams() {
        switch (type) {
            case SLOW_APPROACH -> {
                this.phases = difficulty <= 1 ? 4 : difficulty == 2 ? 5 : 6;
                this.timingWindow = difficulty <= 1 ? 600 : difficulty == 2 ? 450 : 300;
                this.maxMistakes = difficulty <= 1 ? 2 : difficulty == 2 ? 1 : 1;
                this.speed = 130;
                this.zoneSize = 0;
            }
            case RHYTHM_SYNC -> {
                this.phases = difficulty <= 1 ? 4 : difficulty == 2 ? 5 : 5;
                this.timingWindow = difficulty <= 1 ? 380 : difficulty == 2 ? 260 : 180;
                this.maxMistakes = difficulty <= 1 ? 2 : difficulty == 2 ? 1 : 1;
                this.speed = difficulty <= 1 ? 100 : difficulty == 2 ? 120 : 150;
                this.zoneSize = 0;
            }
            case GENTLE_OFFER -> {
                this.phases = 1;
                this.timingWindow = difficulty <= 1 ? 900 : difficulty == 2 ? 600 : 350;
                this.maxMistakes = difficulty <= 1 ? 2 : difficulty == 2 ? 1 : 1;
                this.speed = 120;
                this.zoneSize = 0;
            }
            case FOLLOW_MOVEMENT -> {
                this.phases = 1;
                this.timingWindow = 8000;
                this.maxMistakes = difficulty <= 1 ? 3 : difficulty == 2 ? 2 : 1;
                this.speed = difficulty <= 1 ? 80 : difficulty == 2 ? 100 : 130;
                this.zoneSize = difficulty <= 1 ? 100 : difficulty == 2 ? 75 : 55;
            }
            case STEADY_BREATH -> {
                this.phases = difficulty <= 1 ? 5 : difficulty == 2 ? 6 : 7;
                this.timingWindow = difficulty <= 1 ? 450 : difficulty == 2 ? 320 : 240;
                this.maxMistakes = difficulty <= 1 ? 2 : difficulty == 2 ? 1 : 1;
                this.speed = difficulty <= 1 ? 90 : difficulty == 2 ? 110 : 130;
                this.zoneSize = 0;
            }
            case GAZE_LOCK -> {
                this.phases = 1;
                this.timingWindow = difficulty <= 1 ? 6000 : difficulty == 2 ? 8000 : 10000;
                this.maxMistakes = difficulty <= 1 ? 3 : difficulty == 2 ? 2 : 1;
                this.speed = difficulty <= 1 ? 70 : difficulty == 2 ? 95 : 120;
                this.zoneSize = difficulty <= 1 ? 85 : difficulty == 2 ? 60 : 42;
            }
        }
    }

    private void applyTraitModifiers(CompanionTrait trait, int bond) {
        double bondMulti = bond >= 80 ? 1.4 : bond >= 50 ? 1.2 : bond >= 30 ? 1.1 : 1.0;
        String name = trait.getName();

        if (trait == CompanionTrait.DOG) {
            // 安心感：容错区扩大
            timingWindow = (int)(timingWindow * 1.25 * bondMulti);
            maxMistakes += 1;
            traitModifierText = "🐶 安心感：容错范围扩大，多一次失误机会";
        } else if (trait == CompanionTrait.ZEBRA) {
            // 群体安心：失败一次不中断
            maxMistakes += 2;
            traitModifierText = "🦓 群体安心：可多失误两次";
        } else if (trait == CompanionTrait.RED_PANDA) {
            // 慢慢来：速度要求降低
            speed = (int)(speed * 0.7);
            timingWindow = (int)(timingWindow * 1.15 * bondMulti);
            traitModifierText = "🐼 慢慢来：节奏更慢，时间窗口更宽";
        } else if (trait == CompanionTrait.KANGAROO) {
            // 节奏爆发
            bonusPhase = true;
            traitModifierText = "🦘 节奏爆发：额外加成阶段，可获更高分！";
        } else if (trait == CompanionTrait.DOLPHIN) {
            // 共情：自动修正一次
            maxMistakes += 1;
            traitModifierText = "🐬 共情：多一次机会，即使失误也能补救";
        } else if (trait == CompanionTrait.SQUID) {
            // 深海混沌：随机改变一个参数
            int chaos = new Random().nextInt(3);
            if (chaos == 0) { speed = (int)(speed * (0.7 + new Random().nextDouble() * 0.6)); }
            else if (chaos == 1) { timingWindow = (int)(timingWindow * (0.7 + new Random().nextDouble() * 0.6)); }
            else { maxMistakes = Math.max(1, maxMistakes + new Random().nextInt(3) - 1); }
            traitModifierText = "🦑 深海混沌：规则发生了微妙变化……";
        } else if (trait == CompanionTrait.KOALA) {
            // 放松
            speed = (int)(speed * 0.75);
            traitModifierText = "🐨 放松：一切节奏都变慢了";
        } else if (trait == CompanionTrait.BROWN_BEAR) {
            // 守护：容错
            maxMistakes += 1;
            timingWindow = (int)(timingWindow * 1.1);
            traitModifierText = "🐻 守护：容错一次，时间窗口略宽";
        } else if (trait == CompanionTrait.POLAR_BEAR) {
            // 压制：难度增加但收益更高
            speed = (int)(speed * 1.2);
            timingWindow = (int)(timingWindow * 0.85);
            traitModifierText = "🐻‍❄️ 压制：难度提高，但成功后效果翻倍！";
        } else if (trait == CompanionTrait.FOX) {
            // 试探
            timingWindow = (int)(timingWindow * 1.1 * bondMulti);
            traitModifierText = "🦊 试探：经验丰富，时机把握更准";
        } else if (trait == CompanionTrait.SLOTH) {
            // 安静陪伴
            speed = (int)(speed * 0.5);
            timingWindow = (int)(timingWindow * 1.3);
            traitModifierText = "🦥 安静陪伴：慢到极致，容错极高";
        }
    }

    // ==================== 结果计算 ====================

    public enum Result { BIG_SUCCESS, SUCCESS, FAILURE, CRITICAL_FAILURE }

    /**
     * 根据玩家得分(0-100)计算结果
     */
    public Result calculateResult(int score) {
        if (score >= 90) return Result.BIG_SUCCESS;
        if (score >= 55) return Result.SUCCESS;
        if (score >= 25) return Result.FAILURE;
        return Result.CRITICAL_FAILURE;
    }

    /**
     * 获取结果对应的情绪变化 [security, interest, pressure, trust]
     */
    public int[] getEmotionDelta(Result result) {
        return switch (result) {
            case BIG_SUCCESS -> new int[]{15, 12, -10, 18};
            case SUCCESS -> new int[]{8, 5, -3, 10};
            case FAILURE -> new int[]{-3, -5, 8, -2};
            case CRITICAL_FAILURE -> new int[]{-8, -10, 18, -5};
        };
    }

    /** 结果是否直接触发可收养 */
    public boolean isInstantAdopt(Result result) {
        return result == Result.BIG_SUCCESS;
    }

    /** 结果是否触发逃跑预警 */
    public boolean isFleeRisk(Result result) {
        return result == Result.CRITICAL_FAILURE;
    }

    // ==================== Getters ====================

    public EventType getType() { return type; }
    public String getAnimalName() { return animalName; }
    public String getAnimalEmoji() { return animalEmoji; }
    public int getDifficulty() { return difficulty; }
    public int getTimingWindow() { return timingWindow; }
    public int getMaxMistakes() { return maxMistakes; }
    public int getPhases() { return phases; }
    public int getSpeed() { return speed; }
    public int getZoneSize() { return zoneSize; }
    public boolean hasBonusPhase() { return bonusPhase; }
    public String getTraitModifierText() { return traitModifierText; }

    /** JSON 序列化给前端 */
    public String toJson() {
        StringBuilder sb = new StringBuilder("{");
        sb.append("\"type\":\"").append(type.name()).append("\",");
        sb.append("\"name\":\"").append(type.name).append("\",");
        sb.append("\"scene\":\"").append(escapeJson(type.scene)).append("\",");
        sb.append("\"instruction\":\"").append(escapeJson(type.instruction)).append("\",");
        sb.append("\"animalName\":\"").append(escapeJson(animalName)).append("\",");
        sb.append("\"animalEmoji\":\"").append(escapeJson(animalEmoji)).append("\",");
        sb.append("\"difficulty\":").append(difficulty).append(",");
        sb.append("\"timingWindow\":").append(timingWindow).append(",");
        sb.append("\"maxMistakes\":").append(maxMistakes).append(",");
        sb.append("\"phases\":").append(phases).append(",");
        sb.append("\"speed\":").append(speed).append(",");
        sb.append("\"zoneSize\":").append(zoneSize).append(",");
        sb.append("\"bonusPhase\":").append(bonusPhase).append(",");
        sb.append("\"traitModifierText\":\"").append(traitModifierText != null ? escapeJson(traitModifierText) : "").append("\"");
        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
