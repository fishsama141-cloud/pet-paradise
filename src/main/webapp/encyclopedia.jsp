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

    // Group species by archetype
    Map<String, List<PetSpecies>> archSpeciesMap = new LinkedHashMap<>();
    archSpeciesMap.put("CAUTIOUS", new ArrayList<>());
    archSpeciesMap.put("CURIOUS", new ArrayList<>());
    archSpeciesMap.put("BOLD", new ArrayList<>());
    archSpeciesMap.put("GENTLE", new ArrayList<>());
    archSpeciesMap.put("PLAYFUL", new ArrayList<>());
    archSpeciesMap.put("MYSTERIOUS", new ArrayList<>());
    for (PetSpecies sp : PetSpecies.ALL) {
        String arch = getArch(sp.getId());
        archSpeciesMap.get(arch).add(sp);
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>&#x1F4D6; 动物图鉴 - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #1b2838 0%, #0d1b2a 30%, #1b2838 100%);
            min-height: 100vh; color: #e8dcc8;
        }
        .nav {
            background: #2d1f10; padding: 14px 28px; display: flex;
            align-items: center; justify-content: space-between;
            box-shadow: 0 4px 20px rgba(0,0,0,0.5); position: sticky; top: 0; z-index: 100;
            border-bottom: 2px solid #5a3e28;
        }
        .nav .brand { font-size: 22px; font-weight: 700; color: #f0c27a; text-decoration: none; }
        .nav-links { display: flex; gap: 10px; align-items: center; }
        .nav-links a {
            color: #d4b896; text-decoration: none; padding: 8px 16px; border-radius: 20px;
            font-weight: 600; font-size: 15px; background: rgba(255,255,255,0.08); transition: all 0.3s;
        }
        .nav-links a:hover, .nav-links a.active { background: #5a3e28; color: #f0c27a; }

        .main { max-width: 960px; margin: 0 auto; padding: 24px 20px; }
        .page-header { text-align: center; margin-bottom: 20px; }
        .page-header h1 { font-size: 30px; color: #f0c27a; }
        .page-header .sub { font-size: 14px; color: #8a9a7a; margin-top: 4px; }

        /* Filter row */
        .filter-section { margin-bottom: 16px; }
        .filter-label { font-size: 12px; color: #6a7a5a; font-weight: 600; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 1px; }
        .filter-tabs {
            display: flex; gap: 6px; flex-wrap: wrap;
        }
        .filter-tab {
            padding: 8px 16px; border: 2px solid #2a3a2a; border-radius: 20px;
            cursor: pointer; font-size: 13px; font-weight: 600; transition: all 0.3s;
            background: #1e2d1e; color: #8a9a7a; font-family: inherit;
        }
        .filter-tab:hover { border-color: #5a7a4a; color: #c0d0b0; }
        .filter-tab.active {
            background: linear-gradient(135deg, #4a6a3a, #5a7a4a); color: #f0c27a;
            border-color: #8bc34a; box-shadow: 0 0 12px rgba(139,195,74,0.2);
        }
        .filter-tab .count { font-size: 11px; opacity: 0.7; margin-left: 2px; }
        .arch-tab {
            background: #1a2218; border-color: #2a3a20;
        }
        .arch-tab.active[data-arch="CAUTIOUS"] { background: #3a3020; border-color: #d4a060; color: #f0d0a0; box-shadow: 0 0 12px rgba(212,160,96,0.2); }
        .arch-tab.active[data-arch="CURIOUS"] { background: #2a3a20; border-color: #b0d060; color: #d0f0a0; box-shadow: 0 0 12px rgba(176,208,96,0.2); }
        .arch-tab.active[data-arch="BOLD"] { background: #3a2020; border-color: #e08060; color: #f0b0a0; box-shadow: 0 0 12px rgba(224,128,96,0.2); }
        .arch-tab.active[data-arch="GENTLE"] { background: #2a3a3a; border-color: #80c0c0; color: #a0e0e0; box-shadow: 0 0 12px rgba(128,192,192,0.2); }
        .arch-tab.active[data-arch="PLAYFUL"] { background: #3a2a20; border-color: #e0b040; color: #f0d080; box-shadow: 0 0 12px rgba(224,176,64,0.2); }
        .arch-tab.active[data-arch="MYSTERIOUS"] { background: #2a2040; border-color: #b080e0; color: #d0b0f0; box-shadow: 0 0 12px rgba(176,128,224,0.2); }

        /* Section title */
        .section-title {
            font-size: 18px; font-weight: 700; color: #f0c27a;
            margin: 20px 0 12px; padding-bottom: 8px;
            border-bottom: 2px solid #3a4a2a;
            display: flex; align-items: center; gap: 8px;
        }
        .section-title .icon { font-size: 22px; }
        .section-subtitle {
            font-size: 13px; color: #6a7a5a; margin-bottom: 10px; padding-left: 4px;
            display: flex; align-items: center; gap: 8px;
        }
        .section-subtitle .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
        .dot-owned { background: #66BB6A; }
        .dot-missing { background: #666; }

        /* Species grid */
        .species-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 12px; margin-bottom: 16px;
        }
        .species-card {
            background: #1a2a1a; border-radius: 14px; padding: 16px;
            border: 2px solid #2a3a2a; transition: all 0.3s;
            position: relative; overflow: hidden;
        }
        .species-card:hover { transform: translateY(-3px); border-color: #5a7a4a; box-shadow: 0 8px 24px rgba(0,0,0,0.3); }
        .species-card.collected { border-color: #3a6a3a; }
        .species-card.collected::after {
            content: '\2714'; position: absolute; top: 10px; right: 14px;
            font-size: 14px; color: #66BB6A; background: #1a3a1a;
            width: 26px; height: 26px; border-radius: 50%; display: flex;
            align-items: center; justify-content: center; border: 2px solid #4CAF50;
        }
        .species-card.not-collected { opacity: 0.6; }
        .species-card .sc-top { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
        .species-card .sc-emoji { font-size: 40px; }
        .species-card .sc-name { font-size: 17px; font-weight: 700; color: #f0c27a; }
        .species-card .sc-rarity { font-size: 11px; color: #8a7a6a; }
        .species-card .sc-info { font-size: 12px; color: #8a9a7a; line-height: 1.6; }
        .species-card .sc-info span { display: block; margin-bottom: 1px; }
        .species-card .sc-tags { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 8px; }
        .sc-tag {
            font-size: 10px; padding: 3px 10px; border-radius: 10px;
            font-weight: 600; white-space: nowrap;
        }
        .sc-tag-archetype { background: #3a3020; color: #d4a060; }
        .sc-tag-trait { background: #2a3a20; color: #b0c060; }
        .sc-tag-starter { background: #2a2040; color: #a080d0; }
        .sc-capture { font-size: 11px; margin-top: 8px; padding: 8px; background: #151d15; border-radius: 8px; color: #8a9a7a; line-height: 1.5; }

        /* Food grid */
        .food-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 10px; margin-bottom: 30px;
        }
        .food-card {
            background: #1a2a1a; border-radius: 14px; padding: 14px;
            border: 1px solid #2a3a2a; transition: all 0.3s; display: flex; gap: 12px; align-items: center;
        }
        .food-card:hover { transform: translateY(-2px); border-color: #5a7a4a; }
        .food-card.owned { border-color: #3a6a3a; background: #152015; }
        .food-card .fc-emoji { font-size: 34px; flex-shrink: 0; }
        .food-card .fc-info { flex: 1; min-width: 0; }
        .food-card .fc-name { font-size: 14px; font-weight: 700; color: #e0d5c1; }
        .food-card .fc-desc { font-size: 11px; color: #8a9a7a; margin-top: 2px; }
        .food-card .fc-regions { font-size: 11px; color: #6a7a5a; margin-top: 2px; }

        .empty-hint { text-align: center; padding: 30px; color: #6a7a5a; font-size: 14px; }

        @media (max-width: 600px) {
            .species-grid { grid-template-columns: 1fr; }
            .food-grid { grid-template-columns: 1fr; }
            .filter-tab { padding: 6px 12px; font-size: 12px; }
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
            <a href="<%= request.getContextPath() %>/help">&#x2753; 帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">&#x1F6AA; 退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="page-header">
            <h1>&#x1F4D6; 动物图鉴</h1>
            <div class="sub">已收集 <strong style="color:#f0c27a;"><%= collectedSpecies.size() %></strong> / <%= PetSpecies.ALL.size() %> 种动物</div>
        </div>

        <!-- Region filter -->
        <div class="filter-section">
            <div class="filter-label">&#x1F30D; 按地区筛选</div>
            <div class="filter-tabs" id="regionFilters">
                <button class="filter-tab active" data-region="all" onclick="filterRegion('all')">
                    &#x1F30D; 全部<span class="count"><%= collectedSpecies.size() %>/<%= PetSpecies.ALL.size() %></span>
                </button>
                <% for (PetSpecies.RegionDef rd : allRegions) {
                    int total = 0, have = 0;
                    List<PetSpecies> sps = regionSpecies.get(rd.id());
                    if (sps != null) {
                        total = sps.size();
                        for (PetSpecies sp : sps) if (collectedSpecies.contains(sp.getName())) have++;
                    }
                %>
                <button class="filter-tab" data-region="<%= rd.id() %>" onclick="filterRegion('<%= rd.id() %>')">
                    <%= rd.emoji() %> <%= rd.name() %><span class="count"><%= have %>/<%= total %></span>
                </button>
                <% } %>
            </div>
        </div>

        <!-- Archetype filter -->
        <div class="filter-section">
            <div class="filter-label">&#x1F3AD; 按性格原型筛选</div>
            <div class="filter-tabs" id="archFilters">
                <button class="filter-tab arch-tab" data-arch="all" onclick="filterArch('all')">
                    &#x1F3AD; 全部
                </button>
                <% for (String arch : archSpeciesMap.keySet()) {
                    int archHave = 0;
                    for (PetSpecies sp : archSpeciesMap.get(arch)) if (collectedSpecies.contains(sp.getName())) archHave++;
                %>
                <button class="filter-tab arch-tab" data-arch="<%= arch %>" onclick="filterArch('<%= arch %>')">
                    <%= archLabel(arch) %><span class="count"><%= archHave %>/<%= archSpeciesMap.get(arch).size() %></span>
                </button>
                <% } %>
            </div>
        </div>

        <!-- Active filter indicator -->
        <div id="activeFilterInfo" style="text-align:center;padding:8px;color:#6a7a5a;font-size:13px;display:none;"></div>

        <!-- Content: by region + archetype -->
        <%
            for (PetSpecies.RegionDef rd : allRegions) {
                List<PetSpecies> rsp = regionSpecies.get(rd.id());
                if (rsp == null) continue;
        %>
        <div class="region-content" id="region-<%= rd.id() %>">
            <div class="section-title">
                <span class="icon"><%= rd.emoji() %></span> <%= rd.name() %>
            </div>

            <!-- Owned species -->
            <div class="section-subtitle">
                <span class="dot dot-owned"></span> 已拥有
                <%
                    int ownedCount = 0;
                    for (PetSpecies sp : rsp) if (collectedSpecies.contains(sp.getName())) ownedCount++;
                %>
                <span style="color:#8a9a7a;">(<%= ownedCount %>)</span>
            </div>
            <div class="species-grid">
                <% for (PetSpecies sp : rsp) {
                    if (!collectedSpecies.contains(sp.getName())) continue;
                    String arch = getArch(sp.getId());
                    CompanionTrait ct = CompanionTrait.forSpecies(sp.getId());
                %>
                <div class="species-card collected" data-arch="<%= arch %>" data-collected="true">
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
                        <span class="sc-tag sc-tag-archetype"><%= archLabel(arch) %></span>
                        <% if (ct != null) { %>
                        <span class="sc-tag sc-tag-trait">&#x2B50; <%= ct.getName() %></span>
                        <% } %>
                        <% if (sp.getId().startsWith("starter_")) { %>
                        <span class="sc-tag sc-tag-starter">&#x1F393; 初始</span>
                        <% } %>
                    </div>
                    <div class="sc-capture">
                        <% int[] cap = getCap(sp.getId()); %>
                        &#x1F3AF; 捕捉条件：安&#x2265;<%= cap[0] %> 趣&#x2265;<%= cap[1] %>
                        压&#x2264;<%= cap[2] %> 信&#x2265;<%= cap[3] %>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Unowned species -->
            <div class="section-subtitle">
                <span class="dot dot-missing"></span> 未拥有
                <%
                    int missingCount = rsp.size() - ownedCount;
                %>
                <span style="color:#6a7a5a;">(<%= missingCount %>)</span>
            </div>
            <div class="species-grid">
                <% for (PetSpecies sp : rsp) {
                    if (collectedSpecies.contains(sp.getName())) continue;
                    String arch = getArch(sp.getId());
                    CompanionTrait ct = CompanionTrait.forSpecies(sp.getId());
                %>
                <div class="species-card not-collected" data-arch="<%= arch %>" data-collected="false">
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
                        <span class="sc-tag sc-tag-archetype"><%= archLabel(arch) %></span>
                        <% if (ct != null) { %>
                        <span class="sc-tag sc-tag-trait">&#x2B50; <%= ct.getName() %></span>
                        <% } %>
                    </div>
                    <div class="sc-capture">
                        <% int[] cap2 = getCap(sp.getId()); %>
                        &#x1F3AF; 捕捉条件：安&#x2265;<%= cap2[0] %> 趣&#x2265;<%= cap2[1] %>
                        压&#x2264;<%= cap2[2] %> 信&#x2265;<%= cap2[3] %>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Food for this region -->
            <div class="section-title" style="font-size:16px;">
                <span class="icon">&#x1F372;</span> 可获得食物
            </div>
            <div class="food-grid">
                <% List<FoodDef> flist = regionFoods.get(rd.id());
                   if (flist != null) {
                       for (FoodDef fd : flist) {
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
    </div>

    <script>
        var currentRegion = 'all';
        var currentArch = 'all';

        function updateDisplay() {
            var allCards = document.querySelectorAll('.species-card');
            var regionContents = document.querySelectorAll('.region-content');
            var info = document.getElementById('activeFilterInfo');

            if (currentRegion === 'all' && currentArch === 'all') {
                info.style.display = 'none';
                regionContents.forEach(function(c) { c.style.display = 'block'; });
                allCards.forEach(function(c) { c.style.display = ''; });
                return;
            }

            var activeLabels = [];
            if (currentRegion !== 'all') {
                var rTab = document.querySelector('[data-region="'+currentRegion+'"]');
                if (rTab) activeLabels.push(rTab.textContent.trim().split(/[\d]/)[0]);
                regionContents.forEach(function(c) {
                    if (c.id === 'region-' + currentRegion) c.style.display = 'block';
                    else c.style.display = 'none';
                });
            } else {
                regionContents.forEach(function(c) { c.style.display = 'block'; });
            }
            if (currentArch !== 'all') {
                var aTab = document.querySelector('[data-arch="'+currentArch+'"]');
                if (aTab) activeLabels.push(aTab.textContent.trim().split(/[\d]/)[0]);
                allCards.forEach(function(c) {
                    if (c.getAttribute('data-arch') === currentArch) c.style.display = '';
                    else c.style.display = 'none';
                });
            }

            if (activeLabels.length > 0) {
                info.style.display = 'block';
                info.textContent = '🔍 正在筛选：' + activeLabels.join(' + ');
            } else {
                info.style.display = 'none';
            }

            // Apply cross filters
            if (currentArch !== 'all' && currentRegion !== 'all') {
                var visibleRegion = document.getElementById('region-' + currentRegion);
                if (visibleRegion) {
                    var cards = visibleRegion.querySelectorAll('.species-card');
                    cards.forEach(function(c) {
                        if (c.getAttribute('data-arch') !== currentArch) c.style.display = 'none';
                    });
                }
            }
        }

        function filterRegion(regionId) {
            currentRegion = regionId;
            document.querySelectorAll('#regionFilters .filter-tab').forEach(function(t) { t.classList.remove('active'); });
            var tab = document.querySelector('#regionFilters [data-region="'+regionId+'"]');
            if (tab) tab.classList.add('active');
            updateDisplay();
        }

        function filterArch(arch) {
            currentArch = arch;
            document.querySelectorAll('#archFilters .filter-tab').forEach(function(t) { t.classList.remove('active'); });
            var tab = document.querySelector('#archFilters [data-arch="'+arch+'"]');
            if (tab) tab.classList.add('active');
            updateDisplay();
        }
    </script>
</body>
</html>
<%!
    String getArch(String speciesId) {
        if (speciesId == null) return "MYSTERIOUS";
        if (speciesId.contains("fox") || speciesId.contains("crane") || speciesId.contains("owl")
            || speciesId.contains("rabbit")) return "CAUTIOUS";
        if (speciesId.contains("monkey") || speciesId.contains("toucan") || speciesId.contains("macaw")
            || speciesId.contains("dolphin")) return "CURIOUS";
        if (speciesId.contains("jaguar") || speciesId.contains("lion") || speciesId.contains("bear")
            || speciesId.contains("kangaroo")) return "BOLD";
        if (speciesId.contains("sloth") || speciesId.contains("koala") || speciesId.contains("turtle")
            || speciesId.contains("giraffe")) return "GENTLE";
        if (speciesId.contains("dog") || speciesId.contains("cat") || speciesId.contains("zebra")
            || speciesId.contains("platypus")) return "PLAYFUL";
        return "MYSTERIOUS";
    }

    String archLabel(String arch) {
        if ("CAUTIOUS".equals(arch)) return "&#x1F440; 谨慎型";
        if ("CURIOUS".equals(arch)) return "&#x1F50D; 好奇型";
        if ("BOLD".equals(arch)) return "&#x1F4AA; 大胆型";
        if ("GENTLE".equals(arch)) return "&#x1F33F; 温柔型";
        if ("PLAYFUL".equals(arch)) return "&#x1F3BE; 活泼型";
        if ("MYSTERIOUS".equals(arch)) return "&#x2728; 神秘型";
        return "";
    }

    int[] getCap(String speciesId) {
        if (speciesId == null) return new int[]{55, 40, 30, 75};
        if ("east_asia_red_panda".equals(speciesId)) return new int[]{70, 30, 30, 75};
        if ("east_asia_crane".equals(speciesId)) return new int[]{80, 25, 25, 70};
        if ("east_asia_golden_monkey".equals(speciesId)) return new int[]{45, 60, 25, 80};
        if ("starter_cat".equals(speciesId)) return new int[]{60, 45, 30, 75};
        if ("starter_fox".equals(speciesId)) return new int[]{75, 35, 20, 75};
        if ("amazon_toucan".equals(speciesId)) return new int[]{35, 70, 35, 75};
        if ("amazon_sloth".equals(speciesId)) return new int[]{60, 20, 35, 70};
        if ("amazon_jaguar".equals(speciesId)) return new int[]{50, 45, 20, 85};
        if ("starter_macaw".equals(speciesId)) return new int[]{35, 70, 25, 75};
        if ("africa_zebra".equals(speciesId)) return new int[]{65, 40, 30, 75};
        if ("africa_giraffe".equals(speciesId)) return new int[]{75, 30, 25, 70};
        if ("africa_lion".equals(speciesId)) return new int[]{55, 35, 20, 85};
        if ("starter_dog".equals(speciesId)) return new int[]{45, 65, 25, 70};
        if ("starter_rabbit".equals(speciesId)) return new int[]{80, 45, 20, 80};
        if ("australia_koala".equals(speciesId)) return new int[]{70, 25, 35, 75};
        if ("australia_platypus".equals(speciesId)) return new int[]{50, 60, 20, 70};
        if ("australia_kangaroo".equals(speciesId)) return new int[]{45, 65, 25, 80};
        if ("starter_lizard".equals(speciesId)) return new int[]{55, 50, 20, 75};
        if ("arctic_snowy_owl".equals(speciesId)) return new int[]{80, 30, 20, 75};
        if ("arctic_fox".equals(speciesId)) return new int[]{75, 40, 25, 70};
        if ("arctic_polar_bear".equals(speciesId)) return new int[]{55, 30, 20, 85};
        if ("starter_bear".equals(speciesId)) return new int[]{65, 35, 30, 75};
        if ("ocean_turtle".equals(speciesId)) return new int[]{70, 25, 30, 80};
        if ("ocean_squid".equals(speciesId)) return new int[]{40, 55, 30, 75};
        if ("ocean_whale".equals(speciesId)) return new int[]{55, 30, 25, 85};
        if ("starter_dolphin".equals(speciesId)) return new int[]{50, 60, 20, 80};
        return new int[]{55, 40, 30, 75};
    }
%>
