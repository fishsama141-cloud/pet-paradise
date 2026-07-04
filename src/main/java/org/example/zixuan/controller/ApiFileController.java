/**
 * 文件下载REST API，自动从保存文件名中还原原始文件名
 */
package org.example.zixuan.controller;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;

@RestController
@RequestMapping("/api/file")
public class ApiFileController {

    @Autowired
    private ServletContext servletContext;

    @GetMapping("/download")
    public void download(@RequestParam("file") String file,
                         HttpServletResponse response) throws IOException {
        if (file == null || file.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "文件名不能为空");
            return;
        }
        String uploadPath = (String) servletContext.getAttribute("uploadPath");
        File f = new File(uploadPath, file);
        if (!f.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "文件不存在");
            return;
        }
        String originalName = file;
        int idx = file.indexOf('_', file.indexOf('_') + 1);
        if (idx > 0) {
            int idx2 = file.indexOf('_', idx + 1);
            if (idx2 > 0) originalName = file.substring(idx2 + 1);
        }
        response.setContentType("application/octet-stream");
        response.setContentLengthLong(f.length());
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + URLEncoder.encode(originalName, "UTF-8") + "\"");
        try (FileInputStream fis = new FileInputStream(f);
             OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        }
    }
}
