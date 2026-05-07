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
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎮 互动 - <%= pet.getName() %> - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #FFF8F0 0%, #FFF5E6 30%, #FFF0E0 100%);
            min-height: 100vh; color: #5D4037;
        }
        .nav {
            background: linear-gradient(135deg, #FF8C42, #FF6B6B);
            padding: 16px 28px; display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 4px 20px rgba(255, 140, 66, 0.3);
        }
        .nav .brand { font-size: 22px; font-weight: 700; color: white; text-decoration: none; }
        .nav-links { display: flex; gap: 12px; align-items: center; }
        .nav-links a { color: white; text-decoration: none; padding: 8px 16px; border-radius: 20px; font-weight: 600; font-size: 14px; background: rgba(255,255,255,0.15); transition: all 0.3s; }
        .nav-links a:hover { background: rgba(255,255,255,0.3); }
        .main { max-width: 900px; margin: 0 auto; padding: 24px 20px; }
        .back-link { display: inline-block; color: #FF8C42; text-decoration: none; font-weight: 600; margin-bottom: 16px; font-size: 14px; }
        .back-link:hover { text-decoration: underline; }
        .pet-hero {
            background: white; border-radius: 24px; padding: 28px; box-shadow: 0 8px 32px rgba(255, 140, 66, 0.15);
            text-align: center; margin-bottom: 24px; position: relative; overflow: hidden;
        }
        .pet-hero::before {
            content: ''; position: absolute; top: -40px; right: -40px;
            width: 120px; height: 120px; background: #FFF3E0; border-radius: 50%; z-index: 0;
        }
        .pet-emoji { font-size: 100px; display: block; position: relative; z-index: 1; animation: bounce 2s ease-in-out infinite; }
        @keyframes bounce { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-12px); } }
        .pet-name { font-size: 28px; font-weight: 700; color: #E65100; margin-top: 8px; position: relative; z-index: 1; }
        .pet-level-badge { display: inline-block; background: linear-gradient(135deg, #FFD93D, #FFC107); color: #5D4037; padding: 6px 20px; border-radius: 20px; font-weight: 700; font-size: 15px; margin-top: 8px; }
        .pet-desc { color: #8D6E63; font-size: 14px; margin-top: 8px; }
        .alert-success { background: #E8F5E9; color: #2E7D32; padding: 12px 20px; border-radius: 14px; margin-bottom: 16px; font-weight: 600; border-left: 4px solid #66BB6A; animation: fadeIn 0.5s; }
        .alert-error { background: #FFF0F0; color: #C62828; padding: 12px 20px; border-radius: 14px; margin-bottom: 16px; font-weight: 600; border-left: 4px solid #EF5350; animation: fadeIn 0.5s; }
        .rarity-badge { display: inline-block; padding: 4px 14px; border-radius: 12px; font-size: 13px; font-weight: 700; margin-top: 6px; background: linear-gradient(135deg, #FFD93D, #FFC107); color: #5D4037; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }

        /* Section */
        .section { background: white; border-radius: 20px; padding: 22px; box-shadow: 0 4px 16px rgba(0,0,0,0.06); margin-bottom: 20px; }
        .section h3 { color: #E65100; margin-bottom: 14px; font-size: 18px; }

        /* Two-column: status + log side by side */
        .two-col { display: flex; gap: 20px; margin-bottom: 20px; }
        .two-col .section { flex: 1; min-width: 0; margin-bottom: 0; }
        .section-log .log-box { max-height: 380px; overflow-y: auto; }

        /* Food inventory */
        .food-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 10px; margin-bottom: 16px; }
        .food-item {
            border: 2px solid #e0e0e0; border-radius: 14px; padding: 12px; text-align: center;
            cursor: pointer; transition: all 0.3s; background: #fafafa;
        }
        .food-item:hover { transform: translateY(-3px); box-shadow: 0 6px 18px rgba(0,0,0,0.1); }
        .food-item input { display: none; }
        .food-item.selected { border-color: #FF8C42; background: #FFF3E0; }
        .food-item .food-emoji { font-size: 32px; display: block; margin-bottom: 4px; }
        .food-item .food-name { font-size: 14px; font-weight: 700; color: #5D4037; }
        .food-item .food-qty { font-size: 12px; color: #8D6E63; }
        .food-item .food-hint { font-size: 11px; margin-top: 4px; font-weight: 600; }
        .food-like { border-color: #66BB6A !important; background: #E8F5E9 !important; }
        .food-like .food-hint { color: #2E7D32; }
        .food-dislike { border-color: #EF5350 !important; background: #FFF0F0 !important; }
        .food-dislike .food-hint { color: #C62828; }
        .no-food { text-align: center; padding: 20px; color: #A1887F; font-size: 14px; }

        .btn-feed-submit {
            width: 100%; padding: 16px; border: none; border-radius: 14px;
            font-size: 18px; font-weight: 700; cursor: pointer; transition: all 0.3s;
            background: linear-gradient(135deg, #FF8C42, #FF6B6B); color: white;
            font-family: inherit; margin-bottom: 8px;
        }
        .btn-feed-submit:hover:not(:disabled) { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(255,140,66,0.4); }
        .btn-feed-submit:disabled { background: #ccc; cursor: not-allowed; }

        /* Play & Bathe buttons */
        .interact-buttons { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
        .interact-btn {
            background: white; border: none; border-radius: 20px; padding: 20px 16px;
            cursor: pointer; text-align: center; box-shadow: 0 4px 16px rgba(0,0,0,0.06);
            transition: all 0.3s; font-family: inherit;
        }
        .interact-btn:hover { transform: translateY(-4px); box-shadow: 0 10px 28px rgba(255, 140, 66, 0.25); }
        .interact-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
        .interact-btn .icon { font-size: 44px; display: block; margin-bottom: 8px; }
        .interact-btn .label { font-weight: 700; font-size: 16px; color: #5D4037; }
        .interact-btn .effect { font-size: 12px; color: #A1887F; margin-top: 4px; }
        .btn-play { border-top: 3px solid #FF6B6B; }
        .btn-bathe { border-top: 3px solid #42A5F5; }
        .bathe-limit { text-align: center; font-size: 12px; color: #A1887F; margin-top: 4px; }

        .btn-release {
            display: inline-block; padding: 12px 28px; border-radius: 14px;
            font-weight: 700; font-size: 14px; cursor: pointer; transition: all 0.3s;
            background: linear-gradient(135deg, #66bb6a, #43a047); color: white;
            border: none; font-family: inherit; margin-top: 16px;
        }
        .btn-release:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(76,175,80,0.4); }

        /* Status */
        .status-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .status-item .label { font-size: 12px; font-weight: 600; color: #8D6E63; margin-bottom: 4px; }
        .status-bar-wrap { height: 14px; background: #F5F5F5; border-radius: 7px; overflow: hidden; }
        .status-bar-fill { height: 100%; border-radius: 7px; transition: width 0.6s ease; }
        .bar-h { background: linear-gradient(90deg, #FF9800, #FFB74D); }
        .bar-m { background: linear-gradient(90deg, #FF6B6B, #FF8A80); }
        .bar-c { background: linear-gradient(90deg, #42A5F5, #64B5F6); }
        .exp-bar-wrap { grid-column: 1 / -1; margin-top: 4px; }
        .exp-bar-wrap .label { margin-bottom: 4px; }
        .exp-bar { height: 12px; background: #F5F5F5; border-radius: 6px; overflow: hidden; }
        .exp-fill { height: 100%; background: linear-gradient(90deg, #FFD93D, #FFC107); border-radius: 6px; transition: width 0.6s; }
        .attributes { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 16px; }
        .attr-item { background: #FFF8F0; border-radius: 14px; padding: 12px 18px; text-align: center; min-width: 70px; flex: 1; }
        .attr-item .attr-icon { font-size: 22px; display: block; }
        .attr-item .attr-val { font-size: 20px; font-weight: 700; color: #E65100; }
        .attr-item .attr-name { font-size: 11px; color: #A1887F; }
        .log-box { max-height: 260px; overflow-y: auto; }
        .log-entry { padding: 8px 0; border-bottom: 1px solid #F5F5F5; font-size: 13px; color: #6D4C41; font-family: "Consolas", monospace; }
        .log-entry:last-child { border-bottom: none; }

        @media (max-width: 600px) {
            .interact-buttons { grid-template-columns: 1fr; }
            .status-grid { grid-template-columns: 1fr; }
            .food-grid { grid-template-columns: repeat(2, 1fr); }
            .two-col { flex-direction: column; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">🐾 宠物乐园</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard">🏠 我的宠物</a>
            <a href="<%= request.getContextPath() %>/map">🗺️ 世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia">📖 图鉴</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">🚪 退出</a>
        </div>
    </nav>

    <div class="main">
        <a href="<%= request.getContextPath() %>/dashboard" class="back-link">← 返回宠物列表</a>

        <% if (success != null) { %><div class="alert-success">✅ <%= success %></div><% } %>
        <% if (error != null) { %><div class="alert-error">⚠️ <%= error %></div><% } %>

        <div class="pet-hero">
            <span class="pet-emoji"><%= pet.getEmoji() %></span>
            <div class="pet-name"><%= pet.getName() %></div>
            <div class="pet-level-badge">⭐ Lv.<%= pet.getLevel() %></div>
            <div class="pet-desc"><%= pet.getSpecies() %> · <%= pet.getRegion() %></div>
            <% if (pet.getRarityLabel() != null && !pet.getRarityLabel().isEmpty()) { %>
            <div class="rarity-badge"><%= pet.getRarityLabel() %></div>
            <% } %>
            <%
                CompanionTrait ct = CompanionTrait.forPet(pet);
                if (ct != null) {
            %>
            <div style="margin-top:10px; padding:10px 16px; background:linear-gradient(135deg, #2a3a10, #3a4a1a); border-radius:12px; border:1px solid #5a7a3a; display:inline-block; text-align:left;">
                <div style="font-size:12px; color:#90a070; margin-bottom:2px;">&#x2B50; 同行特性</div>
                <div style="font-size:16px; font-weight:700; color:#c0e080;"><%= ct.getName() %></div>
                <div style="font-size:12px; color:#a0b080; margin-top:2px;"><%= ct.getDescription() %></div>
                <div style="font-size:11px; color:#708050; margin-top:2px;">定位：<%= ct.getPositioning() %> · <%= ct.getType().label %></div>
                <% if (ct.getHiddenTendency() != null) { %>
                <div style="font-size:11px; color:#8090a0; margin-top:1px;">&#x1F512; 隐藏倾向：<%= ct.getHiddenTendency() %></div>
                <% } %>
            </div>
            <% } %>
            <% if (favFood != null) { %>
            <div style="margin-top:8px;font-size:12px;color:#8D6E63;">
                &#x2764; 最爱：<%= FoodDef.getEmoji(favFood) %> <%= favFood %>
                <% if (disFood != null) { %> &nbsp;|&nbsp; 👎 讨厌：<%= FoodDef.getEmoji(disFood) %> <%= disFood %><% } %>
            </div>
            <% } %>
        </div>

        <!-- Status + Activity log side by side -->
        <div class="two-col">
            <div class="section section-status">
                <h3>📊 状态详情</h3>
                <div class="status-grid">
                    <div class="status-item">
                        <div class="label">🍖 饱食度 <%= pet.getHunger() %>/100</div>
                        <div class="status-bar-wrap"><div class="status-bar-fill bar-h" style="width:<%= pet.getHunger() %>%"></div></div>
                    </div>
                    <div class="status-item">
                        <div class="label">&#x2764; 心情值 <%= pet.getMood() %>/100</div>
                        <div class="status-bar-wrap"><div class="status-bar-fill bar-m" style="width:<%= pet.getMood() %>%"></div></div>
                    </div>
                    <div class="status-item exp-bar-wrap">
                        <div class="label">⭐ 经验值 <%= pet.getExperience() %> / <%= pet.getLevel() * 100 %></div>
                        <div class="exp-bar"><div class="exp-fill" style="width:<%= expPercent %>%"></div></div>
                    </div>
                </div>
                <div class="attributes">
                    <div class="attr-item">
                        <span class="attr-icon">&#x2764;</span>
                        <div class="attr-val"><%= pet.getAffinity() %></div>
                        <div class="attr-name">亲密度</div>
                    </div>
                    <div class="attr-item">
                        <span class="attr-icon">&#x1F91D;</span>
                        <div class="attr-val"><%= pet.getBond() %></div>
                        <div class="attr-name">默契度</div>
                    </div>
                    <div class="attr-item">
                        <span class="attr-icon">&#x1F3AD;</span>
                        <div class="attr-val"><%= pet.getPersonality() %></div>
                        <div class="attr-name">性格</div>
                    </div>
                </div>
            </div>

            <div class="section section-log">
                <h3>📜 活动日志</h3>
                <div class="log-box">
                    <%
                        List<String> logs = pet.getActivityLog();
                        if (logs == null || logs.isEmpty()) {
                    %>
                    <div class="log-entry">还没有活动记录，快和你的宠物互动吧~</div>
                    <%
                    } else {
                        for (String log : logs) {
                    %>
                    <div class="log-entry"><%= log %></div>
                    <% } } %>
                </div>
            </div>
        </div>

        <!-- ===== 喂食（食物系统） ===== -->
        <div class="section">
            <h3>🍖 喂食 — 选择食物</h3>
            <% if (!hasFood) { %>
            <div class="no-food">
                <p>🎒 背包里还没有食物……</p>
                <p style="margin-top:4px;">去 <a href="<%= request.getContextPath() %>/map" style="color:#FF8C42;font-weight:700;">🗺️ 世界地图</a> 探险获取食物吧！</p>
            </div>
            <button class="btn-feed-submit" disabled>🎒 没有食物可以喂</button>
            <% } else { %>
            <form method="post" action="<%= request.getContextPath() %>/pet" id="feedForm">
                <input type="hidden" name="action" value="feed">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <input type="hidden" name="foodName" id="selectedFoodName" value="">
                <input type="hidden" name="foodEmoji" id="selectedFoodEmoji" value="">

                <div class="food-grid">
                    <% for (String[] f : foodInventory) {
                        String fName = f[0]; String fEmoji = f[1]; int qty = Integer.parseInt(f[2]);
                        String prefClass = "";
                        String prefHint = "";
                        if (fName.equals(favFood)) { prefClass = "food-like"; prefHint = "&#x2764; 最爱"; }
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

                <button type="submit" class="btn-feed-submit" id="feedBtn" disabled>🍖 选择一个食物来喂食</button>
            </form>
            <% } %>
        </div>

        <!-- ===== 玩耍 ===== -->
        <div class="interact-buttons">
            <a href="<%= request.getContextPath() %>/play?petId=<%= pet.getId() %>" style="text-decoration:none;">
                <div class="interact-btn btn-play" style="display:flex; flex-direction:column; align-items:center; padding: 24px 18px; border-radius: 16px; cursor:pointer;">
                    <span class="icon">⚽</span>
                    <span class="label">玩耍</span>
                    <span class="effect">&#x1F3AE; 猜拳 · 打砖块 · 翻牌对对碰</span>
                </div>
            </a>
        </div>

        <!-- Release -->
        <%
            Integer petCount = (Integer) request.getAttribute("petCount");
            boolean canRelease = petCount != null && petCount > 1;
        %>
        <div style="text-align:center;">
            <% if (canRelease) { %>
            <form method="post" action="<%= request.getContextPath() %>/pet" onsubmit="return confirmRelease()">
                <input type="hidden" name="action" value="release">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <button type="submit" class="btn-release">🌿 放生这只宠物</button>
            </form>
            <% } else { %>
            <p style="color:#A1887F; font-size:13px; margin-top:10px;">🐾 这是你唯一的伙伴，不能放生哦</p>
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

        function confirmRelease() {
            return confirm('确定要放生「<%= pet.getName() %>」吗？\n\n放生后它将离开你的宠物乐园，回到大自然中。其他宠物伙伴会获得亲密度+8和默契度+5的祝福。\n\n此操作不可撤销！');
        }
    </script>
</body>
</html>
