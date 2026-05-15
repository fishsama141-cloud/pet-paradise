<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "login";
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>宠物乐园</title>
    <style>
        :root {
            --bg: #FDF8F0;
            --card: #FFFEF9;
            --card-border: #E8DCC8;
            --text: #5C4A3A;
            --text-light: #8C7B6B;
            --text-lighter: #B5A898;
            --accent: #7B9E6D;
            --accent-warm: #D4956A;
            --input-bg: #FAF7F1;
            --input-border: #E0D6C5;
            --input-focus: #B8A890;
            --shadow: 0 2px 12px rgba(80, 60, 40, 0.06);
            --radius: 10px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: "Microsoft YaHei", "PingFang SC", "Hiragino Sans GB", sans-serif;
            background-color: var(--bg);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .container {
            width: 100%;
            max-width: 420px;
            background: var(--card);
            border-radius: 16px;
            box-shadow: var(--shadow);
            border: 1px solid var(--card-border);
            overflow: hidden;
        }

        /* ---- header ---- */
        .card-header {
            padding: 40px 32px 28px;
            text-align: center;
            background: url('<%= request.getContextPath() %>/assets/images/bg/header-bg.png') center/cover no-repeat;
            background-color: #F5EFE3;
        }
        .card-header .logo-img {
            width: 64px;
            height: 64px;
            object-fit: contain;
            display: block;
            margin: 0 auto 12px;
        }
        .card-header .logo-fallback {
            font-size: 52px;
            display: none;
        }
        .card-header .logo-img[src=""] ~ .logo-fallback,
        .card-header .logo-img:not([src]),
        .card-header .logo-img[src="#"] {
            display: none;
        }
        .card-header h1 {
            font-size: 24px;
            font-weight: 600;
            color: var(--text);
            letter-spacing: 2px;
        }
        .card-header p {
            font-size: 13px;
            color: var(--text-light);
            margin-top: 6px;
        }

        /* ---- tabs ---- */
        .tabs {
            display: flex;
            border-bottom: 1px solid var(--card-border);
            margin: 0 28px;
        }
        .tab {
            flex: 1;
            text-align: center;
            padding: 14px 0;
            cursor: pointer;
            font-size: 15px;
            font-weight: 500;
            color: var(--text-lighter);
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            transition: all 0.2s;
            font-family: inherit;
        }
        .tab.active {
            color: var(--text);
            font-weight: 600;
            border-bottom-color: var(--accent-warm);
        }
        .tab:hover { color: var(--text); }

        /* ---- form ---- */
        .form-box {
            padding: 28px 28px 36px;
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: 500;
            color: var(--text-light);
        }
        .form-group input {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid var(--input-border);
            border-radius: var(--radius);
            font-size: 15px;
            color: var(--text);
            background: var(--input-bg);
            transition: border-color 0.2s;
            outline: none;
            font-family: inherit;
        }
        .form-group input:focus {
            border-color: var(--input-focus);
        }
        .form-group input::placeholder {
            color: var(--text-lighter);
        }

        .btn {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: var(--radius);
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            font-family: inherit;
            letter-spacing: 1px;
        }
        .btn-primary {
            background: var(--accent-warm);
            color: #fff;
            margin-top: 4px;
        }
        .btn-primary:hover {
            background: #C8855A;
        }

        .error-msg {
            background: #FEF5F0;
            color: #C05040;
            padding: 10px 14px;
            border-radius: var(--radius);
            margin-bottom: 16px;
            font-size: 13px;
            border: 1px solid #F0D8C8;
        }

        .hint {
            text-align: center;
            margin-top: 12px;
            font-size: 12px;
            color: var(--text-lighter);
        }

        .hidden { display: none; }

        /* ---- footer decoration ---- */
        .footer-deco {
            text-align: center;
            padding: 0 28px 28px;
            font-size: 11px;
            color: var(--text-lighter);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card-header">
            <!--
                替换为你的 logo 图片，放在 /assets/images/ui/logo.png
                图片没准备好时用 emoji 占位
            -->
            <img class="logo-img" src="<%= request.getContextPath() %>/assets/images/ui/logo.png" alt="logo" onerror="this.style.display='none';this.nextElementSibling.style.display='block';">
            <span class="logo-fallback">🐾</span>
            <h1>宠物乐园</h1>
            <p>与动物伙伴一起冒险</p>
        </div>

        <div class="tabs">
            <button class="tab <%= "login".equals(activeTab) ? "active" : "" %>" onclick="switchTab('login')">登录</button>
            <button class="tab <%= "register".equals(activeTab) ? "active" : "" %>" onclick="switchTab('register')">注册</button>
        </div>

        <div class="form-box">
            <% if (error != null) { %>
            <div class="error-msg"><%= error %></div>
            <% } %>

            <form id="loginForm" action="<%= request.getContextPath() %>/auth" method="post" class="<%= "register".equals(activeTab) ? "hidden" : "" %>">
                <input type="hidden" name="action" value="login">
                <div class="form-group">
                    <label>用户名</label>
                    <input type="text" name="username" placeholder="请输入用户名" required>
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" name="password" placeholder="请输入密码" required>
                </div>
                <button type="submit" class="btn btn-primary">登 录</button>
            </form>

            <form id="registerForm" action="<%= request.getContextPath() %>/auth" method="post" class="<%= "login".equals(activeTab) ? "hidden" : "" %>">
                <input type="hidden" name="action" value="register">
                <div class="form-group">
                    <label>用户名</label>
                    <input type="text" name="username" placeholder="请输入用户名" required>
                </div>
                <div class="form-group">
                    <label>邮箱（选填）</label>
                    <input type="email" name="email" placeholder="请输入邮箱">
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" name="password" placeholder="请设置密码" required>
                </div>
                <button type="submit" class="btn btn-primary">注 册</button>
                <p class="hint">注册即表示同意与动物伙伴愉快玩耍</p>
            </form>
        </div>

        <div class="footer-deco">—— 开启你的冒险 ——</div>
    </div>

    <script>
        function switchTab(tab) {
            document.querySelectorAll('.tab').forEach(function(t) { t.classList.remove('active'); });
            event.target.classList.add('active');
            if (tab === 'login') {
                document.getElementById('loginForm').classList.remove('hidden');
                document.getElementById('registerForm').classList.add('hidden');
            } else {
                document.getElementById('registerForm').classList.remove('hidden');
                document.getElementById('loginForm').classList.add('hidden');
            }
        }
    </script>
</body>
</html>
