<%-- 岗位申请页面：查看岗位详情并提交申请 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="岗位申请" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<c:if test="${not empty requestScope.error}">
    <div class="alert alert-danger">${requestScope.error}</div>
</c:if>

<div class="card">
    <h3>申请岗位</h3>

    <div style="background:#f8f9fa;padding:15px;border-radius:6px;margin-bottom:20px;">
        <p><strong>岗位名称：</strong><c:out value="${position.title}"/></p>
        <p><strong>岗位描述：</strong><c:out value="${position.description}"/></p>
        <p><strong>工作要求：</strong><c:out value="${position.requirements}"/></p>
        <p><strong>工作地点：</strong><c:out value="${position.location}"/></p>
        <p><strong>发布老师：</strong><c:out value="${position.teacherName}"/></p>
        <p><strong>已录取/总名额：</strong>${position.currentCount} / ${position.maxStudents}</p>
    </div>

    <form action="${pageContext.request.contextPath}/student/apply" method="post" enctype="multipart/form-data" id="applyForm">
        <input type="hidden" name="positionId" value="${position.id}">
        <div class="form-group">
            <label for="reason">申请理由</label>
            <textarea id="reason" name="reason" rows="5" required placeholder="请详细说明您申请该岗位的理由..."></textarea>
        </div>
        <div class="form-group">
            <label>上传附件</label>
            <small style="color:#999;display:block;margin-bottom:8px;">可上传简历、成绩单和课表等材料（多文件支持）</small>
            <div id="fileList">
                <div class="file-item" style="display:flex;gap:10px;margin-bottom:8px;align-items:center;">
                    <input type="file" name="attachmentFiles" accept=".pdf,.doc,.docx,.jpg,.png,.xls,.xlsx" style="flex:1;">
                </div>
            </div>
            <button type="button" id="addFileBtn" class="btn btn-primary btn-sm" style="margin-top:8px;">+ 添加更多文件</button>
        </div>
        <div style="display:flex;gap:10px;">
            <button type="submit" class="btn btn-success">提交申请</button>
            <a href="${pageContext.request.contextPath}/student/positions" class="btn btn-primary">返回岗位列表</a>
        </div>
    </form>
</div>

<script>
document.getElementById('addFileBtn').addEventListener('click', function() {
    var div = document.createElement('div');
    div.className = 'file-item';
    div.style.cssText = 'display:flex;gap:10px;margin-bottom:8px;align-items:center;';
    div.innerHTML = '<input type="file" name="attachmentFiles" accept=".pdf,.doc,.docx,.jpg,.png,.xls,.xlsx" style="flex:1;">' +
        '<button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.remove()">移除</button>';
    document.getElementById('fileList').appendChild(div);
});
</script>

<jsp:include page="../common/footer.jsp"/>
