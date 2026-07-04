<%-- 老师个人信息与已发布岗位概览页面 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="我的" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<c:if test="${not empty requestScope.error}">
    <div class="alert alert-danger">${requestScope.error}</div>
</c:if>
<c:if test="${not empty requestScope.success}">
    <div class="alert alert-success">${requestScope.success}</div>
</c:if>

<!-- 个人信息 -->
<div class="card">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
        <h3 style="margin:0;border:none;padding:0;">个人信息</h3>
        <button type="button" class="btn btn-primary btn-sm" id="editBtn" onclick="toggleEdit()">编辑</button>
    </div>

    <!-- 只读模式 -->
    <div id="viewMode">
        <div style="display:grid; grid-template-columns: repeat(4, 1fr); gap:15px;">
            <div><strong>姓名：</strong><c:out value="${profile.name}"/></div>
            <div><strong>工号：</strong><c:out value="${profile.number}"/></div>
            <div><strong>邮箱：</strong><c:out value="${profile.email}"/></div>
            <div><strong>角色：</strong>教师</div>
            <div><strong>手机：</strong><c:out value="${profile.phone}"/></div>
        </div>
    </div>

    <!-- 编辑模式 -->
    <div id="editMode" style="display:none;">
        <form action="${pageContext.request.contextPath}/teacher/profile" method="post">
            <div style="display:grid; grid-template-columns: repeat(2, 1fr); gap:15px;">
                <div class="form-group">
                    <label>姓名</label>
                    <input type="text" name="name" value="<c:out value='${profile.name}'/>" required>
                </div>
                <div class="form-group">
                    <label>工号</label>
                    <input type="text" name="number" value="<c:out value='${profile.number}'/>" required>
                </div>
                <div class="form-group">
                    <label>邮箱</label>
                    <input type="email" name="email" value="<c:out value='${profile.email}'/>">
                </div>
                <div class="form-group">
                    <label>角色</label>
                    <input type="text" value="教师" disabled style="background:#eee;color:#999;">
                </div>
                <div class="form-group">
                    <label>手机</label>
                    <input type="text" name="phone" value="<c:out value='${profile.phone}'/>">
                </div>
            </div>
            <div style="margin-top:15px;display:flex;gap:10px;">
                <button type="submit" class="btn btn-success">保存</button>
                <button type="button" class="btn btn-warning" onclick="toggleEdit()">取消</button>
            </div>
        </form>
    </div>
</div>

<!-- 我发布的岗位及录取学生 -->
<div class="card">
    <h3>我发布的岗位</h3>
    <c:choose>
        <c:when test="${not empty positions}">
            <c:forEach var="p" items="${positions}">
                <div style="background:#f8f9fa;border-radius:8px;padding:18px;margin-bottom:15px;border-left:4px solid #3498db;">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
                        <strong style="font-size:1.1em;color:#2c3e50;"><c:out value="${p.title}"/></strong>
                        <span style="font-size:0.9em;">
                            录取
                            <c:set var="approvedCount" value="0"/>
                            <c:forEach var="a" items="${p.approvedStudents}">
                                <c:if test="${a.status == 'approved'}"><c:set var="approvedCount" value="${approvedCount + 1}"/></c:if>
                            </c:forEach>
                            ${approvedCount}/${p.maxStudents} 人
                            <c:choose>
                                <c:when test="${p.status == 'open'}"><span class="badge badge-open">开放中</span></c:when>
                                <c:otherwise><span class="badge badge-closed">已关闭</span></c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <p style="color:#666;font-size:0.9em;margin-bottom:8px;"><c:out value="${p.description}"/></p>
                    <c:if test="${not empty p.approvedStudents}">
                        <div style="display:flex;flex-wrap:wrap;gap:8px;">
                            <span style="color:#555;font-weight:600;">已录取学生：</span>
                            <c:forEach var="a" items="${p.approvedStudents}">
                                <span style="background:#d4edda;color:#155724;padding:3px 10px;border-radius:12px;font-size:0.85em;">
                                    <c:out value="${a.studentName}"/>
                                </span>
                            </c:forEach>
                        </div>
                    </c:if>
                    <c:if test="${empty p.approvedStudents}">
                        <span style="color:#999;font-size:0.85em;">暂未录取学生</span>
                    </c:if>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂未发布岗位，<a href="${pageContext.request.contextPath}/teacher/positions">去发布</a></div>
        </c:otherwise>
    </c:choose>
</div>

<script>
    function toggleEdit() {
        var view = document.getElementById('viewMode');
        var edit = document.getElementById('editMode');
        var btn = document.getElementById('editBtn');
        if (edit.style.display === 'none') {
            view.style.display = 'none';
            edit.style.display = 'block';
            btn.style.display = 'none';
        } else {
            view.style.display = 'block';
            edit.style.display = 'none';
            btn.style.display = 'inline-block';
        }
    }
</script>

<jsp:include page="../common/footer.jsp"/>
