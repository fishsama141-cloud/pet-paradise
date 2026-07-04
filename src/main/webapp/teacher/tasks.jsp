<%-- 老师端任务管理页面，向学生下达和查看任务 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="任务管理" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <h3>下达任务</h3>
    <form action="${pageContext.request.contextPath}/teacher/tasks" method="post">
        <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:15px;">
            <div class="form-group">
                <label>选择岗位</label>
                <select name="positionId" required>
                    <option value="">--请选择岗位--</option>
                    <c:forEach var="p" items="${positions}">
                        <option value="${p.id}"><c:out value="${p.title}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>指派学生</label>
                <select name="studentId" required>
                    <option value="">--请选择学生--</option>
                    <c:forEach var="p" items="${positions}">
                        <c:forEach var="a" items="${p.approvedStudents}">
                            <option value="${a.studentId}">
                                <c:out value="${a.studentName}"/> - <c:out value="${p.title}"/>
                            </option>
                        </c:forEach>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>任务状态</label>
                <select name="status">
                    <option value="pending">待处理</option>
                    <option value="in_progress">进行中</option>
                    <option value="completed">已完成</option>
                </select>
            </div>
            <div class="form-group">
                <label>任务标题</label>
                <input type="text" name="title" required placeholder="输入任务标题">
            </div>
            <div class="form-group">
                <label>截止日期</label>
                <input type="date" name="deadline">
            </div>
            <div style="display:flex;align-items:end;">
                <button type="submit" class="btn btn-success">下达任务</button>
            </div>
        </div>
        <div class="form-group" style="margin-top:10px;">
            <label>任务描述</label>
            <textarea name="description" rows="3" placeholder="详细描述任务内容、要求等"></textarea>
        </div>
    </form>
</div>

<div class="card">
    <h3>已下达的任务</h3>
    <c:choose>
        <c:when test="${not empty tasks}">
            <table>
                <thead>
                    <tr>
                        <th>岗位</th>
                        <th>学生</th>
                        <th>标题</th>
                        <th>描述</th>
                        <th>状态</th>
                        <th>截止日期</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="t" items="${tasks}">
                        <tr>
                            <td><c:out value="${t.positionTitle}"/></td>
                            <td><c:out value="${t.studentName}"/></td>
                            <td><c:out value="${t.title}"/></td>
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
                                <a href="${pageContext.request.contextPath}/teacher/tasks?action=delete&taskId=${t.id}" class="btn btn-danger btn-sm" onclick="return confirm('确定删除？')">删除</a>
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
