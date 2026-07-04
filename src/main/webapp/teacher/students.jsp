<%-- 老师端查看岗位申请学生列表，审核录取或拒绝申请 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="学生管理" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <h3>选择岗位查看学生</h3>
    <c:choose>
        <c:when test="${not empty positions}">
            <div style="display:flex;flex-wrap:wrap;gap:10px;">
                <c:forEach var="p" items="${positions}">
                    <a href="${pageContext.request.contextPath}/teacher/students?positionId=${p.id}" class="btn ${param.positionId == p.id ? 'btn-success' : 'btn-primary'} btn-sm">
                        <c:out value="${p.title}"/> (${p.currentCount}/${p.maxStudents})
                    </a>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无岗位，请先发布岗位</div>
        </c:otherwise>
    </c:choose>
</div>

<c:if test="${not empty position}">
<div class="card">
    <h3>「<c:out value="${position.title}"/>」的申请学生</h3>
    <c:choose>
        <c:when test="${not empty applications}">
            <table>
                <thead>
                    <tr>
                        <th>学生姓名</th>
                        <th>学号</th>
                        <th>班级</th>
                        <th>手机</th>
                        <th>邮箱</th>
                        <th>申请理由</th>
                        <th>附件</th>
                        <th>状态</th>
                        <th>申请时间</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${applications}">
                        <tr>
                            <td><strong><c:out value="${a.studentName}"/></strong></td>
                            <td><c:out value="${a.studentNumber}"/></td>
                            <td><c:out value="${a.studentClassName}"/></td>
                            <td><c:out value="${a.studentPhone}"/></td>
                            <td><c:out value="${a.studentEmail}"/></td>
                            <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<c:out value='${a.reason}'/>">
                                <c:out value="${a.reason}"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty a.files}">
                                        <c:forEach var="f" items="${a.files}">
                                            <a href="${pageContext.request.contextPath}/student/download?file=${f.filePath}" class="btn btn-primary btn-sm" style="margin-bottom:3px;display:block;" title="<c:out value='${f.fileName}'/>">
                                                <c:out value="${f.fileName}"/>
                                            </a>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:#999;">无附件</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${a.status == 'pending'}"><span class="badge badge-pending">审核中</span></c:when>
                                    <c:when test="${a.status == 'approved'}"><span class="badge badge-approved">已录取</span></c:when>
                                    <c:when test="${a.status == 'rejected'}"><span class="badge badge-rejected">已拒绝</span></c:when>
                                </c:choose>
                            </td>
                            <td><fmt:formatDate value="${a.appliedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                            <td>
                                <c:if test="${a.status == 'pending'}">
                                    <a href="${pageContext.request.contextPath}/teacher/students?action=approve&appId=${a.id}&positionId=${position.id}" class="btn btn-success btn-sm">录取</a>
                                    <a href="${pageContext.request.contextPath}/teacher/students?action=reject&appId=${a.id}&positionId=${position.id}" class="btn btn-danger btn-sm">拒绝</a>
                                </c:if>
                                <c:if test="${a.status == 'approved'}">
                                    <a href="${pageContext.request.contextPath}/teacher/students?action=reject&appId=${a.id}&positionId=${position.id}" class="btn btn-danger btn-sm">取消录取</a>
                                </c:if>
                                <c:if test="${a.status == 'rejected'}">
                                    <a href="${pageContext.request.contextPath}/teacher/students?action=approve&appId=${a.id}&positionId=${position.id}" class="btn btn-success btn-sm">重新录取</a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无学生申请该岗位</div>
        </c:otherwise>
    </c:choose>
</div>
</c:if>

<jsp:include page="../common/footer.jsp"/>
