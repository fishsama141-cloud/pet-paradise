/**
 * 自动登录过滤器，当Session中没有用户时，尝试根据Cookie中的Token恢复用户登录状态，实现"记住我"功能。
 */
package org.example.zixuan.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.example.zixuan.model.User;
import org.example.zixuan.service.UserService;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

public class AutoLoginFilter extends HttpFilter {

    private UserService userService;

    @Override
    public void init(FilterConfig config) throws ServletException {
        super.init(config);
        WebApplicationContext ctx = WebApplicationContextUtils
                .getRequiredWebApplicationContext(config.getServletContext());
        userService = ctx.getBean(UserService.class);
    }
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        if (req.getSession().getAttribute("user") == null) {
            Cookie[] cookies = req.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("autoLoginToken".equals(cookie.getName())) {
                        String token = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8);
                        User user = userService.findByToken(token);
                        if (user != null) {
                            req.getSession().setAttribute("user", user);
                        } else {
                            // token无效，清除cookie
                            Cookie c = new Cookie("autoLoginToken", "");
                            c.setMaxAge(0);
                            c.setPath("/");
                            resp.addCookie(c);
                        }
                        break;
                    }
                }
            }
        }
        chain.doFilter(request, response);
    }
}
