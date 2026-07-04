<%-- 500服务器错误页面，显示异常详情供调试 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>500 - 服务器错误</title>
    <style>
        body { font-family:'Microsoft YaHei',sans-serif; background:#f5f6fa; margin:40px; }
        .error-box { text-align:center; }
        .error-box h1 { font-size:6em; color:#f39c12; margin:0; }
        .error-box p { color:#666; margin:10px 0 25px; }
        .detail { background:#fff; border:1px solid #e0e0e0; border-radius:8px; padding:20px; margin-top:20px; text-align:left; max-width:900px; margin-left:auto; margin-right:auto; }
        .detail h3 { color:#e74c3c; margin-top:0; }
        .detail pre { background:#2d2d2d; color:#f8f8f2; padding:15px; border-radius:4px; overflow-x:auto; font-size:0.85em; white-space:pre-wrap; word-break:break-all; }
    </style>
</head>
<body>
<div class="error-box">
    <h1>500</h1>
    <p>服务器内部错误，请稍后再试！</p>
    <a href="${pageContext.request.contextPath}/" style="color:#3498db;text-decoration:none;">返回首页</a>
</div>
<%
    Object exObj = request.getAttribute("exception");
    Object exFromContainer = request.getAttribute("jakarta.servlet.error.exception");
    String errMsg = exObj != null ? exObj.toString() : (String) request.getAttribute("jakarta.servlet.error.message");
    Throwable ex = (Throwable) (exObj instanceof Throwable ? exObj : exFromContainer);
    String stackTrace = (String) request.getAttribute("stackTrace");
%>
<% if (errMsg != null || ex != null) { %>
<div class="detail">
    <% if (errMsg != null) { %>
    <h3>错误信息：<%= errMsg %></h3>
    <% } %>
    <% if (ex != null) { %>
        <p><strong>异常类型：</strong><%= ex.getClass().getName() %></p>
        <p><strong>异常消息：</strong><%= ex.getMessage() %></p>
    <% } %>
    <% if (stackTrace != null) { %>
    <pre><%= stackTrace %></pre>
    <% } %>
</div>
<% } %>
</body>
</html>
