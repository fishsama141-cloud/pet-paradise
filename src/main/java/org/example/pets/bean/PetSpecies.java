package org.example.pets.bean;

import java.util.*;

/**
 * 真实世界动物物种定义 — 6大区域，自由解锁，难度递增。
 * 初始区域由问卷决定，后续区域可自由选择解锁顺序。
 */
public class PetSpecies {
    private final String id;
    private final String name;
    private final String emoji;
    private final String regionId;
    private final String regionName;
    private final String realLocation;
    private final String habitat;
    private final String diet;
    private final String funFact;
    private final String climate;
    private final int requiredLevel;
    private final String description;
    private final double encounterRate;
    private final String rarity;
    private final boolean isKeySpecies;

    private final int[] strengthRange, agilityRange, intelligenceRange, charmRange, defenseRange;

    public PetSpecies(String id, String name, String emoji, String regionId, String regionName,
                      String realLocation, String habitat, String diet, String funFact, String climate,
                      int requiredLevel, String description, double encounterRate,
                      String rarity, boolean isKeySpecies,
                      int[] str, int[] agi, int[] intl, int[] cha, int[] def) {
        this.id = id; this.name = name; this.emoji = emoji;
        this.regionId = regionId; this.regionName = regionName;
        this.realLocation = realLocation; this.habitat = habitat; this.diet = diet;
        this.funFact = funFact; this.climate = climate;
        this.requiredLevel = requiredLevel; this.description = description;
        this.encounterRate = encounterRate; this.rarity = rarity; this.isKeySpecies = isKeySpecies;
        this.strengthRange = str; this.agilityRange = agi;
        this.intelligenceRange = intl; this.charmRange = cha; this.defenseRange = def;
    }

    public int[] rollStats() {
        Random r = new Random();
        return new int[]{
            r(strengthRange, r),
            r(agilityRange, r),
            r.nextInt(3),
        };
    }

    private int r(int[] range, Random r) { return range[0] + r.nextInt(range[1] - range[0] + 1); }

    public Pet createPet(String name) {
        Pet pet = new Pet(name, this.name, emoji, regionName, description);
        int[] rolled = rollStats();
        pet.setAffinity(Math.min(100, rolled[0]));
        pet.setBond(Math.min(100, rolled[1]));
        String[] personalities = {"活泼", "胆小", "温顺"};
        pet.setPersonality(personalities[rolled[2]]);
        pet.setRarity(rarity);
        return pet;
    }

    // --- Getters ---
    public String getId() { return id; }
    public String getName() { return name; }
    public String getEmoji() { return emoji; }
    public String getRegionId() { return regionId; }
    public String getRegionName() { return regionName; }
    public String getRealLocation() { return realLocation; }
    public String getHabitat() { return habitat; }
    public String getDiet() { return diet; }
    public String getFunFact() { return funFact; }
    public String getClimate() { return climate; }
    public int getRequiredLevel() { return requiredLevel; }
    public String getDescription() { return description; }
    public double getEncounterRate() { return encounterRate; }
    public String getRarity() { return rarity; }
    public boolean isKeySpecies() { return isKeySpecies; }
    public int[] getStrengthRange() { return strengthRange; }
    public int[] getAgilityRange() { return agilityRange; }
    public int[] getIntelligenceRange() { return intelligenceRange; }
    public int[] getCharmRange() { return charmRange; }
    public int[] getDefenseRange() { return defenseRange; }

    public String getRequiredLevelDisplay() { return requiredLevel > 0 ? "Lv." + requiredLevel + "+" : "初始"; }
    public String getRarityLabel() {
        return switch (rarity) {
            case "common" -> "⭐ 常见";
            case "uncommon" -> "⭐⭐ 稀有";
            case "rare" -> "🌟🌟🌟 极稀有";
            default -> "⭐";
        };
    }
    public String getStatRangeText() {
        return String.format("❤️亲密度潜力 %d-%d · 🤝默契潜力 %d-%d",
            strengthRange[0], strengthRange[1], agilityRange[0], agilityRange[1]);
    }

    // ==================== 6大区域定义 ====================

    private static int[] s(int min, int max) { return new int[]{min, max}; }

    public record RegionDef(String id, String name, String emoji, String realLocation,
                            String climate, String desc, String color,
                            int topPct, int leftPct) {}

    public static List<RegionDef> REGIONS = List.of(
        new RegionDef("east_asia",  "东亚森林", "🏯", "中国·四川/云南", "温带·亚热带",
            "东亚温带森林与竹林，生物多样性极为丰富。", "#4CAF50", 40, 72),
        new RegionDef("amazon",    "亚马孙雨林", "🌴", "巴西·亚马孙盆地", "热带雨林",
            "地球之肺，拥有全世界最丰富的物种。", "#2E7D32", 58, 28),
        new RegionDef("africa",    "非洲稀树草原", "🦁", "肯尼亚·塞伦盖蒂", "热带草原",
            "广袤的金色草原，大迁徙的舞台。", "#F57C00", 50, 52),
        new RegionDef("australia", "澳大利亚内陆", "🦘", "澳大利亚·昆士兰", "干旱·半干旱",
            "独特的大陆生态，众多特有物种的家园。", "#FF9800", 72, 78),
        new RegionDef("arctic",    "北极冰原", "🧊", "挪威·斯瓦尔巴群岛", "极地冰原",
            "冰雪覆盖的极北之地，生命在这里顽强绽放。", "#90CAF9", 12, 48),
        new RegionDef("deep_ocean","深海世界", "🌊", "太平洋·马里亚纳海沟", "深海",
            "地球上最后的未知领域，神秘而壮丽。", "#1565C0", 65, 10)
    );

    // ==================== 全部18种真实动物 + 6种初始宠物 ====================

    public static List<PetSpecies> ALL = List.of(
        // ── 东亚森林 ──
        new PetSpecies("east_asia_red_panda", "小熊猫", "🐼", "east_asia", "东亚森林",
            "中国四川·海拔2500-4800m竹林", "竹林·针阔混交林", "竹子为主(95%)，偶食浆果",
            "小熊猫不是熊猫的宝宝！它自成一科，和大熊猫、浣熊都没有直接亲缘关系。",
            "温带湿润", 1,
            "身材圆润的小熊猫，拖着一条蓬松的环纹尾巴。它们大部分时间都在树上悠闲地啃竹子。",
            0.22, "common", false,
            s(4,10), s(10,18), s(8,14), s(18,28), s(6,12)),

        new PetSpecies("east_asia_crane", "丹顶鹤", "🕊️", "east_asia", "东亚森林",
            "中国东北·扎龙湿地", "湿地·芦苇沼泽", "鱼虾、水生植物",
            "丹顶鹤是世界上最稀有的鹤类之一，在中国文化中象征长寿，寿命可达60年以上。",
            "温带湿润", 1,
            "优雅的丹顶鹤，头顶一抹朱红，修长的双腿在浅水中踱步，宛如仙鸟下凡。",
            0.16, "uncommon", false,
            s(6,12), s(14,22), s(12,18), s(14,24), s(4,10)),

        new PetSpecies("east_asia_golden_monkey", "金丝猴", "🐒", "east_asia", "东亚森林",
            "中国云南·海拔3000-4500m", "高山针叶林·竹丛", "松萝、竹笋、野果",
            "金丝猴是除人类外唯一能在海拔4000米以上生活的灵长类动物，金色的毛发是天然防寒服。",
            "高山·寒冷", 3,
            "毛发如金丝般灿烂的金丝猴，在雪山森林中跳跃穿行。",
            0.10, "rare", false,
            s(8,16), s(16,26), s(14,24), s(16,28), s(8,16)),

        // ── 亚马孙雨林 ──
        new PetSpecies("amazon_toucan", "巨嘴鸟", "🦜", "amazon", "亚马孙雨林",
            "巴西·亚马孙热带雨林", "热带雨林树冠层", "水果、昆虫、小型蜥蜴",
            "巨嘴鸟的喙虽然很大但非常轻(中空结构)，而且喙里有血管可以帮助散热，是天然空调。",
            "热带·高温多雨", 5,
            "色彩艳丽的大嘴鸟，它的巨喙是亚马孙雨林中最抢眼的标志。",
            0.20, "common", false,
            s(6,12), s(14,20), s(10,16), s(16,24), s(4,10)),

        new PetSpecies("amazon_sloth", "树懒", "🦥", "amazon", "亚马孙雨林",
            "巴西·哥斯达黎加雨林", "热带雨林树冠层", "树叶(几乎只吃伞树科)",
            "树懒的代谢速度是哺乳动物中最慢的，一周才下树排便一次。身上的藻类让它们看起来发绿。",
            "热带·高温多雨", 6,
            "慢悠悠的树懒挂在树枝上，用最佛系的方式享受着雨林生活。",
            0.14, "uncommon", false,
            s(4,8), s(2,6), s(4,10), s(20,30), s(14,22)),

        new PetSpecies("amazon_jaguar", "美洲豹", "🐆", "amazon", "亚马孙雨林",
            "巴西·潘塔纳尔湿地", "热带雨林·河岸密林", "水豚、凯门鳄、鹿",
            "美洲豹是美洲最大的猫科动物，咬合力是狮子的1.5倍，能直接咬穿龟壳或头骨。",
            "热带·高温多雨", 8,
            "丛林之王美洲豹，金底黑斑的华丽皮毛下藏着惊人的力量。",
            0.09, "rare", false,
            s(20,30), s(14,22), s(12,18), s(14,20), s(10,18)),

        // ── 非洲稀树草原 ──
        new PetSpecies("africa_zebra", "细纹斑马", "🦓", "africa", "非洲稀树草原",
            "肯尼亚·马赛马拉", "热带稀树草原", "草类、树叶",
            "每只斑马的条纹都是独一无二的，就像人类的指纹。斑马的条纹可以迷惑采采蝇的视觉。",
            "热带·干湿季交替", 10,
            "黑白条纹的细纹斑马在金色草原上奔驰，条纹在阳光下闪耀如流动的光影。",
            0.18, "common", false,
            s(14,22), s(16,24), s(8,14), s(10,18), s(8,14)),

        new PetSpecies("africa_giraffe", "网纹长颈鹿", "🦒", "africa", "非洲稀树草原",
            "坦桑尼亚·塞伦盖蒂", "稀树草原·金合欢林地", "金合欢树叶、嫩枝",
            "长颈鹿每天只睡2小时(5分钟一段)，血压是人类的两倍，心脏重达11公斤。",
            "热带·干湿季交替", 12,
            "优雅的网纹长颈鹿，修长的脖子能够到最高的金合欢树冠，是草原上的瞭望塔。",
            0.12, "uncommon", false,
            s(12,18), s(10,16), s(10,16), s(16,26), s(12,20)),

        new PetSpecies("africa_lion", "非洲狮", "🦁", "africa", "非洲稀树草原",
            "肯尼亚·马赛马拉保护区", "热带稀树草原", "角马、斑马、羚羊",
            "一个狮群通常由1-2头雄狮和6-8头母狮组成。雄狮的鬃毛越黑越浓密代表越健康。",
            "热带·干湿季交替", 15,
            "草原之王非洲狮，金色的鬃毛在风中飘扬，象征着力量与勇气。",
            0.08, "rare", false,
            s(22,32), s(12,20), s(10,16), s(14,20), s(10,18)),

        // ── 澳大利亚内陆 ──
        new PetSpecies("australia_koala", "考拉", "🐨", "australia", "澳大利亚内陆",
            "澳大利亚·昆士兰", "桉树林", "桉树叶(仅吃少数几种)",
            "考拉每天睡18-22小时，不是因为懒而是因为桉树叶热量极低且有毒，需要大量睡眠来解毒。",
            "亚热带·半干旱", 16,
            "憨态可掬的考拉抱着树干打瞌睡的样子，让人忍不住想摸摸它的脑袋。",
            0.16, "common", false,
            s(4,10), s(4,8), s(6,12), s(22,32), s(8,14)),

        new PetSpecies("australia_platypus", "鸭嘴兽", "🦆", "australia", "澳大利亚内陆",
            "澳大利亚东部·淡水溪流", "淡水溪流·河岸洞穴", "水生无脊椎动物",
            "鸭嘴兽是哺乳动物中唯一有毒刺的(雄性后腿)，而且它用喙的电磁感应探测猎物。",
            "亚热带·半干旱", 18,
            "奇特的鸭嘴兽仿佛是造物主打瞌睡时的作品——鸭子嘴+水獭身+海狸尾。",
            0.11, "uncommon", false,
            s(6,12), s(12,18), s(16,24), s(8,16), s(10,18)),

        new PetSpecies("australia_kangaroo", "红袋鼠", "🦘", "australia", "澳大利亚内陆",
            "澳大利亚内陆·沙漠草原", "半干旱草原·灌木丛", "草类、灌木叶",
            "红袋鼠是现存最大的有袋动物，一次跳跃可达9米远、3米高，尾巴是它的平衡杆。",
            "半干旱·内陆", 20,
            "澳大利亚的象征——红袋鼠，强健的后腿能让它在荒漠中如风般跳跃。",
            0.07, "rare", false,
            s(18,28), s(20,30), s(6,12), s(8,14), s(10,18)),

        // ── 北极冰原 ──
        new PetSpecies("arctic_snowy_owl", "雪鸮", "🦉", "arctic", "北极冰原",
            "挪威·斯瓦尔巴群岛", "北极冻原·岩壁", "旅鼠、雪兔、雷鸟",
            "雪鸮是哈利波特的信使海德薇的原型。它们的羽毛覆盖到脚趾，像穿了雪地靴。",
            "极地·冰原", 22,
            "纯白的雪鸮静立在冰雪之中，金黄色的眼睛扫描着无边冻原上的每一个动静。",
            0.14, "common", false,
            s(6,12), s(16,24), s(14,22), s(12,20), s(8,14)),

        new PetSpecies("arctic_fox", "北极狐", "🦊", "arctic", "北极冰原",
            "冰岛·格陵兰", "极地冻原", "旅鼠、海鸟蛋、浆果",
            "北极狐的皮毛随季节变色——夏天灰褐色，冬天雪白。它的脚底有厚毛，是天然雪地靴。",
            "极地·冰原", 24,
            "灵动的北极狐在雪地中穿梭，一身雪白的皮毛完美融入冰原的纯白世界。",
            0.10, "uncommon", false,
            s(6,12), s(16,24), s(16,24), s(14,22), s(6,12)),

        new PetSpecies("arctic_polar_bear", "北极熊", "🐻‍❄️", "arctic", "北极冰原",
            "挪威·斯瓦尔巴群岛", "北极海冰·海岸", "海豹(主要为环斑海豹)",
            "北极熊的皮肤其实是黑色的！白色毛发是透明的中空管，用来传导阳光到黑色皮肤上吸热。",
            "极地·冰原", 26,
            "冰原霸主北极熊，在浮冰间漫步的雪白巨兽。",
            0.07, "rare", false,
            s(24,34), s(6,12), s(8,14), s(6,12), s(20,30)),

        // ── 深海世界 ──
        new PetSpecies("ocean_turtle", "蠵龟", "🐢", "deep_ocean", "深海世界",
            "太平洋·大堡礁海域", "珊瑚礁·远洋", "水母、海藻、甲壳类",
            "海龟能感知地球磁场，跨越数千公里回到它们出生的海滩产卵，这是自然界的GPS。",
            "热带海洋·深海", 28,
            "远古的航海者蠵龟，背上驮着岁月的纹路，在蓝色深海中优雅滑翔。",
            0.12, "common", false,
            s(8,14), s(6,12), s(8,14), s(12,20), s(24,34)),

        new PetSpecies("ocean_squid", "大王乌贼", "🦑", "deep_ocean", "深海世界",
            "太平洋·马里亚纳海沟附近", "深海(300-1000m)", "深海鱼类、同类互食",
            "大王乌贼的眼睛直径可达30cm，是动物界最大的眼睛，用来在漆黑的深海捕捉微弱的生物荧光。",
            "深海·高压", 30,
            "深海的神秘使者大王乌贼，巨大的触手在黑暗中发着幽蓝色的生物荧光。",
            0.09, "uncommon", false,
            s(14,22), s(12,20), s(14,24), s(6,10), s(14,22)),

        new PetSpecies("ocean_whale", "蓝鲸", "🐋", "deep_ocean", "深海世界",
            "太平洋·南极海域", "远洋·深海", "磷虾(每天4吨)",
            "蓝鲸是地球上有史以来最大的动物，舌头和大象一样重，心脏和小汽车一样大，叫声可达188分贝。",
            "极地·深海", 32,
            "地球最后的巨兽——蓝鲸，在深海唱响悠远的鲸歌。",
            0.06, "rare", false,
            s(28,38), s(4,10), s(14,22), s(10,16), s(22,32)),

        // ── 初始宠物（分布在各自对应的区域）──
        new PetSpecies("starter_cat", "小猫", "🐱", "east_asia", "东亚森林",
            "东亚·村庄与森林交界", "森林边缘·田野", "小鱼干、老鼠、鸟",
            "猫的胡须宽度和身体一样宽，用来判断能否穿过狭窄空间。",
            "温带", 1,
            "一只机敏独立的小猫，喜欢在森林边缘的阳光下打盹，是新手训练师的好伙伴。",
            0.20, "common", false,
            s(4,10), s(14,22), s(10,16), s(16,26), s(4,10)),

        new PetSpecies("starter_dog", "小狗", "🐶", "africa", "非洲稀树草原",
            "东非·草原与村庄交界", "草地·灌木丛", "肉干、骨头、杂食",
            "狗的嗅觉比人类灵敏1000倍以上，能闻到200米外的一滴血。",
            "热带草原", 1,
            "一只忠诚活泼的小狗，在金色草原上奔跑嬉戏，总是摇着尾巴等待冒险。",
            0.20, "common", false,
            s(8,16), s(16,24), s(6,12), s(14,22), s(6,12)),

        new PetSpecies("starter_rabbit", "兔子", "🐰", "africa", "非洲稀树草原",
            "东非·草原与灌木丛", "草地·田野", "胡萝卜、草叶、蔬菜",
            "兔子的视野几乎是360度的，唯一看不到的是正前方鼻子下面。",
            "热带草原", 1,
            "一只活泼可爱的兔子，在金色草原上蹦蹦跳跳让周围的空气都变得轻快起来。",
            0.20, "common", false,
            s(4,8), s(18,28), s(6,12), s(20,30), s(4,8)),

        new PetSpecies("starter_fox", "狐狸", "🦊", "east_asia", "东亚森林",
            "东亚·山林与丘陵", "森林·山地", "蜂蜜、野鼠、浆果",
            "狐狸是犬科动物中最像猫的——它们捕猎时像猫一样伏击跳跃。",
            "温带", 1,
            "一只聪慧灵动的赤狐，琥珀色的眼睛里闪烁着智慧的光芒。",
            0.16, "uncommon", false,
            s(6,14), s(12,20), s(14,24), s(10,18), s(6,12)),

        new PetSpecies("starter_dolphin", "海豚", "🐬", "deep_ocean", "深海世界",
            "热带·沿海与河口", "近海·河口湾", "磷虾、小鱼、乌贼",
            "海豚睡觉时只关一半大脑，另一半保持清醒来呼吸和警惕危险。",
            "温带·海洋性", 1,
            "一头友善聪明的宽吻海豚，在蔚蓝的深海中优雅游弋，等待与你相遇。",
            0.14, "uncommon", false,
            s(8,18), s(14,22), s(16,26), s(14,24), s(8,14)),

        new PetSpecies("starter_bear", "棕熊", "🐻", "arctic", "北极冰原",
            "北极圈·高山森林", "山地森林·溪谷", "蜂蜜、鱼、浆果",
            "棕熊虽然体型庞大，但刚出生的熊宝宝只有小松鼠那么大。",
            "极地·高山", 2,
            "一头毛茸茸的棕熊幼崽，憨厚可靠的力量型伙伴，在冰原上留下可爱的脚印。",
            0.14, "uncommon", false,
            s(16,26), s(4,10), s(4,10), s(10,18), s(14,22)),

        new PetSpecies("starter_macaw", "金刚鹦鹉", "🦜", "amazon", "亚马孙雨林",
            "巴西·亚马孙雨林", "热带雨林树冠层", "坚果、水果、种子",
            "金刚鹦鹉是世界上最大的鹦鹉之一，寿命可达80年，智商相当于3-4岁儿童。",
            "热带·高温多雨", 1,
            "一只羽色绚丽的蓝黄金刚鹦鹉，是亚马孙雨林中最耀眼夺目的精灵。",
            0.18, "common", false,
            s(4,10), s(12,20), s(14,24), s(16,26), s(4,10)),

        new PetSpecies("starter_lizard", "伞蜥", "🦎", "australia", "澳大利亚内陆",
            "澳大利亚北部·热带草原", "桉树林·岩石地带", "昆虫、蜘蛛、小型无脊椎动物",
            "伞蜥受惊时会展开颈部巨大的皮褶，看起来像一把打开的伞，是非常戏剧性的防御姿态。",
            "热带·半干旱", 1,
            "一只酷炫的伞蜥，遇到危险时会展开华丽的颈伞，是澳大利亚最有个性的爬行动物。",
            0.16, "uncommon", false,
            s(6,12), s(14,22), s(10,18), s(14,22), s(8,16))
    );

    // ==================== 新解锁系统 ====================

    /**
     * 计算解锁第N个新区域所需条件（N = 已解锁数量，含初始）
     * 返回 [所需宠物总数, 所需达到等级的宠物数, 所需等级]
     * 解锁第1个新区域：1只宠物即可
     * 解锁第2个新区域：2只宠物，1只≥Lv.3
     * 解锁第3个新区域：3只宠物，2只≥Lv.5
     * 解锁第4个新区域：4只宠物，2只≥Lv.8
     * 解锁第5个新区域：5只宠物，3只≥Lv.10
     */
    public static int[] getUnlockRequirements(int currentUnlockedCount) {
        int n = currentUnlockedCount; // 已解锁数量（含初始）
        if (n <= 0) return new int[]{1, 0, 0};  // 初始区域无条件
        if (n == 1) return new int[]{1, 0, 0};  // 第1个新区域：1只宠物即可
        if (n == 2) return new int[]{2, 1, 3};  // 2只宠物，1只≥Lv.3
        if (n == 3) return new int[]{3, 2, 5};  // 3只宠物，2只≥Lv.5
        if (n == 4) return new int[]{4, 2, 8};  // 4只宠物，2只≥Lv.8
        return new int[]{5, 3, 10};              // 5只宠物，3只≥Lv.10
    }

    /** 检查用户是否可以解锁更多区域 */
    public static boolean canUnlockNewRegion(List<Pet> userPets, int currentUnlockedCount) {
        int[] req = getUnlockRequirements(currentUnlockedCount);
        if (req[1] == 0) {
            // 只需宠物总数
            return userPets.size() >= req[0];
        }
        long atLevel = userPets.stream().filter(p -> p.getLevel() >= req[2]).count();
        return userPets.size() >= req[0] && atLevel >= req[1];
    }

    /** 获取解锁条件描述 */
    public static String getUnlockRequirementsText(int currentUnlockedCount) {
        int[] req = getUnlockRequirements(currentUnlockedCount);
        if (currentUnlockedCount == 0) return "初始区域，无需条件";
        if (req[1] == 0) return String.format("需要 %d 只宠物", req[0]);
        return String.format("需要 %d 只宠物（其中 %d 只达到 Lv.%d+）", req[0], req[1], req[2]);
    }

    /** 检查某区域是否已解锁（通过数据库记录的用户已解锁区域列表） */
    public static boolean isRegionUnlocked(Set<String> unlockedRegionIds, String regionId) {
        return unlockedRegionIds.contains(regionId);
    }

    // ==================== 工具方法 ====================

    public static PetSpecies getById(String id) {
        return ALL.stream().filter(s -> s.id.equals(id)).findFirst().orElse(null);
    }

    public static List<PetSpecies> getByRegion(String regionId, int playerMaxLevel) {
        List<PetSpecies> result = new ArrayList<>();
        for (PetSpecies sp : ALL) {
            if (sp.regionId.equals(regionId) && playerMaxLevel >= sp.requiredLevel) {
                result.add(sp);
            }
        }
        return result;
    }

    public static List<PetSpecies> getByRegion(String regionId) {
        return getByRegion(regionId, 999);
    }

    /** 根据区域ID查找区域定义 */
    public static RegionDef getRegionById(String regionId) {
        for (RegionDef rd : REGIONS) {
            if (rd.id().equals(regionId)) return rd;
        }
        return null;
    }

    /** 获取用户在指定区域已收集的物种名集合 */
    public static Set<String> getCollectedSpeciesInRegion(List<Pet> userPets, String regionId) {
        Set<String> collected = new HashSet<>();
        for (Pet p : userPets) {
            for (PetSpecies sp : ALL) {
                if (sp.getName().equals(p.getSpecies()) && sp.getRegionId().equals(regionId)) {
                    collected.add(sp.getName());
                }
            }
        }
        return collected;
    }

    /** 根据问卷环境映射到区域ID */
    public static String getRegionIdForEnv(String env) {
        return switch (env != null ? env : "forest") {
            case "forest" -> "east_asia";
            case "rainforest" -> "amazon";
            case "grassland" -> "africa";
            case "outback" -> "australia";
            case "ocean" -> "deep_ocean";
            case "arctic" -> "arctic";
            default -> "east_asia";
        };
    }

    /** 根据问卷环境获取该区域的初始宠物物种ID列表 */
    public static List<String> getStarterSpeciesIdsForEnv(String env) {
        String regionId = getRegionIdForEnv(env);
        return ALL.stream()
            .filter(sp -> sp.getRegionId().equals(regionId) && sp.getId().startsWith("starter_"))
            .map(PetSpecies::getId)
            .toList();
    }

    /** 根据问卷环境获取该区域所有物种（含starter和非starter）作为初始可选 */
    public static List<PetSpecies> getStarterOptionsForEnv(String env) {
        String regionId = getRegionIdForEnv(env);
        return ALL.stream()
            .filter(sp -> sp.getRegionId().equals(regionId) && sp.getRequiredLevel() <= 3)
            .toList();
    }
}
