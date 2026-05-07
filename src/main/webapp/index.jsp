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
    <title>🐾 宠物乐园 - 登录/注册</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(135deg, #FFF5E6 0%, #FFE0B2 30%, #FFCC80 60%, #FFE0B2 100%);
            background-size: 400% 400%;
            animation: bgShift 15s ease infinite;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        @keyframes bgShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }
        .container {
            width: 100%;
            max-width: 440px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(255, 140, 66, 0.25);
            overflow: hidden;
            padding: 0;
        }
        .header {
            background: linear-gradient(135deg, #FF8C42, #FF6B6B);
            padding: 32px 24px;
            text-align: center;
            color: white;
        }
        .header .logo {
            font-size: 48px;
            display: block;
            margin-bottom: 8px;
        }
        .header h1 {
            font-size: 26px;
            font-weight: 700;
            letter-spacing: 2px;
        }
        .header p {
            font-size: 13px;
            opacity: 0.9;
            margin-top: 4px;
        }
        .tabs {
            display: flex;
            border-bottom: 2px solid #FFE0B2;
        }
        .tab {
            flex: 1;
            text-align: center;
            padding: 14px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            color: #8D6E63;
            background: #FFF8F0;
            border: none;
            transition: all 0.3s;
        }
        .tab.active {
            color: #FF8C42;
            background: white;
            border-bottom: 3px solid #FF8C42;
            margin-bottom: -2px;
        }
        .tab:hover { background: #FFF3E8; }
        .form-box {
            padding: 32px 28px;
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #5D4037;
            font-size: 14px;
        }
        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #FFE0B2;
            border-radius: 12px;
            font-size: 15px;
            color: #5D4037;
            background: #FFFDF9;
            transition: all 0.3s;
            outline: none;
        }
        .form-group input:focus {
            border-color: #FF8C42;
            box-shadow: 0 0 0 3px rgba(255, 140, 66, 0.15);
        }
        .btn {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 12px;
            font-size: 17px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            letter-spacing: 1px;
        }
        .btn-primary {
            background: linear-gradient(135deg, #FF8C42, #FF6B6B);
            color: white;
            margin-top: 8px;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(255, 140, 66, 0.4);
        }
        .error-msg {
            background: #FFF0F0;
            color: #D32F2F;
            padding: 10px 16px;
            border-radius: 10px;
            margin-bottom: 16px;
            font-size: 13px;
            border-left: 3px solid #EF5350;
        }
        .hint {
            text-align: center;
            margin-top: 12px;
            font-size: 12px;
            color: #A1887F;
        }
        .hidden { display: none; }
        .pets-float {
            position: fixed;
            font-size: 32px;
            pointer-events: none;
            animation: floatUp 8s ease-in infinite;
            opacity: 0.35;
            z-index: 0;
        }
        @keyframes floatUp {
            0% { transform: translateY(0) rotate(0deg); opacity: 0; }
            20% { opacity: 0.35; }
            80% { opacity: 0.35; }
            100% { transform: translateY(-100vh) rotate(40deg); opacity: 0; }
        }
    </style>
</head>
<body>
    <div class="pets-float" style="left:10%; animation-delay:0s;">🐱</div>
    <div class="pets-float" style="left:25%; animation-delay:2s;">🐶</div>
    <div class="pets-float" style="left:50%; animation-delay:4s;">🐰</div>
    <div class="pets-float" style="left:70%; animation-delay:1s;">🦊</div>
    <div class="pets-float" style="left:85%; animation-delay:5s;">🐬</div>
    <div class="pets-float" style="left:40%; animation-delay:3s;">🐻</div>
    <div class="pets-float" style="left:15%; animation-delay:6s;">🦅</div>
    <div class="pets-float" style="left:60%; animation-delay:7s;">🐴</div>

    <div class="container">
        <div class="header">
            <span class="logo">🐾</span>
            <h1>宠物乐园</h1>
            <p>与可爱的动物伙伴们一起冒险吧！</p>
        </div>
        <div class="tabs">
            <button class="tab <%= "login".equals(activeTab) ? "active" : "" %>" onclick="switchTab('login')">🔑 登录</button>
            <button class="tab <%= "register".equals(activeTab) ? "active" : "" %>" onclick="switchTab('register')">✨ 注册</button>
        </div>

        <div class="form-box">
            <% if (error != null) { %>
            <div class="error-msg">⚠️ <%= error %></div>
            <% } %>

            <!-- 登录表单 -->
            <form id="loginForm" action="<%= request.getContextPath() %>/auth" method="post" class="<%= "register".equals(activeTab) ? "hidden" : "" %>">
                <input type="hidden" name="action" value="login">
                <div class="form-group">
                    <label>👤 用户名</label>
                    <input type="text" name="username" placeholder="请输入用户名" required>
                </div>
                <div class="form-group">
                    <label>🔒 密码</label>
                    <input type="password" name="password" placeholder="请输入密码" required>
                </div>
                <button type="submit" class="btn btn-primary">登 录</button>
            </form>

            <!-- 注册表单 -->
            <form id="registerForm" action="<%= request.getContextPath() %>/auth" method="post" class="<%= "login".equals(activeTab) ? "hidden" : "" %>">
                <input type="hidden" name="action" value="register">
                <div class="form-group">
                    <label>👤 用户名</label>
                    <input type="text" name="username" placeholder="请输入用户名" required>
                </div>
                <div class="form-group">
                    <label>📧 邮箱（选填）</label>
                    <input type="email" name="email" placeholder="请输入邮箱">
                </div>
                <div class="form-group">
                    <label>🔒 密码</label>
                    <input type="password" name="password" placeholder="请设置密码" required>
                </div>
                <button type="submit" class="btn btn-primary">注 册</button>
                <p class="hint">注册即表示同意与动物伙伴愉快玩耍 🐾</p>
            </form>
        </div>
    </div>

    <script>
        function switchTab(tab) {
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
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
