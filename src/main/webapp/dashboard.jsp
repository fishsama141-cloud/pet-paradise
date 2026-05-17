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
        .main { max-width: 960px; margin: 0 auto; padding: 28px 20px 80px; }

        .pet-count-bar {
            display: flex; align-items: center; justify-content: center; gap: 10px;
            margin-top: 6px; font-size: 13px; color: var(--text-secondary);
        }
        .pet-count-bar .count-dot {
            width: 8px; height: 8px; border-radius: 50%;
            display: inline-block; transition: background 0.3s;
        }
        .count-dot.filled { background: var(--accent-green); }
        .count-dot.empty { background: var(--border); }

        /* ===== 栖息地地图 ===== */
        .habitat-map {
            position: relative;
            width: 100%;
            max-width: 900px;
            margin: 0 auto 36px;
            height: 440px;
            background: linear-gradient(135deg, #E8DCC8 0%, #DDCFB0 30%, #C8D8B8 70%, #D8CFB8 100%);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            overflow: hidden;
        }
        .habitat-map::before {
            content: '';
            position: absolute; inset: 0;
            background:
                radial-gradient(ellipse at 20% 30%, rgba(255,252,245,0.3) 0%, transparent 50%),
                radial-gradient(ellipse at 70% 60%, rgba(255,252,245,0.2) 0%, transparent 50%);
            pointer-events: none;
            z-index: 1;
        }
        .habitat-map::after {
            content: '';
            position: absolute; inset: 0;
            pointer-events: none; z-index: 0;
            opacity: 0.04;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
        }

        .zone-node {
            position: absolute; transform: translate(-50%, -50%);
            text-align: center; cursor: pointer; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none; z-index: 2;
        }
        .zone-node:hover { transform: translate(-50%, -50%) scale(1.1); }
        .zone-node .zone-icon {
            width: 76px; height: 76px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto; border: 2.5px solid rgba(120,100,70,0.25);
            box-shadow: 0 2px 12px rgba(60,35,15,0.08);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }
        .zone-node:hover .zone-icon {
            box-shadow: 0 6px 20px rgba(60,35,15,0.15);
            border-color: rgba(120,100,70,0.45);
        }
        .zone-node .zone-icon img { width: 42px; height: 42px; object-fit: contain; }
        .zone-node .zone-name {
            font-size: 12px; font-weight: 700; color: var(--text);
            text-shadow: 0 1px 3px rgba(255,255,255,0.9); margin-top: 6px;
            letter-spacing: 0.5px;
        }
        .zone-node .zone-count {
            position: absolute; top: -4px; right: -4px;
            background: var(--accent-warm); color: white;
            min-width: 24px; height: 24px; border-radius: 12px;
            font-size: 11px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 2px 6px rgba(200,128,80,0.3);
            letter-spacing: 0.5px;
        }
        .zone-node.empty .zone-count { background: #C0B5A5; box-shadow: 0 2px 6px rgba(150,130,110,0.2); }

        /* ===== 区域详情 ===== */
        .zone-section {
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            padding: 24px 26px;
            margin-bottom: 18px;
            box-shadow: var(--shadow-xs);
            transition: all 0.3s ease;
            animation: fadeInUp 0.4s ease;
        }
        .zone-section:target {
            border-color: var(--accent-warm);
            box-shadow: 0 0 0 4px rgba(212,149,106,0.1);
        }
        .zone-section-header {
            display: flex; align-items: center; gap: 14px;
            margin-bottom: 18px; padding-bottom: 16px;
            border-bottom: 2px solid var(--border-light);
        }
        .zone-section-header .zs-icon { font-size: 34px; line-height: 1; }
        .zone-section-header .zs-name { font-size: 18px; font-weight: 700; color: var(--text); letter-spacing: 1px; }
        .zone-section-header .zs-count { font-size: 13px; color: var(--text-secondary); font-weight: 500; }

        /* ===== 宠物小卡片 ===== */
        .pet-card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(270px, 1fr));
            gap: 14px;
        }
        .pet-card {
            display: flex; align-items: center; gap: 14px;
            padding: 16px 18px;
            border-radius: var(--radius);
            border: 1px solid var(--border-light);
            text-decoration: none; color: inherit;
            transition: all var(--transition);
            background: #FCFAF6;
            position: relative;
            overflow: hidden;
        }
        .pet-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 3px; height: 100%;
            background: var(--accent-green);
            opacity: 0;
            transition: opacity var(--transition);
            border-radius: 0 2px 2px 0;
        }
        .pet-card:hover {
            border-color: var(--border-warm);
            background: var(--card-hover);
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }
        .pet-card:hover::before { opacity: 0.6; }
        .pet-card .pc-emoji {
            width: 58px; height: 58px;
            border-radius: var(--radius-sm);
            flex-shrink: 0;
            background: linear-gradient(135deg, #F5F0E8, #EDE5D5);
            display: flex; align-items: center; justify-content: center;
            font-size: 34px;
        }
        .pet-card .pc-info { flex: 1; min-width: 0; }
        .pet-card .pc-name { font-size: 15px; font-weight: 700; color: var(--text); letter-spacing: 0.5px; }
        .pet-card .pc-species { font-size: 12px; color: var(--text-secondary); margin-top: 1px; }
        .pet-card .pc-stats {
            display: flex; gap: 6px; margin-top: 6px; flex-wrap: wrap; align-items: center;
        }
        .pc-stat {
            font-size: 11px; color: var(--text-secondary);
            background: #F5F0E8; padding: 2px 8px; border-radius: 6px;
            font-weight: 500;
        }
        .pet-card .pc-level {
            background: linear-gradient(135deg, var(--accent-warm), #E0A870);
            color: #fff;
            padding: 4px 12px; border-radius: 12px;
            font-size: 12px; font-weight: 700; flex-shrink: 0;
            box-shadow: 0 2px 6px rgba(200,128,80,0.2);
            letter-spacing: 0.5px;
        }

        .empty-zone {
            text-align: center; padding: 24px; color: var(--text-muted);
            font-size: 14px;
        }

        @media (max-width: 768px) {
            .habitat-map { height: 320px; border-radius: 16px; }
            .zone-node .zone-icon { width: 56px; height: 56px; }
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
            <div class="pet-count-bar">
                <% for (int i = 0; i < maxPets; i++) { %>
                <span class="count-dot <%= i < petCount ? "filled" : "empty" %>"></span>
                <% } %>
                <span style="margin-left:6px;font-weight:600;"><%= petCount %> / <%= maxPets %></span>
            </div>
        </div>

        <% if (error != null) { %><div class="alert alert-error"><%= error %></div><% } %>
        <% if (success != null) { %><div class="alert alert-success"><%= success.replace("\n", "<br>") %></div><% } %>
        <% if (newRegionMsg != null) { %><div class="alert alert-info"><%= newRegionMsg %></div><% } %>

        <!-- 栖息地地图 -->
        <div class="habitat-map">
            <% for (HabitatZone z : zones) {
                List<Pet> zp = zonePets.get(z.id());
                int cnt = zp != null ? zp.size() : 0;
            %>
            <a href="#zone-<%= z.id() %>" class="zone-node <%= cnt == 0 ? "empty" : "" %>"
               style="top:<%= z.topPct() %>%; left:<%= z.leftPct() %>%;">
                <div class="zone-icon" style="background:<%= z.color() %>20;">
                    <span style="font-size:30px;"><%= z.emoji() %></span>
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
                    CompanionTrait ct = CompanionTrait.forPet(p);
                %>
                <a href="<%= request.getContextPath() %>/pet?action=interact&petId=<%= p.getId() %>" class="pet-card">
                    <span class="pc-emoji"><%= p.getEmoji() %></span>
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
                        <div style="margin-top:5px;">
                            <span style="font-size:10px; background:#F2EDE0; color:var(--text-secondary); padding:3px 9px; border-radius:8px; font-weight:600;">
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
                    target.style.borderColor = '#D4956A';
                    target.style.boxShadow = '0 0 0 4px rgba(212,149,106,0.12)';
                    setTimeout(function() {
                        target.style.borderColor = '#E8DDCC';
                        target.style.boxShadow = '';
                    }, 1800);
                }
            });
        });
    </script>
</body>
</html>
