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
    <title><%= regionName != null ? regionName : "冒险" %> - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        body {
            display: flex; align-items: center; justify-content: center;
            min-height: 100vh; padding: 20px;
        }
        .adventure-card {
            background: var(--card-bg); border-radius: var(--radius-lg);
            border: 1px solid var(--border); box-shadow: var(--shadow-lg);
            max-width: 520px; width: 100%; overflow: hidden;
            animation: fadeIn 0.3s ease;
        }
        .adv-header {
            background: #F5EDE0; padding: 18px 24px; display: flex;
            align-items: center; gap: 14px; border-bottom: 1px solid var(--border-light);
        }
        .adv-header .region-icon { font-size: 30px; }
        .adv-header .region-name { font-size: 16px; font-weight: 600; color: var(--text); }
        .adv-header .region-label { font-size: 11px; color: var(--text-muted); }
        .step-dots { display: flex; gap: 4px; margin-top: 4px; }
        .step-dot { width: 24px; height: 3px; background: #E8DDCA; border-radius: 2px; }
        .step-dot.done { background: #C5B090; }
        .step-dot.current { background: var(--accent-warm); }
        .companion-tag {
            display: inline-block; background: #F5F0E8; border: 1px solid var(--border-light);
            border-radius: 8px; padding: 3px 10px; font-size: 12px; color: var(--text-secondary);
        }
        .adv-body { padding: 24px; }
        .step-title { font-size: 20px; font-weight: 600; color: var(--text); margin-bottom: 14px; }
        .step-text {
            font-size: 15px; line-height: 1.9; color: var(--text-secondary);
            margin-bottom: 24px; background: #FDFBF6; padding: 18px;
            border-radius: var(--radius); border-left: 3px solid #C5B8A0;
        }
        .choices { display: flex; flex-direction: column; gap: 10px; }
        .choice-btn {
            display: block; width: 100%; padding: 14px 18px;
            background: var(--card-bg); border: 1px solid var(--border-light);
            border-radius: var(--radius); color: var(--text); font-size: 15px;
            font-weight: 500; cursor: pointer; transition: all var(--transition);
            text-align: left; font-family: inherit;
        }
        .choice-btn:hover {
            border-color: #C5B8A0; background: #FAF7F0;
            transform: translateX(3px); box-shadow: var(--shadow-xs);
        }
    </style>
</head>
<body>
    <div class="adventure-card">
        <% if (step != null) { %>
        <div class="adv-header">
            <span class="region-icon">🗺️</span>
            <div>
                <div class="region-label">冒险进行中</div>
                <div class="region-name"><%= regionName %></div>
                <% if (companion != null) { %>
                <div class="companion-tag"><%= companion.getEmoji() %> <%= companion.getName() %> Lv.<%= companion.getLevel() %> 同行中</div>
                <% } %>
                <div class="step-dots">
                    <span class="step-dot done"></span>
                    <span class="step-dot <%= stepIndex >= 1 ? "done" : "current" %>"></span>
                    <span class="step-dot <%= stepIndex >= 2 ? "done" : (stepIndex == 2 ? "current" : "") %>"></span>
                </div>
            </div>
        </div>
        <div class="adv-body">
            <div class="step-title"><%= step.title %></div>
            <div class="step-text"><%= step.text %></div>
            <form method="post" action="<%= request.getContextPath() %>/map">
                <input type="hidden" name="action" value="choice">
                <div class="choices">
                    <% for (AdventureChoice c : step.choices) { %>
                    <button type="submit" name="choice" value="<%= c.value() %>" class="choice-btn"><%= c.label() %></button>
                    <% } %>
                </div>
            </form>
        </div>
        <% } %>
    </div>
</body>
</html>
