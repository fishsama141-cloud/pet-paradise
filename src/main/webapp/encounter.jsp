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
    <title>与<%= enc.getAnimalName() %>互动 - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        .container { max-width: 580px; margin: 0 auto; padding: 20px; }

        .enc-header {
            text-align: center; margin-bottom: 10px;
        }
        .enc-header .region-label {
            font-size: 12px; color: var(--text-muted); font-weight: 500;
            letter-spacing: 1px;
        }
        .enc-header h1 {
            font-size: 22px; font-weight: 700; color: var(--text);
            letter-spacing: 1px; margin-top: 2px;
        }

        /* 场景文本 */
        .scene-desc {
            background: linear-gradient(135deg, #FDF9F2, #FAF5E8);
            border-radius: var(--radius); padding: 16px 20px; margin-bottom: 18px;
            border-left: 4px solid var(--accent-warm);
            font-size: 14px; line-height: 1.8;
            color: var(--text-secondary); font-style: italic;
        }

        /* 动物展示 */
        .animal-showcase {
            text-align: center; margin-bottom: 18px;
        }
        .animal-showcase .an-emoji {
            font-size: 88px; display: block;
            filter: drop-shadow(0 4px 12px rgba(120,80,40,0.15));
            animation: pulse 3s ease-in-out infinite;
        }
        .animal-showcase .an-name {
            font-size: 22px; font-weight: 700; color: var(--text);
            margin-top: 6px; letter-spacing: 1px;
        }
        .arch-tag {
            display: inline-block; margin-top: 6px; padding: 5px 16px;
            border-radius: 14px; font-size: 12px; font-weight: 700;
            letter-spacing: 0.5px;
        }
        .arch-CAUTIOUS { background: #F5F0E8; color: #8A7A5A; border: 1px solid #E0D5C0; }
        .arch-CURIOUS { background: #F0F5EC; color: #6A8A5A; border: 1px solid #C8D8C0; }
        .arch-BOLD { background: #FEF2E8; color: #B06848; border: 1px solid #F0D0C0; }
        .arch-GENTLE { background: #F0F4F6; color: #5A8A8A; border: 1px solid #C8D8E0; }
        .arch-PLAYFUL { background: #FDF6E8; color: #B08040; border: 1px solid #E8D8C0; }
        .arch-MYSTERIOUS { background: #F2EEF8; color: #8058A0; border: 1px solid #D8D0E8; }

        /* 捕捉条件 */
        .capture-req {
            background: linear-gradient(135deg, #FDFBF6, #FAF7F0);
            border-radius: var(--radius); padding: 14px 18px;
            margin-bottom: 18px; border: 2px solid var(--border-light);
        }
        .capture-req .cr-title {
            font-size: 13px; font-weight: 700; color: var(--text);
            margin-bottom: 10px; letter-spacing: 1px;
        }
        .capture-req .cr-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
        .capture-req .cr-item {
            font-size: 12px; padding: 8px 12px; border-radius: 8px;
            font-weight: 600; text-align: center; letter-spacing: 0.5px;
        }
        .cr-security { background: #F0F6EC; color: #5A8A4A; }
        .cr-interest { background: #F0F5FA; color: #4A7098; }
        .cr-pressure { background: #FEF5F0; color: #B05840; }
        .cr-trust { background: #FDF6EC; color: #B08040; }

        /* 同行宠物 */
        .companion-bar {
            background: linear-gradient(135deg, #FDFBF6, #FAF7F0);
            border-radius: var(--radius); padding: 12px 18px;
            margin-bottom: 18px; display: flex; align-items: center; gap: 10px;
            border: 2px solid var(--border-light); font-size: 13px; color: var(--text-secondary);
            font-weight: 500;
        }
        .companion-bar .trait-badge {
            margin-left: auto; background: #F2EDE0; color: var(--text-secondary);
            padding: 5px 14px; border-radius: 12px; font-weight: 700; font-size: 12px;
            white-space: nowrap; letter-spacing: 0.5px;
        }

        /* 情绪条 */
        .emotion-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 18px;
        }
        .emo-bar {
            background: var(--card-bg); border-radius: var(--radius);
            padding: 12px 16px; border: 1px solid var(--border-light);
            transition: box-shadow 0.3s;
        }
        .emo-bar:hover { box-shadow: var(--shadow-xs); }
        .emo-bar .eb-label {
            font-size: 12px; color: var(--text-secondary); font-weight: 500;
            display: flex; justify-content: space-between; margin-bottom: 6px;
        }
        .emo-bar .eb-val { font-weight: 700; font-size: 15px; }

        /* 各类提示 */
        .hint-box {
            padding: 14px 18px; border-radius: var(--radius); margin-bottom: 16px;
            font-size: 13px; line-height: 1.7; animation: fadeIn 0.3s ease;
            font-weight: 500;
        }
        .hint-detection { background: #F5F0F8; border: 1px solid #D8C8E8; color: #5A4080; border-left: 4px solid #8B6AAA; }
        .hint-rhythm { background: #FDF6E8; border: 2px dashed #D5C5A5; color: var(--text-secondary); }
        .hint-flee {
            background: #FEF5F0; border: 1px solid #F0C0A0; color: #B04830;
            display: flex; gap: 12px; align-items: center; border-left: 4px solid var(--accent-red);
        }
        .hint-flee .fw-icon { font-size: 24px; flex-shrink: 0; }
        .hint-suggestion {
            background: #F0F5FA; border: 1px solid #C0D4E8; color: #4A6070;
            display: flex; gap: 12px; align-items: flex-start; border-left: 4px solid var(--accent-blue);
        }

        /* 反馈 */
        .feedback {
            background: linear-gradient(135deg, #FDFBF6, #FAF7F0);
            border-radius: var(--radius); padding: 16px 18px;
            margin-bottom: 16px; border-left: 4px solid var(--accent-warm);
            font-size: 14px; line-height: 1.9; color: var(--text-secondary);
            white-space: pre-line; animation: fadeIn 0.3s ease;
        }

        /* 回合 */
        .rounds-info {
            text-align: center; font-size: 13px; color: var(--text-muted);
            margin-bottom: 16px; font-weight: 500;
        }
        .rounds-info span { color: var(--text); font-weight: 700; }

        /* 态度按钮 */
        .attitudes-title {
            font-size: 13px; color: var(--text-muted); margin-bottom: 12px;
            text-align: center; font-weight: 500; letter-spacing: 1px;
        }
        .attitude-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px;
            margin-bottom: 16px;
        }
        .att-btn {
            background: var(--card-bg); border: 2px solid var(--border-light);
            border-radius: var(--radius); padding: 16px 6px;
            cursor: pointer; transition: all var(--transition);
            text-align: center; font-family: inherit; color: var(--text);
        }
        .att-btn:hover {
            border-color: var(--border-warm); background: #FAF7F0;
            transform: translateY(-2px); box-shadow: var(--shadow-sm);
        }
        .att-btn:active { transform: translateY(0); }
        .att-btn.cooldown { opacity: 0.4; cursor: not-allowed; filter: grayscale(50%); }
        .att-btn.cooldown:hover { transform: none; box-shadow: none; }
        .att-btn.bypass { border-color: var(--accent-warm); background: linear-gradient(135deg, #FDF5EC, #FDF0E0); box-shadow: 0 0 0 3px rgba(212,149,106,0.12); }
        .att-btn .att-emoji { font-size: 30px; display: block; margin-bottom: 4px; }
        .att-btn .att-name { font-size: 14px; font-weight: 700; }
        .att-btn .att-desc { font-size: 11px; color: var(--text-muted); margin-top: 3px; font-weight: 500; }

        .back-link {
            display: block; text-align: center; padding: 10px;
            color: var(--text-muted); text-decoration: none; font-size: 13px;
            font-weight: 500; transition: color 0.2s;
        }
        .back-link:hover { color: var(--text-secondary); }

        /* ========== Bond Event Modal ========== */
        .bond-modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(50,30,15,0.5); z-index: 9999;
            display: flex; align-items: center; justify-content: center;
            animation: fadeIn 0.2s ease;
            backdrop-filter: blur(3px);
        }
        .bond-modal {
            background: var(--card-bg); border: 1px solid var(--border);
            border-radius: var(--radius-xl); padding: 28px;
            width: 94%; max-width: 520px; max-height: 92vh;
            overflow-y: auto; position: relative;
            animation: fadeInScale 0.3s ease; box-shadow: var(--shadow-xl);
        }
        .bond-modal .be-header { text-align: center; margin-bottom: 16px; }
        .bond-modal .be-title {
            font-size: 20px; font-weight: 700; color: var(--text); margin-bottom: 8px;
            letter-spacing: 1px;
        }
        .bond-modal .be-scene {
            font-size: 14px; color: var(--text-secondary); line-height: 1.8; margin-bottom: 12px;
            font-style: italic;
        }
        .bond-modal .be-instruction {
            font-size: 13px; color: var(--text-secondary); margin-bottom: 16px;
            padding: 12px 18px; background: linear-gradient(135deg, #FDF9F2, #FAF5E8);
            border-radius: var(--radius-sm); font-weight: 500;
        }
        .bond-modal .be-game-area {
            background: linear-gradient(135deg, #F5F0E8, #EDE5D5);
            border-radius: var(--radius); padding: 20px; min-height: 200px;
            position: relative; overflow: hidden; user-select: none; cursor: default;
            border: 2px solid var(--border-light);
        }
        .bond-modal .be-trait-hint {
            margin-top: 16px; font-size: 12px; color: var(--text-secondary);
            text-align: center; padding: 8px 16px;
            background: linear-gradient(135deg, #FDF9F2, #FAF5E8);
            border-radius: var(--radius-sm); font-weight: 500;
        }
        .bond-modal .be-score-bar {
            height: 8px; background: #F0E8D8; border-radius: 4px;
            margin-top: 16px; overflow: hidden;
            box-shadow: inset 0 1px 2px rgba(60,35,15,0.06);
        }
        .bond-modal .be-score-fill {
            height: 100%; background: linear-gradient(90deg, #C5B090, #D4B870);
            border-radius: 4px; transition: width 0.3s;
        }
        .bond-modal .be-mistakes {
            text-align: center; margin-top: 10px; font-size: 12px; color: var(--accent-red);
            font-weight: 500;
        }

        /* Bond result */
        .bond-result {
            background: #FDFBF6; border-radius: var(--radius); padding: 14px 16px;
            margin-bottom: 14px; border-left: 3px solid #C5B8A0;
            font-size: 14px; line-height: 1.8; color: var(--text-secondary);
            white-space: pre-line; animation: fadeIn 0.3s ease;
        }

        /* --- Mini-game sub-styles --- */
        .sa-track { position: relative; height: 160px; margin: 10px 0; }
        .sa-animal { position: absolute; top: 0; left: 50%; transform: translateX(-50%); font-size: 48px; transition: transform 0.1s; }
        .sa-animal.alert { transform: translateX(-50%) scale(1.15); filter: brightness(1.2) drop-shadow(0 0 6px #D04030); }
        .sa-player { position: absolute; bottom: 0; left: 50%; transform: translateX(-50%); font-size: 28px; transition: bottom 0.05s; }
        .sa-progress { position: absolute; left: 55%; top: 60px; bottom: 60px; width: 8px; background: #E8E0D0; border-radius: 4px; }
        .sa-progress-fill { width: 100%; background: #C5B090; border-radius: 4px; transition: height 0.05s; position: absolute; bottom: 0; }
        .sa-btn { display: block; width: 100%; padding: 16px; font-size: 16px; font-weight: 600; border: 1px solid var(--border); border-radius: var(--radius); background: var(--card-bg); color: var(--text); cursor: pointer; font-family: inherit; transition: all 0.15s; }
        .sa-btn:active, .sa-btn.holding { background: #EDE5D8; border-color: #C5B090; }

        .rs-circles { display: flex; justify-content: center; gap: 16px; margin: 30px 0; }
        .rs-circle { width: 64px; height: 64px; border-radius: 50%; background: #F0EAE0; border: 2px solid #D5C8B5; transition: all 0.12s; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 24px; }
        .rs-circle.active { background: #D0C0A0; border-color: #B09878; box-shadow: 0 0 16px rgba(180,150,120,0.4); transform: scale(1.08); }
        .rs-circle.hit { background: #80B080; border-color: #6A9A6A; box-shadow: 0 0 12px rgba(100,160,100,0.3); }
        .rs-circle.miss { background: #D08080; border-color: #C06060; box-shadow: 0 0 12px rgba(200,100,100,0.3); }
        .rs-judgment { text-align: center; font-size: 15px; font-weight: 600; min-height: 22px; margin-top: 12px; }

        .go-scene { position: relative; height: 150px; margin: 10px 0; }
        .go-hand { position: absolute; left: 20px; top: 50%; transform: translateY(-50%); font-size: 44px; }
        .go-animal { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); font-size: 44px; transition: right 0.1s linear; }
        .go-nervous { position: absolute; right: 80px; top: 30px; font-size: 14px; transition: color 0.3s; }
        .go-btn { display: block; width: 100%; padding: 16px; font-size: 16px; font-weight: 600; border: 1px solid var(--border); border-radius: var(--radius); background: var(--card-bg); color: var(--text); cursor: pointer; font-family: inherit; }

        .fm-zone { width: 100%; height: 200px; background: #F0EAE0; border-radius: var(--radius); position: relative; overflow: hidden; cursor: none; }
        .fm-animal { position: absolute; font-size: 36px; transition: left 0.05s linear, top 0.05s linear; }
        .fm-comfort { position: absolute; border: 2px dashed rgba(180,150,120,0.5); border-radius: 50%; pointer-events: none; }
        .fm-player { position: absolute; width: 14px; height: 14px; border-radius: 50%; background: #C5A080; box-shadow: 0 0 8px rgba(180,150,120,0.4); pointer-events: none; transition: left 0.05s, top 0.05s; }
        .fm-score-text { text-align: center; font-size: 12px; color: var(--text-muted); margin-top: 8px; }

        .ec-display { display: flex; justify-content: center; gap: 12px; margin: 20px 0; }
        .ec-pad { width: 56px; height: 56px; border-radius: 12px; cursor: pointer; transition: all 0.1s; }
        .ec-pad.pad-0 { background: #C08070; }
        .ec-pad.pad-1 { background: #7090B0; }
        .ec-pad.pad-2 { background: #80A080; }
        .ec-pad.pad-3 { background: #D0B070; }
        .ec-pad.glow { transform: scale(1.2); box-shadow: 0 0 20px rgba(0,0,0,0.2); border: 2px solid #fff; filter: brightness(1.3); }
        .ec-pad.wrong { animation: shake 0.4s; filter: grayscale(70%); }
        @keyframes shake { 0%,100% { transform: translateX(0); } 25% { transform: translateX(-5px); } 50% { transform: translateX(5px); } 75% { transform: translateX(-5px); } }
        .ec-status { text-align: center; font-size: 15px; font-weight: 600; margin-top: 12px; min-height: 22px; color: var(--text-secondary); }

        .gl-scene { position: relative; height: 200px; cursor: none; background: #ECEAE0; border-radius: var(--radius); }
        .gl-eyes { position: absolute; font-size: 60px; top: 50%; left: 50%; transform: translate(-50%,-50%); transition: left 0.5s ease-in-out, top 0.5s ease-in-out; }
        .gl-zone { position: absolute; border: 2px solid rgba(180,150,120,0.4); border-radius: 50%; pointer-events: none; }
        .gl-cursor { position: absolute; width: 10px; height: 10px; border-radius: 50%; background: #C5A080; pointer-events: none; box-shadow: 0 0 8px rgba(180,150,120,0.5); }
        .gl-meter { height: 4px; background: #F0EAE0; border-radius: 2px; margin-top: 10px; overflow: hidden; }
        .gl-meter-fill { height: 100%; background: #C5B090; border-radius: 2px; transition: width 0.5s; }

        .countdown-overlay {
            position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            display: flex; align-items: center; justify-content: center;
            background: rgba(245,240,232,0.85); border-radius: var(--radius); z-index: 10;
        }
        .countdown-num {
            font-size: 72px; font-weight: 700; color: var(--text);
            animation: countPop 0.7s ease;
        }
        @keyframes countPop {
            0% { transform: scale(1.5); opacity: 0; }
            50% { transform: scale(0.92); opacity: 1; }
            100% { transform: scale(1); opacity: 1; }
        }

        .hidden { display: none !important; }

        @media (max-width: 500px) {
            .attitude-grid { grid-template-columns: repeat(2, 1fr); }
            .emotion-grid { grid-template-columns: 1fr; }
            .rs-circles { gap: 10px; }
            .rs-circle { width: 52px; height: 52px; font-size: 20px; }
            .ec-pad { width: 46px; height: 46px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div style="text-align:center;margin-bottom:6px;">
            <span style="font-size:13px;color:var(--text-muted);"><%= regionName %></span>
            <h1 style="font-size:20px;font-weight:600;color:var(--text);">与野生动物互动</h1>
        </div>

        <!-- 场景描述 -->
        <div class="scene-desc"><%= enc.getSceneDesc() %></div>

        <!-- 动物展示 -->
        <div class="animal-showcase">
            <span style="font-size:80px;"><%= enc.getAnimalEmoji() %></span>
            <div class="an-name"><%= enc.getAnimalName() %></div>
            <div class="arch-tag arch-<%= arch.name() %>">
                <%
                    String archLabel2;
                    if (arch == WildEncounter.Archetype.CAUTIOUS) archLabel2 = "谨慎型";
                    else if (arch == WildEncounter.Archetype.CURIOUS) archLabel2 = "好奇型";
                    else if (arch == WildEncounter.Archetype.BOLD) archLabel2 = "大胆型";
                    else if (arch == WildEncounter.Archetype.GENTLE) archLabel2 = "温柔型";
                    else if (arch == WildEncounter.Archetype.PLAYFUL) archLabel2 = "活泼型";
                    else archLabel2 = "神秘型";
                %>
                <%= archLabel2 %>
            </div>
        </div>

        <!-- 捕捉条件 -->
        <div class="capture-req">
            <div class="cr-title">捕捉条件</div>
            <div class="cr-grid">
                <span class="cr-item cr-security">安全感≥<%= enc.getRequiredSecurity() %></span>
                <span class="cr-item cr-interest">兴趣≥<%= enc.getRequiredInterest() %></span>
                <span class="cr-item cr-pressure">压力≤<%= enc.getMaxPressure() %></span>
                <span class="cr-item cr-trust">信任≥<%= enc.getRequiredTrust() %></span>
            </div>
        </div>

        <!-- 同行宠物 -->
        <% if (trait != null) { %>
        <div class="companion-bar">
            <span><%= enc.getCompanionEmoji() %> <%= enc.getCompanionName() %></span>
            <span style="color:var(--text-muted);">与你同行</span>
            <span class="trait-badge">⭐ <%= trait.getName() %></span>
        </div>
        <% } %>

        <!-- 情绪条 -->
        <div class="emotion-grid">
            <div class="emo-bar">
                <div class="eb-label"><span>安全感</span><span class="eb-val" style="color:<%= enc.getSecurityColor() %>;"><%= enc.getSecurity() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getSecurity() %>%; background:<%= enc.getSecurityColor() %>;"></div></div>
            </div>
            <div class="emo-bar">
                <div class="eb-label"><span>兴趣</span><span class="eb-val" style="color:<%= enc.getInterestColor() %>;"><%= enc.getInterest() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getInterest() %>%; background:<%= enc.getInterestColor() %>;"></div></div>
            </div>
            <div class="emo-bar">
                <div class="eb-label"><span>压力</span><span class="eb-val" style="color:<%= enc.getPressureColor() %>;"><%= enc.getPressure() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getPressure() %>%; background:<%= enc.getPressureColor() %>;"></div></div>
            </div>
            <div class="emo-bar">
                <div class="eb-label"><span>信任</span><span class="eb-val" style="color:<%= enc.getTrustColor() %>;"><%= enc.getTrust() %></span></div>
                <div class="bar-outer"><div class="bar-inner" style="width:<%= enc.getTrust() %>%; background:<%= enc.getTrustColor() %>;"></div></div>
            </div>
        </div>

        <!-- 探测系提示 -->
        <% if (enc.isHiddenEmotionRevealed() && enc.getRevealedEmotionHint() != null) { %>
        <div class="hint-box hint-detection">
            <div style="font-weight:600;font-size:12px;margin-bottom:2px;">同行伙伴的洞察</div>
            <div><%= enc.getRevealedEmotionHint() %></div>
        </div>
        <% } %>

        <!-- 回合数 -->
        <div class="rounds-info">
            回合：<span><%= enc.getRoundsUsed() %> / <%= enc.getMaxRounds() %></span>
        <% if (enc.getRoundsUsed() >= enc.getMaxRounds() - 3 && enc.getMaxRounds() > 12) { %>
            <br><small style="color:#6A8A5A;">同伴特性延长了相遇时间</small>
        <% } else if (enc.getRoundsUsed() >= enc.getMaxRounds() - 3) { %>
            <br><small style="color:var(--accent-red);">时间不多了……</small>
        <% } %>
        </div>

        <!-- 逃跑预警 -->
        <% if (enc.isFleeWarning()) { %>
        <div class="hint-box hint-flee">
            <div class="fw-icon">!</div>
            <div>
                <strong><%= enc.getAnimalEmoji() %><%= enc.getAnimalName() %></strong> 焦躁不安，下回合可能<strong>逃跑</strong>！
                <br><small>快用「后退」或「等待」降低压力</small>
            </div>
        </div>
        <% } %>

        <!-- 节奏提示 -->
        <%
            String pacingHint = enc.getPacingHint(enc.getLastAttitudeUsed());
            if (pacingHint != null) {
        %>
        <div class="hint-box hint-rhythm"><%= pacingHint %></div>
        <% } %>

        <!-- 反馈 -->
        <%
            String fb = enc.getLastFeedback();
            String traitHint = enc.getTraitHint();
            if (fb != null && !fb.isEmpty()) {
        %>
        <div class="feedback"><%= fb %></div>
        <% } else if (traitHint != null && !traitHint.isEmpty()) { %>
        <div class="feedback"><%= traitHint %></div>
        <% } %>

        <!-- 同伴建议 -->
        <%
            String ts = enc.getTraitSuggestion();
            if (ts != null && !ts.isEmpty()) {
        %>
        <div class="hint-box hint-suggestion">
            <div style="font-size:20px;flex-shrink:0;">💬</div>
            <div><%= ts %></div>
        </div>
        <% } %>

        <!-- Bond 结果 -->
        <%
            String bondResult = (String) request.getAttribute("bondResult");
            if (bondResult != null && !bondResult.isEmpty()) {
        %>
        <div class="bond-result"><%= bondResult %></div>
        <% } %>

        <!-- ===== Bond Event Modal ===== -->
        <%
            BondEvent bondEvent = (BondEvent) request.getAttribute("bondEvent");
        %>
        <% if (bondEvent != null) { %>
        <div class="bond-modal-overlay" id="bondModalOverlay">
            <div class="bond-modal" id="bondEvent">
                <div class="be-header">
                    <div class="be-title"><%= bondEvent.getAnimalEmoji() %> <%= bondEvent.getAnimalName() %>对你产生了兴趣</div>
                    <div class="be-scene"><%= bondEvent.getType().scene %></div>
                    <div class="be-instruction"><%= bondEvent.getType().instruction %></div>
                </div>
                <div class="be-game-area" id="gameArea">
                    <div style="text-align:center;padding:60px 20px;color:var(--text-muted);">
                        小游戏加载中……
                    </div>
                </div>
                <div class="be-score-bar"><div class="be-score-fill" id="scoreFill" style="width:50%"></div></div>
                <div class="be-mistakes" id="mistakeDots"></div>
                <% if (bondEvent.getTraitModifierText() != null && !bondEvent.getTraitModifierText().isEmpty()) { %>
                <div class="be-trait-hint"><%= bondEvent.getTraitModifierText() %></div>
                <% } %>
                <form method="post" action="<%= request.getContextPath() %>/map" id="bondForm">
                    <input type="hidden" name="action" value="bond_event">
                    <input type="hidden" name="score" id="bondScore" value="50">
                </form>
            </div>
        </div>
        <% } %>

        <!-- 态度按钮 -->
        <div id="attitudeSection">
        <div class="attitudes-title">选择你的态度</div>
        <form method="post" action="<%= request.getContextPath() %>/map" id="attitudeForm">
            <input type="hidden" name="action" value="attitude">
            <div class="attitude-grid">
                <% for (WildEncounter.Attitude a : WildEncounter.Attitude.values()) {
                    boolean onCooldown = enc.isOnCooldown(a);
                    String bypassHint = enc.getCooldownBypassHint(a);
                %>
                <button type="submit" name="attitude" value="<%= a.name() %>"
                    class="att-btn<%= onCooldown ? " cooldown" : (bypassHint != null ? " bypass" : "") %>"
                    <%= onCooldown ? "disabled" : "" %>>
                    <span class="att-emoji"><%= a.emoji %></span>
                    <span class="att-name"><%= a.label %><%= bypassHint != null ? " ⭐" : "" %></span>
                    <span class="att-desc"><%= onCooldown ? "冷却中" : (bypassHint != null ? bypassHint : a.desc) %></span>
                </button>
                <% } %>
            </div>
        </form>
        </div>

        <a href="<%= request.getContextPath() %>/map" class="back-link">放弃本次遭遇，返回地图</a>
    </div>

    <!-- ===== Bond Event Mini-Games JS (功能代码保持) ===== -->
    <% if (bondEvent != null) { %>
    <script>
    (function() {
        var bondCfg = {
            type: '<%= bondEvent.getType().name() %>',
            timingWindow: <%= bondEvent.getTimingWindow() %>,
            maxMistakes: <%= bondEvent.getMaxMistakes() %>,
            phases: <%= bondEvent.getPhases() %>,
            speed: <%= bondEvent.getSpeed() %>,
            zoneSize: <%= bondEvent.getZoneSize() %>,
            bonusPhase: <%= bondEvent.hasBonusPhase() %>,
            animalName: '<%= bondEvent.getAnimalName().replace("'", "\\'") %>',
            animalEmoji: '<%= bondEvent.getAnimalEmoji() %>'
        };

        var gameArea = document.getElementById('gameArea');
        var scoreFill = document.getElementById('scoreFill');
        var mistakeDots = document.getElementById('mistakeDots');
        var bondScore = document.getElementById('bondScore');
        var bondForm = document.getElementById('bondForm');

        var score = 50;
        var mistakes = 0;
        var gameRunning = true;

        function updateScore(delta) {
            score = Math.max(0, Math.min(100, score + delta));
            scoreFill.style.width = score + '%';
            bondScore.value = Math.round(score);
        }

        function addMistake() {
            mistakes++;
            var dots = mistakeDots.querySelectorAll('span');
            if (dots.length >= mistakes) {
                dots[mistakes - 1].style.color = '#C05040';
                dots[mistakes - 1].innerHTML = '&#x1F494;';
            }
            if (mistakes >= bondCfg.maxMistakes) {
                updateScore(-15);
                endGame();
            }
        }

        function endGame() {
            if (!gameRunning) return;
            gameRunning = false;
            bondScore.value = Math.round(score);
            var msg = document.createElement('div');
            msg.style.cssText = 'text-align:center;padding:20px;color:var(--text);font-size:16px;font-weight:600;animation:fadeIn 0.3s;';
            msg.textContent = score >= 90 ? '完美！' : score >= 55 ? '不错！' : score >= 25 ? '差一点……' : '失败了……';
            gameArea.appendChild(msg);
            setTimeout(function() { bondForm.submit(); }, 800);
        }

        function initMistakeDots() {
            var html = '';
            for (var i = 0; i < bondCfg.maxMistakes; i++) {
                html += '<span style="color:#80A080;">&#x2764;&#xFE0F;</span> ';
            }
            mistakeDots.innerHTML = html;
        }

        // ==================== SLOW APPROACH ====================
        function startSlowApproach() {
            initMistakeDots();
            var totalPhases = bondCfg.phases + (bondCfg.bonusPhase ? 1 : 0);
            gameArea.innerHTML =
                '<div style="position:relative;height:160px;margin:10px 0;">' +
                '<div id="saAnimal" style="position:absolute;top:0;left:50%;transform:translateX(-50%);font-size:48px;transition:transform 0.1s;">' + bondCfg.animalEmoji + '</div>' +
                '<div id="saProg" style="position:absolute;left:55%;top:60px;bottom:60px;width:8px;background:#E8E0D0;border-radius:4px;">' +
                '<div id="saProgFill" style="width:100%;background:#C5B090;border-radius:4px;position:absolute;bottom:0;height:0%;transition:height 0.05s;"></div></div>' +
                '<div id="saPlayer" style="position:absolute;bottom:5%;left:50%;transform:translateX(-50%);font-size:28px;transition:bottom 0.05s;">&#x1F9D1;</div>' +
                '</div>' +
                '<button class="sa-btn" id="saBtn">按住前进</button>' +
                '<div style="text-align:center;margin-top:6px;font-size:12px;color:var(--text-muted);">' + bondCfg.animalName + '回头时立刻松手！第 <span id="saPhaseNum">1</span>/' + totalPhases + ' 阶段</div>';

            var animal = document.getElementById('saAnimal');
            var player = document.getElementById('saPlayer');
            var progFill = document.getElementById('saProgFill');
            var btn = document.getElementById('saBtn');
            var phaseNum = document.getElementById('saPhaseNum');
            var currentPhase = 0;
            var progress = 0;
            var isHolding = false;
            var isLooking = false;
            var lookTimeout = null;

            function animalLook() {
                if (!gameRunning) return;
                isLooking = true;
                animal.style.transform = 'translateX(-50%) scale(1.15)';
                animal.style.filter = 'brightness(1.2) drop-shadow(0 0 6px #D04030)';
                if (isHolding) {
                    addMistake();
                    updateScore(-8);
                    animal.style.transform = 'translateX(-50%) rotate(-15deg) scale(1.15)';
                    setTimeout(function() { animal.style.transform = 'translateX(-50%) scale(1.15)'; }, 300);
                }
                var lookDuration = 400 + Math.random() * (bondCfg.timingWindow * 1.2);
                setTimeout(function() {
                    isLooking = false;
                    animal.style.transform = 'translateX(-50%)';
                    animal.style.filter = '';
                    if (gameRunning) scheduleLook();
                }, lookDuration);
            }

            function scheduleLook() {
                if (!gameRunning) return;
                var baseInterval = bondCfg.timingWindow * (1.5 - currentPhase * 0.2);
                var delay = Math.max(800, baseInterval + (Math.random() - 0.5) * bondCfg.timingWindow);
                lookTimeout = setTimeout(animalLook, delay);
            }

            btn.addEventListener('mousedown', function(e) { e.preventDefault(); isHolding = true; btn.classList.add('holding'); });
            btn.addEventListener('mouseup', function(e) { e.preventDefault(); isHolding = false; btn.classList.remove('holding'); });
            btn.addEventListener('mouseleave', function(e) { isHolding = false; btn.classList.remove('holding'); });
            btn.addEventListener('touchstart', function(e) { e.preventDefault(); isHolding = true; btn.classList.add('holding'); });
            btn.addEventListener('touchend', function(e) { e.preventDefault(); isHolding = false; btn.classList.remove('holding'); });

            var advanceInterval = setInterval(function() {
                if (!gameRunning) { clearInterval(advanceInterval); return; }
                if (isHolding && !isLooking) {
                    var rate = 1.0 + bondCfg.speed / 100;
                    progress += rate;
                    progFill.style.height = progress + '%';
                    player.style.bottom = (5 + progress * 0.7) + '%';
                    if (progress >= 100) {
                        currentPhase++;
                        updateScore(14);
                        progress = 0;
                        progFill.style.height = '0%';
                        player.style.bottom = '5%';
                        if (currentPhase >= totalPhases) {
                            updateScore(15);
                            endGame();
                        } else {
                            phaseNum.textContent = currentPhase + 1;
                            clearTimeout(lookTimeout);
                            scheduleLook();
                        }
                    }
                }
            }, 50);

            scheduleLook();
            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow * 8);
        }

        // ==================== RHYTHM SYNC ====================
        function startRhythmSync() {
            initMistakeDots();
            var totalPhases = bondCfg.phases + (bondCfg.bonusPhase ? 1 : 0);
            gameArea.innerHTML =
                '<div style="display:flex;justify-content:center;gap:16px;margin:30px 0;" id="rsCircles">' +
                '<div class="rs-circle" data-idx="0">&#x1F3B5;</div>' +
                '<div class="rs-circle" data-idx="1">&#x1F3B6;</div>' +
                '<div class="rs-circle" data-idx="2">&#x1F3B7;</div>' +
                '<div class="rs-circle" data-idx="3">&#x1F3B8;</div>' +
                '</div>' +
                '<div id="rsJudgment" style="text-align:center;font-size:15px;font-weight:600;min-height:22px;margin-top:12px;"></div>' +
                '<div style="text-align:center;margin-top:6px;font-size:12px;color:var(--text-muted);">第 <span id="rsPhaseNum">1</span> / ' + totalPhases + ' 轮</div>';

            var circles = document.querySelectorAll('#rsCircles .rs-circle');
            var judgment = document.getElementById('rsJudgment');
            var phaseNum = document.getElementById('rsPhaseNum');
            var currentPhase = 0;
            var activeIdx = -1;

            function lightUp() {
                if (!gameRunning) return;
                activeIdx = Math.floor(Math.random() * 4);
                circles.forEach(function(c) {
                    c.style.background = '#F0EAE0'; c.style.borderColor = '#D5C8B5';
                    c.style.boxShadow = ''; c.style.transform = '';
                });
                circles[activeIdx].style.background = '#D0C0A0';
                circles[activeIdx].style.borderColor = '#B09878';
                circles[activeIdx].style.boxShadow = '0 0 16px rgba(180,150,120,0.4)';
                circles[activeIdx].style.transform = 'scale(1.08)';
                judgment.textContent = '';

                var windowMs = bondCfg.timingWindow * (1 - currentPhase * 0.12);
                var timeout = setTimeout(function() {
                    if (activeIdx >= 0 && gameRunning) {
                        circles[activeIdx].style.background = '#D08080';
                        circles[activeIdx].style.borderColor = '#C06060';
                        circles[activeIdx].style.boxShadow = '0 0 12px rgba(200,100,100,0.3)';
                        circles[activeIdx].style.transform = '';
                        judgment.innerHTML = '慢了……';
                        addMistake();
                        updateScore(-6);
                        activeIdx = -1;
                    }
                }, windowMs);

                circles.forEach(function(c) {
                    c.onclick = function() {
                        if (!gameRunning) return;
                        var idx = parseInt(c.getAttribute('data-idx'));
                        if (idx === activeIdx) {
                            clearTimeout(timeout);
                            c.style.background = '#80B080'; c.style.borderColor = '#6A9A6A';
                            c.style.boxShadow = '0 0 12px rgba(100,160,100,0.3)'; c.style.transform = '';
                            judgment.innerHTML = '完美！';
                            updateScore(10);
                            activeIdx = -1;
                            currentPhase++;
                            if (currentPhase >= totalPhases) { updateScore(10); endGame(); }
                            else { phaseNum.textContent = currentPhase + 1; setTimeout(lightUp, 500 + Math.random() * 400); }
                        } else if (activeIdx >= 0) {
                            judgment.innerHTML = '按错了……';
                            updateScore(-3);
                        }
                    };
                });
            }

            setTimeout(lightUp, 600);
            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow * 6);
        }

        // ==================== GENTLE OFFER ====================
        function startGentleOffer() {
            initMistakeDots();
            var attempts = Math.max(1, bondCfg.maxMistakes);
            gameArea.innerHTML =
                '<div style="position:relative;height:150px;margin:10px 0;">' +
                '<div style="position:absolute;left:20px;top:50%;transform:translateY(-50%);font-size:44px;">&#x1F9D1;&#x1F356;</div>' +
                '<div id="goNervous" style="position:absolute;right:80px;top:30px;font-size:14px;transition:color 0.3s;"></div>' +
                '<div id="goAnimal" style="position:absolute;right:20px;top:50%;transform:translateY(-50%);font-size:44px;transition:right 0.1s linear;">' + bondCfg.animalEmoji + '</div>' +
                '</div>' +
                '<button class="go-btn" id="goBtn">把握时机！</button>' +
                '<div style="text-align:center;margin-top:6px;font-size:12px;color:var(--text-muted);">还剩 <span id="goAttempts">' + attempts + '</span> 次机会</div>';

            var goAnimal = document.getElementById('goAnimal');
            var goNervous = document.getElementById('goNervous');
            var goBtn = document.getElementById('goBtn');
            var goAttempts = document.getElementById('goAttempts');
            var currentAttempt = attempts;
            var animalDist = 380;
            var readyMoment = false;
            var readyTimeout = null;

            function resetApproach() {
                if (!gameRunning) return;
                animalDist = 300 + Math.random() * 120;
                readyMoment = false;
                goNervous.textContent = '';
                goAnimal.style.right = animalDist + 'px';
                goAnimal.style.opacity = '1';
                goBtn.textContent = '把握时机！';

                var windowMs = bondCfg.timingWindow;
                var greenTime = 500 + Math.random() * (windowMs * 0.5);
                readyTimeout = setTimeout(function() {
                    if (!gameRunning) return;
                    readyMoment = true;
                    goNervous.innerHTML = '&#x1F7E2;';
                    goNervous.style.color = '#6A8A5A';
                    goBtn.textContent = '就是现在！';
                    goBtn.style.background = '#F0F5EC';
                    goBtn.style.borderColor = '#80A080';
                    setTimeout(function() {
                        if (readyMoment && gameRunning) {
                            readyMoment = false;
                            goNervous.innerHTML = '它等不及了……';
                            goNervous.style.color = '#B08040';
                            goBtn.textContent = '把握时机！';
                            goBtn.style.background = '';
                            goBtn.style.borderColor = '';
                            updateScore(-8);
                            currentAttempt--;
                            goAttempts.textContent = currentAttempt;
                            if (currentAttempt <= 0) { endGame(); return; }
                            setTimeout(resetApproach, 800);
                        }
                    }, 700);
                }, windowMs * 0.25);
            }

            goBtn.addEventListener('click', function() {
                if (!gameRunning) return;
                clearTimeout(readyTimeout);
                if (readyMoment) {
                    updateScore(35);
                    goNervous.innerHTML = '太好了！';
                    goNervous.style.color = '#6A8A5A';
                    goAnimal.style.right = '60px';
                    setTimeout(function() { endGame(); }, 500);
                } else {
                    updateScore(-10);
                    addMistake();
                    goNervous.innerHTML = '太早了！它被吓到了……';
                    goNervous.style.color = '#C05040';
                    goAnimal.style.right = Math.min(450, animalDist + 120) + 'px';
                    currentAttempt--;
                    goAttempts.textContent = currentAttempt;
                    if (currentAttempt <= 0) { endGame(); return; }
                    setTimeout(resetApproach, 1000);
                }
                readyMoment = false;
            });

            resetApproach();
            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow * 5);
        }

        // ==================== FOLLOW MOVEMENT ====================
        function startFollowMovement() {
            initMistakeDots();
            gameArea.innerHTML =
                '<div id="fmZone" style="width:100%;height:200px;background:#F0EAE0;border-radius:var(--radius);position:relative;overflow:hidden;cursor:none;">' +
                '<div id="fmAnimal" style="position:absolute;font-size:36px;transition:left 0.05s linear,top 0.05s linear;">' + bondCfg.animalEmoji + '</div>' +
                '<div id="fmComfort" style="position:absolute;border:2px dashed rgba(180,150,120,0.5);border-radius:50%;pointer-events:none;"></div>' +
                '<div id="fmPlayer" style="position:absolute;width:14px;height:14px;border-radius:50%;background:#C5A080;box-shadow:0 0 8px rgba(180,150,120,0.4);pointer-events:none;transition:left 0.05s,top 0.05s;"></div>' +
                '</div>' +
                '<div style="text-align:center;margin-top:6px;font-size:12px;color:var(--text-muted);">保持光标在' + bondCfg.animalName + '的舒适圈内</div>';

            var fmZone = document.getElementById('fmZone');
            var fmAnimal = document.getElementById('fmAnimal');
            var fmComfort = document.getElementById('fmComfort');
            var fmPlayer = document.getElementById('fmPlayer');
            var zoneRect = fmZone.getBoundingClientRect();
            var zoneW = zoneRect.width, zoneH = zoneRect.height;
            var animalX = zoneW / 2, animalY = zoneH / 2;
            var playerX = zoneW / 2, playerY = zoneH / 2;
            var time = 0;
            var inZone = true;
            var comfortRadius = bondCfg.zoneSize;
            var exitCount = 0;

            fmComfort.style.width = (comfortRadius * 2) + 'px';
            fmComfort.style.height = (comfortRadius * 2) + 'px';
            fmAnimal.style.left = animalX + 'px';
            fmAnimal.style.top = animalY + 'px';
            fmPlayer.style.left = playerX + 'px';
            fmPlayer.style.top = playerY + 'px';

            function updateAnimal(t) {
                var sp = bondCfg.speed / 500;
                animalX = zoneW/2 + Math.sin(t * sp * 1.3) * (zoneW * 0.35);
                animalY = zoneH/2 + Math.cos(t * sp * 0.9) * (zoneH * 0.3);
                fmAnimal.style.left = animalX + 'px';
                fmAnimal.style.top = animalY + 'px';
                fmComfort.style.left = (animalX - comfortRadius) + 'px';
                fmComfort.style.top = (animalY - comfortRadius) + 'px';
            }

            fmZone.addEventListener('mousemove', function(e) {
                if (!gameRunning) return;
                var rect = fmZone.getBoundingClientRect();
                playerX = e.clientX - rect.left;
                playerY = e.clientY - rect.top;
                fmPlayer.style.left = playerX + 'px';
                fmPlayer.style.top = playerY + 'px';
            });
            fmZone.addEventListener('touchmove', function(e) {
                e.preventDefault();
                if (!gameRunning) return;
                var rect = fmZone.getBoundingClientRect();
                playerX = e.touches[0].clientX - rect.left;
                playerY = e.touches[0].clientY - rect.top;
                fmPlayer.style.left = playerX + 'px';
                fmPlayer.style.top = playerY + 'px';
            });

            updateAnimal(0);
            var gameInterval = setInterval(function() {
                if (!gameRunning) { clearInterval(gameInterval); return; }
                time += 0.1;
                updateAnimal(time);
                var dist = Math.sqrt((playerX - animalX) ** 2 + (playerY - animalY) ** 2);
                var nowInZone = dist <= comfortRadius;
                if (!nowInZone && inZone) {
                    exitCount++;
                    if (exitCount >= 3) { addMistake(); updateScore(-6); exitCount = 0; }
                }
                if (nowInZone) { exitCount = 0; updateScore(0.3); }
                inZone = nowInZone;
                comfortRadius = bondCfg.zoneSize * (1 - time / (bondCfg.timingWindow / 100));
                fmComfort.style.width = (comfortRadius * 2) + 'px';
                fmComfort.style.height = (comfortRadius * 2) + 'px';
            }, 50);

            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow);
        }

        // ==================== ECHO CALL ====================
        function startEchoCall() {
            initMistakeDots();
            var totalPhases = bondCfg.phases + (bondCfg.bonusPhase ? 1 : 0);
            gameArea.innerHTML =
                '<div style="text-align:center;font-size:13px;color:var(--text-secondary);margin-bottom:6px;">记住' + bondCfg.animalName + '的呼唤顺序</div>' +
                '<div class="ec-display" id="ecPads">' +
                '<div class="ec-pad pad-0" data-idx="0"></div>' +
                '<div class="ec-pad pad-1" data-idx="1"></div>' +
                '<div class="ec-pad pad-2" data-idx="2"></div>' +
                '<div class="ec-pad pad-3" data-idx="3"></div>' +
                '</div>' +
                '<div class="ec-status" id="ecStatus">注意看……</div>' +
                '<div style="text-align:center;margin-top:6px;font-size:12px;color:var(--text-muted);">第 <span id="ecPhaseNum">1</span> / ' + totalPhases + ' 轮 · 长度 <span id="ecSeqLen">2</span></div>';

            var pads = document.querySelectorAll('#ecPads .ec-pad');
            var statusEl = document.getElementById('ecStatus');
            var phaseNum = document.getElementById('ecPhaseNum');
            var seqLen = document.getElementById('ecSeqLen');
            var sequence = [];
            var playerIdx = 0;
            var currentPhase = 0;
            var showingSequence = false;
            var playerTurn = false;
            var seqLength = 2;

            function showSequence() {
                if (!gameRunning) return;
                showingSequence = true; playerTurn = false; playerIdx = 0;
                sequence = [];
                for (var i = 0; i < seqLength; i++) sequence.push(Math.floor(Math.random() * 4));
                statusEl.innerHTML = '记住呼唤顺序……';
                pads.forEach(function(p) { p.style.pointerEvents = 'none'; });
                var i = 0;
                var showSpeed = Math.max(200, bondCfg.speed * 3);
                var showInterval = setInterval(function() {
                    if (!gameRunning || !showingSequence) { clearInterval(showInterval); return; }
                    if (i > 0) pads[sequence[i-1]].classList.remove('glow');
                    if (i >= sequence.length) {
                        clearInterval(showInterval);
                        showingSequence = false; playerTurn = true; playerIdx = 0;
                        statusEl.innerHTML = '轮到你了！按相同顺序回应';
                        pads.forEach(function(p) { p.style.pointerEvents = 'auto'; });
                        return;
                    }
                    pads[sequence[i]].classList.add('glow');
                    i++;
                }, showSpeed);
            }

            pads.forEach(function(pad) {
                pad.addEventListener('click', function() {
                    if (!gameRunning || !playerTurn) return;
                    var idx = parseInt(pad.getAttribute('data-idx'));
                    if (idx === sequence[playerIdx]) {
                        pad.classList.add('glow');
                        setTimeout(function() { pad.classList.remove('glow'); }, 200);
                        playerIdx++;
                        updateScore(3);
                        if (playerIdx >= sequence.length) {
                            currentPhase++;
                            updateScore(12);
                            phaseNum.textContent = currentPhase + 1;
                            if (currentPhase >= totalPhases) {
                                updateScore(10);
                                statusEl.innerHTML = '完美的回声！';
                                endGame();
                            } else {
                                seqLength = Math.min(8, seqLength + 1);
                                seqLen.textContent = seqLength;
                                statusEl.innerHTML = '正确！准备下一轮……';
                                playerTurn = false;
                                pads.forEach(function(p) { p.style.pointerEvents = 'none'; });
                                setTimeout(showSequence, 800);
                            }
                        }
                    } else {
                        pad.classList.add('wrong');
                        setTimeout(function() { pad.classList.remove('wrong'); }, 400);
                        addMistake();
                        updateScore(-8);
                        statusEl.innerHTML = '顺序错了！重新听……';
                        playerTurn = false;
                        pads.forEach(function(p) { p.style.pointerEvents = 'none'; });
                        if (gameRunning) setTimeout(showSequence, 600);
                    }
                });
            });

            setTimeout(showSequence, 500);
            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow * 5);
        }

        // ==================== GAZE LOCK ====================
        function startGazeLock() {
            initMistakeDots();
            gameArea.innerHTML =
                '<div id="glScene" style="position:relative;height:200px;cursor:none;background:#ECEAE0;border-radius:var(--radius);">' +
                '<div id="glEyes" style="position:absolute;font-size:60px;transition:left 0.5s ease-in-out,top 0.5s ease-in-out;">&#x1F440;</div>' +
                '<div id="glZone" style="position:absolute;border:2px solid rgba(180,150,120,0.4);border-radius:50%;pointer-events:none;"></div>' +
                '<div id="glCursor" style="position:absolute;width:10px;height:10px;border-radius:50%;background:#C5A080;pointer-events:none;box-shadow:0 0 8px rgba(180,150,120,0.5);"></div>' +
                '</div>' +
                '<div style="height:4px;background:#F0EAE0;border-radius:2px;margin-top:10px;overflow:hidden;">' +
                '<div id="glMeterFill" style="height:100%;width:50%;background:#C5B090;border-radius:2px;transition:width 0.5s;"></div></div>' +
                '<div style="text-align:center;margin-top:6px;font-size:12px;color:var(--text-muted);">保持光标在它的视线里，不要移开目光</div>';

            var glScene = document.getElementById('glScene');
            var glEyes = document.getElementById('glEyes');
            var glZone = document.getElementById('glZone');
            var glCursor = document.getElementById('glCursor');
            var glMeterFill = document.getElementById('glMeterFill');
            var sceneRect = glScene.getBoundingClientRect();
            var cx = sceneRect.width / 2, cy = sceneRect.height / 2;
            var playerX = cx, playerY = cy;
            var zoneRadius = bondCfg.zoneSize;
            var gazeMeter = 50;
            var time = 0;

            glZone.style.width = (zoneRadius * 2) + 'px';
            glZone.style.height = (zoneRadius * 2) + 'px';
            glEyes.style.left = cx + 'px'; glEyes.style.top = cy + 'px';
            glEyes.style.transform = 'translate(-50%,-50%)';
            glZone.style.left = (cx - zoneRadius) + 'px';
            glZone.style.top = (cy - zoneRadius) + 'px';
            glCursor.style.left = playerX + 'px'; glCursor.style.top = playerY + 'px';

            glScene.addEventListener('mousemove', function(e) {
                if (!gameRunning) return;
                var rect = glScene.getBoundingClientRect();
                playerX = e.clientX - rect.left;
                playerY = e.clientY - rect.top;
                glCursor.style.left = playerX + 'px';
                glCursor.style.top = playerY + 'px';
            });

            var gazeInterval = setInterval(function() {
                if (!gameRunning) { clearInterval(gazeInterval); return; }
                time += 0.15;
                var sp = bondCfg.speed / 300;
                cx = sceneRect.width/2 + Math.sin(time * sp * 1.7) * (sceneRect.width * 0.25);
                cy = sceneRect.height/2 + Math.cos(time * sp * 1.1) * (sceneRect.height * 0.2);
                glEyes.style.left = cx + 'px'; glEyes.style.top = cy + 'px';
                glZone.style.left = (cx - zoneRadius) + 'px';
                glZone.style.top = (cy - zoneRadius) + 'px';
                var dist = Math.sqrt((playerX - cx) ** 2 + (playerY - cy) ** 2);
                if (dist <= zoneRadius) {
                    gazeMeter = Math.min(100, gazeMeter + 0.8);
                    updateScore(0.2);
                } else {
                    gazeMeter = Math.max(0, gazeMeter - 1.5);
                    if (gazeMeter <= 5) { addMistake(); updateScore(-10); gazeMeter = 25; }
                }
                glMeterFill.style.width = gazeMeter + '%';
                zoneRadius = bondCfg.zoneSize * (0.8 + 0.2 * Math.sin(time * 0.5));
                glZone.style.width = (zoneRadius * 2) + 'px';
                glZone.style.height = (zoneRadius * 2) + 'px';
                if (Math.random() < 0.02) {
                    glEyes.style.opacity = '0.1';
                    setTimeout(function() { glEyes.style.opacity = '1'; }, 150);
                }
            }, 50);

            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow);
        }

        // ==================== 3秒倒计时 ====================
        function showCountdown(callback) {
            var overlay = document.createElement('div');
            overlay.className = 'countdown-overlay';
            var num = document.createElement('div');
            num.className = 'countdown-num';
            overlay.appendChild(num);
            gameArea.appendChild(overlay);
            var count = 3;
            function tick() {
                if (count <= 0) { overlay.remove(); callback(); return; }
                num.textContent = count;
                num.style.animation = 'none';
                num.offsetHeight;
                num.style.animation = 'countPop 0.7s ease';
                count--;
                setTimeout(tick, 800);
            }
            tick();
        }

        // ==================== START ====================
        updateScore(0);
        initMistakeDots();
        showCountdown(function() {
            switch (bondCfg.type) {
                case 'SLOW_APPROACH':   startSlowApproach(); break;
                case 'RHYTHM_SYNC':     startRhythmSync(); break;
                case 'GENTLE_OFFER':    startGentleOffer(); break;
                case 'FOLLOW_MOVEMENT': startFollowMovement(); break;
                case 'ECHO_CALL':       startEchoCall(); break;
                case 'GAZE_LOCK':       startGazeLock(); break;
                default: endGame(); break;
            }
        });
    })();
    </script>
    <% } %>

</body>
</html>
