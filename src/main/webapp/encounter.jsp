<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    WildEncounter enc = (WildEncounter) request.getAttribute("encounter");
    PetSpecies species = (PetSpecies) request.getAttribute("species");
    String regionName = (String) request.getAttribute("regionName");
    Pet companion = (Pet) request.getAttribute("companion");
    if (enc == null || species == null) { response.sendRedirect(request.getContextPath() + "/map"); return; }

    CompanionTrait trait = enc.getCompanionTrait();
    WildEncounter.Archetype arch = enc.getArchetype();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>&#x1F43E; 与<%= enc.getAnimalName() %>互动 - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #1a2a1a 0%, #0d1d10 40%, #1a2a1a 100%);
            min-height: 100vh; color: #e0d5c1;
        }
        .container { max-width: 580px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; margin-bottom: 10px; }
        .header .location { font-size: 13px; color: #8a9a7a; margin-bottom: 2px; }
        .header h1 { font-size: 22px; color: #f0c27a; }

        /* Scene description */
        .scene-desc {
            background: linear-gradient(135deg, #1a2518, #1e2d15);
            border-radius: 14px; padding: 16px 18px; margin-bottom: 14px;
            border-left: 3px solid #5a7a4a; font-size: 14px; line-height: 1.7;
            color: #b0c0a0; font-style: italic;
        }

        /* Animal display */
        .animal-card {
            background: linear-gradient(135deg, #2d2410, #3d2f18);
            border-radius: 20px; padding: 20px; text-align: center;
            margin-bottom: 14px; border: 2px solid #4a3a20;
            box-shadow: 0 8px 30px rgba(0,0,0,0.4);
        }
        .animal-card .emoji {
            font-size: 72px; display: block;
            animation: float 3s ease-in-out infinite;
        }
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        .animal-card .name { font-size: 22px; font-weight: 700; color: #f0c27a; margin-top: 4px; }
        .animal-card .arch-tag {
            display: inline-block; margin-top: 6px; padding: 4px 14px;
            border-radius: 12px; font-size: 12px; font-weight: 600;
        }
        .arch-CAUTIOUS { background: #3a3020; color: #d4a060; }
        .arch-CURIOUS { background: #2a3a20; color: #b0d060; }
        .arch-BOLD { background: #3a2020; color: #e08060; }
        .arch-GENTLE { background: #2a3a3a; color: #80c0c0; }
        .arch-PLAYFUL { background: #3a2a20; color: #e0b040; }
        .arch-MYSTERIOUS { background: #2a2040; color: #b080e0; }

        /* Capture requirements */
        .capture-req {
            background: linear-gradient(135deg, #1a2218, #222a15);
            border-radius: 12px; padding: 12px 16px; margin-bottom: 14px;
            border: 1px solid #4a5a30;
        }
        .capture-req .cr-title {
            font-size: 13px; font-weight: 700; color: #c0d470;
            margin-bottom: 8px;
        }
        .capture-req .cr-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 6px;
        }
        .capture-req .cr-item {
            font-size: 12px; padding: 6px 10px; border-radius: 8px;
            font-weight: 600; text-align: center;
        }
        .cr-security { background: #1a301a; color: #80c080; }
        .cr-interest { background: #1a2a30; color: #80b0d0; }
        .cr-pressure { background: #301a1a; color: #e08080; }
        .cr-trust { background: #2a2a1a; color: #e0c060; }

        /* Companion info */
        .companion-bar {
            background: #1e2d1e; border-radius: 12px; padding: 10px 16px;
            margin-bottom: 14px; display: flex; align-items: center; gap: 10px;
            border: 1px solid #3a5a3a; font-size: 13px; color: #b0c090;
        }
        .companion-bar .trait-badge {
            margin-left: auto; background: #3a5a2a; color: #c0e080;
            padding: 4px 12px; border-radius: 10px; font-weight: 600; font-size: 12px;
            white-space: nowrap;
        }

        /* 4 Emotion bars */
        .emotion-bars {
            display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 14px;
        }
        .emo-bar {
            background: #1a2a1a; border-radius: 12px; padding: 12px;
            border: 1px solid #2a3a2a;
        }
        .emo-bar .eb-label {
            font-size: 12px; color: #8a9a7a; margin-bottom: 4px;
            display: flex; justify-content: space-between;
        }
        .emo-bar .eb-val { font-weight: 700; font-size: 14px; }
        .emo-bar .bar-outer { height: 8px; background: #111; border-radius: 4px; overflow: hidden; }
        .emo-bar .bar-inner { height: 100%; border-radius: 4px; transition: width 0.6s ease; }

        /* Hidden emotion hint (detection traits) */
        .hidden-hint {
            background: linear-gradient(135deg, #2a2040, #3a2a50);
            border-radius: 12px; padding: 12px 16px; margin-bottom: 14px;
            border: 1px solid #5a3a7a; text-align: center; animation: fadeIn 0.4s;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: translateY(0); } }
        .hidden-hint .hh-label { font-size: 11px; color: #a090c0; }
        .hidden-hint .hh-text { font-size: 15px; font-weight: 700; color: #d0b0ff; margin-top: 2px; }

        /* Pacing hint */
        .pacing-hint {
            background: #2a3a10; border: 1px dashed #8bc34a; border-radius: 12px;
            padding: 10px 16px; text-align: center; margin-bottom: 14px;
            color: #c0d470; font-size: 13px;
        }

        /* Flee warning */
        .flee-warning {
            background: linear-gradient(135deg, #3a1010, #5a1a1a);
            border: 2px solid #e04040; border-radius: 14px;
            padding: 14px 18px; margin-bottom: 14px;
            display: flex; gap: 12px; align-items: center;
            animation: pulse 1.5s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 8px rgba(255,80,80,0.3); }
            50% { box-shadow: 0 0 20px rgba(255,80,80,0.6); }
        }
        .flee-warning .fw-icon { font-size: 28px; flex-shrink: 0; }
        .flee-warning .fw-text { font-size: 13px; color: #f0c0c0; line-height: 1.6; }
        .flee-warning .fw-text strong { color: #ff8080; }

        /* Trait suggestion */
        .trait-suggestion {
            background: linear-gradient(135deg, #1a2a3a, #253545);
            border: 1px solid #4a7a9a; border-radius: 12px;
            padding: 14px 18px; margin-bottom: 14px; display: flex;
            gap: 12px; align-items: flex-start; animation: fadeIn 0.4s;
        }
        .trait-suggestion .ts-icon { font-size: 22px; flex-shrink: 0; }
        .trait-suggestion .ts-text { font-size: 14px; color: #b0d0e0; line-height: 1.6; font-weight: 600; }

        /* Attitude buttons */
        .attitudes-title {
            font-size: 14px; color: #8a9a7a; margin-bottom: 10px; text-align: center;
        }
        .attitude-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;
            margin-bottom: 14px;
        }
        .att-btn {
            background: linear-gradient(135deg, #2d2418, #3d2f1f);
            border: 2px solid #4a3a20; border-radius: 14px;
            padding: 14px 8px; cursor: pointer; transition: all 0.3s;
            text-align: center; color: #e0d5c1; font-family: inherit;
        }
        .att-btn:hover {
            border-color: #f0c27a; transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(240,194,122,0.2);
            background: linear-gradient(135deg, #3d2f1f, #5a3e28);
        }
        .att-btn.cooldown {
            opacity: 0.4; cursor: not-allowed; filter: grayscale(60%);
        }
        .att-btn.bypass {
            border-color: #f0c27a; background: linear-gradient(135deg, #3d2f10, #5a4e18);
            box-shadow: 0 0 12px rgba(240,194,122,0.3);
        }
        .att-btn.bypass:hover {
            border-color: #FFD700; box-shadow: 0 0 16px rgba(255,215,0,0.5);
        }
        .att-btn .att-emoji { font-size: 26px; display: block; margin-bottom: 4px; }
        .att-btn .att-name { font-size: 14px; font-weight: 700; }
        .att-btn .att-desc { font-size: 10px; color: #8a7a6a; margin-top: 2px; }

        /* Feedback */
        .feedback {
            background: #1e2d1e; border-radius: 14px; padding: 16px 18px;
            margin-bottom: 14px; border-left: 3px solid #f0c27a;
            font-size: 14px; line-height: 1.8; color: #c4b5a0;
            white-space: pre-line; animation: fadeIn 0.3s ease;
        }

        /* Round counter */
        .rounds {
            text-align: center; font-size: 13px; color: #6a7a5a; margin-bottom: 14px;
        }
        .rounds span { color: #f0c27a; font-weight: 700; }

        .btn-back {
            display: block; text-align: center; padding: 10px;
            color: #8a7a6a; text-decoration: none; font-size: 14px;
        }
        .btn-back:hover { color: #c0b090; }

        @media (max-width: 500px) {
            .attitude-grid { grid-template-columns: repeat(2, 1fr); }
            .emotion-bars { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="location">&#x1F4CD; <%= regionName %></div>
            <h1>&#x1F43E; 与野生动物互动</h1>
        </div>

        <!-- Scene description -->
        <div class="scene-desc"><%= enc.getSceneDesc() %></div>

        <!-- Animal display -->
        <div class="animal-card">
            <span class="emoji"><%= enc.getAnimalEmoji() %></span>
            <div class="name"><%= enc.getAnimalName() %></div>
            <div class="arch-tag arch-<%= arch.name() %>">
                <%
                    String archLabel = "";
                    switch (arch) {
                        case CAUTIOUS: archLabel = "&#x1F440; 谨慎型"; break;
                        case CURIOUS: archLabel = "&#x1F50D; 好奇型"; break;
                        case BOLD: archLabel = "&#x1F4AA; 大胆型"; break;
                        case GENTLE: archLabel = "&#x1F33F; 温柔型"; break;
                        case PLAYFUL: archLabel = "&#x1F3BE; 活泼型"; break;
                        case MYSTERIOUS: archLabel = "&#x2728; 神秘型"; break;
                    }
                %>
                <%= archLabel %>
            </div>
        </div>

        <!-- Capture requirements -->
        <div class="capture-req">
            <div class="cr-title">&#x1F3AF; 捕捉条件</div>
            <div class="cr-grid">
                <span class="cr-item cr-security">&#x1F6E1; 安全感≥<%= enc.getRequiredSecurity() %></span>
                <span class="cr-item cr-interest">&#x1F4A1; 兴趣≥<%= enc.getRequiredInterest() %></span>
                <span class="cr-item cr-pressure">&#x26A0; 压力≤<%= enc.getMaxPressure() %></span>
                <span class="cr-item cr-trust">&#x1F91D; 信任≥<%= enc.getRequiredTrust() %></span>
            </div>
        </div>

        <!-- Companion trait -->
        <% if (trait != null) { %>
        <div class="companion-bar">
            <span><%= enc.getCompanionEmoji() %> <%= enc.getCompanionName() %></span>
            <span style="color:#8a9a7a;">与你同行</span>
            <span class="trait-badge">&#x2B50; <%= trait.getName() %></span>
        </div>
        <% } %>

        <!-- 4 Emotion bars -->
        <div class="emotion-bars">
            <div class="emo-bar">
                <div class="eb-label"><span>&#x1F6E1; 安全感</span><span class="eb-val" style="color:<%= enc.getSecurityColor() %>;"><%= enc.getSecurity() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getSecurity() %>%; background:<%= enc.getSecurityColor() %>;"></div></div>
            </div>
            <div class="emo-bar">
                <div class="eb-label"><span>&#x1F4A1; 兴趣</span><span class="eb-val" style="color:<%= enc.getInterestColor() %>;"><%= enc.getInterest() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getInterest() %>%; background:<%= enc.getInterestColor() %>;"></div></div>
            </div>
            <div class="emo-bar">
                <div class="eb-label"><span>&#x26A0; 压力</span><span class="eb-val" style="color:<%= enc.getPressureColor() %>;"><%= enc.getPressure() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getPressure() %>%; background:<%= enc.getPressureColor() %>;"></div></div>
            </div>
            <div class="emo-bar">
                <div class="eb-label"><span>&#x1F91D; 信任</span><span class="eb-val" style="color:<%= enc.getTrustColor() %>;"><%= enc.getTrust() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getTrust() %>%; background:<%= enc.getTrustColor() %>;"></div></div>
            </div>
        </div>

        <!-- Hidden emotion hint (detection traits) -->
        <% if (enc.isHiddenEmotionRevealed() && enc.getRevealedEmotionHint() != null) { %>
        <div class="hidden-hint">
            <div class="hh-label">&#x1F50D; 同行伙伴的洞察</div>
            <div class="hh-text"><%= enc.getRevealedEmotionHint() %></div>
        </div>
        <% } %>

        <!-- Round counter -->
        <div class="rounds">回合：<span><%= enc.getRoundsUsed() %> / <%= enc.getMaxRounds() %></span>
        <% if (enc.getRoundsUsed() >= enc.getMaxRounds() - 3 && enc.getMaxRounds() > 12) { %>
            <br><small style="color:#f0c27a;">&#x1F49B; 同伴特性延长了相遇时间</small>
        <% } else if (enc.getRoundsUsed() >= enc.getMaxRounds() - 3) { %>
            <br><small style="color:#e08060;">&#x23F3; 时间不多了……</small>
        <% } %>
        </div>

        <!-- Flee warning banner -->
        <% if (enc.isFleeWarning()) { %>
        <div class="flee-warning">
            <div class="fw-icon">&#x26A0;&#xFE0F;</div>
            <div class="fw-text">
                <strong><%= enc.getAnimalEmoji() %><%= enc.getAnimalName() %></strong> 焦躁不安，下回合可能<strong>逃跑</strong>！
                <br><small>压力越高逃跑概率越大，快用「后退」或「等待」降低压力吧</small>
            </div>
        </div>
        <% } %>

        <!-- Pacing hint -->
        <%
            String pacingHint = enc.getPacingHint(enc.getLastAttitudeUsed());
            if (pacingHint != null) {
        %>
        <div class="pacing-hint">&#x1F4A1; <%= pacingHint %></div>
        <% } %>

        <!-- Last feedback -->
        <%
            String fb = enc.getLastFeedback();
            String traitHint = enc.getTraitHint();
            if (fb != null && !fb.isEmpty()) {
        %>
        <div class="feedback"><%= fb %></div>
        <% } else if (traitHint != null && !traitHint.isEmpty()) { %>
        <div class="feedback">&#x1F4A1; <%= traitHint %></div>
        <% } %>

        <!-- Trait suggestion (detection/empathy companions) -->
        <%
            String ts = enc.getTraitSuggestion();
            if (ts != null && !ts.isEmpty()) {
        %>
        <div class="trait-suggestion">
            <div class="ts-icon">&#x1F4AC;</div>
            <div class="ts-text"><%= ts %></div>
        </div>
        <% } %>

        <!-- Attitude buttons -->
        <div class="attitudes-title">选择你的态度：</div>
        <form method="post" action="<%= request.getContextPath() %>/map" id="attitudeForm">
            <input type="hidden" name="action" value="attitude">
            <div class="attitude-grid">
                <% for (WildEncounter.Attitude a : WildEncounter.Attitude.values()) {
                    boolean onCooldown = enc.isOnCooldown(a);
                    String bypassHint = enc.getCooldownBypassHint(a);
                %>
                <button type="submit" name="attitude" value="<%= a.name() %>" class="att-btn<%= onCooldown ? " cooldown" : (bypassHint != null ? " bypass" : "") %>"
                    <%= onCooldown ? "disabled title=\"冷却中——下回合可用\"" : (bypassHint != null ? "title=\"" + bypassHint + "\"" : "") %>>
                    <span class="att-emoji"><%= a.emoji %></span>
                    <span class="att-name"><%= a.label %><%= bypassHint != null ? " &#x2B50;" : "" %></span>
                    <span class="att-desc"><%= onCooldown ? "冷却中" : (bypassHint != null ? bypassHint : a.desc) %></span>
                </button>
                <% } %>
            </div>
        </form>

        <a href="<%= request.getContextPath() %>/map" class="btn-back">&#x1F5FA; 放弃本次遭遇，返回地图</a>
    </div>
</body>
</html>
