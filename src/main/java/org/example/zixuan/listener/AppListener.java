/**
 * 应用生命周期监听器，在应用启动时创建上传目录并设置全局属性（应用名称、上传路径），在销毁时输出关闭日志。
 */
package org.example.zixuan.listener;

import jakarta.servlet.*;
import java.io.File;

public class AppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // 创建上传目录
        String uploadPath = sce.getServletContext().getRealPath("/") + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        sce.getServletContext().setAttribute("appName", "校园助管申请管理平台");
        sce.getServletContext().setAttribute("uploadPath", uploadPath);
        System.out.println("===== 校园助管申请管理平台 启动完成 =====");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("===== 校园助管申请管理平台 已关闭 =====");
    }
}
