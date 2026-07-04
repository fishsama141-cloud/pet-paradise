/**
 * 身份认证过滤器，拦截所有请求，对未登录用户返回401（API请求）或重定向到登录页（页面请求）。
 */
package org.example.zixuan.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AuthFilter extends HttpFilter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 允许访问的公共路径
        if (path.startsWith("/login.jsp") || path.startsWith("/register.jsp") ||
            path.startsWith("/common/") || path.startsWith("/css/") || path.startsWith("/js/") ||
            path.equals("/login") || path.equals("/register") || path.equals("/") ||
            path.equals("/app") || path.equals("/app.jsp") ||
            path.equals("/api/login") || path.equals("/api/register") ||
            path.startsWith("/api/user/current")) {
            chain.doFilter(request, response);
            return;
        }

        // 检查登录状态
        Object user = req.getSession().getAttribute("user");
        if (user == null) {
            if (path.startsWith("/api/")) {
                resp.setStatus(401);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"code\":401,\"message\":\"未登录\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
            }
            return;
        }

        chain.doFilter(request, response);
    }
}
