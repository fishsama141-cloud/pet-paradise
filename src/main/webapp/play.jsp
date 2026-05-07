<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%@ page import="org.example.pets.servlet.PlayServlet.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    Pet pet = (Pet) request.getAttribute("pet");
    if (pet == null) { response.sendRedirect(request.getContextPath() + "/dashboard"); return; }

    String error = (String) request.getAttribute("error");
    String currentGame = (String) request.getAttribute("game");
    GameResult result = (GameResult) request.getAttribute("result");

    int hunger = pet.getHunger();
    int playsLeft = hunger / 8;
    boolean canPlay = hunger >= 8;

    // Memory card pairs (same emoji = a matching pair)
    String[][] cardPairs = {
        {"🐱","🐱"}, {"🐶","🐶"}, {"🐰","🐰"},
        {"🦊","🦊"}, {"🐼","🐼"}, {"🐨","🐨"}
    };
    List<String> cards = new ArrayList<>();
    for (String[] pair : cardPairs) { cards.add(pair[0]); cards.add(pair[1]); }
    Collections.shuffle(cards, new Random());
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>&#x1F3AE; 玩耍 - <%= pet.getName() %> - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #FFF8E7 0%, #FFECB3 30%, #FFE0B2 100%);
            min-height: 100vh; color: #5D4037;
        }
        .header { background: linear-gradient(135deg, #FF8C42, #FF6B6B); padding: 16px 28px;
            display: flex; align-items: center; justify-content: space-between; color: white; }
        .header a { color: white; text-decoration: none; font-weight: 600; font-size: 14px; }
        .container { max-width: 620px; margin: 0 auto; padding: 20px; }

        .pet-card { background: white; border-radius: 20px; padding: 20px; text-align: center;
            box-shadow: 0 4px 20px rgba(255,140,66,0.15); margin-bottom: 16px; display: flex;
            align-items: center; gap: 16px; justify-content: center; }
        .pet-emoji { font-size: 60px; animation: bounce 1.5s ease-in-out infinite; }
        @keyframes bounce { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-8px)} }
        .pet-info { text-align: left; flex: 1; }
        .pet-info h3 { font-size: 18px; margin-bottom: 4px; }
        .pet-info .stats { font-size: 12px; color: #A1887F; margin-bottom: 6px; }

        .hunger-row { display: flex; align-items: center; gap: 8px; }
        .hunger-bar-wrap { flex: 1; height: 8px; background: #FFE0B2; border-radius: 4px; overflow: hidden; }
        .hunger-bar-fill { height: 100%; border-radius: 4px; transition: width 0.5s; }
        .hunger-high { background: linear-gradient(90deg, #4CAF50, #66BB6A); }
        .hunger-mid { background: linear-gradient(90deg, #FFC107, #FFB300); }
        .hunger-low { background: linear-gradient(90deg, #FF6B6B, #FF5252); }
        .hunger-text { font-size: 11px; color: #A1887F; white-space: nowrap; }
        .plays-left { font-size: 11px; color: #FF8C42; font-weight: 600; }

        /* Game tabs */
        .game-tabs { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; margin-bottom: 18px; }
        .game-tab { padding: 12px 6px; border-radius: 14px; border: 2px solid #FFE0B2;
            background: white; cursor: pointer; text-align: center; font-size: 12px; font-weight: 600;
            transition: all 0.3s; color: #5D4037; }
        .game-tab:hover { border-color: #FF8C42; background: #FFF3E0; }
        .game-tab.active { border-color: #FF8C42; background: #FFF3E0; color: #E65100;
            box-shadow: 0 0 0 3px rgba(255,140,66,0.15); }
        .game-tab .tab-emoji { font-size: 28px; display: block; margin-bottom: 2px; }

        .game-panel { display: none; background: white; border-radius: 20px; padding: 24px;
            box-shadow: 0 4px 20px rgba(255,140,66,0.15); margin-bottom: 16px; }
        .game-panel.active { display: block; }
        .game-panel h3 { text-align: center; margin-bottom: 4px; font-size: 18px; color: #E65100; }
        .game-desc { text-align: center; font-size: 13px; color: #A1887F; margin-bottom: 16px; }
        .hunger-warn { text-align: center; padding: 12px; background: #FFF8E1; border-radius: 12px;
            margin-bottom: 16px; font-size: 13px; color: #E65100; }

        /* RPS */
        .rps-scoreboard { display: flex; align-items: center; justify-content: center; gap: 20px;
            margin-bottom: 16px; padding: 12px; background: #FFF8F0; border-radius: 14px; }
        .rps-score { text-align: center; }
        .rps-score .rps-num { font-size: 32px; font-weight: 700; color: #E65100; }
        .rps-score .rps-label { font-size: 11px; color: #A1887F; }
        .rps-vs { font-size: 20px; color: #FF8C42; font-weight: 700; }
        .rps-history { margin-bottom: 16px; }
        .rps-history .rh-item { padding: 4px 10px; font-size: 12px; color: #8D6E63; text-align: center; }
        .rps-round-label { text-align: center; font-size: 13px; color: #FF8C42; font-weight: 600; margin-bottom: 8px; }

        .choice-row { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
        .choice-btn { flex: 1; min-width: 90px; padding: 18px 12px; border: 2px solid #FFE0B2;
            border-radius: 16px; background: #FFFDF9; cursor: pointer; text-align: center;
            font-size: 14px; font-weight: 700; transition: all 0.3s; color: #5D4037; }
        .choice-btn:hover { border-color: #FF8C42; background: #FFF3E0; transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255,140,66,0.2); }
        .choice-btn:disabled { opacity: 0.5; cursor: not-allowed; pointer-events: none; }
        .choice-btn .big-emoji { font-size: 40px; display: block; margin-bottom: 6px; }

        /* Breakout */
        .breakout-wrap { position: relative; text-align: center; }
        .breakout-wrap canvas { display: block; margin: 0 auto; border-radius: 12px;
            background: #1a1a2e; cursor: none; touch-action: none; max-width: 100%; }
        .breakout-info { display: flex; justify-content: center; gap: 24px; margin: 10px 0 6px;
            font-size: 13px; font-weight: 600; }
        .breakout-submit { display: block; width: 100%; padding: 14px; border: none; border-radius: 14px;
            background: linear-gradient(135deg, #4CAF50, #66BB6A); color: white; font-size: 16px;
            font-weight: 700; cursor: pointer; transition: all 0.3s; margin-top: 12px; }
        .breakout-submit:disabled { background: #BDBDBD; cursor: not-allowed; }
        .breakout-submit:not(:disabled):hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(76,175,80,0.4); }
        .breakout-start { text-align: center; padding: 40px 20px; }
        .breakout-start .start-btn { display: inline-block; padding: 16px 40px; border: none; border-radius: 16px;
            background: linear-gradient(135deg, #FF8C42, #FF6B6B); color: white; font-size: 18px;
            font-weight: 700; cursor: pointer; transition: all 0.3s; }
        .breakout-start .start-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(255,140,66,0.4); }

        /* Memory */
        .memory-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; max-width: 360px; margin: 0 auto; }
        .memory-card { aspect-ratio: 1; perspective: 800px; cursor: pointer; }
        .memory-card .inner { position: relative; width: 100%; height: 100%; transition: transform 0.5s;
            transform-style: preserve-3d; }
        .memory-card.flipped .inner { transform: rotateY(180deg); }
        .memory-card.matched .inner { transform: rotateY(180deg); }
        .memory-card .face { position: absolute; width: 100%; height: 100%; backface-visibility: hidden;
            border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 36px; }
        .memory-card .front { background: linear-gradient(135deg, #FF8C42, #FF6B6B); color: white; }
        .memory-card .back { background: #FFF8F0; border: 3px solid #FFE0B2; transform: rotateY(180deg); }
        .memory-card.matched .back { border-color: #4CAF50; background: #E8F5E9; }
        .memory-score { text-align: center; margin: 16px 0; font-size: 15px; font-weight: 600; }
        .memory-submit { display: block; width: 100%; padding: 14px; border: none; border-radius: 14px;
            background: linear-gradient(135deg, #4CAF50, #66BB6A); color: white; font-size: 16px;
            font-weight: 700; cursor: pointer; transition: all 0.3s; margin-top: 12px; }
        .memory-submit:disabled { background: #BDBDBD; cursor: not-allowed; }
        .memory-submit:not(:disabled):hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(76,175,80,0.4); }

        /* Result overlay */
        .result-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5); z-index: 100; align-items: center; justify-content: center; }
        .result-overlay.show { display: flex; }
        .result-card { background: white; border-radius: 24px; padding: 32px 24px; max-width: 400px;
            width: 90%; text-align: center; animation: popIn 0.4s ease; }
        @keyframes popIn { from { opacity:0; transform:scale(0.8); } to { opacity:1; transform:scale(1); } }
        .result-tier { font-size: 48px; display: block; margin-bottom: 8px; }
        .result-msg { font-size: 16px; margin-bottom: 16px; color: #5D4037; line-height: 1.6; }
        .result-vs { display: flex; align-items: center; justify-content: center; gap: 16px; margin: 16px 0; }
        .result-vs .vs-side { text-align: center; }
        .result-vs .vs-side .vs-emoji { font-size: 36px; display: block; }
        .result-vs .vs-side .vs-label { font-size: 12px; color: #A1887F; margin-top: 4px; }
        .result-vs .vs-mid { font-size: 20px; font-weight: 700; color: #FF8C42; }
        .result-rewards { display: flex; gap: 12px; justify-content: center; margin: 16px 0; flex-wrap: wrap; }
        .reward-badge { background: #FFF3E0; padding: 8px 16px; border-radius: 12px; font-size: 13px; font-weight: 600; }
        .result-close { display: inline-block; padding: 12px 32px; border-radius: 14px;
            background: linear-gradient(135deg, #FF8C42, #FF6B6B); color: white; font-weight: 700;
            border: none; cursor: pointer; font-size: 16px; transition: all 0.3s; text-decoration: none; }
        .result-close:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(255,140,66,0.4); }

        .msg { padding: 10px 16px; border-radius: 12px; margin-bottom: 16px; font-size: 13px; text-align: center; }
        .msg-error { background: #FFF0F0; color: #C62828; }

        @media (max-width: 400px) {
            .game-tabs { grid-template-columns: 1fr 1fr; }
            .memory-grid { grid-template-columns: repeat(3, 1fr); max-width: 280px; }
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="<%= request.getContextPath() %>/pet?action=interact&petId=<%= pet.getId() %>">← 返回互动</a>
        <span>&#x1F3AE; 游戏中心</span>
        <a href="<%= request.getContextPath() %>/dashboard">🏠 主页</a>
    </div>

    <div class="container">
        <% if (error != null) { %><div class="msg msg-error"><%= error %></div><% } %>

        <!-- Pet card -->
        <div class="pet-card">
            <span class="pet-emoji"><%= pet.getEmoji() %></span>
            <div class="pet-info">
                <h3><%= pet.getName() %> <small>Lv.<%= pet.getLevel() %></small></h3>
                <div class="stats">&#x2764;<%= pet.getAffinity() %> &#x1F91D;<%= pet.getBond() %> &#x263A;<%= pet.getMood() %>%</div>
                <div class="hunger-row">
                    <span style="font-size:12px;">&#x1F356;</span>
                    <div class="hunger-bar-wrap">
                        <div class="hunger-bar-fill <%= hunger >= 50 ? "hunger-high" : hunger >= 20 ? "hunger-mid" : "hunger-low" %>"
                             style="width:<%= hunger %>%;"></div>
                    </div>
                    <span class="hunger-text"><%= hunger %>/100</span>
                </div>
                <div class="plays-left">
                    <% if (canPlay) { %>
                    ⚡ 还能玩 <strong><%= playsLeft %></strong> 次（每次消耗 8 饱食度）
                    <% } else { %>
                    &#x26A0;&#xFE0F; 饱食度不足，无法玩耍！快去喂食吧~
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Game tabs -->
        <div class="game-tabs">
            <div class="game-tab active" onclick="switchGame('rps')">
                <span class="tab-emoji">&#x1FAA8;</span>猜拳对决
            </div>
            <div class="game-tab" onclick="switchGame('breakout')">
                <span class="tab-emoji">&#x1F9F1;</span>打砖块
            </div>
            <div class="game-tab" onclick="switchGame('memory')">
                <span class="tab-emoji">&#x1F9E0;</span>翻牌对对碰
            </div>
        </div>

        <% if (!canPlay) { %>
        <div class="hunger-warn">&#x1F356; 饱食度仅剩 <%= hunger %> 点，每次玩耍需要 8 点。请先喂食后再来玩~</div>
        <% } %>

        <!-- Game 1: RPS -->
        <div class="game-panel active" id="panel-rps">
            <h3>&#x1FAA8; 猜拳对决 · 三局两胜</h3>
            <p class="game-desc">和<%= pet.getName() %>来一场三局两胜的猜拳对决！</p>

            <% if (result != null && "rps".equals(result.game) && result.rpsHistory != null && !result.isComplete) { %>
            <div class="rps-scoreboard">
                <div class="rps-score">
                    <div class="rps-num"><%= result.rpsPlayerWins %></div>
                    <div class="rps-label">&#x1F60A; 你</div>
                </div>
                <div class="rps-vs">VS</div>
                <div class="rps-score">
                    <div class="rps-num"><%= result.rpsPetWins %></div>
                    <div class="rps-label"><%= pet.getEmoji() %> <%= pet.getName() %></div>
                </div>
            </div>
            <div class="rps-history">
                <% for (String h : result.rpsHistory) { %>
                <div class="rh-item"><%= h %></div>
                <% } %>
            </div>
            <div class="rps-round-label">📍 第 <%= result.rpsRound + 1 %> 局，请出拳！</div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/play">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <input type="hidden" name="game" value="rps">
                <div class="choice-row">
                    <button type="submit" name="choice" value="rock" class="choice-btn" <%= canPlay ? "" : "disabled" %>>
                        <span class="big-emoji">&#x1FAA8;</span>石头
                    </button>
                    <button type="submit" name="choice" value="scissors" class="choice-btn" <%= canPlay ? "" : "disabled" %>>
                        <span class="big-emoji">✂️</span>剪刀
                    </button>
                    <button type="submit" name="choice" value="paper" class="choice-btn" <%= canPlay ? "" : "disabled" %>>
                        <span class="big-emoji">&#x1F4C4;</span>布
                    </button>
                </div>
            </form>
        </div>

        <!-- Game 2: Breakout -->
        <div class="game-panel" id="panel-breakout">
            <h3>&#x1F9F1; 打砖块</h3>
            <p class="game-desc">限时 <strong>60 秒</strong>，移动鼠标控制挡板击碎更多砖块！（30块）<br>3条命，掉球扣命，命用完则结束</p>
            <div class="breakout-info">
                <span>&#x23F1;&#xFE0F; <span id="bkTimer" style="color:#4CAF50;">60</span> 秒</span>
                <span>&#x2764;&#xFE0F; <span id="bkLives" style="color:#FF5252;">&#x2764;&#x2764;&#x2764;</span></span>
                <span>&#x1F9F1; <span id="brickCount">0</span>/30</span>
            </div>
            <div class="breakout-wrap">
                <canvas id="breakoutCanvas" width="360" height="400"></canvas>
                <div class="breakout-start" id="breakoutStart">
                    <button class="start-btn" id="breakoutStartBtn" onclick="startBreakout()" <%= canPlay ? "" : "disabled" %>>&#x1F3AE; 开始游戏</button>
                </div>
            </div>
            <form id="breakoutForm" method="post" action="<%= request.getContextPath() %>/play">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <input type="hidden" name="game" value="breakout">
                <input type="hidden" name="bricks" id="breakoutBricks" value="0">
            </form>
        </div>

        <!-- Game 3: Memory -->
        <div class="game-panel" id="panel-memory">
            <h3>&#x1F9E0; 翻牌对对碰</h3>
            <p class="game-desc">限时 <strong>60 秒</strong>，尽可能多地配对相同的宠物！（共6对）</p>
            <div class="memory-score">
                &#x23F1;&#xFE0F; 剩余 <span id="timerDisplay" style="color:#4CAF50; font-size:18px;">60</span> 秒 ·
                已配对：<span id="matchCount">0</span> / 6
            </div>
            <div class="memory-grid" id="memoryGrid"></div>
            <form id="memoryForm" method="post" action="<%= request.getContextPath() %>/play">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <input type="hidden" name="game" value="memory">
                <input type="hidden" name="pairs" id="memoryPairs" value="0">
            </form>
        </div>
    </div>

    <!-- Result overlay -->
    <div class="result-overlay" id="resultOverlay" style="display:none;">
        <div class="result-card">
            <span class="result-tier" id="resultTier"></span>
            <div class="result-msg" id="resultMsg"></div>
            <div class="result-vs" id="resultVS"></div>
            <div class="result-rewards" id="resultRewards"></div>
            <a href="<%= request.getContextPath() %>/play?petId=<%= pet.getId() %>" class="result-close">&#x1F3AE; 再玩一次</a>
        </div>
    </div>

    <script>
        function switchGame(name) {
            document.querySelectorAll('.game-tab').forEach(function(t) { t.classList.remove('active'); });
            document.querySelectorAll('.game-panel').forEach(function(p) { p.classList.remove('active'); });
            var tab = document.querySelector('.game-tab[onclick*="'+name+'"]');
            if (tab) tab.classList.add('active');
            var panel = document.getElementById('panel-'+name);
            if (panel) panel.classList.add('active');
        }

        // ==================== Breakout Game (Timer-based) ====================
        var breakoutRunning = false, breakoutOver = false;
        var canvas, ctx, animationId;
        var paddle, ball, bricks, brickCount, bkLives;
        var brickRows = 5, brickCols = 6, totalBricks = brickRows * brickCols;
        var brickColors = ['#FF6B6B','#FF8C42','#FFD93D','#6BCB77','#4D96FF'];
        var bkTimeLeft = 60, bkTimerInterval;

        function updateBkTimer() {
            var el = document.getElementById('bkTimer');
            el.textContent = bkTimeLeft;
            el.style.color = bkTimeLeft <= 10 ? '#FF5252' : bkTimeLeft <= 30 ? '#FF8C42' : '#4CAF50';
        }

        function startBreakout() {
            if (breakoutRunning) return;
            canvas = document.getElementById('breakoutCanvas');
            ctx = canvas.getContext('2d');
            paddle = { x: canvas.width/2 - 40, y: canvas.height - 30, w: 80, h: 10 };
            ball = { x: canvas.width/2, y: canvas.height - 50, r: 6, dx: 3, dy: -3 };
            brickCount = 0; bkTimeLeft = 60; bkLives = 3;
            document.getElementById('bkLives').innerHTML = '&#x2764;&#x2764;&#x2764;';
            bricks = [];
            var bw = (canvas.width - 20) / brickCols, bh = 18;
            for (var r = 0; r < brickRows; r++) {
                bricks[r] = [];
                for (var c = 0; c < brickCols; c++) {
                    bricks[r][c] = { x: 10 + c*bw, y: 30 + r*(bh+4), w: bw-4, h: bh, alive: true, color: brickColors[r] };
                }
            }
            document.getElementById('brickCount').textContent = brickCount;
            document.getElementById('breakoutBricks').value = brickCount;
            updateBkTimer();
            document.getElementById('breakoutStart').style.display = 'none';
            breakoutRunning = true; breakoutOver = false;
            canvas.style.cursor = 'none';
            loop();
            bkTimerInterval = setInterval(function() {
                bkTimeLeft--;
                updateBkTimer();
                if (bkTimeLeft <= 0) { endBreakout(); }
            }, 1000);
        }

        function loop() {
            if (!breakoutRunning) return;
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            for (var r = 0; r < brickRows; r++) {
                for (var c = 0; c < brickCols; c++) {
                    var b = bricks[r][c];
                    if (!b.alive) continue;
                    ctx.fillStyle = b.color;
                    ctx.fillRect(b.x, b.y, b.w, b.h);
                    ctx.strokeStyle = 'rgba(255,255,255,0.3)';
                    ctx.strokeRect(b.x, b.y, b.w, b.h);
                }
            }

            ctx.fillStyle = '#FF8C42';
            ctx.fillRect(paddle.x, paddle.y, paddle.w, paddle.h);
            ctx.fillStyle = '#FFAB91';
            ctx.fillRect(paddle.x + 4, paddle.y + 2, paddle.w - 8, paddle.h - 4);

            ctx.beginPath();
            ctx.arc(ball.x, ball.y, ball.r, 0, Math.PI*2);
            ctx.fillStyle = '#FFF'; ctx.fill(); ctx.closePath();

            ball.x += ball.dx; ball.y += ball.dy;

            if (ball.x - ball.r <= 0 || ball.x + ball.r >= canvas.width) ball.dx = -ball.dx;
            if (ball.y - ball.r <= 0) ball.dy = -ball.dy;

            if (ball.y + ball.r >= paddle.y && ball.y - ball.r <= paddle.y + paddle.h &&
                ball.x >= paddle.x && ball.x <= paddle.x + paddle.w) {
                var hitPos = (ball.x - paddle.x) / paddle.w;
                var angle = (hitPos - 0.5) * Math.PI * 0.7;
                var speed = Math.sqrt(ball.dx*ball.dx + ball.dy*ball.dy);
                ball.dx = speed * Math.sin(angle);
                ball.dy = -speed * Math.cos(angle);
                ball.y = paddle.y - ball.r;
            }

            for (var r = 0; r < brickRows; r++) {
                for (var c = 0; c < brickCols; c++) {
                    var b = bricks[r][c];
                    if (!b.alive) continue;
                    if (ball.x + ball.r > b.x && ball.x - ball.r < b.x + b.w &&
                        ball.y + ball.r > b.y && ball.y - ball.r < b.y + b.h) {
                        b.alive = false; brickCount++;
                        document.getElementById('brickCount').textContent = brickCount;
                        document.getElementById('breakoutBricks').value = brickCount;
                        ball.dy = -ball.dy;
                        if (brickCount >= totalBricks) { endBreakout(); return; }
                    }
                }
            }

            if (ball.y - ball.r > canvas.height) {
                bkLives--;
                var hearts = ''; for (var i = 0; i < 3; i++) hearts += i < bkLives ? '&#x2764;' : '&#x1F5A4;';
                document.getElementById('bkLives').innerHTML = hearts;
                if (bkLives <= 0) { endBreakout(); return; }
                // Respawn at bricks center
                var brickAreaCenterY = 30 + brickRows * (18 + 4) / 2;
                ball.x = canvas.width/2; ball.y = brickAreaCenterY;
                ball.dx = (Math.random() > 0.5 ? 3 : -3); ball.dy = 3;
            }

            animationId = requestAnimationFrame(loop);
        }

        function endBreakout() {
            breakoutRunning = false; breakoutOver = true;
            cancelAnimationFrame(animationId);
            if (bkTimerInterval) clearInterval(bkTimerInterval);
            canvas.style.cursor = 'default';
            document.getElementById('breakoutBricks').value = brickCount;
            document.getElementById('breakoutForm').submit();
        }

        (function() {
            var c = document.getElementById('breakoutCanvas');
            c.addEventListener('mousemove', function(e) {
                if (!breakoutRunning) return;
                var rect = c.getBoundingClientRect();
                var scaleX = c.width / rect.width;
                var mx = (e.clientX - rect.left) * scaleX;
                paddle.x = Math.max(0, Math.min(c.width - paddle.w, mx - paddle.w/2));
            });
            c.addEventListener('touchmove', function(e) {
                if (!breakoutRunning) return;
                e.preventDefault();
                var rect = c.getBoundingClientRect();
                var scaleX = c.width / rect.width;
                var mx = (e.touches[0].clientX - rect.left) * scaleX;
                paddle.x = Math.max(0, Math.min(c.width - paddle.w, mx - paddle.w/2));
            }, {passive: false});
        })();

        // ==================== Memory Game with Timer ====================
        (function() {
            var cardEmojis = [<% for (int i = 0; i < cards.size(); i++) { %>"<%= cards.get(i) %>"<%= i < cards.size()-1 ? "," : "" %><% } %>];
            var flipped = [], matched = [], locked = false, matchCount = 0;
            var timeLeft = 60, totalTime = 60, timerStarted = false, timerInterval;
            var grid = document.getElementById('memoryGrid');
            var timerEl = document.getElementById('timerDisplay');
            var matchEl = document.getElementById('matchCount');
            var pairsInput = document.getElementById('memoryPairs');
            var submitBtn = document.getElementById('memorySubmit');

            cardEmojis.forEach(function(emoji, idx) {
                var card = document.createElement('div');
                card.className = 'memory-card';
                card.setAttribute('data-index', idx);
                card.setAttribute('data-emoji', emoji);
                card.innerHTML = '<div class="inner"><div class="face front">?</div><div class="face back">'+emoji+'</div></div>';
                card.onclick = function() { flipCard(card); };
                grid.appendChild(card);
            });

            function startTimer() {
                if (timerStarted) return;
                timerStarted = true;
                updateTimerDisplay();
                timerInterval = setInterval(function() {
                    timeLeft--;
                    updateTimerDisplay();
                    if (timeLeft <= 0) {
                        clearInterval(timerInterval);
                        locked = true;
                        if (flipped.length > 0) {
                            flipped.forEach(function(i) {
                                document.querySelector('[data-index="'+i+'"]').classList.remove('flipped');
                            });
                            flipped = [];
                        }
                        pairsInput.value = matchCount;
                        document.getElementById('memoryForm').submit();
                    }
                }, 1000);
            }

            function updateTimerDisplay() {
                timerEl.textContent = timeLeft;
                if (timeLeft <= 10) {
                    timerEl.style.color = '#FF5252';
                } else if (timeLeft <= 30) {
                    timerEl.style.color = '#FF8C42';
                } else {
                    timerEl.style.color = '#4CAF50';
                }
            }

            function checkAllDone() {
                if (matchCount >= 6) {
                    if (timerInterval) clearInterval(timerInterval);
                    pairsInput.value = matchCount;
                    setTimeout(function() { document.getElementById('memoryForm').submit(); }, 500);
                }
            }

            function flipCard(card) {
                if (locked) return;
                if (!timerStarted) startTimer();
                var idx = card.getAttribute('data-index');
                if (flipped.indexOf(idx) >= 0 || matched.indexOf(idx) >= 0) return;
                if (flipped.length >= 2) return;
                card.classList.add('flipped'); flipped.push(idx);
                if (flipped.length === 2) {
                    locked = true;
                    var i1 = flipped[0], i2 = flipped[1];
                    var c1 = document.querySelector('[data-index="'+i1+'"]');
                    var c2 = document.querySelector('[data-index="'+i2+'"]');
                    if (cardEmojis[i1] === cardEmojis[i2]) {
                        matched.push(i1, i2); matchCount++;
                        matchEl.textContent = matchCount;
                        pairsInput.value = matchCount;
                        c1.classList.add('matched'); c2.classList.add('matched');
                        flipped = []; locked = false;
                        checkAllDone();
                    } else {
                        setTimeout(function() {
                            c1.classList.remove('flipped'); c2.classList.remove('flipped');
                            flipped = []; locked = false;
                        }, 600);
                    }
                }
            }
        })();

        // Show result overlay
        <%
        if (result != null && result.isComplete) {
        %>
            document.getElementById('resultOverlay').style.display = 'flex';
            document.getElementById('resultTier').innerHTML = '<%= result.tier.equals("win") ? "&#x1F389;" : result.tier.equals("tie") ? "&#x1F91D;" : "&#x1F605;" %>';
            document.getElementById('resultMsg').textContent = '<%= result.message.replace("'", "\\'") %>';
            document.getElementById('resultVS').innerHTML = '<div class="vs-side"><span class="vs-emoji">&#x1F60A;</span><span class="vs-label">你</span></div><div class="vs-mid">VS</div><div class="vs-side"><span class="vs-emoji"><%= pet.getEmoji() %></span><span class="vs-label"><%= pet.getName() %></span></div>';
            var rewardsHtml = '<div class="reward-badge">&#x1F60A; 心情 +<%= result.mood %></div>' +
                '<div class="reward-badge">&#x1F91D; 默契 +<%= result.bond %></div>';
            <% if (result.affinity > 0) { %>
            rewardsHtml += '<div class="reward-badge">&#x2764; 亲密度 +<%= result.affinity %></div>';
            <% } %>
            document.getElementById('resultRewards').innerHTML = rewardsHtml;
            switchGame('<%= currentGame != null ? currentGame : "rps" %>');
        <% } %>
    </script>
</body>
</html>
