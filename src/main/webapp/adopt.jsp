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
            background-image:
                radial-gradient(ellipse at 30% 30%, rgba(180,150,110,0.06) 0%, transparent 55%),
                radial-gradient(ellipse at 70% 70%, rgba(140,170,120,0.05) 0%, transparent 55%);
        }
        .adopt-card {
            background: var(--card-bg); border-radius: var(--radius-xl);
            border: 1px solid var(--border); box-shadow: var(--shadow-xl);
            max-width: 480px; width: 100%; overflow: hidden;
            animation: fadeInScale 0.45s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .adopt-header {
            background: linear-gradient(135deg, #F7F0E3, #F2E8D5);
            padding: 32px 28px; text-align: center;
            border-bottom: 1px solid var(--border-light);
        }
        .adopt-header .location-tag {
            display: inline-block; background: rgba(255,255,255,0.6);
            padding: 5px 16px; border-radius: 14px; font-size: 12px;
            font-weight: 700; color: var(--text-secondary); margin-bottom: 14px;
            letter-spacing: 0.5px;
        }
        .adopt-header .an-emoji { font-size: 80px; filter: drop-shadow(0 4px 12px rgba(120,80,40,0.15)); }
        .adopt-header .an-name { font-size: 26px; font-weight: 700; color: var(--text); margin-top: 10px; letter-spacing: 1px; }
        .adopt-header .an-sub { font-size: 14px; color: var(--text-secondary); margin-top: 4px; font-weight: 500; }
        .adopt-body { padding: 22px 26px; }
        .adopt-body .desc { font-size: 14px; color: var(--text-secondary); line-height: 1.7; margin-bottom: 14px; text-align: center; }
        .attr-row { display: flex; gap: 12px; margin-bottom: 20px; }
        .attr-box {
            flex: 1; text-align: center;
            background: linear-gradient(135deg, #FDF9F2, #FAF5E8);
            border-radius: var(--radius); padding: 16px 8px; border: 2px solid var(--border-light);
            transition: all var(--transition);
        }
        .attr-box:hover { border-color: var(--border-warm); transform: translateY(-1px); }
        .attr-box .val { font-size: 20px; font-weight: 700; color: var(--text); }
        .attr-box .name { font-size: 11px; color: var(--text-secondary); margin-top: 4px; font-weight: 500; }
        .attr-box .hint { font-size: 10px; color: var(--text-muted); margin-top: 4px; }
        .encounter-fb {
            background: linear-gradient(135deg, #FDF9F2, #FAF5E8);
            border-radius: var(--radius); padding: 14px 18px;
            margin-bottom: 18px; font-size: 13px; color: var(--text-secondary);
            border-left: 4px solid var(--accent-warm); white-space: pre-line; line-height: 1.7;
        }
        .name-group { margin-bottom: 18px; }
        .name-group label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: var(--text); }
        .name-group input {
            width: 100%; padding: 12px 16px; border: 2px solid var(--border);
            border-radius: var(--radius); font-size: 15px; outline: none;
            font-family: inherit; color: var(--text); background: #FDFBF6;
            transition: all var(--transition);
        }
        .name-group input:focus { border-color: var(--accent-warm); box-shadow: 0 0 0 3px rgba(212,149,106,0.1); }
        .btn-group { display: flex; gap: 12px; }
        .btn-adopt { background: var(--accent-warm); color: #fff; border-color: var(--accent-warm); font-weight: 700; letter-spacing: 1px; }
        .btn-adopt:hover { background: var(--accent-warm-hover); }
        .btn-release { background: #F5F0E8; color: var(--text-secondary); border-color: var(--border-light); font-weight: 500; }
    </style>
</head>
<body>
    <div class="adopt-card">
        <div class="adopt-header">
            <span class="location-tag"><%= regionName %></span>
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
