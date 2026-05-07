<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.servlet.MapServlet.*" %>
<%@ page import="org.example.pets.bean.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    AdventureStep step = (AdventureStep) request.getAttribute("step");
    String regionName = (String) request.getAttribute("regionName");
    Integer stepIndex = (Integer) request.getAttribute("stepIndex");
    Pet companion = (Pet) request.getAttribute("companion");
    if (stepIndex == null) stepIndex = 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🗺️ <%= regionName != null ? regionName : "冒险" %> - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 30%, #0f3460 60%, #1a1a2e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            color: #e0d5c1;
        }
        .card {
            background: linear-gradient(180deg, #2d2418 0%, #3d2f1f 100%);
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 40px rgba(255,140,66,0.1);
            max-width: 560px;
            width: 100%;
            overflow: hidden;
            border: 1px solid #5a3e28;
            animation: fadeIn 0.5s ease;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .card-top {
            background: linear-gradient(135deg, #4a3520, #5a3e28);
            padding: 20px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: 1px solid #6b4c32;
        }
        .card-top .region-icon { font-size: 36px; }
        .card-top .info { flex: 1; }
        .card-top .region-label { font-size: 12px; color: #b8956a; text-transform: uppercase; letter-spacing: 2px; }
        .card-top .region-name { font-size: 18px; font-weight: 700; color: #f0c27a; }
        .progress-bar {
            display: flex; gap: 6px; margin-top: 4px;
        }
        .progress-dot {
            width: 28px; height: 4px; background: #4a3520; border-radius: 2px;
        }
        .progress-dot.done { background: #f0c27a; }
        .progress-dot.current { background: #ff8c42; }
        .companion-tag {
            display: inline-block; background: #3a2a20; border: 1px solid #5a4a3a;
            border-radius: 10px; padding: 4px 10px; font-size: 13px; color: #c0b090;
            margin-top: 4px;
        }
        .card-body { padding: 28px 24px; }
        .step-title {
            font-size: 22px; font-weight: 700; color: #f0c27a; margin-bottom: 14px;
            display: flex; align-items: center; gap: 8px;
        }
        .step-text {
            font-size: 16px; line-height: 1.9; color: #c4b5a0;
            margin-bottom: 24px; background: rgba(0,0,0,0.2);
            padding: 18px; border-radius: 14px; border-left: 3px solid #6b4c32;
        }
        .choices { display: flex; flex-direction: column; gap: 12px; }
        .choice-btn {
            display: block; width: 100%; padding: 16px 20px;
            background: linear-gradient(135deg, #3d2f1f, #4a3520);
            border: 2px solid #5a3e28; border-radius: 14px;
            color: #e0d5c1; font-size: 15px; font-weight: 600;
            cursor: pointer; transition: all 0.3s; text-align: left;
            font-family: inherit;
        }
        .choice-btn:hover {
            border-color: #f0c27a;
            background: linear-gradient(135deg, #4a3520, #5a3e28);
            transform: translateX(4px);
            box-shadow: 0 4px 16px rgba(240,194,122,0.15);
        }
        .choice-btn .emoji { margin-right: 8px; font-size: 18px; }
        .ambient-particles {
            position: fixed; pointer-events: none; z-index: 0; top: 0; left: 0; width: 100%; height: 100%;
            overflow: hidden;
        }
        .particle {
            position: absolute; font-size: 16px; opacity: 0.15;
            animation: floatUp 8s ease-in infinite;
        }
        @keyframes floatUp {
            0% { transform: translateY(100vh) rotate(0deg); opacity: 0; }
            10% { opacity: 0.15; }
            90% { opacity: 0.15; }
            100% { transform: translateY(-10vh) rotate(60deg); opacity: 0; }
        }
    </style>
</head>
<body>
    <div class="ambient-particles">
        <span class="particle" style="left:10%; animation-delay:0s;">✨</span>
        <span class="particle" style="left:25%; animation-delay:2s;">🍂</span>
        <span class="particle" style="left:45%; animation-delay:4s;">🌟</span>
        <span class="particle" style="left:65%; animation-delay:1s;">💫</span>
        <span class="particle" style="left:80%; animation-delay:5s;">🪲</span>
        <span class="particle" style="left:55%; animation-delay:3s;">🌿</span>
        <span class="particle" style="left:35%; animation-delay:6s;">🍃</span>
    </div>

    <div class="card">
        <% if (step != null) { %>
        <div class="card-top">
            <span class="region-icon">🗺️</span>
            <div class="info">
                <div class="region-label">冒险进行中</div>
                <div class="region-name"><%= regionName %></div>
                <% if (companion != null) { %>
                <div class="companion-tag">🐾 <%= companion.getEmoji() %> <%= companion.getName() %> Lv.<%= companion.getLevel() %> 同行中</div>
                <% } %>
                <div class="progress-bar">
                    <span class="progress-dot <%= stepIndex >= 0 ? "done" : "" %>"></span>
                    <span class="progress-dot <%= stepIndex >= 1 ? "done" : (stepIndex == 0 ? "current" : "") %>"></span>
                    <span class="progress-dot <%= stepIndex >= 2 ? "done" : (stepIndex == 2 ? "current" : "") %>"></span>
                </div>
            </div>
        </div>
        <div class="card-body">
            <div class="step-title">📜 <%= step.title %></div>
            <div class="step-text"><%= step.text %></div>

            <form method="post" action="<%= request.getContextPath() %>/map">
                <input type="hidden" name="action" value="choice">
                <div class="choices">
                    <% for (AdventureChoice c : step.choices) { %>
                    <button type="submit" name="choice" value="<%= c.value() %>" class="choice-btn">
                        <%= c.label() %>
                    </button>
                    <% } %>
                </div>
            </form>
        </div>
        <% } %>
    </div>
</body>
</html>
