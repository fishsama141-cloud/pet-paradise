<%-- 学生首页/仪表盘 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="学生首页" scope="request"/>
<jsp:include page="../common/header.jsp"/>
<div class="stats">
    <div class="stat-card">
        <div class="number">学生面板</div>
        <div class="label">欢迎，${sessionScope.user.name}</div>
    </div>
</div>
<div class="card">
    <h3>快捷导航</h3>
    <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:20px; margin-top:20px;">
        <a href="${pageContext.request.contextPath}/student/positions" style="text-decoration:none;color:#333;">
            <div class="stat-card">
                <div class="number" style="font-size:1.5em;">浏览岗位</div>
                <div class="label">查看可申请的校园助管岗位</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/student/profile" style="text-decoration:none;color:#333;">
            <div class="stat-card">
                <div class="number" style="font-size:1.5em;">我的</div>
                <div class="label">个人信息、简历课表、申请记录</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/student/work" style="text-decoration:none;color:#333;">
            <div class="stat-card">
                <div class="number" style="font-size:1.5em;">工作台</div>
                <div class="label">查看排班与任务</div>
            </div>
        </a>
    </div>
</div>
<jsp:include page="../common/footer.jsp"/>
