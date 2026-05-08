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
        .att-btn .att-emoji { font-size: 36px; display: block; margin-bottom: 6px; }
        .att-btn .att-name { font-size: 18px; font-weight: 700; }
        .att-btn .att-desc { font-size: 13px; color: #8a7a6a; margin-top: 3px; }

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

        /* Bond Event Modal Overlay */
        .bond-modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.80); z-index: 9999;
            display: flex; align-items: center; justify-content: center;
            animation: fadeIn 0.3s ease;
            backdrop-filter: blur(4px);
        }
        .bond-modal {
            background: linear-gradient(135deg, #1a2230, #1d2a38);
            border: 2px solid #f0c27a; border-radius: 20px;
            padding: 24px; width: 92%; max-width: 520px; max-height: 90vh;
            overflow-y: auto; position: relative;
            animation: bondModalIn 0.5s ease;
            box-shadow: 0 0 60px rgba(240,194,122,0.25);
        }
        @keyframes bondModalIn {
            from { opacity: 0; transform: scale(0.9) translateY(20px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }
        .bond-modal .be-header { text-align: center; margin-bottom: 14px; }
        .bond-modal .be-title {
            font-size: 22px; font-weight: 700; color: #f0c27a; margin-bottom: 4px;
        }
        .bond-modal .be-scene {
            font-size: 15px; color: #c0d0e0; line-height: 1.7; margin-bottom: 12px;
            font-style: italic;
        }
        .bond-modal .be-instruction {
            font-size: 14px; color: #a0b0c0; margin-bottom: 16px;
            padding: 10px 16px; background: rgba(240,194,122,0.1);
            border-radius: 10px;
        }
        .bond-modal .be-game-area {
            background: #111820; border-radius: 16px;
            padding: 20px; min-height: 200px; position: relative;
            overflow: hidden; user-select: none; cursor: default;
            border: 1px solid #2a3a4a;
        }
        .bond-modal .be-trait-hint {
            margin-top: 14px; font-size: 13px; color: #90b090;
            text-align: center; padding: 6px 14px;
            background: rgba(120,200,120,0.08); border-radius: 10px;
        }
        .bond-modal .be-score-bar {
            height: 6px; background: #1a202a; border-radius: 3px;
            margin-top: 14px; overflow: hidden;
        }
        .bond-modal .be-score-fill {
            height: 100%; background: linear-gradient(90deg, #e04040, #f0c040, #40c040);
            border-radius: 3px; transition: width 0.3s;
        }
        .bond-modal .be-mistakes {
            text-align: center; margin-top: 8px; font-size: 12px; color: #e08060;
        }
        .bond-modal .be-mistakes .dot { color: #f04040; }

        /* Bond result */
        .bond-result {
            background: #1e2d1e; border-radius: 14px; padding: 16px 18px;
            margin-bottom: 14px; border-left: 3px solid #f0c27a;
            font-size: 14px; line-height: 1.8; color: #c4b5a0;
            white-space: pre-line; animation: fadeIn 0.5s ease;
        }
        .bond-result.big-success { border-left-color: #FFD700; background: #2a3018; }
        .bond-result.crit-fail { border-left-color: #e04040; background: #2a1818; }

        /* Slow Approach game */
        .sa-track { position: relative; height: 160px; margin: 10px 0; }
        .sa-animal { position: absolute; top: 0; left: 50%; transform: translateX(-50%); font-size: 48px; transition: transform 0.1s; }
        .sa-animal.alert { transform: translateX(-50%) scale(1.15); filter: brightness(1.3) drop-shadow(0 0 8px #ff6040); }
        .sa-player { position: absolute; bottom: 0; left: 50%; transform: translateX(-50%); font-size: 28px; transition: bottom 0.05s; }
        .sa-progress { position: absolute; left: 55%; top: 60px; bottom: 60px; width: 8px; background: #2a3a2a; border-radius: 4px; }
        .sa-progress-fill { width: 100%; background: linear-gradient(0deg, #40c040, #f0c040, #e04040); border-radius: 4px; transition: height 0.05s; position: absolute; bottom: 0; }
        .sa-btn { display: block; width: 100%; padding: 16px; font-size: 18px; font-weight: 700; border: 2px solid #5a7a4a; border-radius: 14px; background: linear-gradient(135deg, #2d3d1f, #3d4d2f); color: #c0d0a0; cursor: pointer; font-family: inherit; transition: all 0.2s; }
        .sa-btn:active, .sa-btn.holding { background: linear-gradient(135deg, #4d5d3f, #5d6d4f); border-color: #f0c040; }

        /* Rhythm Sync game */
        .rs-circles { display: flex; justify-content: center; gap: 20px; margin: 30px 0; }
        .rs-circle { width: 70px; height: 70px; border-radius: 50%; background: #1a2a1a; border: 3px solid #3a5a3a; transition: all 0.15s; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 28px; }
        .rs-circle.active { background: #f0c27a; border-color: #FFD700; box-shadow: 0 0 24px rgba(240,194,122,0.6); transform: scale(1.1); }
        .rs-circle.hit { background: #40c040; border-color: #80ff80; box-shadow: 0 0 16px rgba(64,255,64,0.4); }
        .rs-circle.miss { background: #c04040; border-color: #ff4040; box-shadow: 0 0 16px rgba(255,64,64,0.4); }
        .rs-judgment { text-align: center; font-size: 16px; font-weight: 700; min-height: 24px; margin-top: 12px; }

        /* Gentle Offer game */
        .go-scene { position: relative; height: 150px; margin: 10px 0; }
        .go-hand { position: absolute; left: 20px; top: 50%; transform: translateY(-50%); font-size: 44px; }
        .go-animal { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); font-size: 44px; transition: right 0.1s linear; }
        .go-nervous { position: absolute; right: 80px; top: 30px; font-size: 14px; transition: color 0.3s; }
        .go-btn { display: block; width: 100%; padding: 16px; font-size: 18px; font-weight: 700; border: 2px solid #5a7a4a; border-radius: 14px; background: linear-gradient(135deg, #2d3d1f, #3d4d2f); color: #c0d0a0; cursor: pointer; font-family: inherit; }

        /* Follow Movement game */
        .fm-zone { width: 100%; height: 200px; background: radial-gradient(ellipse at center, #1a2a2a, #0d1515); border-radius: 16px; position: relative; overflow: hidden; cursor: none; }
        .fm-animal { position: absolute; font-size: 36px; transition: left 0.05s linear, top 0.05s linear; }
        .fm-comfort { position: absolute; border: 2px dashed rgba(100,200,100,0.4); border-radius: 50%; pointer-events: none; }
        .fm-player { position: absolute; width: 16px; height: 16px; border-radius: 50%; background: #f0c040; box-shadow: 0 0 12px rgba(240,194,64,0.5); pointer-events: none; transition: left 0.05s, top 0.05s; }
        .fm-score-text { text-align: center; font-size: 13px; color: #8a9a7a; margin-top: 8px; }

        /* Steady Breath game */
        .sb-visual { text-align: center; margin: 20px 0; }
        .sb-circle { display: inline-block; width: 120px; height: 120px; border-radius: 50%; background: #1a2a3a; border: 3px solid #4a6a8a; transition: transform 0.1s; }
        .sb-circle.inhale { transform: scale(1.3); border-color: #80c0e0; box-shadow: 0 0 30px rgba(128,192,224,0.3); }
        .sb-circle.exhale { transform: scale(0.7); border-color: #406080; }
        .sb-label { font-size: 16px; margin-top: 10px; font-weight: 700; }
        .sb-target-zone { display: inline-block; border: 2px dashed #5a8a5a; border-radius: 50%; position: absolute; transition: all 0.1s; }
        .sb-btn { display: block; width: 100%; padding: 20px; font-size: 20px; font-weight: 700; border: 2px solid #4a6a8a; border-radius: 14px; background: linear-gradient(135deg, #1a2a3a, #2a3a4a); color: #a0c0d0; cursor: pointer; font-family: inherit; }
        .sb-btn:active, .sb-btn.holding { background: linear-gradient(135deg, #3a4a5a, #4a5a6a); border-color: #80c0e0; }

        /* Gaze Lock game */
        .gl-scene { position: relative; height: 200px; cursor: none; background: radial-gradient(circle, #111820 60%, #0a1018 100%); border-radius: 16px; }
        .gl-eyes { position: absolute; font-size: 60px; top: 50%; left: 50%; transform: translate(-50%,-50%); transition: left 0.5s ease-in-out, top 0.5s ease-in-out; }
        .gl-zone { position: absolute; border: 2px solid rgba(240,194,64,0.3); border-radius: 50%; pointer-events: none; }
        .gl-cursor { position: absolute; width: 12px; height: 12px; border-radius: 50%; background: #f0c040; pointer-events: none; box-shadow: 0 0 12px rgba(240,194,64,0.6); }
        .gl-meter { height: 4px; background: #1a202a; border-radius: 2px; margin-top: 10px; overflow: hidden; }
        .gl-meter-fill { height: 100%; background: linear-gradient(90deg, #e04040, #f0c27a, #40c040); border-radius: 2px; transition: width 0.5s; }

        .hidden { display: none !important; }

        @media (max-width: 500px) {
            .attitude-grid { grid-template-columns: repeat(2, 1fr); }
            .emotion-bars { grid-template-columns: 1fr; }
            .rs-circles { gap: 12px; }
            .rs-circle { width: 55px; height: 55px; font-size: 22px; }
            .sa-animal { font-size: 36px; }
            .sa-player { font-size: 22px; }
            .go-hand, .go-animal { font-size: 34px; }
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

        <!-- Bond result (after mini-game finishes) -->
        <%
            String bondResult = (String) request.getAttribute("bondResult");
            if (bondResult != null && !bondResult.isEmpty()) {
        %>
        <div class="bond-result"><%= bondResult %></div>
        <% } %>

        <!-- Bond Event Modal -->
        <%
            BondEvent bondEvent = (BondEvent) request.getAttribute("bondEvent");
        %>
        <% if (bondEvent != null) { %>
        <div class="bond-modal-overlay" id="bondModalOverlay">
            <div class="bond-modal" id="bondEvent">
                <div class="be-header">
                    <div class="be-title">&#x2728; <%= bondEvent.getAnimalEmoji() %> <%= bondEvent.getAnimalName() %>对你产生了兴趣</div>
                    <div class="be-scene"><%= bondEvent.getType().scene %></div>
                    <div class="be-instruction">&#x1F3AE; <%= bondEvent.getType().instruction %></div>
                </div>
                <div class="be-game-area" id="gameArea">
                    <div style="text-align:center;padding:60px 20px;color:#8a9a7a;">
                        &#x1F3AE; 小游戏加载中……
                    </div>
                </div>
                <div class="be-score-bar"><div class="be-score-fill" id="scoreFill" style="width:50%"></div></div>
                <div class="be-mistakes" id="mistakeDots"></div>
                <% if (bondEvent.getTraitModifierText() != null && !bondEvent.getTraitModifierText().isEmpty()) { %>
                <div class="be-trait-hint">&#x1F31F; <%= bondEvent.getTraitModifierText() %></div>
                <% } %>
                <form method="post" action="<%= request.getContextPath() %>/map" id="bondForm">
                    <input type="hidden" name="action" value="bond_event">
                    <input type="hidden" name="score" id="bondScore" value="50">
                </form>
            </div>
        </div>
        <% } %>

        <!-- Attitude buttons (hidden during bond event) -->
        <div id="attitudeSection">
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
                    <span class="att-name"><%= a.label %><%= bypassHint != null ? " ⭐" : "" %></span>
                    <span class="att-desc"><%= onCooldown ? "冷却中" : (bypassHint != null ? bypassHint : a.desc) %></span>
                </button>
                <% } %>
            </div>
        </form>
        </div>

        <a href="<%= request.getContextPath() %>/map" class="btn-back">&#x1F5FA; 放弃本次遭遇，返回地图</a>
    </div>

    <!-- Bond Event Mini-Games JS -->
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
                var target = dots[mistakes - 1];
                target.style.color = '#e04040';
                target.innerHTML = '&#x1F494;';
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
            msg.style.cssText = 'text-align:center;padding:20px;color:#f0c27a;font-size:18px;font-weight:700;animation:fadeIn 0.5s;';
            msg.textContent = score >= 90 ? '\u{1F31F} 完美！' : score >= 55 ? '\u{1F44D} 不错！' : score >= 25 ? '\u{1F614} 差一点……' : '\u{1F625} 失败了……';
            gameArea.appendChild(msg);
            setTimeout(function() { bondForm.submit(); }, 800);
        }

        function initMistakeDots() {
            var html = '';
            for (var i = 0; i < bondCfg.maxMistakes; i++) {
                html += '<span style="color:#40c040;">&#x2764;&#xFE0F;</span> ';
            }
            mistakeDots.innerHTML = html;
        }

        // ==================== GAME 1: SLOW APPROACH ====================
        function startSlowApproach() {
            initMistakeDots();
            var totalPhases = bondCfg.phases + (bondCfg.bonusPhase ? 1 : 0);
            gameArea.innerHTML =
                '<div style="position:relative;height:160px;margin:10px 0;">' +
                '<div id="saAnimal" style="position:absolute;top:0;left:50%;transform:translateX(-50%);font-size:48px;transition:transform 0.1s;">' + bondCfg.animalEmoji + '</div>' +
                '<div id="saProg" style="position:absolute;left:55%;top:60px;bottom:60px;width:8px;background:#2a3a2a;border-radius:4px;">' +
                '<div id="saProgFill" style="width:100%;background:linear-gradient(0deg,#40c040,#f0c040);border-radius:4px;position:absolute;bottom:0;height:0%;transition:height 0.05s;"></div></div>' +
                '<div id="saPlayer" style="position:absolute;bottom:5%;left:50%;transform:translateX(-50%);font-size:28px;transition:bottom 0.05s;">&#x1F9D1;</div>' +
                '</div>' +
                '<button class="sa-btn" id="saBtn" style="display:block;width:100%;padding:16px;font-size:18px;font-weight:700;border:2px solid #5a7a4a;border-radius:14px;background:linear-gradient(135deg,#2d3d1f,#3d4d2f);color:#c0d0a0;cursor:pointer;font-family:inherit;">&#x1F422; 按住前进</button>' +
                '<div style="text-align:center;margin-top:8px;font-size:12px;color:#8a9a7a;">' + bondCfg.animalName + '回头时立刻松手！第 <span id="saPhaseNum">1</span>/' + totalPhases + ' 阶段</div>';

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
                animal.style.filter = 'brightness(1.3) drop-shadow(0 0 8px #ff6040)';
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

            btn.addEventListener('mousedown', function(e) { e.preventDefault(); isHolding = true; btn.style.background = 'linear-gradient(135deg,#4d5d3f,#5d6d4f)'; btn.style.borderColor = '#f0c040'; });
            btn.addEventListener('mouseup', function(e) { e.preventDefault(); isHolding = false; btn.style.background = ''; btn.style.borderColor = ''; });
            btn.addEventListener('mouseleave', function(e) { isHolding = false; btn.style.background = ''; btn.style.borderColor = ''; });
            btn.addEventListener('touchstart', function(e) { e.preventDefault(); isHolding = true; btn.style.background = 'linear-gradient(135deg,#4d5d3f,#5d6d4f)'; btn.style.borderColor = '#f0c040'; });
            btn.addEventListener('touchend', function(e) { e.preventDefault(); isHolding = false; btn.style.background = ''; btn.style.borderColor = ''; });

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

        // ==================== GAME 2: RHYTHM SYNC ====================
        function startRhythmSync() {
            initMistakeDots();
            var totalPhases = bondCfg.phases + (bondCfg.bonusPhase ? 1 : 0);
            gameArea.innerHTML =
                '<div style="display:flex;justify-content:center;gap:20px;margin:30px 0;" id="rsCircles">' +
                '<div class="rs-circle" data-idx="0" style="width:70px;height:70px;border-radius:50%;background:#1a2a1a;border:3px solid #3a5a3a;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:28px;transition:all 0.15s;">&#x1F3B5;</div>' +
                '<div class="rs-circle" data-idx="1" style="width:70px;height:70px;border-radius:50%;background:#1a2a1a;border:3px solid #3a5a3a;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:28px;transition:all 0.15s;">&#x1F3B6;</div>' +
                '<div class="rs-circle" data-idx="2" style="width:70px;height:70px;border-radius:50%;background:#1a2a1a;border:3px solid #3a5a3a;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:28px;transition:all 0.15s;">&#x1F3B7;</div>' +
                '<div class="rs-circle" data-idx="3" style="width:70px;height:70px;border-radius:50%;background:#1a2a1a;border:3px solid #3a5a3a;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:28px;transition:all 0.15s;">&#x1F3B8;</div>' +
                '</div>' +
                '<div id="rsJudgment" style="text-align:center;font-size:16px;font-weight:700;min-height:24px;margin-top:12px;"></div>' +
                '<div style="text-align:center;margin-top:8px;font-size:12px;color:#8a9a7a;">第 <span id="rsPhaseNum">1</span> / ' + totalPhases + ' 轮</div>';

            var circles = document.querySelectorAll('#rsCircles > div');
            var judgment = document.getElementById('rsJudgment');
            var phaseNum = document.getElementById('rsPhaseNum');
            var currentPhase = 0;
            var activeIdx = -1;

            function lightUp() {
                if (!gameRunning) return;
                activeIdx = Math.floor(Math.random() * 4);
                circles.forEach(function(c) {
                    c.style.background = '#1a2a1a'; c.style.borderColor = '#3a5a3a';
                    c.style.boxShadow = ''; c.style.transform = '';
                });
                circles[activeIdx].style.background = '#f0c27a';
                circles[activeIdx].style.borderColor = '#FFD700';
                circles[activeIdx].style.boxShadow = '0 0 24px rgba(240,194,122,0.6)';
                circles[activeIdx].style.transform = 'scale(1.1)';
                judgment.textContent = '';

                var windowMs = bondCfg.timingWindow * (1 - currentPhase * 0.12);
                var timeout = setTimeout(function() {
                    if (activeIdx >= 0 && gameRunning) {
                        circles[activeIdx].style.background = '#c04040';
                        circles[activeIdx].style.borderColor = '#ff4040';
                        circles[activeIdx].style.boxShadow = '0 0 16px rgba(255,64,64,0.4)';
                        circles[activeIdx].style.transform = '';
                        judgment.innerHTML = '&#x1F615; 慢了……';
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
                            c.style.background = '#40c040'; c.style.borderColor = '#80ff80';
                            c.style.boxShadow = '0 0 16px rgba(64,255,64,0.4)'; c.style.transform = '';
                            judgment.innerHTML = ['&#x1F44D; 漂亮！','&#x2728; 完美！','&#x1F389; 节奏感满分！'][Math.floor(Math.random()*3)];
                            updateScore(10);
                            activeIdx = -1;
                            currentPhase++;
                            if (currentPhase >= totalPhases) { updateScore(10); endGame(); }
                            else { phaseNum.textContent = currentPhase + 1; setTimeout(lightUp, 500 + Math.random() * 400); }
                        } else if (activeIdx >= 0) {
                            judgment.innerHTML = '&#x1F937; 按错了……';
                            updateScore(-3);
                        }
                    };
                });
            }

            setTimeout(lightUp, 600);
            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow * 6);
        }

        // ==================== GAME 3: GENTLE OFFER ====================
        function startGentleOffer() {
            initMistakeDots();
            var attempts = Math.max(1, bondCfg.maxMistakes);
            gameArea.innerHTML =
                '<div style="position:relative;height:150px;margin:10px 0;">' +
                '<div style="position:absolute;left:20px;top:50%;transform:translateY(-50%);font-size:44px;">&#x1F9D1;&#x1F356;</div>' +
                '<div id="goNervous" style="position:absolute;right:80px;top:30px;font-size:14px;transition:color 0.3s;"></div>' +
                '<div id="goAnimal" style="position:absolute;right:20px;top:50%;transform:translateY(-50%);font-size:44px;transition:right 0.1s linear;">' + bondCfg.animalEmoji + '</div>' +
                '</div>' +
                '<button class="go-btn" id="goBtn" style="display:block;width:100%;padding:16px;font-size:18px;font-weight:700;border:2px solid #5a7a4a;border-radius:14px;background:linear-gradient(135deg,#2d3d1f,#3d4d2f);color:#c0d0a0;cursor:pointer;font-family:inherit;">&#x2728; 把握时机！</button>' +
                '<div style="text-align:center;margin-top:8px;font-size:12px;color:#8a9a7a;">还剩 <span id="goAttempts">' + attempts + '</span> 次机会</div>';

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
                goBtn.textContent = '\u{2728} 把握时机！';
                goBtn.style.background = 'linear-gradient(135deg,#2d3d1f,#3d4d2f)';
                goBtn.style.borderColor = '#5a7a4a';

                var windowMs = bondCfg.timingWindow;
                var greenTime = 500 + Math.random() * (windowMs * 0.5);

                readyTimeout = setTimeout(function() {
                    if (!gameRunning) return;
                    readyMoment = true;
                    goNervous.innerHTML = '&#x1F7E2;';
                    goNervous.style.color = '#40c040';
                    goBtn.textContent = '\u{2728} 就是现在！';
                    goBtn.style.background = 'linear-gradient(135deg,#3a5a2a,#5a7a3a)';
                    goBtn.style.borderColor = '#80c040';

                    setTimeout(function() {
                        if (readyMoment && gameRunning) {
                            readyMoment = false;
                            goNervous.innerHTML = '&#x1F614; 它等不及了……';
                            goNervous.style.color = '#e0a040';
                            goBtn.textContent = '\u{2728} 把握时机！';
                            goBtn.style.background = 'linear-gradient(135deg,#2d3d1f,#3d4d2f)';
                            goBtn.style.borderColor = '#5a7a4a';
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
                    goNervous.innerHTML = '&#x1F60A; 太好了！';
                    goNervous.style.color = '#80c080';
                    goAnimal.style.right = '60px';
                    setTimeout(function() { endGame(); }, 500);
                } else {
                    updateScore(-10);
                    addMistake();
                    goNervous.innerHTML = '&#x1F628; 太早了！它被吓到了……';
                    goNervous.style.color = '#e04040';
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

        // ==================== GAME 4: FOLLOW MOVEMENT ====================
        function startFollowMovement() {
            initMistakeDots();
            gameArea.innerHTML =
                '<div id="fmZone" style="width:100%;height:200px;background:radial-gradient(ellipse at center,#1a2a2a,#0d1515);border-radius:16px;position:relative;overflow:hidden;cursor:none;">' +
                '<div id="fmAnimal" style="position:absolute;font-size:36px;transition:left 0.05s linear,top 0.05s linear;">' + bondCfg.animalEmoji + '</div>' +
                '<div id="fmComfort" style="position:absolute;border:2px dashed rgba(100,200,100,0.4);border-radius:50%;pointer-events:none;"></div>' +
                '<div id="fmPlayer" style="position:absolute;width:16px;height:16px;border-radius:50%;background:#f0c040;box-shadow:0 0 12px rgba(240,194,64,0.5);pointer-events:none;transition:left 0.05s,top 0.05s;"></div>' +
                '</div>' +
                '<div style="text-align:center;margin-top:8px;font-size:12px;color:#8a9a7a;">&#x1F3AF; 保持光标在' + bondCfg.animalName + '的舒适圈内</div>';

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

        // ==================== GAME 5: STEADY BREATH ====================
        function startSteadyBreath() {
            initMistakeDots();
            var totalPhases = bondCfg.phases + (bondCfg.bonusPhase ? 2 : 0);
            gameArea.innerHTML =
                '<div style="text-align:center;margin:20px 0;">' +
                '<div id="sbCircle" style="display:inline-block;width:120px;height:120px;border-radius:50%;background:#1a2a3a;border:3px solid #4a6a8a;transition:transform 0.1s;"></div>' +
                '</div>' +
                '<div id="sbLabel" style="text-align:center;font-size:16px;font-weight:700;margin:10px 0;">&#x1F4A8; 准备开始</div>' +
                '<button id="sbBtn" style="display:block;width:100%;padding:20px;font-size:20px;font-weight:700;border:2px solid #4a6a8a;border-radius:14px;background:linear-gradient(135deg,#1a2a3a,#2a3a4a);color:#a0c0d0;cursor:pointer;font-family:inherit;">&#x1F33F; 按住吸气</button>' +
                '<div style="text-align:center;margin-top:8px;font-size:12px;color:#8a9a7a;">第 <span id="sbPhaseNum">1</span> / ' + totalPhases + ' 次呼吸</div>';

            var sbCircle = document.getElementById('sbCircle');
            var sbLabel = document.getElementById('sbLabel');
            var sbBtn = document.getElementById('sbBtn');
            var sbPhaseNum = document.getElementById('sbPhaseNum');
            var currentPhase = 0;
            var isHolding = false;
            var isInhaling = true;
            var breathProgress = 0;
            var breathSpeed = bondCfg.speed / 100;

            function resetBreath() {
                if (!gameRunning) return;
                isInhaling = true;
                breathProgress = 0;
                sbCircle.style.transform = 'scale(0.7)';
                sbCircle.style.borderColor = '#4a6a8a';
                sbCircle.style.boxShadow = '';
                sbLabel.innerHTML = '&#x1F4A8; 吸气……';
                sbBtn.textContent = '\u{1F33F} 按住吸气';
            }

            sbBtn.addEventListener('mousedown', function(e) { e.preventDefault(); isHolding = true; sbBtn.style.background = 'linear-gradient(135deg,#3a4a5a,#4a5a6a)'; sbBtn.style.borderColor = '#80c0e0'; });
            sbBtn.addEventListener('mouseup', function(e) { e.preventDefault(); isHolding = false; sbBtn.style.background = ''; sbBtn.style.borderColor = ''; });
            sbBtn.addEventListener('mouseleave', function(e) { isHolding = false; sbBtn.style.background = ''; sbBtn.style.borderColor = ''; });
            sbBtn.addEventListener('touchstart', function(e) { e.preventDefault(); isHolding = true; sbBtn.style.background = 'linear-gradient(135deg,#3a4a5a,#4a5a6a)'; sbBtn.style.borderColor = '#80c0e0'; });
            sbBtn.addEventListener('touchend', function(e) { e.preventDefault(); isHolding = false; sbBtn.style.background = ''; sbBtn.style.borderColor = ''; });

            var breathInterval = setInterval(function() {
                if (!gameRunning) { clearInterval(breathInterval); return; }
                breathProgress += breathSpeed * 0.5;

                if (isInhaling) {
                    sbCircle.style.transform = 'scale(' + (0.7 + breathProgress * 0.6) + ')';
                    sbCircle.style.borderColor = '#80c0e0';
                    sbCircle.style.boxShadow = '0 0 30px rgba(128,192,224,0.3)';
                    if (isHolding) updateScore(0.4);
                    else updateScore(-0.15);
                    if (breathProgress >= 1) {
                        isInhaling = false; breathProgress = 0;
                        sbLabel.innerHTML = '&#x1F4A8; 呼气……';
                        sbBtn.textContent = '\u{1F33F} 松开呼气';
                    }
                } else {
                    sbCircle.style.transform = 'scale(' + (1.3 - breathProgress * 0.6) + ')';
                    sbCircle.style.borderColor = '#406080';
                    sbCircle.style.boxShadow = '';
                    if (!isHolding) updateScore(0.4);
                    else updateScore(-0.15);
                    if (breathProgress >= 1) {
                        currentPhase++; updateScore(6);
                        sbPhaseNum.textContent = currentPhase + 1;
                        if (currentPhase >= totalPhases) { updateScore(8); endGame(); }
                        else resetBreath();
                    }
                }
            }, 30);

            resetBreath();
            setTimeout(function() { if (gameRunning) endGame(); }, bondCfg.timingWindow * 5);
        }

        // ==================== GAME 6: GAZE LOCK ====================
        function startGazeLock() {
            initMistakeDots();
            gameArea.innerHTML =
                '<div id="glScene" style="position:relative;height:200px;cursor:none;background:radial-gradient(circle,#111820 60%,#0a1018 100%);border-radius:16px;">' +
                '<div id="glEyes" style="position:absolute;font-size:60px;transition:left 0.5s ease-in-out,top 0.5s ease-in-out;">&#x1F440;</div>' +
                '<div id="glZone" style="position:absolute;border:2px solid rgba(240,194,64,0.3);border-radius:50%;pointer-events:none;"></div>' +
                '<div id="glCursor" style="position:absolute;width:12px;height:12px;border-radius:50%;background:#f0c040;pointer-events:none;box-shadow:0 0 12px rgba(240,194,64,0.6);"></div>' +
                '</div>' +
                '<div style="height:4px;background:#1a202a;border-radius:2px;margin-top:10px;overflow:hidden;">' +
                '<div id="glMeterFill" style="height:100%;width:50%;background:linear-gradient(90deg,#e04040,#f0c27a,#40c040);border-radius:2px;transition:width 0.5s;"></div></div>' +
                '<div style="text-align:center;margin-top:8px;font-size:12px;color:#8a9a7a;">保持光标在它的视线里，不要移开目光</div>';

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
            glEyes.style.left = cx + 'px';
            glEyes.style.top = cy + 'px';
            glEyes.style.transform = 'translate(-50%,-50%)';
            glZone.style.left = (cx - zoneRadius) + 'px';
            glZone.style.top = (cy - zoneRadius) + 'px';
            glCursor.style.left = playerX + 'px';
            glCursor.style.top = playerY + 'px';

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
                glEyes.style.left = cx + 'px';
                glEyes.style.top = cy + 'px';
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

        // ==================== START ====================
        updateScore(0);
        initMistakeDots();

        switch (bondCfg.type) {
            case 'SLOW_APPROACH':   startSlowApproach(); break;
            case 'RHYTHM_SYNC':     startRhythmSync(); break;
            case 'GENTLE_OFFER':    startGentleOffer(); break;
            case 'FOLLOW_MOVEMENT': startFollowMovement(); break;
            case 'STEADY_BREATH':   startSteadyBreath(); break;
            case 'GAZE_LOCK':       startGazeLock(); break;
            default: endGame(); break;
        }
    })();
    </script>
    <% } %>

</body>
</html>
