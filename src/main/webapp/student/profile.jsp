<%-- 学生个人中心：查看/编辑资料、上传简历课表、查看申请记录 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
            <div><strong>学号：</strong><c:out value="${profile.number}"/></div>
            <div><strong>班级：</strong><c:out value="${profile.className}"/></div>
            <div><strong>角色：</strong>学生</div>
            <div><strong>邮箱：</strong><c:out value="${profile.email}"/></div>
            <div><strong>手机：</strong><c:out value="${profile.phone}"/></div>
        </div>
    </div>

    <!-- 编辑模式 -->
    <div id="editMode" style="display:none;">
        <form action="${pageContext.request.contextPath}/student/profile" method="post">
            <div style="display:grid; grid-template-columns: repeat(2, 1fr); gap:15px;">
                <div class="form-group">
                    <label>姓名</label>
                    <input type="text" name="name" value="<c:out value='${profile.name}'/>" required>
                </div>
                <div class="form-group">
                    <label>学号</label>
                    <input type="text" name="number" value="<c:out value='${profile.number}'/>" required>
                </div>
                <div class="form-group">
                    <label>班级</label>
                    <input type="text" name="className" value="<c:out value='${profile.className}'/>">
                </div>
                <div class="form-group">
                    <label>角色</label>
                    <input type="text" value="学生" disabled style="background:#eee;color:#999;">
                </div>
                <div class="form-group">
                    <label>邮箱</label>
                    <input type="email" name="email" value="<c:out value='${profile.email}'/>">
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

<!-- 上传简历 -->
<div class="card">
    <h3>上传简历</h3>
    <c:if test="${not empty profile.resumePath}">
        <div style="background:#d4edda;color:#155724;padding:12px;border-radius:4px;margin-bottom:15px;">
            已上传简历：
            <a href="${pageContext.request.contextPath}/student/download?file=${profile.resumePath}" style="color:#27ae60;text-decoration:underline;">点击下载查看</a>
        </div>
    </c:if>
    <form action="${pageContext.request.contextPath}/student/uploadResume" method="post" enctype="multipart/form-data">
        <div class="form-group">
            <label for="resumeFile">选择简历文件</label>
            <input type="file" id="resumeFile" name="resumeFile" required accept=".pdf,.doc,.docx,.jpg,.png">
            <small style="color:#999;">支持格式：PDF、Word、图片</small>
        </div>
        <button type="submit" class="btn btn-primary">上传简历</button>
    </form>
</div>

<!-- 上传课表 -->
<div class="card">
    <h3>上传课表</h3>
    <c:if test="${not empty profile.courseSchedulePath}">
        <div style="background:#d4edda;color:#155724;padding:12px;border-radius:4px;margin-bottom:15px;">
            已上传课表：
            <a href="${pageContext.request.contextPath}/student/download?file=${profile.courseSchedulePath}" style="color:#27ae60;text-decoration:underline;">点击下载查看</a>
        </div>
    </c:if>
    <form action="${pageContext.request.contextPath}/student/upload" method="post" enctype="multipart/form-data">
        <div class="form-group">
            <label for="scheduleFile">选择课表文件</label>
            <input type="file" id="scheduleFile" name="scheduleFile" required accept=".pdf,.doc,.docx,.jpg,.png,.xls,.xlsx">
            <small style="color:#999;">支持格式：PDF、Word、图片、Excel</small>
        </div>
        <button type="submit" class="btn btn-primary">上传课表</button>
    </form>
</div>

<!-- 我的申请 -->
<div class="card">
    <h3>我的申请</h3>
    <c:choose>
        <c:when test="${not empty applications}">
            <table>
                <thead>
                    <tr>
                        <th>岗位名称</th>
                        <th>申请理由</th>
                        <th>状态</th>
                        <th>申请时间</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${applications}">
                        <tr>
                            <td><c:out value="${a.positionTitle}"/></td>
                            <td><c:out value="${a.reason}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${a.status == 'pending'}"><span class="badge badge-pending">审核中</span></c:when>
                                    <c:when test="${a.status == 'approved'}"><span class="badge badge-approved">已录取</span></c:when>
                                    <c:when test="${a.status == 'rejected'}"><span class="badge badge-rejected">已拒绝</span></c:when>
                                </c:choose>
                            </td>
                            <td><fmt:formatDate value="${a.appliedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无申请记录</div>
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
