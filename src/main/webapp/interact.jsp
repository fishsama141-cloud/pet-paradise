<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    Pet pet = (Pet) request.getAttribute("pet");
    if (pet == null) { response.sendRedirect(request.getContextPath() + "/dashboard"); return; }
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    int expPercent = (int)((pet.getExperience() % 100) / 100.0 * 100);

    List<String[]> foodInventory = (List<String[]>) request.getAttribute("foodInventory");
    if (foodInventory == null) foodInventory = new ArrayList<>();
    String favFood = (String) request.getAttribute("favFood");
    String disFood = (String) request.getAttribute("disFood");
    boolean hasFood = !foodInventory.isEmpty();
    String petImg = pet.getImagePath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pet.getName() %> - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        .back-link { display: inline-block; color: var(--text-muted); text-decoration: none; font-weight: 500; margin-bottom: 16px; font-size: 14px; }
        .back-link:hover { color: var(--text-secondary); }
        .pet-hero {
            background: var(--card-bg); border-radius: var(--radius-lg); padding: 28px; margin-bottom: 20px;
            border: 1px solid var(--border); box-shadow: var(--shadow-xs); text-align: center;
        }
        .pet-hero img { width: 110px; height: 110px; object-fit: contain; display: block; margin: 0 auto; }
        .pet-hero .ph-emoji { font-size: 80px; display: none; }
        .pet-hero .ph-name { font-size: 26px; font-weight: 600; color: var(--text); margin-top: 8px; }
        .pet-hero .ph-species { font-size: 14px; color: var(--text-secondary); }
        .ph-trait-box {
            margin-top: 10px; padding: 10px 16px; background: #FDF9F2;
            border-radius: var(--radius); border: 1px solid var(--border-light);
            display: inline-block; text-align: left;
        }
        .food-pref { margin-top: 8px; font-size: 12px; color: var(--text-muted); }

        .two-col { display: flex; gap: 16px; margin-bottom: 20px; }
        .two-col .card { flex: 1; min-width: 0; }
        .log-box { max-height: 300px; overflow-y: auto; }
        .log-entry { padding: 7px 0; border-bottom: 1px solid var(--border-light); font-size: 13px; color: var(--text-secondary); }
        .log-entry:last-child { border-bottom: none; }

        .status-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .status-item .s-label { font-size: 12px; font-weight: 500; color: var(--text-secondary); margin-bottom: 3px; }
        .status-item .s-num { font-size: 12px; color: var(--text-muted); float: right; }
        .attr-list { display: flex; gap: 10px; margin-top: 14px; }
        .attr-chip {
            flex: 1; text-align: center; background: #FDF9F2; border-radius: var(--radius);
            padding: 12px 8px; border: 1px solid var(--border-light);
        }
        .attr-chip .av { font-size: 18px; font-weight: 600; color: var(--text); }
        .attr-chip .an { font-size: 11px; color: var(--text-muted); }

        .effect-box {
            margin-top: 10px; padding: 10px 14px; background: #FDF9F2;
            border-radius: var(--radius); font-size: 11px; color: var(--text-secondary); line-height: 1.8;
        }

        .food-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 8px; margin-bottom: 14px; }
        .food-item {
            border: 1px solid var(--border-light); border-radius: var(--radius); padding: 12px;
            text-align: center; cursor: pointer; transition: all var(--transition); background: #FDFBF6;
        }
        .food-item:hover { border-color: #C5B8A0; background: #FAF7F0; }
        .food-item.selected { border-color: var(--accent-warm); background: #FDF5EC; }
        .food-like { border-color: #80A080 !important; background: #F0F5EC !important; }
        .food-like .food-hint { color: #6A8A5A; }
        .food-dislike { border-color: #C08070 !important; background: #FEF5F0 !important; }
        .food-dislike .food-hint { color: #B06040; }
        .food-item .food-emoji { font-size: 28px; display: block; margin-bottom: 2px; }
        .food-item .food-name { font-size: 13px; font-weight: 500; color: var(--text); }
        .food-item .food-qty { font-size: 11px; color: var(--text-muted); }
        .food-item .food-hint { font-size: 10px; margin-top: 2px; font-weight: 600; }
        .no-food { text-align: center; padding: 16px; color: var(--text-muted); font-size: 14px; }

        .btn-feed { width: 100%; padding: 14px; border: none; border-radius: var(--radius); font-size: 16px; font-weight: 600; cursor: pointer; font-family: inherit; background: var(--accent-warm); color: #fff; }
        .btn-feed:disabled { background: #D5C8B5; cursor: not-allowed; }
        .section-title { font-size: 17px; font-weight: 600; color: var(--text); margin-bottom: 14px; }

        .play-link {
            display: flex; align-items: center; justify-content: center; gap: 12px;
            padding: 20px; background: #FDF9F2; border: 1px solid var(--border-light);
            border-radius: var(--radius); text-decoration: none; color: var(--text);
            font-weight: 600; font-size: 16px; transition: all var(--transition); margin-bottom: 16px;
        }
        .play-link:hover { border-color: #C5B8A0; background: #FAF5EC; }
        .play-link .pl-icon { font-size: 28px; }

        .section { background: var(--card-bg); border-radius: var(--radius-lg); border: 1px solid var(--border); padding: 20px 24px; margin-bottom: 16px; box-shadow: var(--shadow-xs); }

        @media (max-width: 600px) {
            .two-col { flex-direction: column; }
            .food-grid { grid-template-columns: repeat(2, 1fr); }
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
            <a href="<%= request.getContextPath() %>/encyclopedia">图鉴</a>
            <a href="<%= request.getContextPath() %>/help">帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">退出</a>
        </div>
    </nav>

    <div class="main">
        <a href="<%= request.getContextPath() %>/dashboard" class="back-link">← 返回宠物列表</a>

        <% if (success != null) { %><div class="alert alert-success"><%= success %></div><% } %>
        <% if (error != null) { %><div class="alert alert-error"><%= error %></div><% } %>

        <!-- 宠物展示 -->
        <div class="pet-hero">
            <img src="<%= request.getContextPath() %>/assets/images/animals/<%= petImg != null ? petImg : "" %>"
                 alt="<%= pet.getName() %>"
                 onerror="this.style.display='none';this.nextElementSibling.style.display='block';">
            <span class="ph-emoji"><%= pet.getEmoji() %></span>
            <div class="ph-name"><%= pet.getName() %></div>
            <div class="ph-species"><%= pet.getSpecies() %> · <%= pet.getRegion() %> · Lv.<%= pet.getLevel() %></div>
            <% if (pet.getRarityLabel() != null && !pet.getRarityLabel().isEmpty()) { %>
            <span class="tag tag-<%= pet.getRarity() != null ? pet.getRarity() : "common" %>" style="margin-top:6px;"><%= pet.getRarityLabel() %></span>
            <% } %>
            <%
                CompanionTrait ct = CompanionTrait.forPet(pet);
                if (ct != null) {
            %>
            <div class="ph-trait-box">
                <div style="font-size:11px;color:var(--text-muted);margin-bottom:2px;">⭐ 同行特性</div>
                <div style="font-size:15px;font-weight:600;"><%= ct.getName() %></div>
                <div style="font-size:12px;color:var(--text-secondary);"><%= ct.getDescription() %></div>
                <div style="font-size:10px;color:var(--text-muted);">定位：<%= ct.getPositioning() %> · <%= ct.getType().label %></div>
            </div>
            <% } %>
            <% if (favFood != null) { %>
            <div class="food-pref">❤ 最爱：<%= FoodDef.getEmoji(favFood) %> <%= favFood %>
                <% if (disFood != null) { %> · 👎 讨厌：<%= FoodDef.getEmoji(disFood) %> <%= disFood %><% } %></div>
            <% } %>
        </div>

        <!-- 状态 + 日志 -->
        <div class="two-col">
            <div class="card">
                <div class="section-title">状态详情</div>
                <div class="status-grid">
                    <div class="status-item">
                        <div class="s-label">饱食度<span class="s-num"><%= pet.getHunger() %>/100</span></div>
                        <div class="bar-outer"><div class="bar-inner" style="width:<%= pet.getHunger() %>%; background:#D0A870;"></div></div>
                    </div>
                    <div class="status-item">
                        <div class="s-label">心情值<span class="s-num"><%= pet.getMood() %>/100</span></div>
                        <div class="bar-outer"><div class="bar-inner" style="width:<%= pet.getMood() %>%; background:#C08070;"></div></div>
                    </div>
                    <div class="status-item" style="grid-column:1/-1;">
                        <div class="s-label">经验值<span class="s-num"><%= pet.getExperience() %> / <%= pet.getLevel() * 100 %></span></div>
                        <div class="bar-outer"><div class="bar-inner" style="width:<%= expPercent %>%; background:#C5B090;"></div></div>
                    </div>
                </div>
                <div class="attr-list">
                    <div class="attr-chip"><div class="av"><%= pet.getAffinity() %></div><div class="an">❤ 亲密度</div></div>
                    <div class="attr-chip"><div class="av"><%= pet.getBond() %></div><div class="an">🤝 默契度</div></div>
                    <div class="attr-chip"><div class="av"><%= pet.getPersonality() %></div><div class="an">🎭 性格</div></div>
                </div>
                <%
                    String affHint = pet.getAffinity() >= 80 ? "深度信任 · 喂食+50%饱食" :
                        pet.getAffinity() >= 50 ? "亲密无间 · 喂食+30%饱食" :
                        pet.getAffinity() >= 30 ? "友好关系 · 喂食+15%饱食" : "初次相识 · 喂食无加成";
                    String moodHint = pet.getMood() >= 80 ? "兴高采烈 · 玩耍奖励x1.3" :
                        pet.getMood() >= 50 ? "心情平稳 · 玩耍奖励x1.0" :
                        pet.getMood() >= 30 ? "心情低落 · 玩耍奖励x0.8" : "心情沮丧 · 玩耍奖励x0.6";
                    String bondHint = pet.getBond() >= 80 ? "心有灵犀 · 遭遇特性x1.4" :
                        pet.getBond() >= 50 ? "配合默契 · 遭遇特性x1.2" :
                        pet.getBond() >= 30 ? "初步磨合 · 遭遇特性x1.1" : "尚不熟悉 · 遭遇无加成";
                %>
                <div class="effect-box">
                    <div style="font-weight:600;margin-bottom:2px;">属性效果（<a href="<%= request.getContextPath() %>/help" style="color:var(--accent-warm);">查看完整说明</a>）</div>
                    <div>❤ <%= affHint %></div>
                    <div>😊 <%= moodHint %></div>
                    <div>🤝 <%= bondHint %></div>
                </div>
            </div>

            <div class="card">
                <div class="section-title">活动日志</div>
                <div class="log-box">
                    <%
                        List<String> logs = pet.getActivityLog();
                        if (logs == null || logs.isEmpty()) {
                    %><div class="log-entry">还没有活动记录，快和你的宠物互动吧~</div><%
                    } else {
                        for (String log : logs) {
                    %><div class="log-entry"><%= log %></div><% } } %>
                </div>
            </div>
        </div>

        <!-- 喂食 -->
        <div class="section">
            <div class="section-title">喂食 — 选择食物</div>
            <% if (!hasFood) { %>
            <div class="no-food">
                <p>背包里还没有食物……</p>
                <p>去 <a href="<%= request.getContextPath() %>/map" style="color:var(--accent-warm);font-weight:600;">世界地图</a> 探险获取食物吧</p>
            </div>
            <% } else { %>
            <form method="post" action="<%= request.getContextPath() %>/pet" id="feedForm">
                <input type="hidden" name="action" value="feed">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <input type="hidden" name="foodName" id="selectedFoodName" value="">
                <input type="hidden" name="foodEmoji" id="selectedFoodEmoji" value="">

                <div class="food-grid">
                    <% for (String[] f : foodInventory) {
                        String fName = f[0]; String fEmoji = f[1]; int qty = Integer.parseInt(f[2]);
                        String prefClass = ""; String prefHint = "";
                        if (fName.equals(favFood)) { prefClass = "food-like"; prefHint = "❤ 最爱"; }
                        else if (fName.equals(disFood)) { prefClass = "food-dislike"; prefHint = "👎 讨厌"; }
                    %>
                    <div class="food-item <%= prefClass %>" onclick="selectFood(this, '<%= fName %>', '<%= fEmoji %>')">
                        <span class="food-emoji"><%= fEmoji %></span>
                        <div class="food-name"><%= fName %></div>
                        <div class="food-qty">x<%= qty %></div>
                        <% if (!prefHint.isEmpty()) { %><div class="food-hint"><%= prefHint %></div><% } %>
                    </div>
                    <% } %>
                </div>
                <button type="submit" class="btn-feed" id="feedBtn" disabled>选择一个食物来喂食</button>
            </form>
            <% } %>
        </div>

        <!-- 玩耍 -->
        <a href="<%= request.getContextPath() %>/play?petId=<%= pet.getId() %>" class="play-link">
            <span class="pl-icon">⚽</span>
            <div>
                <div>玩耍</div>
                <div style="font-size:12px;color:var(--text-muted);font-weight:400;">猜拳 · 打砖块 · 翻牌对对碰</div>
            </div>
        </a>

        <!-- 放归 -->
        <%
            Integer petCount = (Integer) request.getAttribute("petCount");
            boolean canRelease = petCount != null && petCount > 1;
        %>
        <div style="text-align:center;">
            <% if (canRelease) { %>
            <form method="post" action="<%= request.getContextPath() %>/pet" onsubmit="return confirm('确定要放生「<%= pet.getName() %>」吗？放生后其他宠物将获得亲密度+8和默契度+5的祝福。此操作不可撤销！')">
                <input type="hidden" name="action" value="release">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <button type="submit" class="btn" style="border-color:#D0B0A0; color:#A07060;">放生这只宠物</button>
            </form>
            <% } else { %>
            <p style="color:var(--text-muted);font-size:13px;">这是你唯一的伙伴，不能放生哦</p>
            <% } %>
        </div>
    </div>

    <script>
        function selectFood(el, name, emoji) {
            document.querySelectorAll('.food-item').forEach(function(item) { item.classList.remove('selected'); });
            el.classList.add('selected');
            document.getElementById('selectedFoodName').value = name;
            document.getElementById('selectedFoodEmoji').value = emoji;
            var btn = document.getElementById('feedBtn');
            btn.disabled = false;
            btn.textContent = emoji + ' 喂食「' + name + '」';
        }
    </script>
</body>
</html>
