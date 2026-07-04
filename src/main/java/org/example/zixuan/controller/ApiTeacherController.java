/**
 * 教师端REST API，提供岗位管理、学生申请审批、排班管理、任务管理接口
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
import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/teacher")
public class ApiTeacherController {

    @Autowired private ServletContext servletContext;
    @Autowired private PositionService positionService;
    @Autowired private ApplicationService applicationService;
    @Autowired private ScheduleService scheduleService;
    @Autowired private TaskService taskService;
    @Autowired private UserService userService;

    private User getSessionUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }

    /** 安全解析日期字符串，支持 yyyy-MM-dd 和毫秒时间戳两种格式 */
    private Date parseDeadline(String deadline) {
        if (deadline == null || deadline.isEmpty()) return null;
        try {
            // 尝试 yyyy-MM-dd
            return Date.valueOf(deadline);
        } catch (IllegalArgumentException e1) {
            try {
                // 尝试毫秒时间戳 (Jackson 默认序列化格式)
                long ms = Long.parseLong(deadline);
                return new Date(ms);
            } catch (NumberFormatException e2) {
                return null;
            }
        }
    }

    private List<Position> enrichPositions(List<Position> positions) {
        for (Position p : positions) {
            p.setApprovedStudents(applicationService.findApprovedByPosition(p.getId()));
        }
        return positions;
    }

    @GetMapping("/profile")
    public Result<Map<String, Object>> profile(HttpSession session) {
        User user = getSessionUser(session);
        Map<String, Object> data = new HashMap<>();
        data.put("profile", user);
        data.put("positions", enrichPositions(positionService.findByTeacher(user.getId())));
        return Result.ok(data);
    }

    @PutMapping("/profile")
    public Result<User> updateProfile(@RequestBody User form, HttpSession session) {
        User user = getSessionUser(session);
        if (form.getName() != null) user.setName(form.getName().trim());
        if (form.getNumber() != null) user.setNumber(form.getNumber().trim());
        if (form.getEmail() != null) user.setEmail(form.getEmail().trim());
        if (form.getPhone() != null) user.setPhone(form.getPhone().trim());
        userService.update(user);
        session.setAttribute("user", user);
        return Result.ok("个人信息已更新！", user);
    }

    @GetMapping("/positions")
    public Result<List<Position>> listPositions(HttpSession session) {
        User user = getSessionUser(session);
        return Result.ok(enrichPositions(positionService.findByTeacher(user.getId())));
    }

    @PostMapping("/positions")
    public Result<Position> createPosition(@RequestBody Position p, HttpSession session) {
        User user = getSessionUser(session);
        p.setTeacherId(user.getId());
        if (p.getStatus() == null) p.setStatus("open");
        positionService.create(p);
        return Result.ok("岗位发布成功！", p);
    }

    @PutMapping("/positions/{id}")
    public Result<Position> updatePosition(@PathVariable int id, @RequestBody Position p, HttpSession session) {
        User user = getSessionUser(session);
        Position existing = positionService.findById(id);
        if (existing == null) {
            return Result.fail(404, "岗位不存在");
        }
        if (existing.getTeacherId() != user.getId()) {
            return Result.fail(403, "无权操作该岗位");
        }
        p.setId(id);
        p.setTeacherId(user.getId());
        positionService.update(p);
        return Result.ok("岗位更新成功！", p);
    }

    @DeleteMapping("/positions/{id}")
    public Result<Void> deletePosition(@PathVariable int id, HttpSession session) {
        User user = getSessionUser(session);
        Position existing = positionService.findById(id);
        if (existing == null) {
            return Result.fail(404, "岗位不存在");
        }
        if (existing.getTeacherId() != user.getId()) {
            return Result.fail(403, "无权操作该岗位");
        }
        positionService.delete(id);
        return Result.ok(null);
    }

    @PutMapping("/applications/{id}/status")
    public Result<Void> updateApplicationStatus(@PathVariable int id, @RequestBody Map<String, String> body) {
        applicationService.updateStatus(id, body.get("status"));
        return Result.ok(null);
    }

    @GetMapping("/schedules")
    public Result<Map<String, Object>> listSchedules(HttpSession session) {
        User user = getSessionUser(session);
        Map<String, Object> data = new HashMap<>();
        data.put("schedules", scheduleService.findByTeacher(user.getId()));
        data.put("positions", enrichPositions(positionService.findByTeacher(user.getId())));
        return Result.ok(data);
    }

    @PostMapping("/schedules")
    public Result<Schedule> createSchedule(@RequestBody Schedule s) {
        if (s.getPositionId() == 0 || s.getStudentId() == 0) {
            return Result.fail(400, "请选择岗位和学生");
        }
        scheduleService.create(s);
        return Result.ok("排班创建成功！", s);
    }

    @DeleteMapping("/schedules/{id}")
    public Result<Void> deleteSchedule(@PathVariable int id) {
        scheduleService.delete(id);
        return Result.ok(null);
    }

    @GetMapping("/tasks")
    public Result<Map<String, Object>> listTasks(HttpSession session) {
        User user = getSessionUser(session);
        Map<String, Object> data = new HashMap<>();
        data.put("tasks", taskService.findByTeacher(user.getId()));
        data.put("positions", enrichPositions(positionService.findByTeacher(user.getId())));
        return Result.ok(data);
    }

    @PostMapping("/tasks")
    public Result<Task> createTask(@RequestParam("title") String title,
                                   @RequestParam(name = "description", required = false) String description,
                                   @RequestParam(name = "location", required = false) String location,
                                   @RequestParam(name = "deadline", required = false) String deadline,
                                   @RequestParam(name = "studentId", required = false) Integer studentId,
                                   @RequestParam(name = "positionId", required = false) Integer positionId,
                                   @RequestParam(name = "taskFile", required = false) MultipartFile file,
                                   HttpSession session) throws IOException {
        Task t = new Task();
        t.setTitle(title.trim());
        t.setDescription(description != null ? description.trim() : "");
        t.setLocation(location != null ? location.trim() : "");
        t.setStatus("pending");
        t.setStudentId(studentId != null ? studentId : 0);
        t.setPositionId(positionId != null ? positionId : 0);
        if (deadline != null && !deadline.isEmpty()) {
            t.setDeadline(parseDeadline(deadline));
        }
        if (file != null && !file.isEmpty()) {
            String uploadPath = (String) servletContext.getAttribute("uploadPath");
            String savedName = "task_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
            file.transferTo(new File(uploadPath, savedName));
            t.setFilePath(savedName);
        }
        taskService.create(t);
        return Result.ok("任务创建成功！", t);
    }

    @PutMapping("/tasks/{id}")
    public Result<Task> updateTask(@PathVariable int id,
                                   @RequestParam("title") String title,
                                   @RequestParam(name = "description", required = false) String description,
                                   @RequestParam(name = "location", required = false) String location,
                                   @RequestParam(name = "deadline", required = false) String deadline,
                                   @RequestParam(name = "studentId", required = false) Integer studentId,
                                   @RequestParam(name = "positionId", required = false) Integer positionId,
                                   @RequestParam(name = "status", required = false) String status,
                                   @RequestParam(name = "taskFile", required = false) MultipartFile file,
                                   HttpSession session) throws IOException {
        Task t = taskService.findById(id);
        if (t == null) return Result.fail(404, "任务不存在");
        t.setTitle(title.trim());
        t.setDescription(description != null ? description.trim() : "");
        t.setLocation(location != null ? location.trim() : "");
        t.setStudentId(studentId != null ? studentId : 0);
        t.setPositionId(positionId != null ? positionId : 0);
        if (status != null) t.setStatus(status);
        if (deadline != null && !deadline.isEmpty()) {
            t.setDeadline(parseDeadline(deadline));
        }
        if (file != null && !file.isEmpty()) {
            String uploadPath = (String) servletContext.getAttribute("uploadPath");
            String savedName = "task_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
            file.transferTo(new File(uploadPath, savedName));
            t.setFilePath(savedName);
        }
        taskService.update(t);
        return Result.ok("任务更新成功！", t);
    }

    @PostMapping("/tasks/{id}")
    public Result<Task> updateTaskPost(@PathVariable int id,
                                       @RequestParam("title") String title,
                                       @RequestParam(name = "description", required = false) String description,
                                       @RequestParam(name = "location", required = false) String location,
                                       @RequestParam(name = "deadline", required = false) String deadline,
                                       @RequestParam(name = "studentId", required = false) Integer studentId,
                                       @RequestParam(name = "positionId", required = false) Integer positionId,
                                       @RequestParam(name = "status", required = false) String status,
                                       @RequestParam(name = "taskFile", required = false) MultipartFile file,
                                       HttpSession session) throws IOException {
        Task t = taskService.findById(id);
        if (t == null) return Result.fail(404, "任务不存在");
        t.setTitle(title.trim());
        t.setDescription(description != null ? description.trim() : "");
        t.setLocation(location != null ? location.trim() : "");
        t.setStudentId(studentId != null ? studentId : 0);
        t.setPositionId(positionId != null ? positionId : 0);
        if (status != null) t.setStatus(status);
        if (deadline != null && !deadline.isEmpty()) {
            t.setDeadline(parseDeadline(deadline));
        }
        if (file != null && !file.isEmpty()) {
            String uploadPath = (String) servletContext.getAttribute("uploadPath");
            String savedName = "task_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
            file.transferTo(new File(uploadPath, savedName));
            t.setFilePath(savedName);
        }
        taskService.update(t);
        return Result.ok("任务更新成功！", t);
    }

    @DeleteMapping("/tasks/{id}")
    public Result<Void> deleteTask(@PathVariable int id) {
        taskService.delete(id);
        return Result.ok(null);
    }

    @GetMapping("/work")
    public Result<Map<String, Object>> work(HttpSession session) {
        User user = getSessionUser(session);
        Map<String, Object> data = new HashMap<>();
        data.put("schedules", scheduleService.findByTeacher(user.getId()));
        data.put("tasks", taskService.findByTeacher(user.getId()));
        data.put("positions", enrichPositions(positionService.findByTeacher(user.getId())));
        return Result.ok(data);
    }

    @GetMapping("/students/applications")
    public Result<Map<String, Object>> studentApplications(@RequestParam("positionId") int positionId) {
        List<Application> apps = applicationService.findByPosition(positionId);
        for (Application app : apps) {
            app.setFiles(applicationService.getFilesByApplication(app.getId()));
        }
        Map<String, Object> data = new HashMap<>();
        data.put("applications", apps);
        data.put("position", positionService.findById(positionId));
        return Result.ok(data);
    }
}
