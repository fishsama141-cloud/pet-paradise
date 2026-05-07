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
    <title>&#x1F43E; 我的宠物 - 宠物乐园</title>
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
        .page-header { text-align: center; margin-bottom: 24px; }
        .page-header h1 { font-size: 34px; color: #f0c27a; }
        .page-header p { color: #9a8a6a; font-size: 15px; margin-top: 6px; }

        .alert {
            padding: 14px 20px; border-radius: 14px; margin-bottom: 20px;
            font-weight: 600; font-size: 14px; animation: fadeIn 0.5s;
        }
        .alert-error { background: #3d1010; color: #ff9090; border-left: 4px solid #ff5252; }
        .alert-success { background: #1a3a1a; color: #90c090; border-left: 4px solid #66bb6a; }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }

        /* Habitat map */
        .habitat-map {
            position: relative; width: 100%; max-width: 900px; margin: 0 auto 32px;
            height: 440px; background: linear-gradient(180deg, #1a3a2a 0%, #1a2a3a 40%, #1a2a1a 70%, #1a3a3a 100%);
            border-radius: 24px; border: 3px solid #3a5a4a;
            box-shadow: 0 12px 40px rgba(0,0,0,0.5), inset 0 0 60px rgba(0,0,0,0.4);
            overflow: hidden;
        }
        .habitat-map::before {
            content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background:
                radial-gradient(ellipse at 70% 28%, rgba(76,175,80,0.2) 0%, transparent 60%),
                radial-gradient(ellipse at 50% 45%, rgba(245,124,0,0.15) 0%, transparent 50%),
                radial-gradient(ellipse at 18% 65%, rgba(21,101,192,0.2) 0%, transparent 45%),
                radial-gradient(ellipse at 55% 14%, rgba(121,85,72,0.2) 0%, transparent 40%),
                radial-gradient(ellipse at 75% 72%, rgba(255,152,0,0.15) 0%, transparent 40%),
                radial-gradient(ellipse at 10% 35%, rgba(144,202,249,0.15) 0%, transparent 40%);
            pointer-events: none;
        }

        .zone-node {
            position: absolute; transform: translate(-50%, -50%);
            text-align: center; cursor: pointer; transition: all 0.3s;
            text-decoration: none;
        }
        .zone-node:hover { transform: translate(-50%, -50%) scale(1.12); z-index: 10; }
        .zone-node .zone-circle {
            width: 90px; height: 90px; border-radius: 50%; display: flex;
            align-items: center; justify-content: center; flex-direction: column;
            transition: all 0.3s; margin: 0 auto;
            border: 3px solid rgba(255,255,255,0.5);
            box-shadow: 0 4px 20px rgba(0,0,0,0.4);
        }
        .zone-node:hover .zone-circle {
            box-shadow: 0 8px 32px rgba(255,255,255,0.25);
            border-color: rgba(255,255,255,0.8);
        }
        .zone-node .zone-emoji { font-size: 32px; display: block; }
        .zone-node .zone-name {
            font-size: 12px; font-weight: 700; color: #fff;
            text-shadow: 0 1px 4px rgba(0,0,0,0.7); margin-top: 2px;
        }
        .zone-node .zone-count {
            position: absolute; top: -10px; right: -10px;
            background: #f44336; color: white; width: 26px; height: 26px;
            border-radius: 50%; font-size: 12px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 2px 10px rgba(244,67,54,0.5);
        }
        .zone-node.empty .zone-count { background: #555; box-shadow: none; }

        /* Zone detail sections */
        .zone-detail {
            background: #1e2d1e; border-radius: 18px; padding: 20px 24px;
            margin-bottom: 18px; border: 2px solid #2a3a2a; transition: all 0.3s;
        }
        .zone-detail-header {
            display: flex; align-items: center; gap: 14px; margin-bottom: 16px;
            padding-bottom: 14px; border-bottom: 1px solid #2a3a2a;
        }
        .zone-detail-header .zd-emoji { font-size: 40px; }
        .zone-detail-header .zd-name { font-size: 20px; font-weight: 700; color: #f0c27a; }
        .zone-detail-header .zd-count { font-size: 14px; color: #8a9a7a; }

        .pet-mini-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 12px; }
        .pet-mini-card {
            background: #151d15; border-radius: 14px; padding: 14px 16px;
            text-decoration: none; color: inherit; display: flex; align-items: center;
            gap: 12px; transition: all 0.3s; border: 1px solid #2a3a2a;
        }
        .pet-mini-card:hover { border-color: #5a7a4a; background: #1a2a1a; transform: translateY(-2px); }
        .pet-mini-card .pm-emoji { font-size: 40px; flex-shrink: 0; }
        .pet-mini-info { flex: 1; min-width: 0; }
        .pet-mini-info .pm-name { font-size: 16px; font-weight: 700; color: #f0c27a; }
        .pet-mini-info .pm-species { font-size: 12px; color: #8a9a7a; }
        .pet-mini-info .pm-stats { display: flex; gap: 8px; margin-top: 4px; flex-wrap: wrap; }
        .pm-stat {
            font-size: 11px; color: #a0b090; background: #1a2a1a;
            padding: 2px 8px; border-radius: 6px;
        }
        .pm-stat.rarity-tag {
            background: linear-gradient(135deg, #FFD93D, #FFC107); color: #5D4037;
            font-weight: 700;
        }
        .pet-mini-card .pm-level {
            background: #FF8C42; color: white; padding: 4px 10px;
            border-radius: 12px; font-size: 12px; font-weight: 700; flex-shrink: 0;
        }
        .empty-zone {
            text-align: center; padding: 12px; color: #5a6a5a; font-size: 14px;
        }

        @media (max-width: 768px) {
            .habitat-map { height: 340px; }
            .zone-node .zone-circle { width: 64px; height: 64px; }
            .zone-node .zone-emoji { font-size: 24px; }
            .zone-node .zone-name { font-size: 10px; }
            .pet-mini-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">&#x1F43E; 宠物乐园</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard" class="active">🏠 我的宠物</a>
            <a href="<%= request.getContextPath() %>/map">🗺️ 世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia">📖 图鉴</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">🚪 退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="page-header">
            <h1>🏠 宠物栖息地</h1>
            <p>每只宠物都在适合自己习性的环境中生活 · 共 <strong><%= petCount %></strong> / <%= maxPets %> 只</p>
        </div>

        <% if (error != null) { %><div class="alert alert-error">⚠️ <%= error %></div><% } %>
        <% if (success != null) { %><div class="alert alert-success">🎉 <%= success.replace("\n", "<br>") %></div><% } %>
        <% if (newRegionMsg != null) { %><div class="alert" style="background:#1a3a3a;color:#90d0c0;border-left:4px solid #4dd0e1;padding:14px 20px;border-radius:14px;margin-bottom:20px;font-weight:600;font-size:14px;animation:fadeIn 0.5s;">🗺️ <%= newRegionMsg %></div><% } %>

        <!-- Habitat visual map -->
        <div class="habitat-map">
            <% for (HabitatZone z : zones) {
                List<Pet> zp = zonePets.get(z.id());
                int cnt = zp != null ? zp.size() : 0;
            %>
            <a href="#zone-<%= z.id() %>" class="zone-node <%= cnt == 0 ? "empty" : "" %>"
               style="top:<%= z.topPct() %>%; left:<%= z.leftPct() %>%;">
                <div class="zone-circle" style="background:<%= z.color() %>cc;">
                    <span class="zone-emoji"><%= z.emoji() %></span>
                    <span class="zone-name"><%= z.name() %></span>
                </div>
                <span class="zone-count"><%= cnt %></span>
            </a>
            <% } %>
            <div style="position:absolute;bottom:30px;left:10%;color:#2a5a2a;font-size:14px;pointer-events:none;">🌲🌲🌲🌲</div>
            <div style="position:absolute;bottom:40px;right:8%;color:#3a6a3a;font-size:14px;pointer-events:none;">🏔️🏔️</div>
            <div style="position:absolute;bottom:20px;left:42%;color:#5a7a2a;font-size:12px;pointer-events:none;">🌿🌿🌿</div>
        </div>

        <!-- Zone details with pet cards -->
        <% for (HabitatZone z : zones) {
            List<Pet> zp = zonePets.get(z.id());
            int cnt = zp != null ? zp.size() : 0;
        %>
        <div class="zone-detail" id="zone-<%= z.id() %>">
            <div class="zone-detail-header">
                <span class="zd-emoji"><%= z.emoji() %></span>
                <div>
                    <div class="zd-name"><%= z.name() %></div>
                    <div class="zd-count"><%= cnt %> 只宠物在此栖息</div>
                </div>
            </div>

            <% if (zp == null || zp.isEmpty()) { %>
            <div class="empty-zone">🔍 这里还没有宠物居住，去世界地图探索发现新的伙伴吧！</div>
            <% } else { %>
            <div class="pet-mini-grid">
                <% for (Pet p : zp) { %>
                <a href="<%= request.getContextPath() %>/pet?action=interact&petId=<%= p.getId() %>" class="pet-mini-card">
                    <span class="pm-emoji"><%= p.getEmoji() %></span>
                    <div class="pm-mini-info">
                        <div class="pm-name"><%= p.getName() %></div>
                        <div class="pm-species"><%= p.getSpecies() %></div>
                        <div class="pm-stats">
                            <span class="pm-stat rarity-tag"><%= p.getRarityLabel() %></span>
                            <span class="pm-stat">&#x2764;<%= p.getAffinity() %></span>
                            <span class="pm-stat">&#x1F91D;<%= p.getBond() %></span>
                            <span class="pm-stat">&#x1F3AD;<%= p.getPersonality() %></span>
                        </div>
                        <%
                            CompanionTrait ct = CompanionTrait.forPet(p);
                            if (ct != null) {
                        %>
                        <div style="margin-top:4px;">
                            <span style="font-size:10px; background:#3a5a2a; color:#c0e080; padding:2px 8px; border-radius:8px; font-weight:600;">&#x2B50; <%= ct.getName() %> · <%= ct.getPositioning() %></span>
                        </div>
                        <% } %>
                    </div>
                    <span class="pm-level">Lv.<%= p.getLevel() %></span>
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
                    target.style.borderColor = '#f0c27a';
                    setTimeout(function() { target.style.borderColor = '#2a3a2a'; }, 1500);
                }
            });
        });
    </script>
</body>
</html>
