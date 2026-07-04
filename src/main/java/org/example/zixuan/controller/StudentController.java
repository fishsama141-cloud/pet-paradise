/**
 * 学生端页面导航，包括个人资料、岗位浏览、岗位申请、课表上传、任务查看
 */
package org.example.zixuan.controller;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpSession;
import org.example.zixuan.model.*;
import org.example.zixuan.service.*;
import org.example.zixuan.mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.List;

@Controller
@RequestMapping("/student")
public class StudentController {

    @Autowired private ServletContext servletContext;
    @Autowired private PositionService positionService;
    @Autowired private ApplicationService applicationService;
    @Autowired private ScheduleService scheduleService;
    @Autowired private TaskService taskService;
    @Autowired private UserService userService;

    @GetMapping("/profile")
    public String profile(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        model.addAttribute("profile", user);
        model.addAttribute("applications", applicationService.findByStudent(user.getId()));
        return "student/profile";
    }

    @PostMapping("/profile")
    public String updateProfile(@RequestParam("name") String name,
                                @RequestParam("number") String number,
                                @RequestParam("email") String email,
                                @RequestParam("phone") String phone,
                                @RequestParam("className") String className,
                                HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        user.setName(name.trim());
        user.setNumber(number.trim());
        user.setEmail(email != null ? email.trim() : "");
        user.setPhone(phone != null ? phone.trim() : "");
        user.setClassName(className != null ? className.trim() : "");
        userService.update(user);
        session.setAttribute("user", user);
        model.addAttribute("success", "个人信息已更新！");
        model.addAttribute("profile", user);
        model.addAttribute("applications", applicationService.findByStudent(user.getId()));
        return "student/profile";
    }

    @PostMapping("/uploadResume")
    public String uploadResume(@RequestParam("resumeFile") MultipartFile file,
                               HttpSession session, Model model) throws IOException {
        User user = (User) session.getAttribute("user");
        if (file.isEmpty()) {
            model.addAttribute("error", "请选择要上传的文件！");
            model.addAttribute("applications", applicationService.findByStudent(user.getId()));
            model.addAttribute("profile", user);
            return "student/profile";
        }
        String fileName = file.getOriginalFilename();
        String uploadPath = (String) servletContext.getAttribute("uploadPath");
        String savedName = "resume_" + user.getId() + "_" + System.currentTimeMillis() + "_" + fileName;
        file.transferTo(new File(uploadPath, savedName));
        userService.updateResumePath(user.getId(), savedName);
        user.setResumePath(savedName);
        session.setAttribute("user", user);
        model.addAttribute("success", "简历上传成功！");
        model.addAttribute("profile", user);
        model.addAttribute("applications", applicationService.findByStudent(user.getId()));
        return "student/profile";
    }

    @GetMapping("/positions")
    public String positions(Model model) {
        model.addAttribute("positions", positionService.findOpen());
        return "student/positions";
    }

    @GetMapping("/apply")
    public String applyForm(@RequestParam("positionId") int positionId, Model model) {
        Position position = positionService.findById(positionId);
        if (position == null) return "redirect:/student/positions";
        model.addAttribute("position", position);
        return "student/apply";
    }

    @PostMapping("/apply")
    public String applySubmit(@RequestParam("positionId") int positionId,
                              @RequestParam("reason") String reason,
                              @RequestParam(name = "attachmentFiles", required = false) List<MultipartFile> files,
                              HttpSession session, Model model) throws IOException {
        User user = (User) session.getAttribute("user");
        if (reason == null || reason.trim().isEmpty()) {
            model.addAttribute("error", "请填写申请理由！");
            model.addAttribute("position", positionService.findById(positionId));
            return "student/apply";
        }
        Application app = new Application();
        app.setPositionId(positionId);
        app.setStudentId(user.getId());
        app.setReason(reason.trim());
        if (!applicationService.apply(app)) {
            model.addAttribute("error", "申请失败，您可能已经申请过该岗位！");
            model.addAttribute("position", positionService.findById(positionId));
            return "student/apply";
        }
        // 保存上传的附件
        if (files != null) {
            String uploadPath = (String) servletContext.getAttribute("uploadPath");
            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    String fileName = file.getOriginalFilename();
                    String savedName = "app_" + app.getId() + "_" + System.currentTimeMillis() + "_" + fileName;
                    file.transferTo(new File(uploadPath, savedName));
                    ApplicationFile af = new ApplicationFile();
                    af.setApplicationId(app.getId());
                    af.setFileName(fileName);
                    af.setFilePath(savedName);
                    applicationService.saveFile(af);
                }
            }
        }
        return "redirect:/student/profile";
    }

    @GetMapping("/applications")
    public String myApplications(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        model.addAttribute("applications", applicationService.findByStudent(user.getId()));
        return "student/myApplications";
    }

    @GetMapping("/upload")
    public String uploadPage() {
        return "student/uploadSchedule";
    }

    @PostMapping("/upload")
    public String uploadFile(@RequestParam("scheduleFile") MultipartFile file,
                             HttpSession session, Model model) throws IOException {
        User user = (User) session.getAttribute("user");
        if (file.isEmpty()) {
            model.addAttribute("error", "请选择要上传的文件！");
            return "student/uploadSchedule";
        }
        String fileName = file.getOriginalFilename();
        if (fileName != null && !fileName.matches(".*\\.(pdf|doc|docx|jpg|png|xls|xlsx)$")) {
            model.addAttribute("error", "仅支持上传 pdf/doc/docx/jpg/png/xls/xlsx 格式的文件！");
            return "student/uploadSchedule";
        }
        String uploadPath = (String) servletContext.getAttribute("uploadPath");
        String savedName = "schedule_" + user.getId() + "_" + System.currentTimeMillis() + "_" + fileName;
        File dest = new File(uploadPath, savedName);
        file.transferTo(dest);
        userService.updateSchedulePath(user.getId(), savedName);
        user.setCourseSchedulePath(savedName);
        session.setAttribute("user", user);
        model.addAttribute("success", "课表上传成功！");
        return "student/uploadSchedule";
    }

    @GetMapping("/download")
    public void downloadFile(@RequestParam("file") String file,
                             HttpSession session,
                             jakarta.servlet.http.HttpServletResponse response) throws IOException {
        if (file == null || file.isEmpty()) {
            response.sendError(jakarta.servlet.http.HttpServletResponse.SC_BAD_REQUEST, "文件名不能为空");
            return;
        }
        String uploadPath = (String) servletContext.getAttribute("uploadPath");
        File f = new File(uploadPath, file);
        if (!f.exists()) {
            response.sendError(jakarta.servlet.http.HttpServletResponse.SC_NOT_FOUND, "文件不存在");
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

    @GetMapping("/work")
    public String work(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        model.addAttribute("schedules", scheduleService.findByStudent(user.getId()));
        model.addAttribute("tasks", taskService.findByStudent(user.getId()));
        return "student/work";
    }

    @GetMapping("/schedule")
    public String mySchedule(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        model.addAttribute("schedules", scheduleService.findByStudent(user.getId()));
        return "student/mySchedule";
    }

    @GetMapping("/tasks")
    public String myTasks(HttpSession session,
                          @RequestParam(name = "action", required = false) String action,
                          @RequestParam(name = "taskId", required = false) Integer taskId,
                          @RequestParam(name = "status", required = false) String status,
                          Model model) {
        User user = (User) session.getAttribute("user");
        if ("updateStatus".equals(action) && taskId != null && status != null) {
            Task task = taskService.findById(taskId);
            if (task != null && task.getStudentId() == user.getId()) {
                task.setStatus(status);
                taskService.update(task);
            }
            return "redirect:/student/tasks";
        }
        model.addAttribute("tasks", taskService.findByStudent(user.getId()));
        return "student/myTasks";
    }
}
