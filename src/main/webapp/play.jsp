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
    <title>玩耍 - <%= pet.getName() %> - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        .main { max-width: 700px; margin: 0 auto; padding: 24px 20px 80px; }
        .back-link { display: inline-block; color: var(--text-muted); text-decoration: none; font-weight: 500; margin-bottom: 18px; font-size: 14px; transition: color 0.2s; }
        .back-link:hover { color: var(--text-secondary); }

        .pet-card {
            background: linear-gradient(135deg, var(--card-bg), #FFFDF8);
            border-radius: var(--radius-lg); padding: 22px;
            border: 1px solid var(--border); box-shadow: var(--shadow-sm); margin-bottom: 18px;
            display: flex; align-items: center; gap: 18px;
        }
        .pet-card .pc-emoji { font-size: 56px; filter: drop-shadow(0 3px 8px rgba(120,80,40,0.12)); }
        .pet-info { flex: 1; min-width: 0; }
        .pet-info h3 { font-size: 18px; margin-bottom: 4px; color: var(--text); font-weight: 700; }
        .pet-info .stats { font-size: 12px; color: var(--text-secondary); margin-bottom: 8px; font-weight: 500; }

        .hunger-row { display: flex; align-items: center; gap: 8px; }
        .hunger-bar-wrap { flex: 1; height: 8px; background: #EDE5D5; border-radius: 4px; overflow: hidden; box-shadow: inset 0 1px 2px rgba(60,35,15,0.06); }
        .hunger-bar-fill { height: 100%; border-radius: 4px; transition: width 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .hunger-high { background: linear-gradient(90deg, #7DA068, #8BAA7A); }
        .hunger-mid { background: linear-gradient(90deg, #D4B870, #DCC080); }
        .hunger-low { background: linear-gradient(90deg, #C08070, #D09080); }
        .hunger-text { font-size: 11px; color: var(--text-secondary); white-space: nowrap; font-weight: 500; }
        .plays-left { font-size: 12px; color: var(--accent-warm); font-weight: 700; margin-top: 6px; }

        .game-tabs { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 20px; }
        .game-tab {
            padding: 16px 6px; border-radius: var(--radius); border: 2px solid var(--border-light);
            background: var(--card-bg); cursor: pointer; text-align: center; font-size: 13px;
            font-weight: 700; transition: all var(--transition); color: var(--text); font-family: inherit;
        }
        .game-tab:hover { border-color: var(--border-warm); background: #FAF7F0; transform: translateY(-2px); }
        .game-tab.active { border-color: var(--accent-warm); background: linear-gradient(135deg, #FDF5EC, #FDF0E0); color: #B06840; box-shadow: 0 0 0 3px rgba(212,149,106,0.1); }
        .game-tab .tab-emoji { font-size: 30px; display: block; margin-bottom: 4px; }

        .game-panel { display: none; background: var(--card-bg); border-radius: var(--radius-lg); padding: 26px;
            border: 1px solid var(--border); box-shadow: var(--shadow-sm); margin-bottom: 18px; }
        .game-panel.active { display: block; animation: fadeInScale 0.3s ease; }
        .game-panel h3 { text-align: center; margin-bottom: 6px; font-size: 20px; color: var(--accent-warm); font-weight: 700; letter-spacing: 1px; }
        .game-desc { text-align: center; font-size: 13px; color: var(--text-muted); margin-bottom: 18px; font-weight: 500; }
        .hunger-warn { text-align: center; padding: 14px; background: linear-gradient(135deg, #FDF9F2, #FAF5E8); border-radius: var(--radius);
            margin-bottom: 18px; font-size: 13px; color: var(--accent-warm); border: 2px solid var(--border-light); font-weight: 500; }

        .rps-scoreboard { display: flex; align-items: center; justify-content: center; gap: 20px;
            margin-bottom: 16px; padding: 14px; background: #FDF9F2; border-radius: var(--radius); }
        .rps-score { text-align: center; }
        .rps-score .rps-num { font-size: 36px; font-weight: 700; color: var(--accent-warm); }
        .rps-score .rps-label { font-size: 12px; color: var(--text-secondary); }
        .rps-vs { font-size: 20px; color: var(--accent-warm); font-weight: 700; }
        .rps-history { margin-bottom: 16px; }
        .rps-history .rh-item { padding: 4px 10px; font-size: 12px; color: var(--text-secondary); text-align: center; }
        .rps-round-label { text-align: center; font-size: 14px; color: var(--accent-warm); font-weight: 600; margin-bottom: 10px; }

        .choice-row { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
        .choice-btn { flex: 1; min-width: 90px; padding: 18px 12px; border: 1px solid var(--border-light);
            border-radius: var(--radius); background: #FDFBF6; cursor: pointer; text-align: center;
            font-size: 14px; font-weight: 600; transition: all var(--transition); color: var(--text); font-family: inherit; }
        .choice-btn:hover { border-color: #C5B8A0; background: #FAF7F0; transform: translateY(-2px); }
        .choice-btn:disabled { opacity: 0.5; cursor: not-allowed; pointer-events: none; }
        .choice-btn .big-emoji { font-size: 40px; display: block; margin-bottom: 6px; }

        .breakout-wrap { position: relative; text-align: center; }
        .breakout-wrap canvas { display: block; margin: 0 auto; border-radius: var(--radius);
            background: #3A3228; cursor: none; touch-action: none; max-width: 100%; }
        .breakout-info { display: flex; justify-content: center; gap: 24px; margin: 10px 0 6px;
            font-size: 13px; font-weight: 600; color: var(--text-secondary); }
        .breakout-submit { display: block; width: 100%; padding: 14px; border: none; border-radius: var(--radius);
            background: var(--accent-green); color: #fff; font-size: 16px;
            font-weight: 600; cursor: pointer; transition: all var(--transition); margin-top: 12px; font-family: inherit; }
        .breakout-submit:disabled { background: #D5C8B5; cursor: not-allowed; }
        .breakout-submit:not(:disabled):hover { opacity: 0.9; transform: translateY(-1px); }
        .breakout-start { text-align: center; padding: 40px 20px; }
        .breakout-start .start-btn { display: inline-block; padding: 16px 40px; border: none; border-radius: var(--radius);
            background: var(--accent-warm); color: #fff; font-size: 18px;
            font-weight: 600; cursor: pointer; transition: all var(--transition); font-family: inherit; }
        .breakout-start .start-btn:hover { opacity: 0.9; transform: translateY(-2px); }

        .memory-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; max-width: 360px; margin: 0 auto; }
        .memory-card { aspect-ratio: 1; perspective: 800px; cursor: pointer; }
        .memory-card .inner { position: relative; width: 100%; height: 100%; transition: transform 0.5s;
            transform-style: preserve-3d; }
        .memory-card.flipped .inner { transform: rotateY(180deg); }
        .memory-card.matched .inner { transform: rotateY(180deg); }
        .memory-card .face { position: absolute; width: 100%; height: 100%; backface-visibility: hidden;
            border-radius: var(--radius); display: flex; align-items: center; justify-content: center; font-size: 36px; }
        .memory-card .front { background: #C5B090; color: #fff; }
        .memory-card .back { background: #FDF9F2; border: 2px solid var(--border-light); transform: rotateY(180deg); }
        .memory-card.matched .back { border-color: var(--accent-green); background: #F0F5EC; }
        .memory-score { text-align: center; margin: 16px 0; font-size: 15px; font-weight: 600; color: var(--text); }
        .memory-submit { display: block; width: 100%; padding: 14px; border: none; border-radius: var(--radius);
            background: var(--accent-green); color: #fff; font-size: 16px;
            font-weight: 600; cursor: pointer; transition: all var(--transition); margin-top: 12px; font-family: inherit; }
        .memory-submit:disabled { background: #D5C8B5; cursor: not-allowed; }

        .result-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(60,40,20,0.4); z-index: 100; align-items: center; justify-content: center; }
        .result-overlay.show { display: flex; }
        .result-card { background: var(--card-bg); border-radius: 20px; padding: 32px 24px; max-width: 400px;
            width: 90%; text-align: center; animation: popIn 0.4s ease; box-shadow: var(--shadow-lg); }
        @keyframes popIn { from { opacity:0; transform:scale(0.8); } to { opacity:1; transform:scale(1); } }
        .result-tier { font-size: 48px; display: block; margin-bottom: 8px; }
        .result-msg { font-size: 16px; margin-bottom: 16px; color: var(--text); line-height: 1.6; }
        .result-vs { display: flex; align-items: center; justify-content: center; gap: 16px; margin: 16px 0; }
        .result-vs .vs-side { text-align: center; }
        .result-vs .vs-side .vs-emoji { font-size: 36px; display: block; }
        .result-vs .vs-side .vs-label { font-size: 12px; color: var(--text-secondary); margin-top: 4px; }
        .result-vs .vs-mid { font-size: 20px; font-weight: 700; color: var(--accent-warm); }
        .result-rewards { display: flex; gap: 12px; justify-content: center; margin: 16px 0; flex-wrap: wrap; }
        .reward-badge { background: #FDF9F2; padding: 8px 16px; border-radius: var(--radius); font-size: 13px; font-weight: 600; color: var(--text); border: 1px solid var(--border-light); }
        .result-close { display: inline-block; padding: 12px 32px; border-radius: var(--radius);
            background: var(--accent-warm); color: #fff; font-weight: 600;
            border: none; cursor: pointer; font-size: 16px; transition: all var(--transition); text-decoration: none; font-family: inherit; }
        .result-close:hover { opacity: 0.9; transform: translateY(-1px); }

        @media (max-width: 400px) {
            .game-tabs { grid-template-columns: 1fr 1fr; }
            .memory-grid { grid-template-columns: repeat(3, 1fr); max-width: 280px; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">
            <img src="<%= request.getContextPath() %>/assets/images/ui/logo.png" alt="logo" onerror="this.style.display='none'">
            宠物乐园
        </a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard">我的宠物</a>
            <a href="<%= request.getContextPath() %>/map">世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia">图鉴</a>
            <a href="<%= request.getContextPath() %>/help">帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">退出</a>
        </div>
    </nav>

    <div class="main">
        <a href="<%= request.getContextPath() %>/pet?action=interact&petId=<%= pet.getId() %>" class="back-link">← 返回互动</a>

        <% if (error != null) { %><div class="alert alert-error"><%= error %></div><% } %>

        <div class="pet-card">
            <span class="pc-emoji"><%= pet.getEmoji() %></span>
            <div class="pet-info">
                <h3><%= pet.getName() %> · Lv.<%= pet.getLevel() %></h3>
                <div class="stats">❤<%= pet.getAffinity() %> · 🤝<%= pet.getBond() %> · 😊<%= pet.getMood() %>%</div>
                <div class="hunger-row">
                    <span style="font-size:12px;">饱食</span>
                    <div class="hunger-bar-wrap">
                        <div class="hunger-bar-fill <%= hunger >= 50 ? "hunger-high" : hunger >= 20 ? "hunger-mid" : "hunger-low" %>"
                             style="width:<%= hunger %>%;"></div>
                    </div>
                    <span class="hunger-text"><%= hunger %>/100</span>
                </div>
                <div class="plays-left">
                    <% if (canPlay) { %>
                    还能玩 <strong><%= playsLeft %></strong> 次（每次消耗 8 饱食度）
                    <% } else { %>
                    饱食度不足，无法玩耍！快去喂食吧~
                    <% } %>
                </div>
            </div>
        </div>

        <div class="game-tabs">
            <div class="game-tab active" onclick="switchGame('rps')">
                <span class="tab-emoji">✊</span>猜拳对决
            </div>
            <div class="game-tab" onclick="switchGame('breakout')">
                <span class="tab-emoji">🧱</span>打砖块
            </div>
            <div class="game-tab" onclick="switchGame('memory')">
                <span class="tab-emoji">🃏</span>翻牌对对碰
            </div>
        </div>

        <% if (!canPlay) { %>
        <div class="hunger-warn">饱食度仅剩 <%= hunger %> 点，每次玩耍需要 8 点。请先喂食后再来玩~</div>
        <% } %>

        <!-- Game 1: RPS -->
        <div class="game-panel active" id="panel-rps">
            <h3>猜拳对决 · 三局两胜</h3>
            <p class="game-desc">和<%= pet.getName() %>来一场三局两胜的猜拳对决！</p>

            <% if (result != null && "rps".equals(result.game) && result.rpsHistory != null && !result.isComplete) { %>
            <div class="rps-scoreboard">
                <div class="rps-score">
                    <div class="rps-num"><%= result.rpsPlayerWins %></div>
                    <div class="rps-label">你</div>
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
            <div class="rps-round-label">第 <%= result.rpsRound + 1 %> 局，请出拳！</div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/play">
                <input type="hidden" name="petId" value="<%= pet.getId() %>">
                <input type="hidden" name="game" value="rps">
                <div class="choice-row">
                    <button type="submit" name="choice" value="rock" class="choice-btn" <%= canPlay ? "" : "disabled" %>>
                        <span class="big-emoji">✊</span>石头
                    </button>
                    <button type="submit" name="choice" value="scissors" class="choice-btn" <%= canPlay ? "" : "disabled" %>>
                        <span class="big-emoji">✌</span>剪刀
                    </button>
                    <button type="submit" name="choice" value="paper" class="choice-btn" <%= canPlay ? "" : "disabled" %>>
                        <span class="big-emoji">🖐</span>布
                    </button>
                </div>
            </form>
        </div>

        <!-- Game 2: Breakout -->
        <div class="game-panel" id="panel-breakout">
            <h3>打砖块</h3>
            <p class="game-desc">限时 <strong>60 秒</strong>，移动鼠标控制挡板击碎更多砖块！（30块）<br>3条命，掉球扣命，命用完则结束</p>
            <div class="breakout-info">
                <span>⏱ <span id="bkTimer" style="color:var(--accent-green);">60</span> 秒</span>
                <span>❤ <span id="bkLives" style="color:#C08070;">❤❤❤</span></span>
                <span>🧱 <span id="brickCount">0</span>/30</span>
            </div>
            <div class="breakout-wrap">
                <canvas id="breakoutCanvas" width="360" height="400"></canvas>
                <div class="breakout-start" id="breakoutStart">
                    <button class="start-btn" id="breakoutStartBtn" onclick="startBreakout()" <%= canPlay ? "" : "disabled" %>>开始游戏</button>
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
            <h3>翻牌对对碰</h3>
            <p class="game-desc">限时 <strong>60 秒</strong>，尽可能多地配对相同的宠物！（共6对）</p>
            <div class="memory-score">
                剩余 <span id="timerDisplay" style="color:var(--accent-green); font-size:18px;">60</span> 秒 ·
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
            <a href="<%= request.getContextPath() %>/play?petId=<%= pet.getId() %>" class="result-close">再玩一次</a>
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

        var breakoutRunning = false, breakoutOver = false;
        var canvas, ctx, animationId;
        var paddle, ball, bricks, brickCount, bkLives;
        var brickRows = 5, brickCols = 6, totalBricks = brickRows * brickCols;
        var brickColors = ['#D4956A','#C5B090','#D4B870','#8BAA7A','#7B9E8D'];
        var bkTimeLeft = 60, bkTimerInterval;

        function updateBkTimer() {
            var el = document.getElementById('bkTimer');
            el.textContent = bkTimeLeft;
            el.style.color = bkTimeLeft <= 10 ? '#C08070' : bkTimeLeft <= 30 ? '#D4956A' : '#7B9E6D';
        }

        function startBreakout() {
            if (breakoutRunning) return;
            canvas = document.getElementById('breakoutCanvas');
            ctx = canvas.getContext('2d');
            paddle = { x: canvas.width/2 - 40, y: canvas.height - 30, w: 80, h: 10 };
            ball = { x: canvas.width/2, y: canvas.height - 50, r: 6, dx: 3, dy: -3 };
            brickCount = 0; bkTimeLeft = 60; bkLives = 3;
            document.getElementById('bkLives').innerHTML = '❤❤❤';
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
                    ctx.strokeStyle = 'rgba(255,255,255,0.2)';
                    ctx.strokeRect(b.x, b.y, b.w, b.h);
                }
            }
            ctx.fillStyle = '#D4956A';
            ctx.fillRect(paddle.x, paddle.y, paddle.w, paddle.h);
            ctx.fillStyle = '#E0B890';
            ctx.fillRect(paddle.x + 4, paddle.y + 2, paddle.w - 8, paddle.h - 4);
            ctx.beginPath();
            ctx.arc(ball.x, ball.y, ball.r, 0, Math.PI*2);
            ctx.fillStyle = '#FFFEF9'; ctx.fill(); ctx.closePath();
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
                var hearts = ''; for (var i = 0; i < 3; i++) hearts += i < bkLives ? '❤' : '♡';
                document.getElementById('bkLives').innerHTML = hearts;
                if (bkLives <= 0) { endBreakout(); return; }
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

        (function() {
            var cardEmojis = [<% for (int i = 0; i < cards.size(); i++) { %>"<%= cards.get(i) %>"<%= i < cards.size()-1 ? "," : "" %><% } %>];
            var flipped = [], matched = [], locked = false, matchCount = 0;
            var timeLeft = 60, timerStarted = false, timerInterval;
            var grid = document.getElementById('memoryGrid');
            var timerEl = document.getElementById('timerDisplay');
            var matchEl = document.getElementById('matchCount');
            var pairsInput = document.getElementById('memoryPairs');

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
                timerEl.style.color = timeLeft <= 10 ? '#C08070' : timeLeft <= 30 ? '#D4956A' : '#7B9E6D';
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

        <%
        if (result != null && result.isComplete) {
        %>
            document.getElementById('resultOverlay').style.display = 'flex';
            document.getElementById('resultTier').innerHTML = '<%= result.tier.equals("win") ? "🎉" : result.tier.equals("tie") ? "🤝" : "😅" %>';
            document.getElementById('resultMsg').textContent = '<%= result.message.replace("'", "\\'") %>';
            document.getElementById('resultVS').innerHTML = '<div class="vs-side"><span class="vs-emoji">😊</span><span class="vs-label">你</span></div><div class="vs-mid">VS</div><div class="vs-side"><span class="vs-emoji"><%= pet.getEmoji() %></span><span class="vs-label"><%= pet.getName() %></span></div>';
            var rewardsHtml = '<div class="reward-badge">😊 心情 +<%= result.mood %></div>' +
                '<div class="reward-badge">🤝 默契 +<%= result.bond %></div>';
            <% if (result.affinity > 0) { %>
            rewardsHtml += '<div class="reward-badge">❤ 亲密度 +<%= result.affinity %></div>';
            <% } %>
            document.getElementById('resultRewards').innerHTML = rewardsHtml;
            switchGame('<%= currentGame != null ? currentGame : "rps" %>');
        <% } %>
    </script>
</body>
</html>
