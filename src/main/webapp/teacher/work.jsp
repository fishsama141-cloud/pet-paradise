<%-- 老师端工作台页面，整合排班管理和任务管理功能 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="工作台" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<!-- 排班管理 -->
<div class="card">
    <h3>添加排班</h3>
    <form action="${pageContext.request.contextPath}/teacher/schedule" method="post">
        <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:15px;">
            <div class="form-group">
                <label>选择岗位</label>
                <select name="positionId" required id="schedulePosition">
                    <option value="">--请选择岗位--</option>
                    <c:forEach var="p" items="${positions}">
                        <option value="${p.id}"><c:out value="${p.title}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>选择学生</label>
                <select name="studentId" required id="scheduleStudent">
                    <option value="">--请先选择岗位--</option>
                    <c:forEach var="p" items="${positions}">
                        <c:forEach var="a" items="${p.approvedStudents}">
                            <option value="${a.studentId}" data-position="${p.id}" style="display:none;"><c:out value="${a.studentName}"/></option>
                        </c:forEach>
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
    <h3>排班列表</h3>
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
                                <a href="${pageContext.request.contextPath}/teacher/work?action=deleteSchedule&scheduleId=${s.id}" class="btn btn-danger btn-sm" onclick="return confirm('确定删除？')">删除</a>
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

<!-- 任务管理 -->
<div class="card">
    <h3>下达任务</h3>
    <form action="${pageContext.request.contextPath}/teacher/tasks" method="post">
        <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:15px;">
            <div class="form-group">
                <label>选择岗位</label>
                <select name="positionId" required id="taskPosition">
                    <option value="">--请选择岗位--</option>
                    <c:forEach var="p" items="${positions}">
                        <option value="${p.id}"><c:out value="${p.title}"/></option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>指派学生</label>
                <select name="studentId" required id="taskStudent">
                    <option value="">--请先选择岗位--</option>
                    <c:forEach var="p" items="${positions}">
                        <c:forEach var="a" items="${p.approvedStudents}">
                            <option value="${a.studentId}" data-position="${p.id}" style="display:none;">
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
                                <a href="${pageContext.request.contextPath}/teacher/work?action=deleteTask&taskId=${t.id}" class="btn btn-danger btn-sm" onclick="return confirm('确定删除？')">删除</a>
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

<script>
(function() {
    function filterStudents(selectId, positionSelectId) {
        var posSelect = document.getElementById(positionSelectId);
        var stuSelect = document.getElementById(selectId);
        posSelect.addEventListener('change', function() {
            var pid = this.value;
            var opts = stuSelect.options;
            for (var i = 0; i < opts.length; i++) {
                opts[i].style.display = (opts[i].getAttribute('data-position') == pid) ? 'block' : 'none';
                if (i > 0 && opts[i].style.display == 'none') opts[i].selected = false;
            }
            if (opts[0].style.display == 'none') opts[0].selected = true;
        });
    }
    filterStudents('scheduleStudent', 'schedulePosition');
    filterStudents('taskStudent', 'taskPosition');
})();
</script>

<jsp:include page="../common/footer.jsp"/>
