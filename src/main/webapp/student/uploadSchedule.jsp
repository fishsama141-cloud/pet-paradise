<%-- 上传个人课表文件 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="上传课表" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<c:if test="${not empty requestScope.error}">
    <div class="alert alert-danger">${requestScope.error}</div>
</c:if>
<c:if test="${not empty requestScope.success}">
    <div class="alert alert-success">${requestScope.success}</div>
</c:if>

<div class="card">
    <h3>上传个人课表</h3>

    <c:if test="${not empty sessionScope.user.courseSchedulePath}">
        <div style="background:#d4edda;color:#155724;padding:12px;border-radius:4px;margin-bottom:15px;">
            您已上传课表文件：
            <a href="${pageContext.request.contextPath}/student/download?file=${sessionScope.user.courseSchedulePath}" style="color:#27ae60;text-decoration:underline;">点击下载查看</a>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/student/upload" method="post" enctype="multipart/form-data">
        <div class="form-group">
            <label for="scheduleFile">选择课表文件</label>
            <input type="file" id="scheduleFile" name="scheduleFile" required accept=".pdf,.doc,.docx,.jpg,.png,.xls,.xlsx">
            <small style="color:#999;">支持格式：PDF、Word、图片、Excel，大小不超过10MB</small>
        </div>
        <button type="submit" class="btn btn-primary">上传课表</button>
    </form>
</div>

<jsp:include page="../common/footer.jsp"/>
