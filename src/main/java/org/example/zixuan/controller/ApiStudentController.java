/**
 * 学生端REST API，提供个人资料、岗位浏览、岗位申请、课表上传、任务管理接口
 */
package org.example.zixuan.controller;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpSession;
import org.example.zixuan.dto.Result;
import org.example.zixuan.model.*;
import org.example.zixuan.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student")
public class ApiStudentController {

    @Autowired private ServletContext servletContext;
    @Autowired private PositionService positionService;
    @Autowired private ApplicationService applicationService;
    @Autowired private ScheduleService scheduleService;
    @Autowired private TaskService taskService;
    @Autowired private UserService userService;

    private User getSessionUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }

    @GetMapping("/profile")
    public Result<Map<String, Object>> profile(HttpSession session) {
        User user = getSessionUser(session);
        Map<String, Object> data = new HashMap<>();
        data.put("profile", user);
        data.put("applications", applicationService.findByStudent(user.getId()));
        return Result.ok(data);
    }

    @PutMapping("/profile")
    public Result<User> updateProfile(@RequestBody User form, HttpSession session) {
        User user = getSessionUser(session);
        if (form.getName() != null) user.setName(form.getName().trim());
        if (form.getNumber() != null) user.setNumber(form.getNumber().trim());
        if (form.getEmail() != null) user.setEmail(form.getEmail().trim());
        if (form.getPhone() != null) user.setPhone(form.getPhone().trim());
        if (form.getClassName() != null) user.setClassName(form.getClassName().trim());
        userService.update(user);
        session.setAttribute("user", user);
        return Result.ok("个人信息已更新！", user);
    }

    @PostMapping("/uploadResume")
    public Result<Map<String, Object>> uploadResume(@RequestParam("resumeFile") MultipartFile file,
                                                     HttpSession session) throws IOException {
        User user = getSessionUser(session);
        if (file.isEmpty()) {
            return Result.fail(400, "请选择要上传的文件！");
        }
        String uploadPath = (String) servletContext.getAttribute("uploadPath");
        String savedName = "resume_" + user.getId() + "_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
        file.transferTo(new File(uploadPath, savedName));
        userService.updateResumePath(user.getId(), savedName);
        user.setResumePath(savedName);
        session.setAttribute("user", user);

        Map<String, Object> data = new HashMap<>();
        data.put("profile", user);
        data.put("applications", applicationService.findByStudent(user.getId()));
        return Result.ok("简历上传成功！", data);
    }

    @GetMapping("/positions")
    public Result<List<Position>> positions() {
        return Result.ok(positionService.findOpen());
    }

    @GetMapping("/positions/{id}")
    public Result<Position> positionDetail(@PathVariable int id) {
        Position p = positionService.findById(id);
        if (p == null) return Result.fail(404, "岗位不存在");
        return Result.ok(p);
    }

    @PostMapping("/apply")
    public Result<Void> apply(@RequestParam("positionId") int positionId,
                               @RequestParam("reason") String reason,
                               @RequestParam(name = "attachmentFiles", required = false) List<MultipartFile> files,
                               HttpSession session) throws IOException {
        User user = getSessionUser(session);
        if (reason == null || reason.trim().isEmpty()) {
            return Result.fail(400, "请填写申请理由！");
        }
        Application app = new Application();
        app.setPositionId(positionId);
        app.setStudentId(user.getId());
        app.setReason(reason.trim());
        if (!applicationService.apply(app)) {
            return Result.fail(400, "申请失败，您可能已经申请过该岗位！");
        }
        if (files != null) {
            String uploadPath = (String) servletContext.getAttribute("uploadPath");
            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    String savedName = "app_" + app.getId() + "_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
                    file.transferTo(new File(uploadPath, savedName));
                    ApplicationFile af = new ApplicationFile();
                    af.setApplicationId(app.getId());
                    af.setFileName(file.getOriginalFilename());
                    af.setFilePath(savedName);
                    applicationService.saveFile(af);
                }
            }
        }
        return Result.ok("申请成功", null);
    }

    @GetMapping("/applications")
    public Result<List<Application>> applications(HttpSession session) {
        User user = getSessionUser(session);
        return Result.ok(applicationService.findByStudent(user.getId()));
    }

    @PostMapping("/uploadSchedule")
    public Result<Void> uploadSchedule(@RequestParam("scheduleFile") MultipartFile file,
                                        HttpSession session) throws IOException {
        User user = getSessionUser(session);
        if (file.isEmpty()) {
            return Result.fail(400, "请选择要上传的文件！");
        }
        String fn = file.getOriginalFilename();
        if (fn != null && !fn.matches(".*\\.(pdf|doc|docx|jpg|png|xls|xlsx)$")) {
            return Result.fail(400, "仅支持 pdf/doc/docx/jpg/png/xls/xlsx 格式！");
        }
        String uploadPath = (String) servletContext.getAttribute("uploadPath");
        String savedName = "schedule_" + user.getId() + "_" + System.currentTimeMillis() + "_" + fn;
        file.transferTo(new File(uploadPath, savedName));
        userService.updateSchedulePath(user.getId(), savedName);
        user.setCourseSchedulePath(savedName);
        session.setAttribute("user", user);
        return Result.ok("课表上传成功！", null);
    }

    @GetMapping("/schedules")
    public Result<List<Schedule>> schedules(HttpSession session) {
        User user = getSessionUser(session);
        return Result.ok(scheduleService.findByStudent(user.getId()));
    }

    @GetMapping("/tasks")
    public Result<List<Task>> tasks(HttpSession session) {
        User user = getSessionUser(session);
        return Result.ok(taskService.findByStudent(user.getId()));
    }

    @PutMapping("/tasks/{id}/status")
    public Result<Void> updateTaskStatus(@PathVariable int id, @RequestBody Map<String, String> body,
                                          HttpSession session) {
        User user = getSessionUser(session);
        Task task = taskService.findById(id);
        if (task == null || task.getStudentId() != user.getId()) {
            return Result.fail(403, "无权操作");
        }
        task.setStatus(body.get("status"));
        taskService.update(task);
        return Result.ok(null);
    }

    @GetMapping("/work")
    public Result<Map<String, Object>> work(HttpSession session) {
        User user = getSessionUser(session);
        Map<String, Object> data = new HashMap<>();
        data.put("schedules", scheduleService.findByStudent(user.getId()));
        data.put("tasks", taskService.findByStudent(user.getId()));
        return Result.ok(data);
    }
}
