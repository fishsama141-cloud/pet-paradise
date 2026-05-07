package org.example.pets.bean;

import java.util.*;

/**
 * 食物系统定义：区域 → 食物，物种 → 偏好（喜欢/厌恶），其余为普通。
 * 每个区域特有动物的偏好食物只能在该区域获取。
 */
public class FoodDef {
    private final String name;
    private final String emoji;
    private final String description;
    private final List<String> regions; // 可在哪些区域获取

    public FoodDef(String name, String emoji, String description, String... regions) {
        this.name = name; this.emoji = emoji; this.description = description;
        this.regions = List.of(regions);
    }

    public String getName() { return name; }
    public String getEmoji() { return emoji; }
    public String getDescription() { return description; }
    public List<String> getRegions() { return regions; }

    // ==================== 全部食物定义 ====================

    public static final List<FoodDef> ALL = List.of(
        // ── 通用食物（多区域可获得）──
        new FoodDef("苹果", "🍎", "新鲜多汁的红苹果，大部分动物都能接受。",
            "翠绿森林", "阳光草原", "东亚森林"),
        new FoodDef("胡萝卜", "🥕", "脆甜的胡萝卜，小动物们的最爱。",
            "翠绿森林", "阳光草原"),
        new FoodDef("面包", "🍞", "松软的麦香面包，温和安全的选择。",
            "翠绿森林", "巍峨山脉"),

        // ── 东亚森林特产 ──
        new FoodDef("竹笋", "🎋", "刚从竹林里挖出的嫩竹笋，清脆可口。",
            "东亚森林"),
        new FoodDef("蜂蜜", "🍯", "高山野蜂酿的百花蜜，金色浓稠。",
            "东亚森林"),
        new FoodDef("河鱼", "🐟", "山溪里捕捞的新鲜活鱼，鲜美无比。",
            "东亚森林"),

        // ── 亚马孙雨林特产 ──
        new FoodDef("坚果", "🥜", "雨林巨树上结的坚果，富含油脂和营养。",
            "亚马孙雨林"),
        new FoodDef("野蕉", "🍌", "雨林野生的香蕉，比普通香蕉更香甜。",
            "亚马孙雨林"),
        new FoodDef("昆虫串", "🦗", "富含蛋白质的可食用昆虫，雨林居民的日常美食。",
            "亚马孙雨林"),

        // ── 非洲稀树草原特产 ──
        new FoodDef("肉干", "🥩", "草原上风干的野味肉条，肉香浓郁有嚼劲。",
            "非洲稀树草原"),
        new FoodDef("野瓜", "🍈", "草原上自然生长的甜瓜，水润清甜解渴。",
            "非洲稀树草原"),
        new FoodDef("金合欢叶", "🌿", "金合欢树的新鲜嫩叶，草食动物的美味。",
            "非洲稀树草原"),

        // ── 澳大利亚内陆特产 ──
        new FoodDef("桉树叶", "🍃", "银灰色的桉树嫩叶，散发着独特的清凉气味。",
            "澳大利亚内陆"),
        new FoodDef("幼虫", "🐛", "木头里找到的肥美白蚁幼虫，营养丰富。",
            "澳大利亚内陆"),
        new FoodDef("草籽", "🌱", "内陆耐旱草类的种子，小而香脆。",
            "澳大利亚内陆"),

        // ── 北极冰原特产 ──
        new FoodDef("冻鱼", "🐟", "冰洋下捕获的寒水鱼，肉质紧实鲜美。",
            "北极冰原"),
        new FoodDef("鸟蛋", "🥚", "海崖上鸟巢里找到的蛋，营养浓缩的极地美味。",
            "北极冰原"),
        new FoodDef("海豹肉干", "🍖", "极地风干的海豹肉，高热量高蛋白。",
            "北极冰原"),

        // ── 深海世界特产 ──
        new FoodDef("磷虾", "🦐", "深海磷虾群，微小但数量庞大，是巨兽的主食。",
            "深海世界"),
        new FoodDef("鱿鱼须", "🦑", "新鲜的大王乌贼触手，Q弹有嚼劲。",
            "深海世界"),
        new FoodDef("海藻", "🌿", "深海热泉旁生长的营养海藻，矿物质丰富。",
            "深海世界")
    );

    // ==================== 物种食物偏好 ====================

    /**
     * 食物偏好记录: speciesName → (favoriteFoodName, dislikedFoodName)
     * 不在列表中的食物均为"普通"
     */
    private static final Map<String, String[]> SPECIES_PREFS = new HashMap<>();
    static {
        // ── 东亚森林 ──
        put("小熊猫", "竹笋", "冻鱼");
        put("丹顶鹤", "河鱼", "桉树叶");
        put("金丝猴", "蜂蜜", "磷虾");

        // ── 亚马孙雨林 ──
        put("巨嘴鸟", "野蕉", "肉干");
        put("树懒", "坚果", "海豹肉干");
        put("美洲豹", "肉干", "竹笋");

        // ── 非洲稀树草原 ──
        put("细纹斑马", "金合欢叶", "冻鱼");
        put("网纹长颈鹿", "野瓜", "桉树叶");
        put("非洲狮", "肉干", "竹笋");

        // ── 澳大利亚内陆 ──
        put("考拉", "桉树叶", "河鱼");
        put("鸭嘴兽", "幼虫", "蜂蜜");
        put("红袋鼠", "草籽", "磷虾");

        // ── 北极冰原 ──
        put("雪鸮", "鸟蛋", "野蕉");
        put("北极狐", "冻鱼", "金合欢叶");
        put("北极熊", "海豹肉干", "昆虫串");

        // ── 深海世界 ──
        put("蠵龟", "海藻", "肉干");
        put("大王乌贼", "鱿鱼须", "蜂蜜");
        put("蓝鲸", "磷虾", "野瓜");

        // ── 初始宠物 ──
        put("小猫", "河鱼", "桉树叶");
        put("小狗", "肉干", "竹笋");
        put("兔子", "胡萝卜", "冻鱼");
        put("狐狸", "蜂蜜", "海藻");
        put("海豚", "磷虾", "金合欢叶");
        put("棕熊", "蜂蜜", "鱿鱼须");
    }

    private static void put(String species, String fav, String dislike) {
        SPECIES_PREFS.put(species, new String[]{fav, dislike});
    }

    /** 获取某物种的偏好食物名（喜欢/厌恶），不在表中则都为null */
    public static String getFavoriteFood(String speciesName) {
        String[] p = SPECIES_PREFS.get(speciesName);
        return p != null ? p[0] : null;
    }

    public static String getDislikedFood(String speciesName) {
        String[] p = SPECIES_PREFS.get(speciesName);
        return p != null ? p[1] : null;
    }

    /** 判断某食物对某物种的偏好类型 */
    public static String checkPreference(String speciesName, String foodName) {
        String fav = getFavoriteFood(speciesName);
        if (fav != null && fav.equals(foodName)) return "like";
        String dis = getDislikedFood(speciesName);
        if (dis != null && dis.equals(foodName)) return "dislike";
        return "neutral";
    }

    // ==================== 区域 → 食物 ====================

    /** 获取某区域可获得的食物列表 */
    public static List<FoodDef> getFoodsByRegion(String regionName) {
        List<FoodDef> result = new ArrayList<>();
        for (FoodDef f : ALL) {
            if (f.regions.contains(regionName)) {
                result.add(f);
            }
        }
        return result;
    }

    /** 按名称查找食物 */
    public static FoodDef getByName(String name) {
        return ALL.stream().filter(f -> f.name.equals(name)).findFirst().orElse(null);
    }

    /** 按名称查找食物emoji */
    public static String getEmoji(String name) {
        FoodDef f = getByName(name);
        return f != null ? f.emoji : "🍖";
    }
}
