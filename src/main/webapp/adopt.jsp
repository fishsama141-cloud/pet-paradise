<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    PetSpecies species = (PetSpecies) request.getAttribute("species");
    int[] stats = (int[]) request.getAttribute("rolledStats");
    String regionName = (String) request.getAttribute("regionName");
    String encounterFeedback = (String) request.getAttribute("encounterFeedback");
    if (species == null || stats == null) { response.sendRedirect(request.getContextPath() + "/map"); return; }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎉 互动成功 - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #fff8f0 0%, #fff5e6 100%);
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            padding: 20px; color: #5d4037;
        }
        .card {
            background: white; border-radius: 28px;
            box-shadow: 0 20px 60px rgba(255, 140, 66, 0.3);
            max-width: 480px; width: 100%; overflow: hidden;
            animation: slideUp 0.6s ease;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .card-top {
            background: linear-gradient(135deg, #ffd93d, #ff8c42);
            padding: 32px 24px; text-align: center; color: white;
        }
        .card-top .badge {
            display: inline-block; background: rgba(255,255,255,0.3);
            padding: 4px 16px; border-radius: 14px; font-size: 13px;
            font-weight: 600; margin-bottom: 12px;
        }
        .card-top .emoji {
            font-size: 80px; display: block;
            animation: float 3s ease-in-out infinite;
        }
        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            25% { transform: translateY(-8px) rotate(-5deg); }
            75% { transform: translateY(-8px) rotate(5deg); }
        }
        .card-top .species-name { font-size: 26px; font-weight: 700; margin-top: 8px; }
        .card-top .location { font-size: 13px; opacity: 0.9; margin-top: 2px; }
        .card-body { padding: 20px 28px; }
        .card-body .desc { font-size: 14px; color: #8d6e63; line-height: 1.6; margin-bottom: 12px; text-align: center; }

        /* 新属性展示 */
        .attr-row {
            display: flex; gap: 12px; margin-bottom: 18px;
        }
        .attr-box {
            flex: 1; text-align: center; background: #fff8f0;
            border-radius: 12px; padding: 14px 8px;
        }
        .attr-box .icon { font-size: 24px; display: block; margin-bottom: 4px; }
        .attr-box .val { font-size: 18px; font-weight: 700; color: #e65100; }
        .attr-box .name { font-size: 11px; color: #a1887f; margin-top: 2px; }
        .attr-box .hint { font-size: 10px; color: #b8956a; margin-top: 2px; }

        /* 相遇反馈 */
        .encounter-fb {
            background: #f5f0e8; border-radius: 12px; padding: 12px 16px;
            margin-bottom: 18px; font-size: 13px; color: #6d5a3a;
            border-left: 3px solid #ff8c42; white-space: pre-line; line-height: 1.6;
        }

        /* 名字输入 */
        .name-input-group { margin-bottom: 18px; }
        .name-input-group label { display: block; font-weight: 600; margin-bottom: 6px; font-size: 14px; }
        .name-input-group input {
            width: 100%; padding: 12px 16px; border: 2px solid #ffe0b2;
            border-radius: 12px; font-size: 15px; color: #5d4037; outline: none;
            transition: all 0.3s;
        }
        .name-input-group input:focus {
            border-color: #ff8c42; box-shadow: 0 0 0 3px rgba(255,140,66,0.15);
        }

        /* 按钮 */
        .btn-group { display: flex; gap: 12px; }
        .btn {
            flex: 1; padding: 14px; border: none; border-radius: 14px;
            font-size: 16px; font-weight: 700; cursor: pointer; transition: all 0.3s;
            font-family: inherit; text-align: center;
        }
        .btn-adopt {
            background: linear-gradient(135deg, #ff8c42, #ff6b6b); color: white;
        }
        .btn-adopt:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(255,140,66,0.4); }
        .btn-release {
            background: linear-gradient(135deg, #66bb6a, #43a047); color: white;
        }
        .btn-release:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(76,175,80,0.4); }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-top">
            <span class="badge">📍 <%= regionName %></span>
            <span class="emoji"><%= species.getEmoji() %></span>
            <div class="species-name"><%= species.getName() %></div>
            <div class="location">互动成功！它愿意跟你走了 ✨</div>
        </div>
        <div class="card-body">
            <p class="desc"><%= species.getDescription() %></p>

            <% if (encounterFeedback != null) { %>
            <div class="encounter-fb"><%= encounterFeedback %></div>
            <% } %>

            <!-- 新属性展示 -->
            <div class="attr-row">
                <div class="attr-box">
                    <span class="icon">&#x2764;</span>
                    <div class="val"><%= stats[0] %></div>
                    <div class="name">亲密度潜力</div>
                    <div class="hint">越高越容易建立关系</div>
                </div>
                <div class="attr-box">
                    <span class="icon">&#x1F91D;</span>
                    <div class="val"><%= stats[1] %></div>
                    <div class="name">默契度潜力</div>
                    <div class="hint">越高配合越默契</div>
                </div>
                <div class="attr-box">
                    <span class="icon">&#x1F3AD;</span>
                    <div class="val"><%= new String[]{"活泼","胆小","温顺"}[stats[2]] %></div>
                    <div class="name">性格</div>
                    <div class="hint">影响卡牌倾向</div>
                </div>
            </div>

            <!-- 收养表单 -->
            <form method="post" action="<%= request.getContextPath() %>/map">
                <input type="hidden" name="action" value="adopt">
                <input type="hidden" name="choice" value="adopt">
                <input type="hidden" name="species" value="<%= species.getName() %>">
                <input type="hidden" name="emoji" value="<%= species.getEmoji() %>">
                <input type="hidden" name="region" value="<%= regionName %>">
                <input type="hidden" name="description" value="<%= species.getDescription() %>">

                <div class="name-input-group">
                    <label>✨ 给你的新伙伴取个名字吧</label>
                    <input type="text" name="name" value="<%= species.getName() %>" placeholder="输入宠物名字" maxlength="20" required>
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn btn-adopt">💝 收养ta！</button>
                    <button type="button" class="btn btn-release" onclick="releasePet()">🌿 放生ta</button>
                </div>
            </form>

            <!-- 放生表单 -->
            <form id="releaseForm" method="post" action="<%= request.getContextPath() %>/map" style="display:none;">
                <input type="hidden" name="action" value="adopt">
                <input type="hidden" name="choice" value="release">
                <input type="hidden" name="species" value="<%= species.getName() %>">
                <input type="hidden" name="region" value="<%= regionName %>">
            </form>
        </div>
    </div>

    <script>
        function releasePet() {
            if (confirm('确定要放生<%= species.getName() %>吗？\n\n放生后，你现有的宠物会获得亲密度+8和默契度+5的祝福。')) {
                document.getElementById('releaseForm').submit();
            }
        }
    </script>
</body>
</html>
