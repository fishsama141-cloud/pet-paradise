<%-- 公共头部导航栏，根据用户角色显示不同的导航菜单 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - 校园助管申请管理平台</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
</head>
<body>
<div class="navbar">
    <div class="logo">校园助管申请管理平台</div>
    <div class="nav-links">
        <c:choose>
            <c:when test="${sessionScope.user.role == 'student'}">
                <a href="${pageContext.request.contextPath}/app#/student/dashboard">首页</a>
                <a href="${pageContext.request.contextPath}/app#/student/positions">浏览岗位</a>
                <a href="${pageContext.request.contextPath}/app#/student/profile">我的</a>
                <a href="${pageContext.request.contextPath}/app#/student/work">工作台</a>
            </c:when>
            <c:when test="${sessionScope.user.role == 'teacher'}">
                <a href="${pageContext.request.contextPath}/app#/teacher/dashboard">首页</a>
                <a href="${pageContext.request.contextPath}/app#/teacher/positions">岗位管理</a>
                <a href="${pageContext.request.contextPath}/teacher/students">学生管理</a>
                <a href="${pageContext.request.contextPath}/app#/teacher/profile">我的</a>
                <a href="${pageContext.request.contextPath}/app#/teacher/work">工作台</a>
            </c:when>
        </c:choose>
        <div class="user-info">
            <span>欢迎，${sessionScope.user.name}</span>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">退出</a>
        </div>
    </div>
</div>
<div class="container">
