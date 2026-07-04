<%-- 老师工作台首页，展示快捷导航入口 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="老师工作台" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="stats">
    <div class="stat-card">
        <div class="number">老师面板</div>
        <div class="label">欢迎，${sessionScope.user.name}</div>
    </div>
</div>
<div class="card">
    <h3>快捷导航</h3>
    <div style="display:grid; grid-template-columns: repeat(4, 1fr); gap:20px; margin-top:20px;">
        <a href="${pageContext.request.contextPath}/teacher/positions" style="text-decoration:none;color:#333;">
            <div class="stat-card">
                <div class="number" style="font-size:1.3em;">岗位管理</div>
                <div class="label">发布与管理助管岗位</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/teacher/students" style="text-decoration:none;color:#333;">
            <div class="stat-card">
                <div class="number" style="font-size:1.3em;">学生管理</div>
                <div class="label">审核申请与查看学生</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/teacher/profile" style="text-decoration:none;color:#333;">
            <div class="stat-card">
                <div class="number" style="font-size:1.3em;">我的</div>
                <div class="label">个人信息与岗位概览</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/teacher/work" style="text-decoration:none;color:#333;">
            <div class="stat-card">
                <div class="number" style="font-size:1.3em;">工作台</div>
                <div class="label">排班管理与任务管理</div>
            </div>
        </a>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
