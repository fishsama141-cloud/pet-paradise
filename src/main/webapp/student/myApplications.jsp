<%-- 查看我的申请记录和审核状态 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="我的申请" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <h3>我的申请记录</h3>

    <c:choose>
        <c:when test="${not empty applications}">
            <table>
                <thead>
                    <tr>
                        <th>岗位名称</th>
                        <th>申请理由</th>
                        <th>申请状态</th>
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
                                    <c:when test="${a.status == 'approved'}"><span class="badge badge-approved">已通过</span></c:when>
                                    <c:when test="${a.status == 'rejected'}"><span class="badge badge-rejected">未通过</span></c:when>
                                    <c:otherwise><c:out value="${a.status}"/></c:otherwise>
                                </c:choose>
                            </td>
                            <td><fmt:formatDate value="${a.appliedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">您还没有提交过申请，<a href="${pageContext.request.contextPath}/student/positions">去浏览岗位</a></div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
