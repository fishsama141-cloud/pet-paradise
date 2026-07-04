<%-- 404错误页面，提示用户访问的页面不存在 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>404 - 页面未找到</title>
    <style>
        body { display:flex; justify-content:center; align-items:center; height:100vh; font-family:'Microsoft YaHei',sans-serif; background:#f5f6fa; }
        .error-box { text-align:center; }
        .error-box h1 { font-size:6em; color:#e74c3c; margin:0; }
        .error-box p { color:#666; margin:10px 0 25px; }
    </style>
</head>
<body>
<div class="error-box">
    <h1>404</h1>
    <p>抱歉，您访问的页面不存在！</p>
    <a href="${pageContext.request.contextPath}/" style="color:#3498db;text-decoration:none;">返回首页</a>
</div>
</body>
</html>
