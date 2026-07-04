<%-- 老师端排班管理页面，为学生安排值班时间和地点 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="排班管理" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <h3>添加排班</h3>
    <form action="${pageContext.request.contextPath}/teacher/schedule" method="post">
        <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:15px;">
            <div class="form-group">
                <label>选择岗位</label>
                <select name="positionId" required onchange="window.location.href='${pageContext.request.contextPath}/teacher/schedule?positionId='+this.value">
                    <option value="">--请选择岗位--</option>
                    <c:forEach var="p" items="${positions}">
                        <option value="${p.id}" ${param.positionId == p.id ? 'selected' : ''}><c:out value="${p.title}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>选择学生</label>
                <select name="studentId" required>
                    <option value="">--请选择学生--</option>
                    <c:forEach var="p" items="${positions}">
                        <c:if test="${p.id == param.positionId}">
                            <c:forEach var="a" items="${p.approvedStudents}">
                                <option value="${a.studentId}"><c:out value="${a.studentName}"/></option>
                            </c:forEach>
                        </c:if>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>星期</label>
                <select name="weekDay" required>
                    <option value="星期一">星期一</option>
                    <option value="星期二">星期二</option>
                    <option value="星期三">星期三</option>
                    <option value="星期四">星期四</option>
                    <option value="星期五">星期五</option>
                </select>
            </div>
            <div class="form-group">
                <label>时间段</label>
                <input type="text" name="timeSlot" required placeholder="如 08:00-12:00">
            </div>
            <div class="form-group">
                <label>值班地点</label>
                <input type="text" name="location" required placeholder="如图书馆A区">
            </div>
            <div style="display:flex;align-items:end;">
                <button type="submit" class="btn btn-success">添加排班</button>
            </div>
        </div>
    </form>
</div>

<div class="card">
    <h3>我的排班列表</h3>
    <c:choose>
        <c:when test="${not empty schedules}">
            <table>
                <thead>
                    <tr>
                        <th>岗位</th>
                        <th>学生</th>
                        <th>星期</th>
                        <th>时间段</th>
                        <th>地点</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${schedules}">
                        <tr>
                            <td><c:out value="${s.positionTitle}"/></td>
                            <td><c:out value="${s.studentName}"/></td>
                            <td><c:out value="${s.weekDay}"/></td>
                            <td><c:out value="${s.timeSlot}"/></td>
                            <td><c:out value="${s.location}"/></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/teacher/schedule?action=delete&scheduleId=${s.id}" class="btn btn-danger btn-sm" onclick="return confirm('确定删除？')">删除</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无排班记录</div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
