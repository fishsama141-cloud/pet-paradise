<%-- 登录页面，支持学生和教师角色登录 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
if (session.getAttribute("user") != null) {
    response.sendRedirect(request.getContextPath() + "/app");
    return;
}
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 校园助管申请管理平台</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Microsoft YaHei', sans-serif;
            background: linear-gradient(135deg, #2c3e50, #3498db);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .login-wrapper { width: 420px; }
        .login-wrapper h1 {
            text-align: center;
            color: #fff;
            margin-bottom: 30px;
            font-size: 1.6em;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .login-card {
            background: #fff;
            border-radius: 12px;
            padding: 35px 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        .role-tabs {
            display: flex;
            gap: 0;
            margin-bottom: 25px;
            border-radius: 8px;
            overflow: hidden;
            border: 2px solid #e0e0e0;
        }
        .role-tab {
            flex: 1;
            padding: 12px;
            text-align: center;
            font-size: 1.05em;
            font-weight: 600;
            cursor: pointer;
            border: none;
            background: #f5f5f5;
            color: #888;
            transition: all 0.3s;
        }
        .role-tab.active-student {
            background: #3498db;
            color: #fff;
        }
        .role-tab.active-teacher {
            background: #27ae60;
            color: #fff;
        }
        .form-group { margin-bottom: 16px; }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            color: #555;
            font-weight: 600;
            font-size: 0.9em;
        }
        .form-group input {
            width: 100%;
            padding: 11px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.95em;
            transition: border-color 0.3s;
        }
        .form-group input:focus {
            border-color: #3498db;
            outline: none;
        }
        .teacher-mode .form-group input:focus {
            border-color: #27ae60;
        }
        .remember-row {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 16px;
        }
        .remember-row input[type="checkbox"] { width: auto; }
        .remember-row label { color: #888; font-weight: normal; font-size: 0.9em; }
        .btn-login {
            width: 100%;
            padding: 12px;
            color: #fff;
            border: none;
            border-radius: 6px;
            font-size: 1.05em;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-login.btn-student { background: #3498db; }
        .btn-login.btn-student:hover { background: #2980b9; }
        .btn-login.btn-teacher { background: #27ae60; }
        .btn-login.btn-teacher:hover { background: #219a52; }
        .register-link {
            text-align: center;
            margin-top: 18px;
            color: #888;
            font-size: 0.9em;
        }
        .register-link a { color: #3498db; text-decoration: none; }
        .alert {
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            font-size: 0.9em;
            text-align: center;
        }
        .alert-danger { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>
<div class="login-wrapper">
    <h1>校园助管申请管理平台</h1>

    <c:if test="${not empty requestScope.error || not empty param.error}">
        <div class="alert alert-danger">
            <c:out value="${not empty requestScope.error ? requestScope.error : param.error}"/>
        </div>
    </c:if>
    <c:if test="${not empty requestScope.success}">
        <div class="alert alert-success">${requestScope.success}</div>
    </c:if>

    <div class="login-card" id="loginCard">
        <div class="role-tabs">
            <button type="button" class="role-tab active-student" id="tabStudent" onclick="switchRole('student')">学生</button>
            <button type="button" class="role-tab" id="tabTeacher" onclick="switchRole('teacher')">教师</button>
        </div>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <input type="hidden" name="role" id="roleInput" value="student">

            <div class="form-group">
                <label for="login-name">姓名</label>
                <input type="text" id="login-name" name="name" required placeholder="请输入姓名">
            </div>
            <div class="form-group">
                <label for="login-number" id="numberLabel">学号</label>
                <input type="text" id="login-number" name="number" required placeholder="请输入学号">
            </div>
            <div class="form-group">
                <label for="login-pwd">密码</label>
                <input type="password" id="login-pwd" name="password" required placeholder="请输入密码">
            </div>
            <div class="remember-row">
                <input type="checkbox" id="remember" name="remember">
                <label for="remember">记住我（7天自动登录）</label>
            </div>
            <button type="submit" class="btn-login btn-student" id="btnLogin">登 录</button>
        </form>
        <div class="register-link">
            还没有账号？<a href="${pageContext.request.contextPath}/register.jsp">立即注册</a>
        </div>
    </div>
</div>

<script>
    function switchRole(role) {
        var isStudent = role === 'student';
        document.getElementById('roleInput').value = role;

        var tabStu = document.getElementById('tabStudent');
        var tabTch = document.getElementById('tabTeacher');
        var btnLogin = document.getElementById('btnLogin');
        var card = document.getElementById('loginCard');
        var numberLabel = document.getElementById('numberLabel');
        var numberInput = document.getElementById('login-number');

        if (isStudent) {
            tabStu.className = 'role-tab active-student';
            tabTch.className = 'role-tab';
            btnLogin.className = 'btn-login btn-student';
            card.classList.remove('teacher-mode');
            numberLabel.textContent = '学号';
            numberInput.placeholder = '请输入学号';
        } else {
            tabTch.className = 'role-tab active-teacher';
            tabStu.className = 'role-tab';
            btnLogin.className = 'btn-login btn-teacher';
            card.classList.add('teacher-mode');
            numberLabel.textContent = '教师工号';
            numberInput.placeholder = '请输入教师工号';
        }
    }
</script>
</body>
</html>
