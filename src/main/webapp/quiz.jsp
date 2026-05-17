<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>初始问卷 - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        body {
            display: flex; align-items: center; justify-content: center;
            min-height: 100vh; padding: 20px;
            background-image:
                radial-gradient(ellipse at 20% 20%, rgba(180,150,110,0.06) 0%, transparent 55%),
                radial-gradient(ellipse at 80% 60%, rgba(140,170,120,0.05) 0%, transparent 55%);
        }
        .card {
            background: var(--card-bg); border-radius: var(--radius-xl);
            border: 1px solid var(--border); box-shadow: var(--shadow-xl);
            max-width: 640px; width: 100%; overflow: hidden;
            animation: fadeInScale 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .card-top {
            background: linear-gradient(135deg, #F7F0E3, #F2E8D5);
            padding: 32px 28px; text-align: center;
            border-bottom: 1px solid var(--border-light);
        }
        .card-top .icon { font-size: 44px; display: block; margin-bottom: 8px; }
        .card-top h2 { font-size: 24px; color: var(--text); font-weight: 700; letter-spacing: 1px; }
        .card-top p { font-size: 13px; color: var(--text-secondary); margin-top: 6px; font-weight: 500; }
        .card-body { padding: 28px 30px 34px; }

        .form-group { margin-bottom: 24px; }
        .form-group label {
            display: block; font-weight: 700; font-size: 15px;
            margin-bottom: 12px; color: var(--text); letter-spacing: 0.5px;
        }
        .options { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
        .option { position: relative; cursor: pointer; }
        .option input { display: none; }
        .option .label {
            display: block; padding: 14px 10px; border: 2px solid var(--border-light);
            border-radius: var(--radius); text-align: center; font-size: 13px;
            font-weight: 600; transition: all var(--transition);
            background: linear-gradient(135deg, #FDFBF6, #FAF7F0); color: var(--text); line-height: 1.5;
        }
        .option .label .env-emoji { font-size: 30px; display: block; margin-bottom: 4px; }
        .option .label .env-hint { font-size: 10px; color: var(--text-muted); font-weight: 500; margin-top: 3px; }
        .option input:checked + .label {
            border-color: var(--accent-warm); background: linear-gradient(135deg, #FDF5EC, #FDF0E0);
            color: #B06840; box-shadow: 0 0 0 3px rgba(212,149,106,0.12);
        }
        .option .label:hover { border-color: var(--border-warm); background: #FAF7F0; transform: translateY(-1px); }
        .name-input {
            width: 100%; padding: 13px 18px; border: 2px solid var(--border);
            border-radius: var(--radius); font-size: 15px; color: var(--text);
            outline: none; transition: all var(--transition);
            font-family: inherit; background: #FDFBF6;
        }
        .name-input:focus { border-color: var(--accent-warm); box-shadow: 0 0 0 3px rgba(212,149,106,0.1); }
        .step-indicator {
            text-align: center; margin-bottom: 22px;
            font-size: 13px; color: var(--text-secondary); font-weight: 500;
            background: linear-gradient(135deg, #FDF9F2, #FAF5E8);
            padding: 12px 18px; border-radius: var(--radius); border: 1px solid var(--border-light);
        }

        @media (max-width: 500px) {
            .options { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-top">
            <span class="icon">📝</span>
            <h2>初始伙伴问卷</h2>
            <p>回答几个小问题，为你匹配最合适的初始宠物~</p>
        </div>
        <div class="card-body">
            <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
            <% } %>
            <div class="step-indicator">选择你最喜欢的自然环境，将决定你的起始区域和初始伙伴</div>

            <form method="post" action="<%= request.getContextPath() %>/quiz">
                <div class="form-group">
                    <label>你最喜欢哪种自然环境？</label>
                    <div class="options">
                        <label class="option">
                            <input type="radio" name="environment" value="forest" required>
                            <span class="label">
                                <span class="env-emoji">🏯</span>东亚森林
                                <span class="env-hint">小熊猫·丹顶鹤·金丝猴</span>
                            </span>
                        </label>
                        <label class="option">
                            <input type="radio" name="environment" value="rainforest">
                            <span class="label">
                                <span class="env-emoji">🌴</span>亚马孙雨林
                                <span class="env-hint">巨嘴鸟·树懒·美洲豹</span>
                            </span>
                        </label>
                        <label class="option">
                            <input type="radio" name="environment" value="grassland">
                            <span class="label">
                                <span class="env-emoji">🦁</span>非洲稀树草原
                                <span class="env-hint">斑马·长颈鹿·非洲狮</span>
                            </span>
                        </label>
                        <label class="option">
                            <input type="radio" name="environment" value="outback">
                            <span class="label">
                                <span class="env-emoji">🦘</span>澳大利亚内陆
                                <span class="env-hint">考拉·鸭嘴兽·红袋鼠</span>
                            </span>
                        </label>
                        <label class="option">
                            <input type="radio" name="environment" value="arctic">
                            <span class="label">
                                <span class="env-emoji">🧊</span>北极冰原
                                <span class="env-hint">雪鸮·北极狐·北极熊</span>
                            </span>
                        </label>
                        <label class="option">
                            <input type="radio" name="environment" value="ocean">
                            <span class="label">
                                <span class="env-emoji">🌊</span>深海世界
                                <span class="env-hint">海龟·大王乌贼·蓝鲸</span>
                            </span>
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <label>周末你最喜欢做什么？</label>
                    <div class="options" style="grid-template-columns: 1fr 1fr;">
                        <label class="option">
                            <input type="radio" name="hobby" value="sport" required>
                            <span class="label">⚽ 运动健身</span>
                        </label>
                        <label class="option">
                            <input type="radio" name="hobby" value="reading">
                            <span class="label">📖 安静阅读</span>
                        </label>
                        <label class="option">
                            <input type="radio" name="hobby" value="social">
                            <span class="label">🎉 朋友聚会</span>
                        </label>
                        <label class="option">
                            <input type="radio" name="hobby" value="art">
                            <span class="label">🎨 艺术创作</span>
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <label>你觉得自己是什么性格？</label>
                    <div class="options" style="grid-template-columns: 1fr 1fr;">
                        <label class="option">
                            <input type="radio" name="personality" value="lively" required>
                            <span class="label">🎪 活泼开朗</span>
                        </label>
                        <label class="option">
                            <input type="radio" name="personality" value="calm">
                            <span class="label">🧘 沉稳安静</span>
                        </label>
                        <label class="option">
                            <input type="radio" name="personality" value="smart">
                            <span class="label">🧠 聪明机智</span>
                        </label>
                        <label class="option">
                            <input type="radio" name="personality" value="gentle">
                            <span class="label">🌸 温柔细腻</span>
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <label>给你的初始伙伴取个名字</label>
                    <input type="text" name="petName" class="name-input" placeholder="输入名字（不填则默认为"小可爱"）" maxlength="20">
                </div>

                <button type="submit" class="btn" style="width:100%; padding:14px; font-size:17px; background:var(--accent-warm); color:#fff; border:none;">领取我的初始伙伴！</button>
            </form>
        </div>
    </div>
</body>
</html>
