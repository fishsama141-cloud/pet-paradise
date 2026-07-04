<%-- 老师端创建或编辑助管岗位表单页面 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${empty position ? '发布岗位' : '编辑岗位'}" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <h3>${empty position ? '发布新岗位' : '编辑岗位'}</h3>

    <form action="${pageContext.request.contextPath}/teacher/positions" method="post">
        <c:if test="${not empty position}">
            <input type="hidden" name="id" value="${position.id}">
        </c:if>
        <div class="form-group">
            <label for="title">岗位名称</label>
            <input type="text" id="title" name="title" required value="${position.title}" placeholder="如：图书馆管理员">
        </div>
        <div class="form-group">
            <label for="department">所属部门</label>
            <input type="text" id="department" name="department" value="${position.department}" placeholder="如：计算机学院">
        </div>
        <div class="form-group">
            <label for="description">岗位描述</label>
            <textarea id="description" name="description" rows="3" required placeholder="描述岗位的工作内容">${position.description}</textarea>
        </div>
        <div class="form-group">
            <label for="requirements">岗位要求</label>
            <textarea id="requirements" name="requirements" rows="3" placeholder="对学生的要求">${position.requirements}</textarea>
        </div>
        <div class="form-group">
            <label for="location">工作地点</label>
            <input type="text" id="location" name="location" value="${position.location}" placeholder="如图书馆A区302">
        </div>
        <div class="form-group">
            <label for="maxStudents">招收人数</label>
            <input type="number" id="maxStudents" name="maxStudents" min="1" value="${not empty position ? position.maxStudents : 1}">
        </div>
        <div class="form-group">
            <label for="status">状态</label>
            <select id="status" name="status">
                <option value="open" ${position.status == 'open' ? 'selected' : ''}>招募中</option>
                <option value="closed" ${position.status == 'closed' ? 'selected' : ''}>已关闭</option>
            </select>
        </div>
        <button type="submit" class="btn btn-success">保存</button>
        <a href="${pageContext.request.contextPath}/teacher/positions" class="btn btn-primary">返回</a>
    </form>
</div>

<jsp:include page="../common/footer.jsp"/>
