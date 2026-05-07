<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    Set<String> collectedSpecies = (Set<String>) request.getAttribute("collectedSpecies");
    Set<String> ownedFoods = (Set<String>) request.getAttribute("ownedFoods");
    Map<String, List<PetSpecies>> regionSpecies = (Map<String, List<PetSpecies>>) request.getAttribute("regionSpecies");
    Map<String, List<FoodDef>> regionFoods = (Map<String, List<FoodDef>>) request.getAttribute("regionFoods");
    List<PetSpecies.RegionDef> allRegions = (List<PetSpecies.RegionDef>) request.getAttribute("allRegions");
    if (collectedSpecies == null) collectedSpecies = Set.of();
    if (ownedFoods == null) ownedFoods = Set.of();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>&#x1F4D6; 图鉴 - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #f5f0e8 0%, #ede4d5 30%, #e8dcc8 100%);
            min-height: 100vh; color: #4a3728;
        }
        .nav {
            background: linear-gradient(135deg, #6b4c32, #5a3a20);
            padding: 14px 24px; display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 4px 20px rgba(90,60,30,0.3);
        }
        .nav .brand { font-size: 20px; font-weight: 700; color: #f0d9a0; text-decoration: none; }
        .nav-links { display: flex; gap: 8px; align-items: center; }
        .nav-links a {
            color: #e0d5c1; text-decoration: none; padding: 7px 14px; border-radius: 16px;
            font-weight: 600; font-size: 13px; border: 1px solid rgba(255,255,255,0.15);
            transition: all 0.3s;
        }
        .nav-links a:hover { background: rgba(255,255,255,0.12); }
        .nav-links a.active { background: rgba(255,255,255,0.2); color: #f0c27a; }

        .main { max-width: 920px; margin: 0 auto; padding: 24px 20px; }

        /* Header */
        .page-header { text-align: center; margin-bottom: 24px; }
        .page-header h1 { font-size: 28px; color: #4a3520; }
        .page-header .sub { font-size: 14px; color: #8a7a6a; margin-top: 4px; }

        /* Region tabs */
        .region-tabs {
            display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px;
            justify-content: center; position: sticky; top: 0; z-index: 10;
            background: rgba(245,240,232,0.95); padding: 10px 0; backdrop-filter: blur(6px);
        }
        .region-tab {
            padding: 10px 18px; border: 2px solid #c4b5a0; border-radius: 24px;
            cursor: pointer; font-size: 14px; font-weight: 600; transition: all 0.3s;
            background: white; color: #6b5a48; font-family: inherit;
        }
        .region-tab:hover { border-color: #8a6a4a; background: #f8f0e0; }
        .region-tab.active {
            background: #5a3a20; color: #f0d9a0; border-color: #5a3a20;
        }
        .region-tab .count {
            font-size: 11px; font-weight: 400; margin-left: 4px; opacity: 0.7;
        }

        /* Section title */
        .section-title {
            font-size: 20px; font-weight: 700; color: #4a3520;
            margin-bottom: 14px; padding-bottom: 8px;
            border-bottom: 2px solid #d4c5a0;
            display: flex; align-items: center; gap: 8px;
        }
        .section-title .icon { font-size: 24px; }

        /* Species grid */
        .species-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 14px; margin-bottom: 30px;
        }
        .species-card {
            background: white; border-radius: 16px; padding: 16px;
            box-shadow: 0 3px 12px rgba(0,0,0,0.06); transition: all 0.3s;
            border: 2px solid #e8dcc8; position: relative; overflow: hidden;
        }
        .species-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.1); }
        .species-card.collected { border-color: #66BB6A; }
        .species-card.collected::after {
            content: '\2714'; position: absolute; top: 10px; right: 14px;
            font-size: 18px; color: #43A047; background: #E8F5E9;
            width: 30px; height: 30px; border-radius: 50%; display: flex;
            align-items: center; justify-content: center;
        }
        .species-card.not-collected { opacity: 0.7; }
        .species-card .sc-top { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; }
        .species-card .sc-emoji { font-size: 42px; }
        .species-card .sc-name { font-size: 18px; font-weight: 700; color: #4a3520; }
        .species-card .sc-rarity { font-size: 11px; color: #8a6a4a; }
        .species-card .sc-info { font-size: 12px; color: #6b5a48; line-height: 1.6; }
        .species-card .sc-info span { display: block; margin-bottom: 2px; }
        .species-card .sc-tags { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 8px; }
        .sc-tag {
            font-size: 11px; padding: 3px 10px; border-radius: 10px;
            font-weight: 600; white-space: nowrap;
        }
        .sc-tag-archetype { background: #f5e6d0; color: #8a6a3a; }
        .sc-tag-trait { background: #d4e8c0; color: #4a6a2a; }
        .sc-tag-starter { background: #e0d4f0; color: #5a3a7a; }
        .sc-capture { font-size: 11px; margin-top: 8px; padding: 8px; background: #faf6ee; border-radius: 8px; color: #6b5a48; line-height: 1.5; }

        /* Food grid */
        .food-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 10px; margin-bottom: 30px;
        }
        .food-card {
            background: white; border-radius: 14px; padding: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05); transition: all 0.3s;
            border: 1px solid #e8dcc8; display: flex; gap: 12px; align-items: center;
        }
        .food-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.1); }
        .food-card.owned { border-color: #66BB6A; background: #f8fdf5; }
        .food-card .fc-emoji { font-size: 36px; flex-shrink: 0; }
        .food-card .fc-info { flex: 1; min-width: 0; }
        .food-card .fc-name { font-size: 15px; font-weight: 700; color: #4a3520; }
        .food-card .fc-desc { font-size: 12px; color: #8a7a6a; margin-top: 2px; }
        .food-card .fc-regions { font-size: 11px; color: #a09080; margin-top: 2px; }

        .empty-hint { text-align: center; padding: 40px; color: #a09080; font-size: 15px; }

        @media (max-width: 600px) {
            .species-grid { grid-template-columns: 1fr; }
            .food-grid { grid-template-columns: 1fr; }
            .region-tab { padding: 8px 12px; font-size: 12px; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">&#x1F4D6; 宠物乐园</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard">&#x1F3E0; 我的宠物</a>
            <a href="<%= request.getContextPath() %>/map">&#x1F5FA; 世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia" class="active">&#x1F4D6; 图鉴</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">&#x1F6AA; 退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="page-header">
            <h1>&#x1F4D6; 宠物图鉴</h1>
            <div class="sub">已收集 <%= collectedSpecies.size() %> / <%= PetSpecies.ALL.size() %> 种动物</div>
        </div>

        <!-- Region tabs -->
        <div class="region-tabs">
            <button class="region-tab active" onclick="showRegion('all')">
                &#x1F30D; 全部<span class="count"><%= collectedSpecies.size() %>/<%= PetSpecies.ALL.size() %></span>
            </button>
            <% for (PetSpecies.RegionDef rd : allRegions) {
                int total = 0, have = 0;
                List<PetSpecies> sps = regionSpecies.get(rd.id());
                if (sps != null) {
                    total = sps.size();
                    for (PetSpecies sp : sps) {
                        if (collectedSpecies.contains(sp.getName())) have++;
                    }
                }
            %>
            <button class="region-tab" onclick="showRegion('<%= rd.id() %>')">
                <%= rd.emoji() %> <%= rd.name() %><span class="count"><%= have %>/<%= total %></span>
            </button>
            <% } %>
        </div>

        <!-- Content by region -->
        <% for (PetSpecies.RegionDef rd : allRegions) { %>
        <div class="region-content" id="region-<%= rd.id() %>">
            <div class="section-title">
                <span class="icon"><%= rd.emoji() %></span> <%= rd.name() %>
            </div>

            <!-- Species cards -->
            <div class="species-grid">
                <%
                    List<PetSpecies> spList = regionSpecies.get(rd.id());
                    if (spList != null) {
                        for (PetSpecies sp : spList) {
                            boolean collected = collectedSpecies.contains(sp.getName());
                            CompanionTrait ct = CompanionTrait.forSpecies(sp.getId());
                            WildEncounter.Archetype arch = null;
                            String archLabel = "";
                            String id = sp.getId();
                            if (id.contains("fox") || id.contains("crane") || id.contains("owl") || id.contains("rabbit")) {
                                arch = WildEncounter.Archetype.CAUTIOUS; archLabel = "&#x1F440; 谨慎型";
                            } else if (id.contains("monkey") || id.contains("toucan") || id.contains("macaw") || id.contains("dolphin")) {
                                arch = WildEncounter.Archetype.CURIOUS; archLabel = "&#x1F50D; 好奇型";
                            } else if (id.contains("jaguar") || id.contains("lion") || id.contains("bear") || id.contains("kangaroo")) {
                                arch = WildEncounter.Archetype.BOLD; archLabel = "&#x1F4AA; 大胆型";
                            } else if (id.contains("sloth") || id.contains("koala") || id.contains("turtle") || id.contains("giraffe")) {
                                arch = WildEncounter.Archetype.GENTLE; archLabel = "&#x1F33F; 温柔型";
                            } else if (id.contains("dog") || id.contains("cat") || id.contains("zebra") || id.contains("platypus")) {
                                arch = WildEncounter.Archetype.PLAYFUL; archLabel = "&#x1F3BE; 活泼型";
                            } else {
                                arch = WildEncounter.Archetype.MYSTERIOUS; archLabel = "&#x2728; 神秘型";
                            }
                %>
                <div class="species-card <%= collected ? "collected" : "not-collected" %>">
                    <div class="sc-top">
                        <span class="sc-emoji"><%= sp.getEmoji() %></span>
                        <div>
                            <div class="sc-name"><%= sp.getName() %></div>
                            <div class="sc-rarity"><%= sp.getRarityLabel() %> &middot; Lv.<%= sp.getRequiredLevel() %>+</div>
                        </div>
                    </div>
                    <div class="sc-info">
                        <span>&#x1F30D; <%= sp.getRealLocation() %></span>
                        <span>&#x1F33F; <%= sp.getHabitat() %></span>
                        <span>&#x1F372; <%= sp.getDiet() %></span>
                        <span>&#x1F4A1; <%= sp.getFunFact() %></span>
                    </div>
                    <div class="sc-tags">
                        <span class="sc-tag sc-tag-archetype"><%= archLabel %></span>
                        <% if (ct != null) { %>
                        <span class="sc-tag sc-tag-trait">&#x2B50; <%= ct.getName() %> &#x2014; <%= ct.getPositioning() %></span>
                        <% } %>
                        <% if (sp.getId().startsWith("starter_")) { %>
                        <span class="sc-tag sc-tag-starter">&#x1F393; 初始宠物</span>
                        <% } %>
                    </div>
                    <div class="sc-capture">
                        &#x1F3AF; 捕捉条件：安全感&#x2265;<%= getCaptureReqForSpecies(sp.getId())[0] %>
                        兴趣&#x2265;<%= getCaptureReqForSpecies(sp.getId())[1] %>
                        压力&#x2264;<%= getCaptureReqForSpecies(sp.getId())[2] %>
                        信任&#x2265;<%= getCaptureReqForSpecies(sp.getId())[3] %>
                    </div>
                </div>
                <% } } %>
            </div>

            <!-- Food cards for this region -->
            <div class="section-title" style="font-size:17px;">
                <span class="icon">&#x1F372;</span> 该区域可获得食物
            </div>
            <div class="food-grid">
                <%
                    List<FoodDef> fList = regionFoods.get(rd.id());
                    if (fList != null) {
                        for (FoodDef fd : fList) {
                            boolean owned = ownedFoods.contains(fd.getName());
                %>
                <div class="food-card <%= owned ? "owned" : "" %>">
                    <span class="fc-emoji"><%= fd.getEmoji() %></span>
                    <div class="fc-info">
                        <div class="fc-name"><%= fd.getName() %> <%= owned ? "&#x2705;" : "" %></div>
                        <div class="fc-desc"><%= fd.getDescription() %></div>
                        <div class="fc-regions">&#x1F4CD; <%= String.join("、", fd.getRegions()) %></div>
                    </div>
                </div>
                <% } } %>
            </div>
        </div>
        <% } %>

        <!-- "All" view placeholder -->
        <div class="region-content" id="region-all" style="display:none;"></div>
    </div>

    <script>
        function showRegion(regionId) {
            document.querySelectorAll('.region-tab').forEach(function(t) { t.classList.remove('active'); });
            document.querySelectorAll('.region-content').forEach(function(c) { c.style.display = 'none'; });

            var tab = document.querySelector('.region-tab[onclick*="' + regionId + '"]');
            if (tab) tab.classList.add('active');

            if (regionId === 'all') {
                document.querySelectorAll('.region-content').forEach(function(c) { c.style.display = 'block'; });
                return;
            }
            var content = document.getElementById('region-' + regionId);
            if (content) content.style.display = 'block';
        }

        // Show all regions by default
        (function() {
            document.querySelectorAll('.region-content').forEach(function(c) { c.style.display = 'block'; });
        })();
    </script>
</body>
</html>
<%!
    int[] getCaptureReqForSpecies(String speciesId) {
        if (speciesId == null) return new int[]{55, 40, 30, 75};
        switch (speciesId) {
            case "east_asia_red_panda":    return new int[]{70, 30, 30, 75};
            case "east_asia_crane":        return new int[]{80, 25, 25, 70};
            case "east_asia_golden_monkey": return new int[]{45, 60, 25, 80};
            case "starter_cat":            return new int[]{60, 45, 30, 75};
            case "starter_fox":            return new int[]{75, 35, 20, 75};
            case "amazon_toucan":          return new int[]{35, 70, 35, 75};
            case "amazon_sloth":           return new int[]{60, 20, 35, 70};
            case "amazon_jaguar":          return new int[]{50, 45, 20, 85};
            case "starter_macaw":          return new int[]{35, 70, 25, 75};
            case "africa_zebra":           return new int[]{65, 40, 30, 75};
            case "africa_giraffe":         return new int[]{75, 30, 25, 70};
            case "africa_lion":            return new int[]{55, 35, 20, 85};
            case "starter_dog":            return new int[]{45, 65, 25, 70};
            case "starter_rabbit":         return new int[]{80, 45, 20, 80};
            case "australia_koala":        return new int[]{70, 25, 35, 75};
            case "australia_platypus":     return new int[]{50, 60, 20, 70};
            case "australia_kangaroo":     return new int[]{45, 65, 25, 80};
            case "starter_lizard":         return new int[]{55, 50, 20, 75};
            case "arctic_snowy_owl":       return new int[]{80, 30, 20, 75};
            case "arctic_fox":             return new int[]{75, 40, 25, 70};
            case "arctic_polar_bear":      return new int[]{55, 30, 20, 85};
            case "starter_bear":           return new int[]{65, 35, 30, 75};
            case "ocean_turtle":           return new int[]{70, 25, 30, 80};
            case "ocean_squid":            return new int[]{40, 55, 30, 75};
            case "ocean_whale":            return new int[]{55, 30, 25, 85};
            case "starter_dolphin":        return new int[]{50, 60, 20, 80};
            default:                       return new int[]{55, 40, 30, 75};
        }
    }
%>
