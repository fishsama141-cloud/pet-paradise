/**
 * 全局异常处理器，根据请求类型返回JSON错误或500错误页面
 */
package org.example.zixuan.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.example.zixuan.dto.Result;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public Object handleException(HttpServletRequest request, Exception ex) {
        System.err.println("===== GLOBAL EXCEPTION =====");
        System.err.println("Request URL: " + request.getRequestURL());
        System.err.println("Request Method: " + request.getMethod());
        ex.printStackTrace();

        String path = request.getRequestURI();
        String ctx = request.getContextPath();
        boolean isApi = path.startsWith((ctx != null ? ctx : "") + "/api/");

        if (isApi) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Result.fail(500, "服务器错误: " + ex.getMessage()));
        }

        ModelAndView mav = new ModelAndView("common/500");
        mav.addObject("exception", ex.toString());
        return mav;
    }
}
