<%-- 项目首页，根据登录状态自动跳转到应用主页或登录页 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:choose>
    <c:when test="${not empty sessionScope.user}">
        <c:redirect url="/app"/>
    </c:when>
    <c:otherwise>
        <c:redirect url="/login.jsp"/>
    </c:otherwise>
</c:choose>
