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
    <title>互动成功 - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        body {
            display: flex; align-items: center; justify-content: center;
            min-height: 100vh; padding: 20px;
        }
        .adopt-card {
            background: var(--card-bg); border-radius: var(--radius-lg);
            border: 1px solid var(--border); box-shadow: var(--shadow-lg);
            max-width: 460px; width: 100%; overflow: hidden;
            animation: fadeIn 0.4s ease;
        }
        .adopt-header {
            background: #F5EDE0; padding: 28px 24px; text-align: center;
            border-bottom: 1px solid var(--border-light);
        }
        .adopt-header .location-tag {
            display: inline-block; background: #EDE5D5; padding: 4px 14px;
            border-radius: 12px; font-size: 12px; font-weight: 600; color: var(--text-secondary);
            margin-bottom: 12px;
        }
        .adopt-header img {
            width: 100px; height: 100px; object-fit: contain;
            display: block; margin: 0 auto;
        }
        .adopt-header .an-emoji { font-size: 72px; display: none; }
        .adopt-header .an-name { font-size: 24px; font-weight: 600; color: var(--text); margin-top: 8px; }
        .adopt-header .an-sub { font-size: 13px; color: var(--text-secondary); margin-top: 2px; }
        .adopt-body { padding: 20px 24px; }
        .adopt-body .desc { font-size: 14px; color: var(--text-secondary); line-height: 1.6; margin-bottom: 12px; text-align: center; }
        .attr-row { display: flex; gap: 10px; margin-bottom: 18px; }
        .attr-box {
            flex: 1; text-align: center; background: #FDF9F2;
            border-radius: var(--radius); padding: 14px 8px; border: 1px solid var(--border-light);
        }
        .attr-box .val { font-size: 18px; font-weight: 600; color: var(--text); }
        .attr-box .name { font-size: 11px; color: var(--text-secondary); margin-top: 2px; }
        .attr-box .hint { font-size: 10px; color: var(--text-muted); margin-top: 2px; }
        .encounter-fb {
            background: #FDF9F2; border-radius: var(--radius); padding: 12px 16px;
            margin-bottom: 16px; font-size: 13px; color: var(--text-secondary);
            border-left: 3px solid #C5B8A0; white-space: pre-line; line-height: 1.6;
        }
        .name-group { margin-bottom: 16px; }
        .name-group label { display: block; font-weight: 500; margin-bottom: 6px; font-size: 14px; color: var(--text); }
        .name-group input {
            width: 100%; padding: 11px 14px; border: 1px solid var(--border);
            border-radius: var(--radius); font-size: 15px; outline: none;
            font-family: inherit; color: var(--text); background: #FDFBF6;
        }
        .name-group input:focus { border-color: #C5B8A0; }
        .btn-group { display: flex; gap: 10px; }
        .btn-adopt { background: var(--accent-warm); color: #fff; border-color: var(--accent-warm); font-weight: 600; }
        .btn-release { background: #F5F0E8; color: var(--text-secondary); border-color: var(--border-light); }
    </style>
</head>
<body>
    <div class="adopt-card">
        <div class="adopt-header">
            <span class="location-tag"><%= regionName %></span>
            <img src="<%= request.getContextPath() %>/assets/images/animals/<%= species.getImagePath() %>"
                 alt="<%= species.getName() %>"
                 onerror="this.style.display='none';this.nextElementSibling.style.display='block';">
            <span class="an-emoji"><%= species.getEmoji() %></span>
            <div class="an-name"><%= species.getName() %></div>
            <div class="an-sub">互动成功！它愿意跟你走了</div>
        </div>
        <div class="adopt-body">
            <p class="desc"><%= species.getDescription() %></p>

            <% if (encounterFeedback != null) { %>
            <div class="encounter-fb"><%= encounterFeedback %></div>
            <% } %>

            <div class="attr-row">
                <div class="attr-box">
                    <div class="val"><%= stats[0] %></div>
                    <div class="name">❤ 亲密度潜力</div>
                    <div class="hint">越高越容易建立关系</div>
                </div>
                <div class="attr-box">
                    <div class="val"><%= stats[1] %></div>
                    <div class="name">🤝 默契度潜力</div>
                    <div class="hint">越高配合越默契</div>
                </div>
                <div class="attr-box">
                    <div class="val"><%= new String[]{"活泼","胆小","温顺"}[stats[2]] %></div>
                    <div class="name">🎭 性格</div>
                    <div class="hint">影响互动倾向</div>
                </div>
            </div>

            <form method="post" action="<%= request.getContextPath() %>/map">
                <input type="hidden" name="action" value="adopt">
                <input type="hidden" name="choice" value="adopt">
                <input type="hidden" name="species" value="<%= species.getName() %>">
                <input type="hidden" name="emoji" value="<%= species.getEmoji() %>">
                <input type="hidden" name="region" value="<%= regionName %>">
                <input type="hidden" name="description" value="<%= species.getDescription() %>">

                <div class="name-group">
                    <label>给你的新伙伴取个名字</label>
                    <input type="text" name="name" value="<%= species.getName() %>" placeholder="输入宠物名字" maxlength="20" required>
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn btn-adopt" style="flex:1;">收养ta</button>
                    <button type="button" class="btn btn-release" style="flex:1;" onclick="releasePet()">放生ta</button>
                </div>
            </form>

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
