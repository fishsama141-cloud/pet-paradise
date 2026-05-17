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
    <title>动物图鉴 - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        .main { max-width: 960px; margin: 0 auto; padding: 28px 20px 80px; }
        .page-header { margin-bottom: 22px; }
        .page-header .sub { font-size: 14px; color: var(--text-secondary); margin-top: 6px; font-weight: 500; }

        .filter-section { margin-bottom: 16px; }
        .filter-label { font-size: 12px; color: var(--text-muted); font-weight: 700; margin-bottom: 8px; letter-spacing: 1px; text-transform: uppercase; }
        .filter-tabs { display: flex; gap: 6px; flex-wrap: wrap; }
        .filter-tab {
            padding: 8px 18px; border: 2px solid var(--border-light); border-radius: 20px;
            cursor: pointer; font-size: 13px; font-weight: 600; transition: all var(--transition);
            background: var(--card-bg); color: var(--text-secondary); font-family: inherit;
        }
        .filter-tab:hover { border-color: var(--border-warm); color: var(--text); transform: translateY(-1px); }
        .filter-tab.active { background: linear-gradient(135deg, #FDF5EC, #FDF0E0); border-color: var(--accent-warm); color: #B06840; }
        .filter-tab .count { font-size: 11px; opacity: 0.7; margin-left: 2px; }

        .arch-tab.active[data-arch="CAUTIOUS"] { border-color: #D4A060; background: #FDF5EC; color: #B87030; }
        .arch-tab.active[data-arch="CURIOUS"] { border-color: #A0C060; background: #F5F8EC; color: #708030; }
        .arch-tab.active[data-arch="BOLD"] { border-color: #D08060; background: #FDF2EC; color: #B05030; }
        .arch-tab.active[data-arch="GENTLE"] { border-color: #80B0B0; background: #ECF5F5; color: #407070; }
        .arch-tab.active[data-arch="PLAYFUL"] { border-color: #D4B040; background: #FDF8EC; color: #B09030; }
        .arch-tab.active[data-arch="MYSTERIOUS"] { border-color: #A080C0; background: #F2ECF8; color: #604080; }

        .section-title {
            font-size: 19px; font-weight: 700; color: var(--text);
            margin: 28px 0 14px; padding-bottom: 10px;
            border-bottom: 2px solid var(--border-light);
            display: flex; align-items: center; gap: 10px; letter-spacing: 0.5px;
        }
        .section-title .icon { font-size: 24px; }
        .section-subtitle {
            font-size: 13px; color: var(--text-secondary); margin-bottom: 12px; padding-left: 4px;
            display: flex; align-items: center; gap: 8px; font-weight: 500;
        }
        .section-subtitle .dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; }
        .dot-owned { background: var(--accent-green); box-shadow: 0 0 6px rgba(100,150,80,0.3); }
        .dot-missing { background: #D5C8B5; }

        .species-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
            gap: 14px; margin-bottom: 18px;
        }
        .species-card {
            background: var(--card-bg); border-radius: var(--radius); padding: 18px;
            border: 1px solid var(--border-light); transition: all var(--transition);
            position: relative; overflow: hidden;
        }
        .species-card:hover { transform: translateY(-2px); border-color: var(--border-warm); box-shadow: var(--shadow-sm); }
        .species-card.collected { border-color: #B0C8A0; background: linear-gradient(135deg, #FFFEFA, #F7FAF5); }
        .species-card.collected::after {
            content: '✓'; position: absolute; top: 12px; right: 14px;
            font-size: 14px; color: #fff; background: var(--accent-green);
            width: 28px; height: 28px; border-radius: 50%; display: flex;
            align-items: center; justify-content: center; font-weight: 700;
        }
        .species-card.not-collected { opacity: 0.6; }
        .species-card .sc-top { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; }
        .species-card .sc-emoji { font-size: 38px; }
        .species-card .sc-name { font-size: 17px; font-weight: 700; color: var(--text); letter-spacing: 0.5px; }
        .species-card .sc-rarity { font-size: 11px; color: var(--text-muted); margin-top: 1px; }
        .species-card .sc-info { font-size: 12px; color: var(--text-secondary); line-height: 1.7; }
        .species-card .sc-info span { display: block; margin-bottom: 2px; }
        .species-card .sc-tags { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 10px; }
        .sc-tag {
            font-size: 10px; padding: 4px 12px; border-radius: 12px;
            font-weight: 700; white-space: nowrap; letter-spacing: 0.3px;
        }
        .sc-tag-archetype { background: #FDF9F2; color: #B89060; border: 1px solid #E8DDCA; }
        .sc-tag-trait { background: #F2F7EC; color: #708A50; border: 1px solid #D0E0C8; }
        .sc-tag-starter { background: #F5F0F8; color: #7058A0; border: 1px solid #D8D0E8; }
        .sc-capture { font-size: 11px; margin-top: 10px; padding: 10px 12px; background: linear-gradient(135deg, #FDF9F2, #FAF5E8); border-radius: 8px; color: var(--text-secondary); line-height: 1.6; border: 1px solid var(--border-light); }

        .food-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 10px; margin-bottom: 30px;
        }
        .food-card {
            background: var(--card-bg); border-radius: var(--radius); padding: 14px;
            border: 1px solid var(--border-light); transition: all var(--transition);
            display: flex; gap: 12px; align-items: center;
        }
        .food-card:hover { transform: translateY(-1px); border-color: #C5B8A0; }
        .food-card.owned { border-color: #B0C8A0; background: #F7FAF5; }
        .food-card .fc-emoji { font-size: 32px; flex-shrink: 0; }
        .food-card .fc-info { flex: 1; min-width: 0; }
        .food-card .fc-name { font-size: 14px; font-weight: 600; color: var(--text); }
        .food-card .fc-desc { font-size: 11px; color: var(--text-secondary); margin-top: 2px; }
        .food-card .fc-regions { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        @media (max-width: 600px) {
            .species-grid { grid-template-columns: 1fr; }
            .food-grid { grid-template-columns: 1fr; }
            .filter-tab { padding: 6px 12px; font-size: 12px; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">
            <img src="<%= request.getContextPath() %>/assets/images/ui/logo.png" alt="logo" onerror="this.style.display='none'">
            宠物乐园
        </a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard">我的宠物</a>
            <a href="<%= request.getContextPath() %>/map">世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia" class="active">图鉴</a>
            <a href="<%= request.getContextPath() %>/help">帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="page-header">
            <h1>动物图鉴</h1>
            <div class="sub">已收集 <strong style="color:var(--accent-warm);"><%= collectedSpecies.size() %></strong> / <%= PetSpecies.ALL.size() %> 种动物</div>
        </div>

        <div class="filter-section">
            <div class="filter-label">按地区筛选</div>
            <div class="filter-tabs" id="regionFilters">
                <button class="filter-tab active" data-region="all" onclick="filterRegion('all')">
                    全部<span class="count"><%= collectedSpecies.size() %>/<%= PetSpecies.ALL.size() %></span>
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

        <div class="filter-section">
            <div class="filter-label">按性格原型筛选</div>
            <div class="filter-tabs" id="archFilters">
                <button class="filter-tab arch-tab" data-arch="all" onclick="filterArch('all')">全部</button>
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

        <div id="activeFilterInfo" style="text-align:center;padding:8px;color:var(--text-muted);font-size:13px;display:none;"></div>

        <%
            for (PetSpecies.RegionDef rd : allRegions) {
                List<PetSpecies> rsp = regionSpecies.get(rd.id());
                if (rsp == null) continue;
        %>
        <div class="region-content" id="region-<%= rd.id() %>">
            <div class="section-title">
                <span class="icon"><%= rd.emoji() %></span> <%= rd.name() %>
            </div>

            <div class="section-subtitle">
                <span class="dot dot-owned"></span> 已拥有
                <%
                    int ownedCount = 0;
                    for (PetSpecies sp : rsp) if (collectedSpecies.contains(sp.getName())) ownedCount++;
                %>
                <span style="color:var(--text-muted);">(<%= ownedCount %>)</span>
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
                            <div class="sc-rarity"><%= sp.getRarityLabel() %> · Lv.<%= sp.getRequiredLevel() %>+</div>
                        </div>
                    </div>
                    <div class="sc-info">
                        <span>📍 <%= sp.getRealLocation() %></span>
                        <span>🌿 <%= sp.getHabitat() %></span>
                        <span>🍲 <%= sp.getDiet() %></span>
                        <span>💡 <%= sp.getFunFact() %></span>
                    </div>
                    <div class="sc-tags">
                        <span class="sc-tag sc-tag-archetype"><%= archLabel(arch) %></span>
                        <% if (ct != null) { %>
                        <span class="sc-tag sc-tag-trait">⭐ <%= ct.getName() %></span>
                        <% } %>
                        <% if (sp.getId().startsWith("starter_")) { %>
                        <span class="sc-tag sc-tag-starter">🎓 初始</span>
                        <% } %>
                    </div>
                    <div class="sc-capture">
                        <% int[] cap = getCap(sp.getId()); %>
                        🎯 捕捉条件：安≥<%= cap[0] %> 趣≥<%= cap[1] %>
                        压≤<%= cap[2] %> 信≥<%= cap[3] %>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="section-subtitle">
                <span class="dot dot-missing"></span> 未拥有
                <span style="color:var(--text-muted);">(<%= rsp.size() - ownedCount %>)</span>
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
                            <div class="sc-rarity"><%= sp.getRarityLabel() %> · Lv.<%= sp.getRequiredLevel() %>+</div>
                        </div>
                    </div>
                    <div class="sc-info">
                        <span>📍 <%= sp.getRealLocation() %></span>
                        <span>🌿 <%= sp.getHabitat() %></span>
                        <span>🍲 <%= sp.getDiet() %></span>
                        <span>💡 <%= sp.getFunFact() %></span>
                    </div>
                    <div class="sc-tags">
                        <span class="sc-tag sc-tag-archetype"><%= archLabel(arch) %></span>
                        <% if (ct != null) { %>
                        <span class="sc-tag sc-tag-trait">⭐ <%= ct.getName() %></span>
                        <% } %>
                    </div>
                    <div class="sc-capture">
                        <% int[] cap2 = getCap(sp.getId()); %>
                        🎯 捕捉条件：安≥<%= cap2[0] %> 趣≥<%= cap2[1] %>
                        压≤<%= cap2[2] %> 信≥<%= cap2[3] %>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="section-title" style="font-size:16px;">
                <span class="icon">🍲</span> 可获得食物
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
                        <div class="fc-name"><%= fd.getName() %> <%= owned ? "✅" : "" %></div>
                        <div class="fc-desc"><%= fd.getDescription() %></div>
                        <div class="fc-regions">📍 <%= String.join("、", fd.getRegions()) %></div>
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
                info.textContent = '正在筛选：' + activeLabels.join(' + ');
            } else {
                info.style.display = 'none';
            }

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
        if ("CAUTIOUS".equals(arch)) return "👀 谨慎型";
        if ("CURIOUS".equals(arch)) return "🔍 好奇型";
        if ("BOLD".equals(arch)) return "💪 大胆型";
        if ("GENTLE".equals(arch)) return "🌿 温柔型";
        if ("PLAYFUL".equals(arch)) return "🎾 活泼型";
        if ("MYSTERIOUS".equals(arch)) return "✨ 神秘型";
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
