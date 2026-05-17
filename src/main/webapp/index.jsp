<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.User" %>
<%@ page import="org.example.pets.dao.UserDAO" %>
<%
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "login";
    String error = (String) request.getAttribute("error");

    // Auto-login: check for persistent cookie
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("pets_auto_login".equals(c.getName())) {
                    try {
                        String decoded = new String(java.util.Base64.getDecoder().decode(c.getValue()));
                        String[] parts = decoded.split(":", 2);
                        if (parts.length == 2) {
                            UserDAO dao = new UserDAO();
                            User u = dao.login(parts[0], parts[1]);
                            if (u != null) {
                                session.setAttribute("user", u);
                                response.sendRedirect(request.getContextPath() + "/dashboard");
                                return;
                            }
                        }
                    } catch (Exception ignored) {}
                    break;
                }
            }
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>宠物乐园 — 与动物伙伴一起冒险</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <style>
        :root {
            --bg: #FBF6ED;
            --card: #FFFEFA;
            --card-border: #E8DCC8;
            --text: #4A3728;
            --text-light: #7A6B5A;
            --text-lighter: #B0A090;
            --accent: #6B9E5A;
            --accent-warm: #D4956A;
            --accent-warm-hover: #C08050;
            --input-bg: #FAF7F1;
            --input-border: #E0D6C5;
            --input-focus: #C5B090;
            --shadow: 0 8px 40px rgba(60, 35, 15, 0.10);
            --shadow-sm: 0 2px 8px rgba(60, 35, 15, 0.06);
            --radius: 12px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: "Microsoft YaHei", "PingFang SC", "Hiragino Sans GB", sans-serif;
            background-color: var(--bg);
            background-image:
                radial-gradient(ellipse at 15% 10%, rgba(180,150,110,0.08) 0%, transparent 55%),
                radial-gradient(ellipse at 85% 80%, rgba(140,170,120,0.06) 0%, transparent 55%),
                radial-gradient(ellipse at 40% 95%, rgba(200,160,100,0.05) 0%, transparent 50%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            position: relative;
        }

        /* Decorative floating elements */
        .deco {
            position: fixed;
            pointer-events: none;
            z-index: 0;
            opacity: 0.12;
            font-size: 48px;
            animation: float 20s ease-in-out infinite;
        }
        .deco-1 { top: 8%; left: 6%; animation-delay: 0s; font-size: 56px; }
        .deco-2 { top: 12%; right: 5%; animation-delay: -5s; font-size: 40px; }
        .deco-3 { bottom: 10%; left: 8%; animation-delay: -10s; font-size: 44px; }
        .deco-4 { bottom: 15%; right: 7%; animation-delay: -15s; font-size: 52px; }
        .deco-5 { top: 50%; left: 3%; animation-delay: -7s; font-size: 36px; }
        .deco-6 { top: 45%; right: 4%; animation-delay: -12s; font-size: 38px; }

        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            25% { transform: translateY(-18px) rotate(3deg); }
            50% { transform: translateY(-8px) rotate(-2deg); }
            75% { transform: translateY(-22px) rotate(1deg); }
        }

        .container {
            width: 100%;
            max-width: 420px;
            background: var(--card);
            border-radius: 20px;
            box-shadow: var(--shadow);
            border: 1px solid var(--card-border);
            overflow: hidden;
            position: relative;
            z-index: 1;
            animation: cardIn 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(20px) scale(0.97); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        /* ---- header ---- */
        .card-header {
            padding: 44px 32px 30px;
            text-align: center;
            background: linear-gradient(180deg, #F7F0E3 0%, #F2E8D5 100%);
            position: relative;
            overflow: hidden;
        }
        .card-header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -30%;
            width: 160%;
            height: 160%;
            background: radial-gradient(ellipse, rgba(255,255,255,0.3) 0%, transparent 60%);
            pointer-events: none;
        }
        .card-header .logo-fallback {
            font-size: 60px;
            display: block;
            position: relative;
            z-index: 1;
            animation: bounceIn 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            filter: drop-shadow(0 4px 8px rgba(120,80,40,0.15));
        }
        @keyframes bounceIn {
            0% { transform: scale(0); opacity: 0; }
            60% { transform: scale(1.15); }
            100% { transform: scale(1); opacity: 1; }
        }
        .card-header h1 {
            font-size: 26px;
            font-weight: 700;
            color: var(--text);
            letter-spacing: 3px;
            position: relative;
            z-index: 1;
            margin-top: 8px;
        }
        .card-header p {
            font-size: 13px;
            color: var(--text-light);
            margin-top: 6px;
            position: relative;
            z-index: 1;
            letter-spacing: 1px;
        }
        .card-header .head-deco {
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 12px;
            letter-spacing: 4px;
            color: var(--text-lighter);
            z-index: 1;
        }

        /* ---- tabs ---- */
        .tabs {
            display: flex;
            border-bottom: 1px solid var(--card-border);
            margin: 0 28px;
            position: relative;
        }
        .tab {
            flex: 1;
            text-align: center;
            padding: 16px 0;
            cursor: pointer;
            font-size: 15px;
            font-weight: 500;
            color: var(--text-lighter);
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            transition: all 0.25s ease;
            font-family: inherit;
            position: relative;
            letter-spacing: 1px;
        }
        .tab.active {
            color: var(--text);
            font-weight: 700;
            border-bottom-color: var(--accent-warm);
        }
        .tab:hover { color: var(--text); }

        /* ---- form ---- */
        .form-box {
            padding: 28px 28px 32px;
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-light);
            letter-spacing: 0.5px;
        }
        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 1.5px solid var(--input-border);
            border-radius: var(--radius);
            font-size: 15px;
            color: var(--text);
            background: var(--input-bg);
            transition: all 0.25s ease;
            outline: none;
            font-family: inherit;
        }
        .form-group input:focus {
            border-color: var(--input-focus);
            box-shadow: 0 0 0 3px rgba(200,170,130,0.12);
            background: #fff;
        }
        .form-group input::placeholder {
            color: var(--text-lighter);
        }

        /* Remember me + auto-login hint */
        .remember-row {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 18px;
            font-size: 13px;
            color: var(--text-light);
            cursor: pointer;
        }
        .remember-row input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: var(--accent-warm);
            cursor: pointer;
        }
        .remember-row label {
            cursor: pointer;
            user-select: none;
        }

        .btn-submit {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: var(--radius);
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.25s ease;
            font-family: inherit;
            letter-spacing: 2px;
            background: var(--accent-warm);
            color: #fff;
            position: relative;
            overflow: hidden;
        }
        .btn-submit:hover {
            background: var(--accent-warm-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(200,128,80,0.3);
        }
        .btn-submit:active {
            transform: translateY(0);
            box-shadow: 0 2px 8px rgba(200,128,80,0.2);
        }

        .error-msg {
            background: #FEF6F2;
            color: #B05038;
            padding: 12px 16px;
            border-radius: var(--radius);
            margin-bottom: 18px;
            font-size: 13px;
            font-weight: 500;
            border: 1px solid #F0D8C8;
            border-left: 3px solid #C05848;
            animation: shake 0.4s ease;
        }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20% { transform: translateX(-6px); }
            40% { transform: translateX(6px); }
            60% { transform: translateX(-4px); }
            80% { transform: translateX(4px); }
        }

        .hint {
            text-align: center;
            margin-top: 12px;
            font-size: 12px;
            color: var(--text-lighter);
            letter-spacing: 0.5px;
        }

        .hidden { display: none !important; }

        /* ---- footer ---- */
        .footer-deco {
            text-align: center;
            padding: 0 28px 28px;
            font-size: 11px;
            color: var(--text-lighter);
            letter-spacing: 2px;
        }
    </style>
</head>
<body>
    <!-- Decorative floating animals -->
    <div class="deco deco-1">&#x1F43E;</div>
    <div class="deco deco-2">&#x1F98A;</div>
    <div class="deco deco-3">&#x1F422;</div>
    <div class="deco deco-4">&#x1F98B;</div>
    <div class="deco deco-5">&#x1F439;</div>
    <div class="deco deco-6">&#x1F43F;</div>

    <div class="container">
        <div class="card-header">
            <span class="logo-fallback">&#x1F43E;</span>
            <h1>宠物乐园</h1>
            <p>与动物伙伴一起冒险</p>
        </div>

        <div class="tabs">
            <button class="tab <%= "login".equals(activeTab) ? "active" : "" %>" onclick="switchTab('login')">登 录</button>
            <button class="tab <%= "register".equals(activeTab) ? "active" : "" %>" onclick="switchTab('register')">注 册</button>
        </div>

        <div class="form-box">
            <% if (error != null) { %>
            <div class="error-msg"><%= error %></div>
            <% } %>

            <form id="loginForm" action="<%= request.getContextPath() %>/auth" method="post" class="<%= "register".equals(activeTab) ? "hidden" : "" %>">
                <input type="hidden" name="action" value="login">
                <div class="form-group">
                    <label>用户名</label>
                    <input type="text" name="username" placeholder="请输入用户名" required autocomplete="username">
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" name="password" placeholder="请输入密码" required autocomplete="current-password">
                </div>
                <div class="remember-row" onclick="document.getElementById('rememberMe').click()">
                    <input type="checkbox" name="remember" id="rememberMe" value="on">
                    <label for="rememberMe">记住我（30天内自动登录）</label>
                </div>
                <button type="submit" class="btn-submit">登 录</button>
            </form>

            <form id="registerForm" action="<%= request.getContextPath() %>/auth" method="post" class="<%= "login".equals(activeTab) ? "hidden" : "" %>">
                <input type="hidden" name="action" value="register">
                <div class="form-group">
                    <label>用户名</label>
                    <input type="text" name="username" placeholder="请输入用户名" required autocomplete="username">
                </div>
                <div class="form-group">
                    <label>邮箱（选填）</label>
                    <input type="email" name="email" placeholder="请输入邮箱" autocomplete="email">
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" name="password" placeholder="请设置密码（至少4位）" required minlength="4" autocomplete="new-password">
                </div>
                <button type="submit" class="btn-submit">注 册</button>
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
