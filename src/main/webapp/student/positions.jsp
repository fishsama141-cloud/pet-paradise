<%-- 浏览可申请的校园助管岗位列表 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="浏览岗位" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <h3>可申请的校园助管岗位</h3>

    <c:choose>
        <c:when test="${not empty positions}">
            <table>
                <thead>
                    <tr>
                        <th>岗位名称</th>
                        <th>岗位描述</th>
                        <th>工作地点</th>
                        <th>需要人数</th>
                        <th>发布老师</th>
                        <th>发布时间</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${positions}">
                        <tr>
                            <td><strong><c:out value="${p.title}"/></strong></td>
                            <td><c:out value="${p.description}" escapeXml="true"/></td>
                            <td><c:out value="${p.location}"/></td>
                            <td>${p.currentCount} / ${p.maxStudents}</td>
                            <td><c:out value="${p.teacherName}"/></td>
                            <td><fmt:formatDate value="${p.createdAt}" pattern="yyyy-MM-dd"/></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/student/apply?positionId=${p.id}" class="btn btn-primary btn-sm">申请</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无开放的岗位</div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
