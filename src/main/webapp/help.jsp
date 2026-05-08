<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    List<Pet> userPets = (List<Pet>) request.getAttribute("userPets");
    if (userPets == null) userPets = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>&#x1F4D6; 游戏帮助 - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #1b2838 0%, #0d1b2a 30%, #1b2838 100%);
            min-height: 100vh; color: #e8dcc8;
        }
        .nav {
            background: #2d1f10; padding: 14px 28px; display: flex;
            align-items: center; justify-content: space-between;
            box-shadow: 0 4px 20px rgba(0,0,0,0.5); position: sticky; top: 0; z-index: 100;
            border-bottom: 2px solid #5a3e28;
        }
        .nav .brand { font-size: 22px; font-weight: 700; color: #f0c27a; text-decoration: none; }
        .nav-links { display: flex; gap: 10px; align-items: center; }
        .nav-links a {
            color: #d4b896; text-decoration: none; padding: 8px 16px; border-radius: 20px;
            font-weight: 600; font-size: 15px; background: rgba(255,255,255,0.08); transition: all 0.3s;
        }
        .nav-links a:hover, .nav-links a.active { background: #5a3e28; color: #f0c27a; }

        .main { max-width: 860px; margin: 0 auto; padding: 24px 20px; }

        .help-tabs {
            display: flex; gap: 8px; margin-bottom: 24px; flex-wrap: wrap;
            position: sticky; top: 70px; z-index: 10;
            background: rgba(13,27,42,0.95); padding: 10px 0; backdrop-filter: blur(8px);
        }
        .help-tab {
            padding: 10px 20px; border-radius: 20px; border: 2px solid #2a3a2a;
            cursor: pointer; font-weight: 600; font-size: 14px; transition: all 0.3s;
            background: #1e2d1e; color: #8a9a7a; font-family: inherit;
        }
        .help-tab:hover { border-color: #5a7a4a; color: #c0d0b0; }
        .help-tab.active {
            background: linear-gradient(135deg, #5a3e28, #7a5e3a);
            border-color: #f0c27a; color: #f0c27a;
        }
        .help-section { display: none; }
        .help-section.active { display: block; }

        .section-title {
            font-size: 20px; font-weight: 700; color: #f0c27a;
            margin-bottom: 16px; padding-bottom: 10px;
            border-bottom: 2px solid #3a4a2a;
        }
        .rule-card {
            background: #1a2a1a; border-radius: 14px; padding: 18px 20px;
            margin-bottom: 12px; border-left: 4px solid #5a7a4a;
            transition: all 0.3s;
        }
        .rule-card:hover { border-left-color: #f0c27a; }
        .rule-card .rc-header { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
        .rule-card .rc-icon { font-size: 28px; }
        .rule-card .rc-name { font-size: 18px; font-weight: 700; color: #f0c27a; }
        .rule-card .rc-formula {
            font-size: 12px; color: #90c090; background: #152015;
            padding: 6px 12px; border-radius: 8px; margin-top: 8px;
            font-family: "Consolas", monospace; white-space: pre-line; line-height: 1.6;
        }
        .rule-card .rc-desc { font-size: 14px; color: #a0b090; line-height: 1.7; }
        .rule-card .rc-penalty {
            font-size: 12px; color: #e08060; background: #2a1515;
            padding: 6px 12px; border-radius: 8px; margin-top: 6px;
        }
        @media (max-width: 600px) {
            .help-tab { padding: 8px 14px; font-size: 13px; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">&#x1F4D6; 宠物乐园</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard">&#x1F3E0; 我的宠物</a>
            <a href="<%= request.getContextPath() %>/map">&#x1F5FA; 世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia">&#x1F4D6; 图鉴</a>
            <a href="<%= request.getContextPath() %>/help" class="active">&#x2753; 帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">&#x1F6AA; 退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="help-tabs">
            <button class="help-tab active" onclick="switchHelp('attributes')">&#x1F4CA; 属性详解</button>
            <button class="help-tab" onclick="switchHelp('gameplay')">&#x1F3AE; 玩法指南</button>
        </div>

        <!-- ==================== 属性详解 ==================== -->
        <div class="help-section active" id="help-attributes">
            <div class="section-title">&#x1F4CA; 宠物属性详解</div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">&#x1F356;</span>
                    <span class="rc-name">饱食度 (Hunger)</span>
                </div>
                <div class="rc-desc">
                    决定宠物能否玩耍的核心属性。<strong>每次玩耍消耗 8 点饱食度</strong>，饱食度不足时无法玩耍。<br>
                    可通过喂食恢复，随时间自然下降（每小时 -5）。
                </div>
                <div class="rc-formula">&#x1F7E2; 饱食度 &#x2265; 8：可以玩耍
&#x1F534; 饱食度 &lt; 8：无法玩耍，需喂食</div>
                <div class="rc-penalty">&#x26A0; 惩罚：饱食度 &#x2264; 15 时，每小时 -2 亲密度</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">&#x1F60A;</span>
                    <span class="rc-name">心情值 (Mood)</span>
                </div>
                <div class="rc-desc">
                    影响<strong>玩耍奖励加成</strong>。心情越好，玩耍获得的奖励越多；心情低落时奖励缩水。<br>
                    随时间自然下降（每小时 -3），通过玩耍恢复。
                </div>
                <div class="rc-formula">心情 &#x2265; 80：玩耍奖励 x <strong>1.3</strong>（高兴）
心情 50-79：玩耍奖励 x <strong>1.0</strong>（正常）
心情 30-49：玩耍奖励 x <strong>0.8</strong>（低落）
心情 &lt; 30：玩耍奖励 x <strong>0.6</strong>（沮丧）</div>
                <div class="rc-penalty">&#x26A0; 惩罚：心情 &#x2264; 20 时，每小时 -2 亲密度</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">&#x2764;&#xFE0F;</span>
                    <span class="rc-name">亲密度 (Affinity)</span>
                </div>
                <div class="rc-desc">
                    宠物与主人的<strong>情感纽带</strong>。亲密度越高，喂食效果越好，带它探险时野生动物也更放松。<br>
                    喂食最爱食物 +5，喂讨厌食物 -5，升级 +5，放生祝福 +8。
                </div>
                <div class="rc-formula"><b>【喂食加成】</b>亲密度影响喂食恢复量：
亲密度 &#x2265; 80：饱食恢复 x <strong>1.5</strong>
亲密度 &#x2265; 50：饱食恢复 x <strong>1.3</strong>
亲密度 &#x2265; 30：饱食恢复 x <strong>1.15</strong>

<b>【探险加成】</b>高亲密度同伴让野生动物初始更放松：
亲密度 &#x2265; 80：初始信任 +12，安全感 +6
亲密度 &#x2265; 50：初始信任 +6，安全感 +3
亲密度 &#x2265; 30：初始信任 +3，安全感 +1</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">&#x1F91D;</span>
                    <span class="rc-name">默契度 (Bond)</span>
                </div>
                <div class="rc-desc">
                    宠物与主人的<strong>配合程度</strong>。默契越高，探险中同伴特性效果越强。<br>
                    主要通过玩耍、探险获得，升级 +3，放生祝福 +5。
                </div>
                <div class="rc-formula"><b>【遭遇战加成】</b>默契度放大同伴特性的正收益：
默契度 &#x2265; 80：特性正效果 x <strong>1.4</strong>
默契度 &#x2265; 50：特性正效果 x <strong>1.2</strong>
默契度 &#x2265; 30：特性正效果 x <strong>1.1</strong>
默契度 &lt; 30：无加成</div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">&#x2B50;</span>
                    <span class="rc-name">经验值与等级</span>
                </div>
                <div class="rc-desc">
                    积累 EXP 提升等级。每 100 EXP 升 1 级。升级时亲密度 +5，默契度 +3。<br>
                    EXP 来源：探险、成功遭遇战（稀有度越高越多）。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">&#x1F3AD;</span>
                    <span class="rc-name">性格 (Personality)</span>
                </div>
                <div class="rc-desc">
                    宠物性格分三种：<strong>活泼</strong>（玩耍/靠近加成）、<strong>胆小</strong>（观察/安抚加成）、<strong>温顺</strong>（喂食/安抚加成）。<br>
                    性格影响遭遇战中特定态度的效果加成（x1.2）。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header">
                    <span class="rc-icon">&#x1F48E;</span>
                    <span class="rc-name">稀有度 (Rarity)</span>
                </div>
                <div class="rc-desc">
                    分三档：<strong>常见</strong> / <strong>稀有</strong> / <strong>极稀有</strong>。<br>
                    稀有度越高的动物，遭遇战后获得的 EXP 越多，但捕捉条件也越苛刻。
                </div>
            </div>
        </div>

        <!-- ==================== 玩法指南 ==================== -->
        <div class="help-section" id="help-gameplay">
            <div class="section-title">&#x1F3AE; 新手指南</div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">&#x1F393;</span><span class="rc-name">第1步：获得初始宠物</span></div>
                <div class="rc-desc">
                    注册/登录后先做问卷，根据你的选择获得一只初始宠物（稀有度=常见）。初始宠物来自东亚森林区域。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">&#x1F356;</span><span class="rc-name">第2步：喂食互动</span></div>
                <div class="rc-desc">
                    点击宠物进入互动页 &#x2192; 选择食物喂食 &#x2192; 饱食度恢复。<br>
                    食物通过探险获得。每种宠物有最爱和讨厌的食物——最爱食物恢复更多且+亲密度。<br>
                    <strong>亲密度越高，喂食恢复越多！</strong>
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">&#x1F3AE;</span><span class="rc-name">第3步：玩耍游戏</span></div>
                <div class="rc-desc">
                    每次玩耍消耗 8 饱食度，可选：猜拳对决、打砖块（60秒）、翻牌对对碰（60秒）。<br>
                    奖励心情+默契+亲密度。<strong>心情越高，奖励翻倍！</strong>保持好心情再玩。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">&#x1F5FA;&#xFE0F;</span><span class="rc-name">第4步：世界探险</span></div>
                <div class="rc-desc">
                    世界地图选择区域 &#x2192; 选择同行宠物（特性很重要！）&#x2192; 出发探险。<br>
                    每次探险 3 步，70%概率遇到野生动物，30%获得风景奖励（EXP+食物+属性）。<br>
                    <strong>高亲密度同伴让野生动物更放松，高默契同伴让特性效果更强。</strong>
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">&#x1F43E;</span><span class="rc-name">第5步：遭遇野生动物</span></div>
                <div class="rc-desc">
                    6种态度（等待/靠近/观察/投喂/模仿/后退）影响4个情绪维度（安全感/兴趣/压力/信任）。<br>
                    不同性格原型的动物对每种态度的反应不同 —— 没有唯一正确答案！<br>
                    <strong>满足捕捉条件后动物会跟随你</strong>——选择收服（全队+默契）或放归自然（全队+亲密度）。<br>
                    <strong>&#x26A0; 压力超过25可能触发逃跑预警</strong>，下回合未缓解则逃跑。「后退」或「等待」可降低压力。
                </div>
            </div>

            <div class="rule-card">
                <div class="rc-header"><span class="rc-icon">&#x1F510;</span><span class="rc-name">第6步：解锁新区域</span></div>
                <div class="rc-desc">
                    收集足够物种数量可解锁下一区域。6大区域：东亚森林 &#x2192; 亚马孙雨林 &#x2192; 非洲稀树草原 &#x2192; 澳大利亚内陆 &#x2192; 北极冰原 &#x2192; 深海世界。
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
