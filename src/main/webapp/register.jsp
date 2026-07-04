<%-- 注册页面，支持学生和教师账号注册 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 校园助管申请管理平台</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Microsoft YaHei',sans-serif; background:linear-gradient(135deg, #2c3e50, #3498db); min-height:100vh; display:flex; justify-content:center; align-items:center; }
        .register-box { background:#fff; border-radius:12px; padding:40px; width:480px; box-shadow:0 10px 40px rgba(0,0,0,0.2); }
        .register-box h2 { text-align:center; color:#2c3e50; margin-bottom:30px; font-size:1.6em; }
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; margin-bottom:6px; color:#555; font-weight:600; }
        .form-group input, .form-group select { width:100%; padding:10px; border:1px solid #ddd; border-radius:6px; font-size:0.95em; transition:border-color 0.3s; }
        .form-group input:focus, .form-group select:focus { border-color:#3498db; outline:none; }
        .btn-register { width:100%; padding:12px; background:#27ae60; color:#fff; border:none; border-radius:6px; font-size:1.1em; cursor:pointer; transition:background 0.3s; }
        .btn-register:hover { background:#219a52; }
        .login-link { text-align:center; margin-top:20px; color:#888; }
        .login-link a { color:#3498db; text-decoration:none; }
        .alert { padding:12px 18px; border-radius:6px; margin-bottom:20px; }
        .alert-danger { background:#f8d7da; color:#721c24; border:1px solid #f5c6cb; }
        .student-only { display:none; }
    </style>
</head>
<body>
<div class="register-box">
    <h2>用户注册</h2>

    <c:if test="${not empty requestScope.error}">
        <div class="alert alert-danger">${requestScope.error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/register" method="post">
        <div class="form-group">
            <label>身份</label>
            <select name="role" id="roleSelect">
                <option value="student">学生</option>
                <option value="teacher">老师</option>
            </select>
        </div>
        <div class="form-group">
            <label for="name">姓名 <span style="color:#e74c3c;">*</span></label>
            <input type="text" id="name" name="name" required placeholder="请输入真实姓名">
        </div>
        <div class="form-group">
            <label for="number" id="numberLabel">学号 <span style="color:#e74c3c;">*</span></label>
            <input type="text" id="number" name="number" required placeholder="请输入学号">
        </div>
        <div class="form-group student-only" id="classNameGroup">
            <label for="class_name">班级 <small style="color:#999;font-weight:normal;">选填</small></label>
            <input type="text" id="class_name" name="className" placeholder="如 计科221">
        </div>
        <div class="form-group">
            <label for="email">邮箱 <small style="color:#999;font-weight:normal;">选填</small></label>
            <input type="email" id="email" name="email" placeholder="请输入邮箱地址">
        </div>
        <div class="form-group">
            <label for="phone">手机号 <small style="color:#999;font-weight:normal;">选填</small></label>
            <input type="text" id="phone" name="phone" placeholder="请输入手机号码">
        </div>
        <div class="form-group">
            <label for="password">密码 <span style="color:#e74c3c;">*</span></label>
            <input type="password" id="password" name="password" required placeholder="至少6位密码" minlength="6">
        </div>
        <div class="form-group">
            <label for="confirmPassword">确认密码 <span style="color:#e74c3c;">*</span></label>
            <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="请再次输入密码">
        </div>
        <button type="submit" class="btn-register">注 册</button>
    </form>
    <div class="login-link">
        已有账号？<a href="${pageContext.request.contextPath}/login.jsp">立即登录</a>
    </div>
</div>

<script>
    (function() {
        var roleSelect = document.getElementById('roleSelect');
        var numberLabel = document.getElementById('numberLabel');
        var numberInput = document.getElementById('number');
        var classNameGroup = document.getElementById('classNameGroup');

        function toggleRole() {
            var isStudent = roleSelect.value === 'student';
            numberLabel.textContent = isStudent ? '学号' : '工号';
            numberInput.placeholder = isStudent ? '请输入学号' : '请输入工号';
            classNameGroup.style.display = isStudent ? 'block' : 'none';
        }

        roleSelect.addEventListener('change', toggleRole);
        toggleRole();
    })();
</script>
</body>
</html>
