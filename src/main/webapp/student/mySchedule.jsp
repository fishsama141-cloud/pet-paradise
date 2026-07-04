<%-- 查看我的排班信息 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="排班信息" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="card">
    <h3>我的排班信息</h3>

    <c:choose>
        <c:when test="${not empty schedules}">
            <table>
                <thead>
                    <tr>
                        <th>岗位名称</th>
                        <th>星期</th>
                        <th>时间段</th>
                        <th>地点</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${schedules}">
                        <tr>
                            <td><c:out value="${s.positionTitle}"/></td>
                            <td><c:out value="${s.weekDay}"/></td>
                            <td><c:out value="${s.timeSlot}"/></td>
                            <td><c:out value="${s.location}"/></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">暂无排班信息，请等待老师安排</div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
