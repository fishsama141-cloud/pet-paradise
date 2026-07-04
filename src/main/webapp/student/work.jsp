<%-- 学生工作台：排班与任务总览 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="工作台" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<!-- 排班信息 -->
<div class="card">
    <h3>我的排班</h3>
    <c:choose>
        <c:when test="${not empty schedules}">
            <table>
                <thead>
                    <tr>
                        <th>岗位名称</th>
                        <th>星期</th>
                        <th>时间段</th>
                        <th>地点</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${schedules}">
                        <tr>
                            <td><c:out value="${s.positionTitle}"/></td>
                            <td><c:out value="${s.weekDay}"/></td>
                            <td><c:out value="${s.timeSlot}"/></td>
                            <td><c:out value="${s.location}"/></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无排班信息，请等待老师安排</div>
        </c:otherwise>
    </c:choose>
</div>

<!-- 我的任务 -->
<div class="card">
    <h3>我的任务</h3>
    <c:choose>
        <c:when test="${not empty tasks}">
            <table>
                <thead>
                    <tr>
                        <th>岗位</th>
                        <th>任务标题</th>
                        <th>任务描述</th>
                        <th>状态</th>
                        <th>截止日期</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="t" items="${tasks}">
                        <tr>
                            <td><c:out value="${t.positionTitle}"/></td>
                            <td><strong><c:out value="${t.title}"/></strong></td>
                            <td><c:out value="${t.description}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.status == 'pending'}"><span class="badge badge-pending">待处理</span></c:when>
                                    <c:when test="${t.status == 'in_progress'}"><span class="badge" style="background:#74b9ff;color:#2d6ea0;">进行中</span></c:when>
                                    <c:when test="${t.status == 'completed'}"><span class="badge badge-approved">已完成</span></c:when>
                                </c:choose>
                            </td>
                            <td><fmt:formatDate value="${t.deadline}" pattern="yyyy-MM-dd"/></td>
                            <td>
                                <c:if test="${t.status != 'completed'}">
                                    <a href="${pageContext.request.contextPath}/student/tasks?action=updateStatus&taskId=${t.id}&status=completed" class="btn btn-success btn-sm">标记完成</a>
                                </c:if>
                                <c:if test="${t.status == 'pending'}">
                                    <a href="${pageContext.request.contextPath}/student/tasks?action=updateStatus&taskId=${t.id}&status=in_progress" class="btn btn-warning btn-sm">开始处理</a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无任务</div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
