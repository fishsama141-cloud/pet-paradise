<%-- 老师端岗位管理页面，查看、编辑、删除已发布的助管岗位 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="岗位管理" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <div style="display:flex;justify-content:space-between;align-items:center;">
        <h3 style="border:none;margin:0;padding:0;">我发布的岗位</h3>
        <a href="${pageContext.request.contextPath}/teacher/positions?action=edit" class="btn btn-primary">发布新岗位</a>
    </div>
</div>

<c:choose>
    <c:when test="${not empty positions}">
        <c:forEach var="p" items="${positions}">
            <div class="card">
                <div style="display:flex;justify-content:space-between;align-items:start;">
                    <div style="flex:1;">
                        <h4><c:out value="${p.title}"/></h4>
                        <span class="badge ${p.status == 'open' ? 'badge-approved' : 'badge-rejected'}">
                            ${p.status == 'open' ? '招募中' : '已关闭'}
                        </span>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/teacher/positions?action=edit&id=${p.id}" class="btn btn-warning btn-sm">编辑</a>
                        <a href="${pageContext.request.contextPath}/teacher/students?positionId=${p.id}" class="btn btn-primary btn-sm">查看学生</a>
                        <a href="${pageContext.request.contextPath}/teacher/positions?action=delete&id=${p.id}" class="btn btn-danger btn-sm" onclick="return confirm('确定要删除该岗位吗？')">删除</a>
                    </div>
                </div>
                <p style="margin:10px 0;color:#666;">描述：<c:out value="${p.description}"/></p>
                <p style="margin:5px 0;color:#666;">要求：<c:out value="${p.requirements}"/></p>
                <p style="margin:5px 0;color:#666;">地点：<c:out value="${p.location}"/></p>
                <p style="margin:5px 0;color:#666;">已录取/总名额：${p.currentCount} / ${p.maxStudents}</p>
                <p style="margin:5px 0;color:#999;font-size:0.85em;">发布时间：<fmt:formatDate value="${p.createdAt}" pattern="yyyy-MM-dd HH:mm"/></p>
            </div>
        </c:forEach>
    </c:when>
    <c:otherwise>
        <div class="card">
            <div class="empty-state">暂无发布的岗位</div>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="../common/footer.jsp"/>
