<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%@ page import="org.example.pets.servlet.DashboardServlet.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    List<Pet> pets = (List<Pet>) request.getAttribute("pets");
    Map<String, List<Pet>> zonePets = (Map<String, List<Pet>>) request.getAttribute("zonePets");
    List<HabitatZone> zones = (List<HabitatZone>) request.getAttribute("zones");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    String newRegionMsg = (String) request.getAttribute("newRegionMsg");
    int petCount = request.getAttribute("petCount") != null ? (Integer) request.getAttribute("petCount") : 0;
    int maxPets = request.getAttribute("maxPets") != null ? (Integer) request.getAttribute("maxPets") : 20;
    if (zonePets == null) zonePets = new LinkedHashMap<>();
    if (zones == null) zones = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的宠物 - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        /* ===== 栖息地地图 ===== */
        .habitat-map {
            position: relative;
            width: 100%;
            max-width: 900px;
            margin: 0 auto 32px;
            height: 420px;
            background: url('<%= request.getContextPath() %>/assets/images/bg/map-bg.png') center/cover no-repeat;
            background-color: #E8E0D0;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            overflow: hidden;
        }
        .habitat-map::after {
            content: '';
            position: absolute; inset: 0;
            background: linear-gradient(180deg, rgba(255,252,245,0.15) 0%, rgba(255,252,245,0.05) 100%);
            pointer-events: none;
        }

        .zone-node {
            position: absolute; transform: translate(-50%, -50%);
            text-align: center; cursor: pointer; transition: all 0.25s;
            text-decoration: none; z-index: 2;
        }
        .zone-node:hover { transform: translate(-50%, -50%) scale(1.08); }
        .zone-node .zone-icon {
            width: 72px; height: 72px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto; border: 2px solid rgba(120,100,70,0.3);
            box-shadow: var(--shadow-xs); transition: all 0.25s;
        }
        .zone-node:hover .zone-icon {
            box-shadow: var(--shadow);
            border-color: rgba(120,100,70,0.5);
        }
        .zone-node .zone-icon img { width: 40px; height: 40px; object-fit: contain; }
        .zone-node .zone-name {
            font-size: 12px; font-weight: 600; color: var(--text);
            text-shadow: 0 1px 2px rgba(255,255,255,0.8); margin-top: 4px;
        }
        .zone-node .zone-count {
            position: absolute; top: -6px; right: -6px;
            background: var(--accent-warm); color: white;
            min-width: 22px; height: 22px; border-radius: 11px;
            font-size: 11px; font-weight: 600;
            display: flex; align-items: center; justify-content: center;
        }
        .zone-node.empty .zone-count { background: #C0B5A5; }

        /* ===== 区域详情 ===== */
        .zone-section {
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            padding: 22px 24px;
            margin-bottom: 16px;
            box-shadow: var(--shadow-xs);
        }
        .zone-section-header {
            display: flex; align-items: center; gap: 14px;
            margin-bottom: 16px; padding-bottom: 14px;
            border-bottom: 1px solid var(--border-light);
        }
        .zone-section-header .zs-icon { font-size: 32px; }
        .zone-section-header .zs-icon img { width: 40px; height: 40px; object-fit: contain; }
        .zone-section-header .zs-name { font-size: 18px; font-weight: 600; color: var(--text); }
        .zone-section-header .zs-count { font-size: 13px; color: var(--text-secondary); }

        /* ===== 宠物小卡片 ===== */
        .pet-card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 12px;
        }
        .pet-card {
            display: flex; align-items: center; gap: 14px;
            padding: 14px 16px;
            border-radius: var(--radius);
            border: 1px solid var(--border-light);
            text-decoration: none; color: inherit;
            transition: all var(--transition);
            background: #FCFAF5;
        }
        .pet-card:hover {
            border-color: #C5B8A0;
            background: var(--card-hover);
            transform: translateY(-1px);
            box-shadow: var(--shadow-xs);
        }
        .pet-card .pc-img {
            width: 56px; height: 56px;
            border-radius: var(--radius-sm);
            object-fit: contain;
            flex-shrink: 0;
            background: #F5F0E8;
        }
        .pet-card .pc-info { flex: 1; min-width: 0; }
        .pet-card .pc-name { font-size: 15px; font-weight: 600; color: var(--text); }
        .pet-card .pc-species { font-size: 12px; color: var(--text-secondary); }
        .pet-card .pc-stats {
            display: flex; gap: 6px; margin-top: 4px; flex-wrap: wrap;
        }
        .pc-stat {
            font-size: 11px; color: var(--text-secondary);
            background: #F5F0E8; padding: 2px 8px; border-radius: 4px;
        }
        .pet-card .pc-level {
            background: var(--accent-warm); color: #fff;
            padding: 3px 10px; border-radius: 10px;
            font-size: 12px; font-weight: 600; flex-shrink: 0;
        }

        .empty-zone {
            text-align: center; padding: 20px; color: var(--text-muted);
            font-size: 14px;
        }

        @media (max-width: 768px) {
            .habitat-map { height: 300px; border-radius: 12px; }
            .zone-node .zone-icon { width: 52px; height: 52px; }
            .zone-node .zone-icon img { width: 28px; height: 28px; }
            .zone-node .zone-name { font-size: 10px; }
            .pet-card-grid { grid-template-columns: 1fr; }
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
            <a href="<%= request.getContextPath() %>/dashboard" class="active">我的宠物</a>
            <a href="<%= request.getContextPath() %>/map">世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia">图鉴</a>
            <a href="<%= request.getContextPath() %>/help">帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="page-header">
            <h1>宠物栖息地</h1>
            <p>每只宠物都在适合自己习性的环境中生活 · 共 <strong><%= petCount %></strong> / <%= maxPets %> 只</p>
        </div>

        <% if (error != null) { %><div class="alert alert-error"><%= error %></div><% } %>
        <% if (success != null) { %><div class="alert alert-success"><%= success.replace("\n", "<br>") %></div><% } %>
        <% if (newRegionMsg != null) { %><div class="alert alert-info"><%= newRegionMsg %></div><% } %>

        <!-- 栖息地地图 -->
        <div class="habitat-map">
            <% for (HabitatZone z : zones) {
                List<Pet> zp = zonePets.get(z.id());
                int cnt = zp != null ? zp.size() : 0;
                // 取该区域第一只宠物的图片作为区域图标
                String zoneImg = null;
                if (zp != null && !zp.isEmpty()) {
                    zoneImg = zp.get(0).getImagePath();
                }
            %>
            <a href="#zone-<%= z.id() %>" class="zone-node <%= cnt == 0 ? "empty" : "" %>"
               style="top:<%= z.topPct() %>%; left:<%= z.leftPct() %>%;">
                <div class="zone-icon" style="background:<%= z.color() %>20;">
                    <% if (zoneImg != null) { %>
                    <img src="<%= request.getContextPath() %>/assets/images/animals/<%= zoneImg %>" alt="<%= z.name() %>">
                    <% } else { %>
                    <span style="font-size:28px;"><%= z.emoji() %></span>
                    <% } %>
                </div>
                <span class="zone-name"><%= z.name() %></span>
                <span class="zone-count"><%= cnt %></span>
            </a>
            <% } %>
        </div>

        <!-- 各区域宠物列表 -->
        <% for (HabitatZone z : zones) {
            List<Pet> zp = zonePets.get(z.id());
            int cnt = zp != null ? zp.size() : 0;
        %>
        <div class="zone-section" id="zone-<%= z.id() %>">
            <div class="zone-section-header">
                <span class="zs-icon"><%= z.emoji() %></span>
                <div>
                    <div class="zs-name"><%= z.name() %></div>
                    <div class="zs-count"><%= cnt %> 只宠物在此栖息</div>
                </div>
            </div>

            <% if (zp == null || zp.isEmpty()) { %>
            <div class="empty-zone">这里还没有宠物居住，去世界地图探索发现新的伙伴吧</div>
            <% } else { %>
            <div class="pet-card-grid">
                <% for (Pet p : zp) {
                    String imgPath = p.getImagePath();
                    CompanionTrait ct = CompanionTrait.forPet(p);
                %>
                <a href="<%= request.getContextPath() %>/pet?action=interact&petId=<%= p.getId() %>" class="pet-card">
                    <img class="pc-img"
                         src="<%= request.getContextPath() %>/assets/images/animals/<%= imgPath != null ? imgPath : "" %>"
                         alt="<%= p.getName() %>"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                    <span style="display:none;width:56px;height:56px;align-items:center;justify-content:center;font-size:32px;flex-shrink:0;"><%= p.getEmoji() %></span>
                    <div class="pc-info">
                        <div class="pc-name"><%= p.getName() %></div>
                        <div class="pc-species"><%= p.getSpecies() %></div>
                        <div class="pc-stats">
                            <span class="tag tag-<%= p.getRarity() != null ? p.getRarity() : "common" %>"><%= p.getRarityLabel() %></span>
                            <span class="pc-stat">❤<%= p.getAffinity() %></span>
                            <span class="pc-stat">🤝<%= p.getBond() %></span>
                            <span class="pc-stat">🎭<%= p.getPersonality() %></span>
                        </div>
                        <% if (ct != null) { %>
                        <div style="margin-top:4px;">
                            <span style="font-size:10px; background:#F0EDE0; color:var(--text-secondary); padding:2px 8px; border-radius:6px; font-weight:500;">
                                ⭐ <%= ct.getName() %> · <%= ct.getPositioning() %>
                            </span>
                        </div>
                        <% } %>
                    </div>
                    <span class="pc-level">Lv.<%= p.getLevel() %></span>
                </a>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <script>
        document.querySelectorAll('.zone-node').forEach(function(node) {
            node.addEventListener('click', function(e) {
                e.preventDefault();
                var target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    target.style.borderColor = '#C5B8A0';
                    setTimeout(function() { target.style.borderColor = '#E5DDD0'; }, 1500);
                }
            });
        });
    </script>
</body>
</html>
