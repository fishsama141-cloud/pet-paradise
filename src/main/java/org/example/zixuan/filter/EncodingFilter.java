/**
 * 字符编码过滤器，统一设置请求与响应的字符编码为UTF-8，解决中文乱码问题。
 */
package org.example.zixuan.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpFilter;
import java.io.IOException;

public class EncodingFilter extends HttpFilter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        chain.doFilter(request, response);
    }
}
