package org.example.pets.bean;

/**
 * 同行宠物特性系统 — 改变互动结构，而非数值加成。
 * 每只宠物拥有1个核心特性 + 1个隐藏倾向。
 */
public class CompanionTrait {

    public enum TraitType {
        SAFETY("安全系", "降低逃跑风险"),
        EMPATHY("共情系", "提高信任建立"),
        RHYTHM("节奏系", "稳定情绪波动"),
        DETECTION("探测系", "读取隐藏信息"),
        RISK("风险系", "高收益高风险"),
        PROTECTION("保护系", "失败容错"),
        INDUCTION("诱导系", "改变行为倾向");

        public final String label, desc;
        TraitType(String l, String d) { label = l; desc = d; }
    }

    private final String name;
    private final String description;
    private final TraitType type;
    private final String hiddenTendency;
    private final String positioning;

    public CompanionTrait(String name, String description, TraitType type,
                          String hiddenTendency, String positioning) {
        this.name = name; this.description = description;
        this.type = type; this.hiddenTendency = hiddenTendency;
        this.positioning = positioning;
    }

    public String getName() { return name; }
    public String getDescription() { return description; }
    public TraitType getType() { return type; }
    public String getHiddenTendency() { return hiddenTendency; }
    public String getPositioning() { return positioning; }

    /** 根据物种ID获取同行特性 */
    public static CompanionTrait forSpecies(String speciesId) {
        if (speciesId == null) return null;
        // 匹配物种ID中的关键词
        if (speciesId.contains("red_panda"))       return RED_PANDA;
        if (speciesId.contains("crane"))           return CRANE;
        if (speciesId.contains("golden_monkey"))   return GOLDEN_MONKEY;
        if (speciesId.contains("starter_cat"))     return CAT;
        if (speciesId.contains("starter_fox"))     return FOX;
        if (speciesId.contains("toucan") && !speciesId.contains("starter")) return TOUCAN;
        if (speciesId.contains("sloth"))           return SLOTH;
        if (speciesId.contains("jaguar"))          return JAGUAR;
        if (speciesId.contains("starter_macaw"))   return MACAW;
        if (speciesId.contains("zebra"))           return ZEBRA;
        if (speciesId.contains("giraffe"))         return GIRAFFE;
        if (speciesId.contains("africa_lion"))     return LION;
        if (speciesId.contains("starter_dog"))     return DOG;
        if (speciesId.contains("starter_rabbit"))  return RABBIT;
        if (speciesId.contains("koala"))           return KOALA;
        if (speciesId.contains("platypus"))        return PLATYPUS;
        if (speciesId.contains("kangaroo"))        return KANGAROO;
        if (speciesId.contains("starter_lizard"))  return LIZARD;
        if (speciesId.contains("snowy_owl"))       return SNOWY_OWL;
        if (speciesId.contains("arctic_fox"))      return ARCTIC_FOX;
        if (speciesId.contains("polar_bear"))      return POLAR_BEAR;
        if (speciesId.contains("starter_bear"))    return BROWN_BEAR;
        if (speciesId.contains("turtle"))          return TURTLE;
        if (speciesId.contains("squid"))           return SQUID;
        if (speciesId.contains("whale"))           return WHALE;
        if (speciesId.contains("starter_dolphin")) return DOLPHIN;
        return null;
    }

    /** 根据Pet查找特性（通过物种名反查ID） */
    public static CompanionTrait forPet(Pet pet) {
        if (pet == null) return null;
        for (PetSpecies sp : PetSpecies.ALL) {
            if (sp.getName().equals(pet.getSpecies())) {
                return forSpecies(sp.getId());
            }
        }
        return null;
    }

    // ==================== 🏯 东亚森林 ====================

    public static final CompanionTrait RED_PANDA = new CompanionTrait(
        "慢慢来", "压力增长速度降低30%，连续等待不会降低兴趣",
        TraitType.RHYTHM, "慢热动物更容易亲近", "节奏稳定器"
    );

    public static final CompanionTrait CRANE = new CompanionTrait(
        "观察入微", "更容易看到隐藏情绪变化，第一次互动额外获得情绪提示",
        TraitType.DETECTION, "高智力动物更容易建立默契", "情报型"
    );

    public static final CompanionTrait GOLDEN_MONKEY = new CompanionTrait(
        "情绪连锁", "连续成功互动时收益递增，但失败惩罚也更高",
        TraitType.RISK, "活泼动物更容易共鸣", "爆发成长型"
    );

    public static final CompanionTrait CAT = new CompanionTrait(
        "若即若离", "连续同一行为惩罚降低，野生动物兴趣下降速度减缓",
        TraitType.RHYTHM, "傲娇型动物更容易互动", "节奏控制型"
    );

    public static final CompanionTrait FOX = new CompanionTrait(
        "试探", "能看到野生动物下一步倾向，高警惕动物更容易稳定",
        TraitType.DETECTION, "狐狸会模仿玩家互动节奏", "博弈型"
    );

    // ==================== 🌴 亚马孙 ====================

    public static final CompanionTrait TOUCAN = new CompanionTrait(
        "热闹气氛", "兴趣自然下降减缓，连续互动更容易维持节奏",
        TraitType.RHYTHM, "群体动物更容易被吸引", "气氛维持型"
    );

    public static final CompanionTrait SLOTH = new CompanionTrait(
        "安静陪伴", "所有情绪变化速度减半，不容易崩盘，但建立信任更慢",
        TraitType.SAFETY, "急性动物会感到不耐烦", "超稳定型"
    );

    public static final CompanionTrait JAGUAR = new CompanionTrait(
        "压迫感", "初始信任降低，但成功后亲密增长翻倍",
        TraitType.RISK, "胆小动物容易直接逃跑", "高风险高收益"
    );

    public static final CompanionTrait MACAW = new CompanionTrait(
        "情绪模仿", "自动复制上一回合收益最高的情绪变化方向",
        TraitType.INDUCTION, "聪明动物更容易被引导", "学习型"
    );

    // ==================== 🦁 非洲 ====================

    public static final CompanionTrait ZEBRA = new CompanionTrait(
        "群体安心", "野生动物逃跑概率显著降低",
        TraitType.SAFETY, "群居动物更容易亲近", "防逃跑型"
    );

    public static final CompanionTrait GIRAFFE = new CompanionTrait(
        "远望", "开局提前看到一个隐藏情绪倾向",
        TraitType.DETECTION, "高大体型让小型动物紧张", "预判型"
    );

    public static final CompanionTrait LION = new CompanionTrait(
        "威慑", "强制压制高暴躁动物，但温顺动物压力增加",
        TraitType.INDUCTION, "食物链顶端的气场", "极端控制型"
    );

    public static final CompanionTrait DOG = new CompanionTrait(
        "安心感", "安全感自然下降速度减缓，失败时更容易补救",
        TraitType.PROTECTION, "几乎对所有动物都友好", "新手神宠"
    );

    public static final CompanionTrait RABBIT = new CompanionTrait(
        "敏锐", "更容易触发隐藏互动，更容易察觉情绪变化，但压力变化更剧烈",
        TraitType.DETECTION, "敏感体质放大情绪波动", "高感知型"
    );

    // ==================== 🦘 澳大利亚 ====================

    public static final CompanionTrait KOALA = new CompanionTrait(
        "放松", "压力不会暴涨，负面情绪上限降低",
        TraitType.SAFETY, "慢节奏让快节奏动物不耐烦", "防崩盘型"
    );

    public static final CompanionTrait PLATYPUS = new CompanionTrait(
        "异样感知", "可发现神秘型动物的隐藏状态",
        TraitType.DETECTION, "对特殊动物有独特吸引力", "稀有事件型"
    );

    public static final CompanionTrait KANGAROO = new CompanionTrait(
        "节奏爆发", "短时间内快速提升兴趣，但后续衰减更快",
        TraitType.RISK, "耐力不足需要快速决胜", "冲刺型"
    );

    public static final CompanionTrait LIZARD = new CompanionTrait(
        "虚张声势", "可强行改变一次野生动物的情绪方向",
        TraitType.INDUCTION, "只能用一次的绝招", "干扰型"
    );

    // ==================== ❄️ 北极 ====================

    public static final CompanionTrait SNOWY_OWL = new CompanionTrait(
        "冷静观察", "情绪变化信息更准确，不容易误判",
        TraitType.DETECTION, "对伪装型动物特别有效", "精准分析型"
    );

    public static final CompanionTrait ARCTIC_FOX = new CompanionTrait(
        "耐心试探", "长回合互动收益递增，越久越有利",
        TraitType.RHYTHM, "适合对付慢热动物", "长线成长型"
    );

    public static final CompanionTrait POLAR_BEAR = new CompanionTrait(
        "压制", "可强制阻止一次逃跑，但兴趣下降更快",
        TraitType.PROTECTION, "极地霸主的气场", "强控制型"
    );

    public static final CompanionTrait BROWN_BEAR = new CompanionTrait(
        "守护", "失败惩罚降低，压力过高时自动缓冲一次",
        TraitType.PROTECTION, "憨厚可靠的力量型伙伴", "容错型"
    );

    // ==================== 🌊 深海 ====================

    public static final CompanionTrait TURTLE = new CompanionTrait(
        "记忆", "曾经互动失败的动物再次遇到时更容易建立关系",
        TraitType.EMPATHY, "远古智慧跨越时间", "长期成长型"
    );

    public static final CompanionTrait SQUID = new CompanionTrait(
        "深海混沌", "每回合随机改变一个情绪趋势，带来不可预测的变化",
        TraitType.INDUCTION, "混沌中蕴藏机会", "混乱型"
    );

    public static final CompanionTrait WHALE = new CompanionTrait(
        "共鸣", "高亲密时全情绪稳定，极难崩盘",
        TraitType.EMPATHY, "巨兽的平静感染一切", "后期神宠"
    );

    public static final CompanionTrait DOLPHIN = new CompanionTrait(
        "共情", "更容易恢复失败互动，动物信任提升更快",
        TraitType.EMPATHY, "海洋最聪明的社交者", "社交型"
    );
}
