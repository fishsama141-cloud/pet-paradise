package org.example.pets.bean;

import java.util.*;

/**
 * 情绪博弈遭遇引擎。
 * 动物带着情绪出现 → 玩家表达态度 → 动物动态回应 → 关系推演，不死板猜答案。
 */
public class WildEncounter {

    // ==================== 态度定义 ====================

    public enum Attitude {
        WAIT("等待", "⏳", "放低姿态，让动物掌握节奏"),
        APPROACH("靠近", "🚶", "主动缩短距离，表达信任"),
        OBSERVE("观察", "🔍", "不推动也不后退，收集信息"),
        OFFER_FOOD("投喂", "🍖", "用食物建立正面联结"),
        MIMIC("模仿", "🤟", "模仿姿态，尝试建立共鸣"),
        STEP_BACK("后退", "👣", "拉开距离，给对方空间");

        public final String label, emoji, desc;
        Attitude(String l, String e, String d) { label = l; emoji = e; desc = d; }
    }

    // ==================== 性格原型 ====================

    public enum Archetype {
        CAUTIOUS,   // 谨慎：压力易升，需要耐心
        CURIOUS,    // 好奇：兴趣易升，喜欢探索
        BOLD,       // 大胆：不轻易害怕，但可能不屑
        GENTLE,     // 温柔：信任易建，但容易受惊
        PLAYFUL,    // 活泼：兴趣高，喜欢互动
        MYSTERIOUS  // 神秘：难以捉摸，反馈不明显
    }

    // ==================== 实例字段 ====================

    private final String animalName, animalEmoji, sceneDesc;
    private final Archetype archetype;
    private int security;    // 安全感 0-100
    private int interest;    // 兴趣 0-100
    private int pressure;    // 压力 0-100
    private int trust;       // 信任 0-100
    private int roundsUsed;
    private boolean success, failed, left, timeout;
    private int maxRounds;
    private static final int DEFAULT_MAX_ROUNDS = 12;
    private String lastFeedback;
    private String lastAnimalReaction; // 动物对你行为的具体回应文本
    private String companionEffect;    // 同行宠物本回合的效果说明

    // 同行宠物特性系统
    private CompanionTrait companionTrait;
    private String companionName;
    private String companionEmoji;
    private int consecutiveSuccesses;   // 金丝猴情绪连锁
    private boolean fleeBlockUsed;      // 北极熊压制
    private boolean bufferUsed;         // 棕熊守护
    private boolean forcedChangeUsed;   // 伞蜥虚张声势
    private Attitude lastAttitudeUsed;  // 小猫若即若离
    private int[] lastBestDelta;        // 金刚鹦鹉情绪模仿
    private String traitHint;           // 丹顶鹤/长颈鹿等探测系提示
    private boolean hiddenEmotionRevealed; // 长颈鹿远望
    private String revealedEmotionHint;    // 揭示的情绪提示
    private String traitSuggestion;        // 探测系同伴的态度建议

    // 失败条件
    private static final int PRESSURE_FLEE = 90;
    private static final int INTEREST_GONE = 5;
    private static final Random RAND = new Random();

    // 每物种捕捉条件 [requiredSecurity, requiredInterest, maxPressure, requiredTrust]
    private final int[] captureReq;

    // ==================== 构造 ====================

    public WildEncounter(PetSpecies species, Pet companion) {
        this.animalName = species.getName();
        this.animalEmoji = species.getEmoji();
        this.archetype = assignArchetype(species);
        this.sceneDesc = generateScene(species);
        this.captureReq = getCaptureRequirements(species.getId());
        // 初始情绪由原型决定
        int[] base = baseEmotions(archetype);
        this.security = clamp(base[0] + RAND.nextInt(15));
        this.interest  = clamp(base[1] + RAND.nextInt(20));
        this.pressure  = clamp(base[2] + RAND.nextInt(10));
        this.trust     = clamp(base[3] + RAND.nextInt(12));
        this.roundsUsed = 0;
        this.success = this.failed = this.left = this.timeout = false;
        this.maxRounds = DEFAULT_MAX_ROUNDS;
        this.consecutiveSuccesses = 0;
        this.fleeBlockUsed = false;
        this.bufferUsed = false;
        this.forcedChangeUsed = false;
        this.hiddenEmotionRevealed = false;

        // 同行宠物特性初始化
        if (companion != null) {
            this.companionName = companion.getName();
            this.companionEmoji = companion.getEmoji();
            this.companionTrait = CompanionTrait.forPet(companion);

            if (companionTrait != null) {
                // 美洲豹「压迫感」：初始信任降低
                if (companionTrait == CompanionTrait.JAGUAR) {
                    this.trust = clamp(trust - 10);
                    this.traitHint = companionEmoji + companionName + "的「压迫感」让" + animalName + "有些紧张";
                }
                // 长颈鹿「远望」：开局提前看到一个隐藏情绪
                if (companionTrait == CompanionTrait.GIRAFFE) {
                    this.hiddenEmotionRevealed = true;
                    this.revealedEmotionHint = revealEmotionHint();
                    this.traitHint = companionEmoji + companionName + "的「远望」发现了线索：" + revealedEmotionHint;
                }
                // 丹顶鹤「观察入微」：第一次互动额外获得情绪提示
                if (companionTrait == CompanionTrait.CRANE) {
                    this.hiddenEmotionRevealed = true;
                    this.revealedEmotionHint = revealEmotionHint();
                    this.traitHint = companionEmoji + companionName + "的「观察入微」觉察到：" + revealedEmotionHint;
                }
                // 挽留特性：北极狐「耐心试探」/ 树袋熊「放松」可多挽留3回合
                if (companionTrait == CompanionTrait.ARCTIC_FOX || companionTrait == CompanionTrait.KOALA) {
                    this.maxRounds = DEFAULT_MAX_ROUNDS + 3;
                    this.traitHint = companionEmoji + companionName + "的「" + companionTrait.getName()
                        + "」让" + animalName + "愿意多停留一会儿（+" + (maxRounds - DEFAULT_MAX_ROUNDS) + "回合）";
                }
            }
        }
    }

    /** 揭示一个隐藏情绪倾向（探测系特性使用） */
    private String revealEmotionHint() {
        return switch (archetype) {
            case CAUTIOUS   -> security < 35 ? "它现在很不安，需要安全感" : "它在观察你的每一个动作";
            case CURIOUS    -> interest > 50 ? "它对你充满好奇，趁热打铁" : "它的好奇心正在消退";
            case BOLD       -> pressure < 30 ? "它并不害怕你，大胆行动" : "它开始对你的存在感到不耐烦";
            case GENTLE     -> trust > 20 ? "它已经开始信任你了" : "它需要更温柔的对待";
            case PLAYFUL    -> interest > 55 ? "它现在心情很好，想和你玩" : "它快要觉得无聊了";
            case MYSTERIOUS -> trust < 10 ? "你还远未赢得它的认可" : "它的态度正在微妙地改变";
        };
    }

    private Archetype assignArchetype(PetSpecies sp) {
        String id = sp.getId();
        if (id.contains("fox") || id.contains("crane") || id.contains("owl") || id.contains("rabbit"))
            return Archetype.CAUTIOUS;
        if (id.contains("monkey") || id.contains("toucan") || id.contains("macaw") || id.contains("dolphin"))
            return Archetype.CURIOUS;
        if (id.contains("jaguar") || id.contains("lion") || id.contains("bear") || id.contains("kangaroo"))
            return Archetype.BOLD;
        if (id.contains("sloth") || id.contains("koala") || id.contains("turtle") || id.contains("giraffe"))
            return Archetype.GENTLE;
        if (id.contains("dog") || id.contains("cat") || id.contains("zebra") || id.contains("platypus") || id.contains("otter"))
            return Archetype.PLAYFUL;
        return Archetype.MYSTERIOUS; // squid, whale, arctic_fox
    }

    private int[] baseEmotions(Archetype a) {
        return switch (a) {
            case CAUTIOUS   -> new int[]{25, 40, 35, 10};  // 安全感低,兴趣中,压力高,信任低
            case CURIOUS    -> new int[]{40, 55, 20, 15};  // 安全感中,兴趣高,压力低
            case BOLD       -> new int[]{55, 35, 15, 10};  // 安全感高,兴趣中,压力低,信任低
            case GENTLE     -> new int[]{30, 45, 20, 20};  // 安全感低,兴趣中,压力低,信任中
            case PLAYFUL    -> new int[]{45, 60, 10, 18};  // 安全感中,兴趣高,压力低
            case MYSTERIOUS -> new int[]{35, 30, 25, 5};   // 一切都中等偏低
        };
    }

    private String generateScene(PetSpecies sp) {
        String[] scenes = switch (archetype) {
            case CAUTIOUS -> new String[]{
                "它站在远处的树影里，没有离开，但也没有靠近。",
                "它停下脚步，侧头看了你一眼，似乎在判断你的意图。",
                "它保持着一段安全距离，耳朵微微转动，捕捉着你的动静。"
            };
            case CURIOUS -> new String[]{
                "它歪着头打量你，眼睛里闪烁着好奇的光芒。",
                "它向前迈了半步又退了回去，显然在纠结要不要接近。",
                "它绕着你画了一个弧线，从不同角度观察着你。"
            };
            case BOLD -> new String[]{
                "它直视着你，没有退缩的意思，仿佛在说'你先动'。",
                "它不紧不慢地站在那里，似乎对你有几分兴趣但绝不示弱。",
                "它目光沉稳，像是这片土地的主人审视着来访者。"
            };
            case GENTLE -> new String[]{
                "它安静地待在那里，动作轻柔得像一片落叶。",
                "它低着头，偶尔抬眼看你一下，眼神温和而羞涩。",
                "它缓慢地移动着，呼吸平稳，似乎并不着急。"
            };
            case PLAYFUL -> new String[]{
                "它兴奋地原地跳了一下，似乎在邀请你和它一起玩。",
                "它绕着你小跑了一圈，尾巴愉快地摆动着。",
                "它叼起一根树枝，跑到不远处又放下，期待地看着你。"
            };
            default -> new String[]{
                "它若隐若现，像是这片区域的一个谜。你不确定它到底在想什么。",
                "它的眼神深不可测，仿佛在评估你是否有资格存在于这里。",
                "它静静地存在着，周围的一切似乎都安静下来。"
            };
        };
        return scenes[RAND.nextInt(scenes.length)];
    }

    /** 每个物种的捕捉条件 [requiredSecurity, requiredInterest, maxPressure, requiredTrust] */
    private static int[] getCaptureRequirements(String speciesId) {
        return switch (speciesId) {
            // 🏯 东亚森林
            case "east_asia_red_panda"    -> arr(70, 30, 30, 75);
            case "east_asia_crane"        -> arr(80, 25, 25, 70);
            case "east_asia_golden_monkey" -> arr(45, 60, 25, 80);
            case "starter_cat"            -> arr(60, 45, 30, 75);
            case "starter_fox"            -> arr(75, 35, 20, 75);
            // 🌴 亚马孙
            case "amazon_toucan"          -> arr(35, 70, 35, 75);
            case "amazon_sloth"           -> arr(60, 20, 35, 70);
            case "amazon_jaguar"          -> arr(50, 45, 20, 85);
            case "starter_macaw"          -> arr(35, 70, 25, 75);
            // 🦁 非洲
            case "africa_zebra"           -> arr(65, 40, 30, 75);
            case "africa_giraffe"         -> arr(75, 30, 25, 70);
            case "africa_lion"            -> arr(55, 35, 20, 85);
            case "starter_dog"            -> arr(45, 65, 25, 70);
            case "starter_rabbit"         -> arr(80, 45, 20, 80);
            // 🦘 澳大利亚
            case "australia_koala"        -> arr(70, 25, 35, 75);
            case "australia_platypus"     -> arr(50, 60, 20, 70);
            case "australia_kangaroo"     -> arr(45, 65, 25, 80);
            case "starter_lizard"         -> arr(55, 50, 20, 75);
            // ❄️ 北极
            case "arctic_snowy_owl"       -> arr(80, 30, 20, 75);
            case "arctic_fox"             -> arr(75, 40, 25, 70);
            case "arctic_polar_bear"      -> arr(55, 30, 20, 85);
            case "starter_bear"           -> arr(65, 35, 30, 75);
            // 🌊 深海
            case "ocean_turtle"           -> arr(70, 25, 30, 80);
            case "ocean_squid"            -> arr(40, 55, 30, 75);
            case "ocean_whale"            -> arr(55, 30, 25, 85);
            case "starter_dolphin"        -> arr(50, 60, 20, 80);
            default                       -> arr(55, 40, 30, 75);
        };
    }

    // ==================== 核心互动 ====================

    /**
     * 玩家选择态度后的完整处理。
     * @return 本轮反馈文本（动物回应）
     */
    public String useAttitude(Attitude att) {
        if (isOver()) return "互动已结束";

        // 同态度冷却：不能连续使用同一态度（等待除外）
        if (att == lastAttitudeUsed && att != Attitude.WAIT && !canBypassCooldown(att)) {
            return animalEmoji + animalName + "对你的重复动作感到困惑……试试换个态度吧！";
        }

        roundsUsed++;
        lastFeedback = null;
        companionEffect = null;
        lastAnimalReaction = null;

        // 1. 计算基础情绪变化
        int[] delta = attitudeEffect(att, archetype);

        // 2. 同伴宠物特性应用（改变互动结构）
        companionEffect = null;
        traitHint = null;
        if (companionTrait != null) {
            delta = applyCompanionTrait(delta, att);
            companionEffect = companionEmoji + companionName + " · 「" + companionTrait.getName() + "」— " + companionTrait.getPositioning();
        }
        lastAttitudeUsed = att;

        // 3. 应用变化
        security = clamp(security + delta[0]);
        interest  = clamp(interest  + delta[1]);
        pressure  = clamp(pressure  + delta[2]);
        trust     = clamp(trust     + delta[3]);

        // 存储最佳delta供金刚鹦鹉下回合使用
        if (companionTrait == CompanionTrait.MACAW) {
            lastBestDelta = delta;
        }

        // 探测系同伴给出行为建议
        traitSuggestion = generateTraitSuggestion(att);

        // 观察态度：揭示隐藏情绪信息
        if (att == Attitude.OBSERVE && !hiddenEmotionRevealed) {
            hiddenEmotionRevealed = true;
            revealedEmotionHint = revealEmotionHint();
            if (traitHint == null) {
                traitHint = "🔍 观察发现了线索——" + revealedEmotionHint;
            }
        }

        // 4. 生成动物回应文本
        lastAnimalReaction = generateReaction(att, delta);

        // 5. 构建反馈
        StringBuilder fb = new StringBuilder();
        fb.append(lastAnimalReaction);
        if (traitHint != null) {
            fb.append("\n\n💡 ").append(traitHint);
        }
        if (companionEffect != null) {
            fb.append("\n\n🐾 ").append(companionEffect);
        }
        fb.append("\n").append(emotionChangeText(delta));
        lastFeedback = fb.toString();

        // 6. 检查结束条件
        checkEndConditions();

        return lastFeedback;
    }

    /** 态度对当前原型的基础情绪影响 [security, interest, pressure, trust]
     *  核心设计：没有"正确牌"——每种态度在不同原型上产生不同情绪方向，
     *  玩家需要根据动物当前状态和同行宠物特性来理解互动节奏。 */
    private int[] attitudeEffect(Attitude att, Archetype arch) {
        return switch (att) {
            // 等待：不施加压力，给动物主动权
            case WAIT -> switch (arch) {
                case CAUTIOUS   -> arr(15, -5, -8, 8);
                case CURIOUS    -> arr(8, -8, -5, 5);
                case BOLD       -> arr(5, -10, -3, 3);
                case GENTLE     -> arr(12, -3, -6, 10);
                case PLAYFUL    -> arr(5, -12, -5, 3);
                case MYSTERIOUS -> arr(10, -2, -4, 6);
            };
            // 靠近：主动缩短距离，表达信任
            case APPROACH -> switch (arch) {
                case CAUTIOUS   -> arr(-5, 8, 15, -3);
                case CURIOUS    -> arr(3, 12, 8, 5);
                case BOLD       -> arr(5, 8, 10, 5);
                case GENTLE     -> arr(-8, 5, 12, -5);
                case PLAYFUL    -> arr(5, 12, 5, 8);
                case MYSTERIOUS -> arr(-3, 8, 10, 2);
            };
            // 观察：不推动不后退，收集信息理解动物
            case OBSERVE -> switch (arch) {
                case CAUTIOUS   -> arr(8, -3, -10, 5);
                case CURIOUS    -> arr(2, -8, -3, 1);
                case BOLD       -> arr(0, -10, -5, -2);
                case GENTLE     -> arr(12, -2, -8, 8);
                case PLAYFUL    -> arr(0, -12, -3, -2);
                case MYSTERIOUS -> arr(5, 5, -5, 8);
            };
            // 投喂：用食物建立正面联结
            case OFFER_FOOD -> switch (arch) {
                case CAUTIOUS   -> arr(5, 8, 3, 12);
                case CURIOUS    -> arr(5, 10, 2, 10);
                case BOLD       -> arr(3, 5, 5, 8);
                case GENTLE     -> arr(8, 8, 5, 15);
                case PLAYFUL    -> arr(5, 8, 3, 14);
                case MYSTERIOUS -> arr(3, 6, 5, 6);
            };
            // 模仿：尝试用姿态建立共鸣
            case MIMIC -> switch (arch) {
                case CAUTIOUS   -> arr(10, 5, -5, 12);
                case CURIOUS    -> arr(5, 12, -3, 10);
                case BOLD       -> arr(3, 5, -5, 5);
                case GENTLE     -> arr(8, 8, -8, 12);
                case PLAYFUL    -> arr(5, 15, -5, 8);
                case MYSTERIOUS -> arr(8, 10, -3, 8);
            };
            // 后退：拉开距离，主动给对方空间
            case STEP_BACK -> switch (arch) {
                case CAUTIOUS   -> arr(15, -5, -18, 8);
                case CURIOUS    -> arr(3, -8, -10, 1);
                case BOLD       -> arr(2, -12, -8, -2);
                case GENTLE     -> arr(10, -5, -15, 5);
                case PLAYFUL    -> arr(2, -15, -8, -3);
                case MYSTERIOUS -> arr(5, -3, -8, 2);
            };
        };
    }

    private static int[] arr(int a, int b, int c, int d) { return new int[]{a, b, c, d}; }

    /** 应用同行宠物特性效果 — 改变互动结构而非数值加成 */
    private int[] applyCompanionTrait(int[] delta, Attitude att) {
        if (companionTrait == null) return delta;

        int s = delta[0], i = delta[1], p = delta[2], t = delta[3];

        // === 🏯 东亚森林 ===

        // 小熊猫「慢慢来」：压力增长降低30%，连续等待不降兴趣
        if (companionTrait == CompanionTrait.RED_PANDA) {
            if (p > 0) p = (int)(p * 0.7);
            if (att == Attitude.WAIT && i < 0) i = 0;
        }

        // 金丝猴「情绪连锁」：连续成功收益递增，失败惩罚更高
        if (companionTrait == CompanionTrait.GOLDEN_MONKEY) {
            boolean isSuccess = (s + i + t - p) > 5;
            if (isSuccess) {
                consecutiveSuccesses++;
                double multi = 1.0 + consecutiveSuccesses * 0.15;
                s = (int)(s * multi); i = (int)(i * multi); t = (int)(t * multi);
            } else {
                consecutiveSuccesses = 0;
                s = (int)(s * 1.3); if (s < 0) s = (int)(s * 1.3); // 失败惩罚扩大
                i = (int)(i * 1.3); if (i < 0) i = (int)(i * 1.3);
            }
        }

        // 小猫「若即若离」：连续同一行为惩罚降低，兴趣下降减缓
        if (companionTrait == CompanionTrait.CAT) {
            if (lastAttitudeUsed == att && i < 0) i = (int)(i * 0.5);
            if (i < 0) i = (int)(i * 0.7); // 兴趣下降减缓
        }

        // 狐狸「试探」：高警惕动物更容易稳定
        if (companionTrait == CompanionTrait.FOX) {
            if (archetype == Archetype.CAUTIOUS && p > 0) p = (int)(p * 0.6);
        }

        // === 🌴 亚马孙 ===

        // 巨嘴鸟「热闹气氛」：兴趣自然下降减缓，连续互动维持节奏
        if (companionTrait == CompanionTrait.TOUCAN) {
            if (i < 0) i = (int)(i * 0.5);
            if (roundsUsed >= 2 && i > 0) i += 2;
        }

        // 树懒「安静陪伴」：所有情绪变化速度减半，不崩盘但信任慢
        if (companionTrait == CompanionTrait.SLOTH) {
            s = s / 2; i = i / 2; p = p / 2; t = t / 2;
        }

        // 美洲豹「压迫感」：成功后亲密增长翻倍（在useAttitude成功检查后应用）
        // 标记已处理，实际翻倍在checkEndConditions成功时
        if (companionTrait == CompanionTrait.JAGUAR && trust >= captureReq[3]) {
            // 实际效果在end reason中体现
        }

        // 金刚鹦鹉「情绪模仿」：存储本回合最佳delta用于下回合
        if (companionTrait == CompanionTrait.MACAW && lastBestDelta != null) {
            // 复制上回合收益最高的情绪方向
            int lastBest = Math.max(Math.max(lastBestDelta[0], lastBestDelta[1]),
                          Math.max(lastBestDelta[3], -lastBestDelta[2]));
            if (lastBest == lastBestDelta[0]) s += 3;
            if (lastBest == lastBestDelta[1]) i += 3;
            if (lastBest == lastBestDelta[2]) p -= 3;
            if (lastBest == lastBestDelta[3]) t += 3;
        }

        // === 🦁 非洲 ===

        // 细纹斑马「群体安心」：逃跑概率降低（在checkEndConditions处理）
        // 标记已处理

        // 非洲狮「威慑」：压制暴躁动物，温顺动物压力增加
        if (companionTrait == CompanionTrait.LION) {
            if (archetype == Archetype.BOLD) { p = (int)(p * 0.5); t += 3; }
            else if (archetype == Archetype.GENTLE || archetype == Archetype.CAUTIOUS) { p += 5; }
        }

        // 小狗「安心感」：安全感下降减缓，失败易补救
        if (companionTrait == CompanionTrait.DOG) {
            if (s < 0) s = (int)(s * 0.5);
            if (p > 0) p = (int)(p * 0.7);
        }

        // 兔子「敏锐」：易察觉变化，但压力变化更剧烈
        if (companionTrait == CompanionTrait.RABBIT) {
            if (p != 0) p = (int)(p * 1.3);
            // 压力接近临界时给预警
            if (pressure + p >= 65) {
                traitHint = companionEmoji + companionName + "的「敏锐」察觉到：" + animalName + "的压力正在升高！";
            }
        }

        // === 🦘 澳大利亚 ===

        // 考拉「放松」：压力不暴涨，负面情绪上限降低
        if (companionTrait == CompanionTrait.KOALA) {
            if (p > 8) p = 8;
        }

        // 鸭嘴兽「异样感知」：神秘型动物揭示隐藏状态
        if (companionTrait == CompanionTrait.PLATYPUS && archetype == Archetype.MYSTERIOUS) {
            if (!hiddenEmotionRevealed) {
                hiddenEmotionRevealed = true;
                revealedEmotionHint = revealEmotionHint();
                traitHint = companionEmoji + companionName + "的「异样感知」看穿了神秘：" + revealedEmotionHint;
            }
        }

        // 红袋鼠「节奏爆发」：前3回合兴趣快速提升，后续衰减
        if (companionTrait == CompanionTrait.KANGAROO) {
            if (roundsUsed <= 3 && i > 0) i = (int)(i * 1.5);
            else if (roundsUsed > 3 && i < 0) i = (int)(i * 1.5);
        }

        // 伞蜥「虚张声势」：可强行改变一次情绪方向
        if (companionTrait == CompanionTrait.LIZARD && !forcedChangeUsed && att == Attitude.MIMIC) {
            forcedChangeUsed = true;
            // 反转压力方向
            if (p > 0) { p = -p; s += 5; }
            traitHint = companionEmoji + companionName + "展开了颈伞！" + animalName + "被虚张声势镇住了！";
        }

        // === ❄️ 北极 ===

        // 雪鸮「冷静观察」：情绪变化信息更准确
        if (companionTrait == CompanionTrait.SNOWY_OWL && !hiddenEmotionRevealed && roundsUsed == 1) {
            hiddenEmotionRevealed = true;
            revealedEmotionHint = revealEmotionHint();
            traitHint = companionEmoji + companionName + "的「冷静观察」分析：" + revealedEmotionHint;
        }

        // 北极狐「耐心试探」：长回合互动收益递增
        if (companionTrait == CompanionTrait.ARCTIC_FOX && roundsUsed >= 5) {
            double multi = 1.0 + (roundsUsed - 4) * 0.1;
            if (s > 0) s = (int)(s * multi);
            if (t > 0) t = (int)(t * multi);
        }

        // 北极熊「压制」：兴趣下降更快（作为阻止逃跑的代价）
        if (companionTrait == CompanionTrait.POLAR_BEAR) {
            if (i < 0) i = (int)(i * 1.3);
        }

        // 棕熊「守护」：失败惩罚降低
        if (companionTrait == CompanionTrait.BROWN_BEAR) {
            if (p > 0) p = (int)(p * 0.6);
            if (s < 0) s = (int)(s * 0.5);
        }

        // === 🌊 深海 ===

        // 蠵龟「记忆」：降低初始压力（代表过去的经验）
        if (companionTrait == CompanionTrait.TURTLE && roundsUsed == 1) {
            p = Math.min(p, 3);
        }

        // 大王乌贼「深海混沌」：每回合随机改变一个情绪趋势
        if (companionTrait == CompanionTrait.SQUID) {
            int[] arr = {s, i, p, t};
            int idx = RAND.nextInt(4);
            int chaos = RAND.nextInt(7) - 3; // -3 ~ +3
            switch (idx) {
                case 0 -> s += chaos;
                case 1 -> i += chaos;
                case 2 -> p += chaos;
                case 3 -> t += chaos;
            }
            if (chaos != 0) {
                traitHint = companionEmoji + companionName + "的「深海混沌」搅动了情绪漩涡！";
            }
        }

        // 蓝鲸「共鸣」：高亲密时全情绪稳定
        if (companionTrait == CompanionTrait.WHALE) {
            // 检查同行宠物亲密度（通过companion的affinity）
            if (trust >= 40) {
                if (p > 5) p = 5;
                if (s < -5) s = -5;
                if (i < -5) i = -5;
            }
        }

        // 海豚「共情」：信任提升更快，恢复更容易
        if (companionTrait == CompanionTrait.DOLPHIN) {
            if (t > 0) t = (int)(t * 1.3);
            if (p > 0) p = (int)(p * 0.7);
        }

        return new int[]{s, i, p, t};
    }

    /** 根据态度×原型 生成语境化叙事回应 — 每回合不同 */
    private String generateReaction(Attitude att, int[] delta) {
        String e = animalEmoji;
        int v = RAND.nextInt(3);
        boolean bigTrust = delta[3] >= 10, bigPressure = delta[2] >= 10;
        boolean lowInterest = delta[1] <= -8, lowSecurity = delta[0] <= -8;

        return switch (att) {
            case WAIT -> switch (archetype) {
                case CAUTIOUS -> switch (v) {
                    case 0 -> e + " 它静止了许久，终于眨了眨眼。你不动，它也不动——这个距离刚刚好。";
                    case 1 -> e + " 时间一分一秒过去……它卧了下来。谨慎的动物需要耐心。";
                    default -> e + " 它低头嗅了嗅地面，又抬头看你。等待让它有了掌控感。";
                };
                case CURIOUS -> switch (v) {
                    case 0 -> e + " 它焦急地踱了几步——你的等待让它更加好奇了。";
                    case 1 -> e + " 它叫了一声，似乎对你不为所动感到意外。";
                    default -> e + " 它歪着头，反复打量你。为什么你不动？它想知道。";
                };
                case BOLD -> switch (v) {
                    case 0 -> e + " 它不屑地甩了甩头，似乎在说'我无所谓'。";
                    case 1 -> e + " 它打了个哈欠。你的等待并没有给它留下深刻印象。";
                    default -> e + " 它原地坐了下来，目光依然牢牢锁定着你。";
                };
                case GENTLE -> switch (v) {
                    case 0 -> e + " 它温和地看了你一眼，仿佛在说'没关系，慢慢来'。";
                    case 1 -> e + " 它低头理了理自己的毛发，氛围安静而舒适。";
                    default -> e + " 它轻轻地叹了口气，身体放松了几分。";
                };
                case PLAYFUL -> switch (v) {
                    case 0 -> e + " 它不耐烦地原地蹦了两下。等什么等，快跟它玩啊！";
                    case 1 -> e + " 它叼起一根树枝丢到你面前——它在主动找乐子。";
                    default -> e + " 它无聊地转起了圈。你的等待快把它闷坏了。";
                };
                case MYSTERIOUS -> switch (v) {
                    case 0 -> e + " 它一动不动，像一尊雕像。时间仿佛凝固了。";
                    case 1 -> e + " 它的眼里闪过一丝不易察觉的光。它认同了你的节奏。";
                    default -> e + " 夜色般的沉默笼罩着你们。它在等什么？你也在等。";
                };
            };

            case APPROACH -> switch (archetype) {
                case CAUTIOUS -> switch (v) {
                    case 0 -> e + " 它警觉地绷紧了身体！你的靠近让它不安。";
                    case 1 -> e + " 它后退了一步，但没有跑。它在给你一个警告。";
                    default -> bigPressure ? e + " 它竖起了毛发——你靠得太快了！"
                        : e + " 它迟疑地看着你靠近，耳朵向后抿了抿。";
                };
                case CURIOUS -> switch (v) {
                    case 0 -> e + " 它兴奋地迎上来！这是它期待已久的信号。";
                    case 1 -> e + " 它向前迈了一步，眼睛闪闪发亮。";
                    default -> e + " 它略微犹豫了一下，然后坚定地向你走来。";
                };
                case BOLD -> switch (v) {
                    case 0 -> e + " 它挺起胸膛，直视着你。它从不害怕面对面。";
                    case 1 -> e + " 它一动不动，像一座山。你的靠近只是验证了它的权威。";
                    default -> e + " 它向前迈了一步——不是迎接你，而是宣告领地。";
                };
                case GENTLE -> switch (v) {
                    case 0 -> e + " 它吓得缩了缩身子。温柔的动物需要更慢的节奏。";
                    case 1 -> bigPressure ? e + " 它颤抖着往后退。你的靠近吓到它了。"
                        : e + " 它怯生生地看着你，但尾巴轻轻摆了一下。";
                    default -> e + " 它垂下目光，似乎不知所措。";
                };
                case PLAYFUL -> switch (v) {
                    case 0 -> e + " 它欢快地摇着尾巴迎了上来！它等这一刻很久了。";
                    case 1 -> e + " 它兴奋地绕着你跑了一圈。新朋友来了！";
                    default -> e + " 它扑到你脚边，开心得像个孩子。";
                };
                case MYSTERIOUS -> switch (v) {
                    case 0 -> e + " 它微微侧身，让你靠近了几分。这是难得的让步。";
                    case 1 -> e + " 它的目光变得锐利——你在试探它的边界。";
                    default -> e + " 它没有退缩，也没有欢迎。它只是看着你走来。";
                };
            };

            case OBSERVE -> switch (archetype) {
                case CAUTIOUS -> switch (v) {
                    case 0 -> e + " 它在你的注视下渐渐放松。被理解的感觉是安全的。";
                    case 1 -> e + " 它躲开了你的目光，但没有逃跑。";
                    default -> e + " 你从它的站姿中读到了犹豫——它在权衡。";
                };
                case CURIOUS -> switch (v) {
                    case 0 -> e + " 它饶有兴致地回望着你。这是什么游戏？";
                    case 1 -> lowInterest ? e + " 它看向别处，似乎在说'看够了没？'"
                        : e + " 它摆出各种姿势，仿佛在说'我好看吗？'";
                    default -> e + " 你们的目光交汇了一瞬。它眨了眨眼。";
                };
                case BOLD -> switch (v) {
                    case 0 -> e + " 它毫不在意你的目光，继续做自己的事。";
                    case 1 -> e + " 它回盯着你，好像在说'看什么看？'";
                    default -> e + " 它打了个响鼻。你的观察让它有些不耐烦。";
                };
                case GENTLE -> switch (v) {
                    case 0 -> e + " 它在你温柔的目光下显得更加柔和了。";
                    case 1 -> e + " 它轻轻抬起头，似乎在回应你的注视。";
                    default -> e + " 你注意到它呼吸的节奏——缓慢而平稳。它在慢慢接受你。";
                };
                case PLAYFUL -> switch (v) {
                    case 0 -> e + " 它夸张地表演了起来——它喜欢被关注！";
                    case 1 -> lowInterest ? e + " 它停下了动作。被盯着看让它觉得无聊。"
                        : e + " 它朝你做了个鬼脸，然后开心地跑开了。";
                    default -> e + " 它故意做了个滑稽的动作，逗你笑。";
                };
                case MYSTERIOUS -> switch (v) {
                    case 0 -> e + " 你隐约从它的姿态中读出了什么……但又不确定。";
                    case 1 -> e + " 它的眼神深不可测，但你的观察没有白费。";
                    default -> e + " 观察一只神秘的动物就像读一本无字书。你学到了耐心。";
                };
            };

            case OFFER_FOOD -> switch (archetype) {
                case CAUTIOUS -> switch (v) {
                    case 0 -> e + " 它犹豫了许久，终于小心翼翼地向前挪了挪。";
                    case 1 -> e + " 它的鼻子抽动着——食物的香气正在瓦解它的防线。";
                    default -> bigTrust ? e + " 它终于从你手中接过了食物！"
                        : e + " 它警惕地看着食物，又看看你。它在挣扎。";
                };
                case CURIOUS -> switch (v) {
                    case 0 -> e + " 它兴奋地跑了过来——没有什么比美食更能拉近距离！";
                    case 1 -> e + " 它谨慎地嗅了嗅，然后大口吃了起来。";
                    default -> e + " 它开心地接过了食物，吃得津津有味。";
                };
                case BOLD -> switch (v) {
                    case 0 -> e + " 它昂首阔步走来，理所应当地享用了食物。";
                    case 1 -> e + " 它不客气地一口叼走食物，然后退到一旁细细品尝。";
                    default -> e + " 它看了看食物，又看了看你——它接受贡品了。";
                };
                case GENTLE -> switch (v) {
                    case 0 -> e + " 它轻轻从你手中衔走食物，温柔得让人心软。";
                    case 1 -> e + " 它低头细细地吃着，时不时抬头感激地看你一眼。";
                    default -> e + " 食物是最好的语言。它开始信任你了。";
                };
                case PLAYFUL -> switch (v) {
                    case 0 -> e + " 它兴奋地跳了起来，差点把你手中的食物撞飞！";
                    case 1 -> e + " 它叼起食物抛到空中，玩了一会儿才吃掉。";
                    default -> e + " 它开心地吃完了，然后期待地看着你——还有吗？";
                };
                case MYSTERIOUS -> switch (v) {
                    case 0 -> e + " 它优雅地靠近，轻轻取走了食物。全程没有发出一点声音。";
                    case 1 -> e + " 它迟疑了片刻，然后把食物衔到远处才吃。";
                    default -> e + " 食物消失了——你甚至没看清楚它怎么拿走的。";
                };
            };

            case MIMIC -> switch (archetype) {
                case CAUTIOUS -> switch (v) {
                    case 0 -> e + " 你的模仿让它困惑了一瞬，然后——它放松了警惕。";
                    case 1 -> e + " 它歪着头看着你的模仿，似乎理解了什么。";
                    default -> e + " 模仿是最纯粹的沟通。它听懂了你的身体语言。";
                };
                case CURIOUS -> switch (v) {
                    case 0 -> e + " 它兴奋地模仿了回来！你们在玩一场无声的游戏。";
                    case 1 -> e + " 它被你的模仿逗得团团转，开心极了。";
                    default -> e + " 它停下脚步，仔细看了你的模仿——然后回以同样的动作！";
                };
                case BOLD -> switch (v) {
                    case 0 -> e + " 它冷眼看着你的模仿，似乎在说'你学得不像'。";
                    case 1 -> e + " 它昂起头，你的模仿让它感受到了敬意。";
                    default -> e + " 它低沉地哼了一声——算是认可了。";
                };
                case GENTLE -> switch (v) {
                    case 0 -> e + " 它的眼睛亮了起来。它在你的模仿中看到了共鸣。";
                    case 1 -> e + " 它小心地回以同样的动作，动作柔得像羽毛。";
                    default -> e + " 一种无言的默契在你们之间流淌。你学得像极了。";
                };
                case PLAYFUL -> switch (v) {
                    case 0 -> e + " 它兴奋得快要疯了！模仿游戏是它最爱的玩法！";
                    case 1 -> e + " 它开始做各种动作等你模仿——你们已经成了玩伴。";
                    default -> e + " 它手舞足蹈地开始了最热闹的模仿派对！";
                };
                case MYSTERIOUS -> switch (v) {
                    case 0 -> e + " 你模仿了它的姿态，它用几乎察觉不到的点头回应了你。";
                    case 1 -> e + " 它的神秘中透出一丝认可——模仿是通向它的桥梁。";
                    default -> e + " 它允许你进入它的世界了。你的模仿叩开了门。";
                };
            };

            case STEP_BACK -> switch (archetype) {
                case CAUTIOUS -> switch (v) {
                    case 0 -> e + " 它如释重负地呼出一口长气。距离产生了安全感。";
                    case 1 -> e + " 它终于平静了下来。你的后退是它收到的最好的信号。";
                    default -> bigPressure ? e + " 它紧绷的神经明显松了下来——谢谢你给了它空间。"
                        : e + " 它安心地甩了甩尾巴。尊重边界是最好的沟通。";
                };
                case CURIOUS -> switch (v) {
                    case 0 -> lowInterest ? e + " 你退后了，它的好奇心也随之消退……"
                        : e + " 你退后让它困惑——但它很快又对你产生了兴趣。";
                    case 1 -> e + " 它追了一步——你的后退反而激起了它的好奇。";
                    default -> e + " 距离增加了神秘感，它更加想了解你了。";
                };
                case BOLD -> switch (v) {
                    case 0 -> e + " 它轻蔑地看着你退后。它以为你害怕了。";
                    case 1 -> e + " 你退后一步，它毫无反应。对它来说这不重要。";
                    default -> e + " 它打了个响鼻，好像在说'随你便'。";
                };
                case GENTLE -> switch (v) {
                    case 0 -> e + " 它安心地低下了头。你的尊重让它感动。";
                    case 1 -> e + " 它温柔地目送你退后。空间让一切都变得更舒适了。";
                    default -> e + " 它的呼吸变得更深更平。你在用行动说'我理解你'。";
                };
                case PLAYFUL -> switch (v) {
                    case 0 -> e + " 它愣住了。你不想玩了吗？它的尾巴垂了下去。";
                    case 1 -> e + " 它困惑地歪着头。后退？这是什么新游戏？";
                    default -> e + " 它失落地坐了下来。活泼的它最讨厌冷场。";
                };
                case MYSTERIOUS -> switch (v) {
                    case 0 -> e + " 它纹丝不动。你的后退是它预料之中的举动。";
                    case 1 -> e + " 它在暗处观察着你的后退。这是一场精神博弈。";
                    default -> e + " 你退后一步，它似乎略感意外——但很快恢复了神秘。";
                };
            };
        };
    }

    private String emotionChangeText(int[] d) {
        List<String> parts = new ArrayList<>();
        if (d[0] != 0) parts.add((d[0] > 0 ? "+" : "") + d[0] + "安全感");
        if (d[1] != 0) parts.add((d[1] > 0 ? "+" : "") + d[1] + "兴趣");
        if (d[2] != 0) parts.add((d[2] > 0 ? "↑" : "↓") + "压力" + Math.abs(d[2]));
        if (d[3] != 0) parts.add((d[3] > 0 ? "+" : "") + d[3] + "信任");
        return parts.isEmpty() ? "" : String.join("  ", parts);
    }

    /** 探测系/共情系同伴根据动物当前情绪给出行动建议 */
    /** 公开方法：检查某态度是否处于冷却中（JSP用） */
    public boolean isOnCooldown(Attitude att) {
        return att == lastAttitudeUsed && att != Attitude.WAIT && !canBypassCooldown(att);
    }

    /** 获取冷却绕过的提示文本（JSP用） */
    public String getCooldownBypassHint(Attitude att) {
        if (companionTrait == null || att != lastAttitudeUsed || att == Attitude.WAIT) return null;
        if (companionTrait == CompanionTrait.DOLPHIN && att == Attitude.OFFER_FOOD)
            return companionEmoji + "的「共情」让你可以连续投喂";
        if (companionTrait == CompanionTrait.LION && att == Attitude.APPROACH)
            return companionEmoji + "的「威慑」让你可以连续靠近";
        if (companionTrait == CompanionTrait.KANGAROO && att == Attitude.MIMIC)
            return companionEmoji + "的「节奏爆发」让你可以连续模仿";
        if (companionTrait == CompanionTrait.SLOTH && att == Attitude.STEP_BACK)
            return companionEmoji + "的「安静陪伴」让你可以连续后退";
        if (companionTrait == CompanionTrait.DOG && att == Attitude.OBSERVE)
            return companionEmoji + "的「安心感」让你可以连续观察";
        return null;
    }

    /** 检查同伴特性是否允许连续使用同一态度 */
    private boolean canBypassCooldown(Attitude att) {
        if (companionTrait == null) return false;
        // 海豚「共情」→ 投喂可连续
        if (companionTrait == CompanionTrait.DOLPHIN && att == Attitude.OFFER_FOOD) return true;
        // 狮子「威慑」→ 靠近可连续
        if (companionTrait == CompanionTrait.LION && att == Attitude.APPROACH) return true;
        // 袋鼠「节奏爆发」→ 模仿可连续
        if (companionTrait == CompanionTrait.KANGAROO && att == Attitude.MIMIC) return true;
        // 树懒「安静陪伴」→ 后退可连续
        if (companionTrait == CompanionTrait.SLOTH && att == Attitude.STEP_BACK) return true;
        // 小狗「安心感」→ 观察可连续
        if (companionTrait == CompanionTrait.DOG && att == Attitude.OBSERVE) return true;
        return false;
    }

    private String generateTraitSuggestion(Attitude justUsed) {
        if (companionTrait == null) return null;
        CompanionTrait.TraitType type = companionTrait.getType();
        if (type != CompanionTrait.TraitType.DETECTION && type != CompanionTrait.TraitType.EMPATHY)
            return null;

        String pre = companionEmoji + companionName + "的「" + companionTrait.getName() + "」觉得：";

        // 针对性的行为建议
        if (pressure >= 65)
            return pre + "压力太大了！试试「后退」给" + animalName + "留出空间，或「等待」让它冷静下来。";
        if (interest <= 20)
            return pre + animalName + "快没兴趣了。用「模仿」或「靠近」重新点燃它的好奇心！";
        if (security <= 25)
            return pre + animalName + "缺乏安全感。「等待」让它掌握节奏，或「后退」拉开安全距离。";
        if (trust >= captureReq[3] - 8 && security >= captureReq[0] - 10)
            return pre + "就差一点了！用「投喂」或「模仿」完成最后一击吧！";
        if (trust >= 40 && security >= 50)
            return pre + "关系进展良好，稳妥的「观察」或趁热的「靠近」都是好选择。";
        if (interest >= 60 && trust >= 20)
            return pre + animalName + "兴致正高！此时「模仿」或「投喂」最能拉近距离。";

        // 通用建议
        String[] general = {
            pre + "当前节奏不错。不妨试试「观察」来深入了解它。",
            pre + "保持目前的步调。有时「模仿」能创造意想不到的突破。",
            pre + "耐心永远是美德。「等待」一下看看接下来怎么发展？",
        };
        return general[RAND.nextInt(general.length)];
    }

    private void checkEndConditions() {
        // 棕熊「守护」：压力过高时自动缓冲一次
        if (companionTrait == CompanionTrait.BROWN_BEAR && !bufferUsed && pressure >= PRESSURE_FLEE - 10) {
            bufferUsed = true;
            pressure = clamp(pressure - 25);
            traitHint = companionEmoji + companionName + "的「守护」挡在了" + animalName + "面前！压力大幅降低！";
        }

        // 北极熊「压制」：可强制阻止一次逃跑
        if (companionTrait == CompanionTrait.POLAR_BEAR && !fleeBlockUsed && pressure >= PRESSURE_FLEE) {
            fleeBlockUsed = true;
            pressure = clamp(pressure - 30);
            interest = clamp(interest - 10); // 代价
            traitHint = companionEmoji + companionName + "的「压制」气场阻止了" + animalName + "逃跑！";
        }

        // 细纹斑马「群体安心」：逃跑概率降低（压力阈值提高）
        int effectiveFlee = PRESSURE_FLEE;
        if (companionTrait == CompanionTrait.ZEBRA) {
            effectiveFlee = 95; // 更难逃跑
        }

        // 检查回合超时：动物失去耐心跑走
        if (roundsUsed >= maxRounds && !success) {
            timeout = true;
            return;
        }

        // 检查物种特定捕捉条件
        if (security >= captureReq[0] && interest >= captureReq[1]
            && pressure <= captureReq[2] && trust >= captureReq[3]) {
            success = true;
        } else if (pressure >= effectiveFlee) {
            failed = true;
        } else if (interest <= INTEREST_GONE) {
            left = true;
        }
    }

    private int clamp(int v) { return Math.max(0, Math.min(100, v)); }

    // ==================== 查询 ====================

    public boolean isOver() { return success || failed || left || timeout; }
    public boolean isSuccess() { return success; }
    public boolean isFailed() { return failed || left; }
    public boolean isTimeout() { return timeout; }
    public int getMaxRounds() { return maxRounds; }

    public String getAnimalName() { return animalName; }
    public String getAnimalEmoji() { return animalEmoji; }
    public String getSceneDesc() { return sceneDesc; }
    public Archetype getArchetype() { return archetype; }
    public int getSecurity() { return security; }
    public int getInterest() { return interest; }
    public int getPressure() { return pressure; }
    public int getTrust() { return trust; }
    public int getRoundsUsed() { return roundsUsed; }
    public String getLastFeedback() { return lastFeedback; }
    public String getLastAnimalReaction() { return lastAnimalReaction; }
    public String getCompanionEffect() { return companionEffect; }
    public CompanionTrait getCompanionTrait() { return companionTrait; }
    public String getCompanionName() { return companionName; }
    public String getCompanionEmoji() { return companionEmoji; }
    public String getTraitHint() { return traitHint; }
    public boolean isHiddenEmotionRevealed() { return hiddenEmotionRevealed; }
    public String getRevealedEmotionHint() { return revealedEmotionHint; }
    public boolean isFleeBlockUsed() { return fleeBlockUsed; }
    public boolean isBufferUsed() { return bufferUsed; }
    public boolean isForcedChangeUsed() { return forcedChangeUsed; }
    public Attitude getLastAttitudeUsed() { return lastAttitudeUsed; }
    public String getTraitSuggestion() { return traitSuggestion; }

    /** 捕捉条件获取器（供JSP展示） */
    public int getRequiredSecurity() { return captureReq[0]; }
    public int getRequiredInterest() { return captureReq[1]; }
    public int getMaxPressure() { return captureReq[2]; }
    public int getRequiredTrust() { return captureReq[3]; }

    /** 捕捉条件摘要文本 */
    public String getCaptureReqText() {
        StringBuilder sb = new StringBuilder();
        sb.append("安全感≥").append(captureReq[0]);
        sb.append("  兴趣≥").append(captureReq[1]);
        sb.append("  压力≤").append(captureReq[2]);
        sb.append("  信任≥").append(captureReq[3]);
        return sb.toString();
    }

    /** 信任进度条HTML颜色 */
    public String getTrustColor() { return trust >= 60 ? "#4CAF50" : trust >= 30 ? "#FFC107" : "#FF9800"; }
    /** 压力进度条HTML颜色 */
    public String getPressureColor() { return pressure >= 70 ? "#f44336" : pressure >= 40 ? "#FF9800" : "#8BC34A"; }
    /** 兴趣进度条HTML颜色 */
    public String getInterestColor() { return interest >= 50 ? "#4CAF50" : interest >= 20 ? "#FFC107" : "#f44336"; }
    /** 安全感进度条HTML颜色 */
    public String getSecurityColor() { return security >= 50 ? "#4CAF50" : security >= 25 ? "#FFC107" : "#f44336"; }

    /** 结束原因文本 */
    public String getEndReason() {
        if (success) return animalName + "感受到了你的诚意，主动向你走来！";
        if (failed) return "压力过大——" + animalName + "惊恐地逃走了……";
        if (left)   return "兴趣消退——" + animalName + "转身离开了……";
        if (timeout) return "时间到了——" + animalName + "失去了耐心，消失在丛林深处……但它留下了一些食物作为馈赠。";
        return "";
    }

    /** 失败提示（根据原因不同） */
    public String getFailureHint() {
        if (failed) return "这次靠得太急了。下次试着先降低它的压力——静静等待，或者移开视线。";
        if (left)   return "你的动作没能引起它的兴趣。试试模仿它的动作，或者用温柔的声音呼唤。";
        if (timeout) return "它离开了，但并非空手而归。下次试着在" + maxRounds + "回合内赢得它的信任吧！";
        return "";
    }

    /** 获取态度建议（当玩家连续使用同一态度时提示） */
    public String getPacingHint(Attitude lastAtt) {
        if (lastAtt == null) return null;
        return switch (lastAtt) {
            case APPROACH, OFFER_FOOD -> roundsUsed >= 3 && pressure > 50
                ? "动物似乎有些紧张了。考虑退一步——后退，或静静等待。" : null;
            case WAIT, STEP_BACK, OBSERVE -> roundsUsed >= 3 && interest < 30
                ? "动物开始失去兴趣了。是时候推进了——靠近，或模仿动作。" : null;
            default -> null;
        };
    }
}
