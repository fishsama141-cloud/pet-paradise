<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>游戏帮助 - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        .main { max-width: 860px; margin: 0 auto; padding: 24px 20px; }

        .help-tabs {
            display: flex; gap: 8px; margin-bottom: 24px; flex-wrap: wrap;
            position: sticky; top: 60px; z-index: 10;
            background: rgba(253,248,240,0.95); padding: 10px 0; backdrop-filter: blur(4px);
        }
        .help-tab {
            padding: 10px 20px; border-radius: 20px; border: 1px solid var(--border-light);
            cursor: pointer; font-weight: 600; font-size: 14px; transition: all var(--transition);
            background: var(--card-bg); color: var(--text-secondary); font-family: inherit;
        }
        .help-tab:hover { border-color: #C5B8A0; color: var(--text); }
        .help-tab.active {
            background: #FDF5EC; border-color: var(--accent-warm); color: #B87050;
        }
        .help-section { display: none; }
        .help-section.active { display: block; }

        .section-title {
            font-size: 20px; font-weight: 600; color: var(--text);
            margin-bottom: 16px; padding-bottom: 10px;
            border-bottom: 1px solid var(--border-light);
        }
        .rule-card {
            background: var(--card-bg); border-radius: var(--radius); padding: 18px 20px;
            margin-bottom: 12px; border-left: 4px solid #C5B8A0;
            transition: all var(--transition); border-top: 1px solid var(--border-light);
            border-right: 1px solid var(--border-light); border-bottom: 1px solid var(--border-light);
        }
        .rule-card:hover { border-left-color: var(--accent-warm); }
        .rule-card .rc-header { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
        .rule-card .rc-icon { font-size: 28px; }
        .rule-card .rc-name { font-size: 18px; font-weight: 600; color: var(--text); }
        .rule-card .rc-formula {
            font-size: 12px; color: #708A50; background: #F7FAF5;
            padding: 8px 12px; border-radius: 8px; margin-top: 8px;
            font-family: "Consolas", "Courier New", monospace; white-space: pre-line; line-height: 1.7;
        }
        .rule-card .rc-desc { font-size: 14px; color: var(--text-secondary); line-height: 1.7; }
        .rule-card .rc-penalty {
            font-size: 12px; color: #B06040; background: #FDF5F0;
            padding: 8px 12px; border-radius: 8px; margin-top: 6px;
        }

        @media (max-width: 600px) {
            .help-tab { padding: 8px 14px; font-size: 13px; }
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
            <a href="<%= request.getContextPath() %>/help" class="active">帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="help-tabs">
            <button class="help-tab active" onclick="switchHelp('attributes')">📊 属性详解</button>
            <button class="help-tab" onclick="switchHelp('bondevent')">🤝 互动事件</button>
            <button class="help-tab" onclick="switchHelp('gameplay')">🎮 玩法指南</button>
        </div>

        <!-- 属性详解 -->
        <div class="help-section active" id="help-attributes">
            <div class="section-title">📊 宠物属性详解</div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">🍖</span>
                    <span class="rc-name">饱食度 (Hunger)</span>
                </div>
                <div class="rc-desc">
                    决定宠物能否玩耍的核心属性。<strong>每次玩耍消耗 8 点饱食度</strong>，饱食度不足时无法玩耍。<br>
                    可通过喂食恢复，随时间自然下降（每小时 -5）。
                </div>
                <div class="rc-formula">🟢 饱食度 ≥ 8：可以玩耍
🔴 饱食度 &lt; 8：无法玩耍，需喂食</div>
                <div class="rc-penalty">⚠ 惩罚：饱食度 ≤ 15 时，每小时 -2 亲密度</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">😊</span>
                    <span class="rc-name">心情值 (Mood)</span>
                </div>
                <div class="rc-desc">
                    影响<strong>玩耍奖励加成</strong>。心情越好，玩耍获得的奖励越多；心情低落时奖励缩水。<br>
                    随时间自然下降（每小时 -3），通过玩耍恢复。
                </div>
                <div class="rc-formula">心情 ≥ 80：玩耍奖励 x <strong>1.3</strong>（高兴）
心情 50-79：玩耍奖励 x <strong>1.0</strong>（正常）
心情 30-49：玩耍奖励 x <strong>0.8</strong>（低落）
心情 &lt; 30：玩耍奖励 x <strong>0.6</strong>（沮丧）</div>
                <div class="rc-penalty">⚠ 惩罚：心情 ≤ 20 时，每小时 -2 亲密度</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">❤</span>
                    <span class="rc-name">亲密度 (Affinity)</span>
                </div>
                <div class="rc-desc">
                    宠物与主人的<strong>情感纽带</strong>。亲密度越高，喂食效果越好，带它探险时野生动物也更放松。<br>
                    喂食最爱食物 +5，喂讨厌食物 -5，升级 +5，放生祝福 +8。
                </div>
                <div class="rc-formula"><b>【喂食加成】</b>亲密度影响喂食恢复量：
亲密度 ≥ 80：饱食恢复 x <strong>1.5</strong>
亲密度 ≥ 50：饱食恢复 x <strong>1.3</strong>
亲密度 ≥ 30：饱食恢复 x <strong>1.15</strong>

<b>【探险加成】</b>高亲密度同伴让野生动物初始更放松：
亲密度 ≥ 80：初始信任 +12，安全感 +6
亲密度 ≥ 50：初始信任 +6，安全感 +3
亲密度 ≥ 30：初始信任 +3，安全感 +1</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">🤝</span>
                    <span class="rc-name">默契度 (Bond)</span>
                </div>
                <div class="rc-desc">
                    宠物与主人的<strong>配合程度</strong>。默契越高，探险中同伴特性效果越强。<br>
                    主要通过玩耍、探险获得，升级 +3，放生祝福 +5。
                </div>
                <div class="rc-formula"><b>【遭遇战加成】</b>默契度放大同伴特性的正收益：
默契度 ≥ 80：特性正效果 x <strong>1.4</strong>
默契度 ≥ 50：特性正效果 x <strong>1.2</strong>
默契度 ≥ 30：特性正效果 x <strong>1.1</strong>
默契度 &lt; 30：无加成</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">⭐</span>
                    <span class="rc-name">经验值与等级</span>
                </div>
                <div class="rc-desc">
                    积累 EXP 提升等级。每 100 EXP 升 1 级。升级时亲密度 +5，默契度 +3。<br>
                    EXP 来源：探险、成功遭遇战（稀有度越高越多）。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">🎭</span>
                    <span class="rc-name">性格 (Personality)</span>
                </div>
                <div class="rc-desc">
                    宠物性格分三种：<strong>活泼</strong>（玩耍/靠近加成）、<strong>胆小</strong>（观察/安抚加成）、<strong>温顺</strong>（喂食/安抚加成）。<br>
                    性格影响遭遇战中特定态度的效果加成（x1.2）。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">💎</span>
                    <span class="rc-name">稀有度 (Rarity)</span>
                </div>
                <div class="rc-desc">
                    分三档：<strong>常见</strong> / <strong>稀有</strong> / <strong>极稀有</strong>。<br>
                    稀有度越高的动物，遭遇战后获得的 EXP 越多，但捕捉条件也越苛刻。
                </div>
            </div>
        </div>

        <!-- 互动高潮事件 -->
        <div class="help-section" id="help-bondevent">
            <div class="section-title">🤝 互动高潮事件系统 (Bond Event)</div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">✨</span><span class="rc-name">什么是互动高潮事件？</span></div>
                <div class="rc-desc">
                    在遭遇野生动物的过程中，当情绪条件满足时，动物可能主动发起一次<strong>更深层的互动</strong>——不是普通的回合制选择，而是一个有操作性的即时小游戏。<br>
                    这是你和野生动物之间的<strong>关系突破时刻</strong>——成功通过将大幅提升信任，甚至直接触发可收养状态！
                </div>
                <div class="rc-formula">触发频率：稀有度决定遭遇战中的事件配额
🟢 常见 (common)：0~1 次
🟡 稀有 (uncommon)：1 次
🔴 极稀有 (rare)：1~2 次</div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🎯</span><span class="rc-name">触发条件</span></div>
                <div class="rc-desc">
                    每种性格原型的动物有不同的触发条件，通常在<strong>遭遇中后期</strong>、情绪积累到一定程度时触发：
                </div>
                <div class="rc-formula"><b>谨慎 (CAUTIOUS)</b>：安全感 ≥ 50 且 压力 ≤ 30 且 已进行 ≥ 2 回合
<b>好奇 (CURIOUS)</b>：兴趣 ≥ 55 且 安全感 ≥ 30
<b>大胆 (BOLD)</b>：信任 ≥ 25 且 压力 ≤ 45 且 已进行 ≥ 1 回合
<b>温柔 (GENTLE)</b>：信任 ≥ 30 且 安全感 ≥ 35 且 压力 ≤ 40
<b>顽皮 (PLAYFUL)</b>：兴趣 ≥ 60 且 压力 ≤ 35
<b>神秘 (MYSTERIOUS)</b>：信任 ≥ 35 且 已进行 ≥ 3 回合</div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🎮</span><span class="rc-name">六种事件类型</span></div>
                <div class="rc-desc">
                    根据动物原型匹配最合适的事件类型，每种都有独特的操作方式和策略：
                </div>
                <div class="rc-formula"><b>👟 缓慢接近 (SLOW_APPROACH)</b> — 谨慎/温柔型
  按住按钮接近动物，它在回头时你必须松手。考验耐心与时机。

<b>🎵 节奏同步 (RHYTHM_SYNC)</b> — 好奇/顽皮/大胆/神秘型
  光点随机亮起，在时间窗口内点击。考验反应与节奏感。

<b>🍎 温柔投喂 (GENTLE_OFFER)</b> — 温柔型
  等待完美时机递出食物。过早惊吓动物，过晚错失良机。

<b>🌊 跟随移动 (FOLLOW_MOVEMENT)</b> — 好奇/顽皮型
  动物移动时保持光标在舒适区内。考验微操与稳定。

<b>📣 回声呼唤 (ECHO_CALL)</b> — 谨慎/神秘型
  动物发出有节奏的呼唤，记住颜色顺序并重复。考验记忆与专注。

<b>👀 凝视对视 (GAZE_LOCK)</b> — 大胆/神秘型
  光标保持在视线范围内，谁先移开谁就输了信任。考验定力。</div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🏆</span><span class="rc-name">结果等级</span></div>
                <div class="rc-desc">
                    小游戏得分 0-100，根据得分判定四个结果等级：
                </div>
                <div class="rc-formula"><b>🌟 大成功 (BIG_SUCCESS)</b> — 得分 ≥ 90
  情绪：安全感+15、兴趣+12、压力-10、信任+18
  <strong>直接触发可收养状态！</strong>

<b>✅ 成功 (SUCCESS)</b> — 得分 ≥ 55
  情绪：安全感+8、兴趣+5、压力-3、信任+10

<b>⚠ 失败 (FAILURE)</b> — 得分 ≥ 25
  情绪：安全感-3、兴趣-5、压力+8、信任-2

<b>💀 严重失败 (CRITICAL_FAILURE)</b> — 得分 &lt; 25
  情绪：安全感-8、兴趣-10、压力+18、信任-5
  <strong>可能直接触发逃跑！</strong></div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🐾</span><span class="rc-name">同伴特性影响</span></div>
                <div class="rc-desc">
                    同行宠物的<strong>同伴特性</strong>和<strong>默契度</strong>会直接影响事件难度和参数：
                </div>
                <div class="rc-formula"><b>🐶 狗 (安心感)</b>：容错范围扩大25%，多一次失误机会
<b>🦊 狐狸 (试探)</b>：时间窗口扩大（随默契度增强）
<b>🦥 树懒 (安静陪伴)</b>：速度-50%，时间窗口+30%
<b>🐼 小熊猫 (慢慢来)</b>：速度-30%，时间窗口+15%
<b>🐨 考拉 (放松)</b>：全体节奏减慢25%
<b>🦓 斑马 (群体安心)</b>：多两次失误机会
<b>🐻 狗熊 (守护)</b>：容错一次，时间窗口略宽
<b>🐬 海豚 (共情)</b>：多一次机会，失误可补救
<b>🦘 袋鼠 (节奏爆发)</b>：额外加成阶段，可获更高分
<b>🦑 鱿鱼 (深海混沌)</b>：规则随机变化，保持警惕
<b>🐻‍❄ 北极熊 (压制)</b>：难度增加但成功后效果翻倍！</div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">💡</span><span class="rc-name">策略小贴士</span></div>
                <div class="rc-desc">
                    • 谨慎型动物需要耐心建立安全感，避免给压力<br>
                    • 玩伴型动物喜欢高兴趣值，多用「模仿」「玩耍」态度<br>
                    • 带高默契同伴可大幅降低事件难度<br>
                    • 大成功直接收养，是最快收服稀有动物的捷径<br>
                    • 如果压力已经很高，慎重触发事件——失败可能直接导致逃跑
                </div>
            </div>
        </div>

        <!-- 玩法指南 -->
        <div class="help-section" id="help-gameplay">
            <div class="section-title">🎮 新手指南</div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🎓</span><span class="rc-name">第1步：获得初始宠物</span></div>
                <div class="rc-desc">
                    注册/登录后先做问卷，根据你的选择获得一只初始宠物（稀有度=常见）。初始宠物来自东亚森林区域。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🍖</span><span class="rc-name">第2步：喂食互动</span></div>
                <div class="rc-desc">
                    点击宠物进入互动页 → 选择食物喂食 → 饱食度恢复。<br>
                    食物通过探险获得。每种宠物有最爱和讨厌的食物——最爱食物恢复更多且+亲密度。<br>
                    <strong>亲密度越高，喂食恢复越多！</strong>
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🎮</span><span class="rc-name">第3步：玩耍游戏</span></div>
                <div class="rc-desc">
                    每次玩耍消耗 8 饱食度，可选：猜拳对决、打砖块（60秒）、翻牌对对碰（60秒）。<br>
                    奖励心情+默契+亲密度。<strong>心情越高，奖励翻倍！</strong>保持好心情再玩。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🗺</span><span class="rc-name">第4步：世界探险</span></div>
                <div class="rc-desc">
                    世界地图选择区域 → 选择同行宠物（特性很重要！）→ 出发探险。<br>
                    每次探险 3 步，70%概率遇到野生动物，30%获得风景奖励（EXP+食物+属性）。<br>
                    <strong>高亲密度同伴让野生动物更放松，高默契同伴让特性效果更强。</strong>
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🐾</span><span class="rc-name">第5步：遭遇野生动物</span></div>
                <div class="rc-desc">
                    6种态度（等待/靠近/观察/投喂/模仿/后退）影响4个情绪维度（安全感/兴趣/压力/信任）。<br>
                    不同性格原型的动物对每种态度的反应不同 —— 没有唯一正确答案！<br>
                    <strong>满足捕捉条件后动物会跟随你</strong>——选择收服（全队+默契）或放归自然（全队+亲密度）。<br>
                    <strong>⚠ 压力超过20可能触发逃跑预警</strong>，下回合未缓解则逃跑。压力越高概率越大。「后退」或「等待」可降低压力。<br>
                    <strong>✨ 情绪条件满足时，动物可能发起「互动高潮事件」</strong>——即时操作小游戏，大成功直接收养！详见「互动事件」标签页。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">🔐</span><span class="rc-name">第6步：解锁新区域</span></div>
                <div class="rc-desc">
                    收集足够物种数量可解锁下一区域。6大区域：东亚森林 → 亚马孙雨林 → 非洲稀树草原 → 澳大利亚内陆 → 北极冰原 → 深海世界。
                </div>
            </div>
        </div>
    </div>

    <script>
        function switchHelp(name) {
            document.querySelectorAll('.help-tab').forEach(function(t) { t.classList.remove('active'); });
            document.querySelectorAll('.help-section').forEach(function(s) { s.classList.remove('active'); });
            var tab = document.querySelector('.help-tab[onclick*="'+name+'"]');
            if (tab) tab.classList.add('active');
            var sec = document.getElementById('help-'+name);
            if (sec) sec.classList.add('active');
        }
    </script>
</body>
</html>
