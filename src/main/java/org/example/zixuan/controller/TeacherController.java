/**
 * 教师端页面导航，包括个人资料、岗位管理、学生审批、排班管理、任务管理
 */
package org.example.zixuan.controller;

import jakarta.servlet.http.HttpSession;
import org.example.zixuan.model.*;
import org.example.zixuan.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.sql.Date;
import java.util.List;

@Controller
@RequestMapping("/teacher")
public class TeacherController {

    @Autowired private PositionService positionService;
    @Autowired private ApplicationService applicationService;
    @Autowired private ScheduleService scheduleService;
    @Autowired private TaskService taskService;
    @Autowired private UserService userService;

    @GetMapping("/profile")
    public String profile(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        model.addAttribute("profile", user);
        List<Position> positions = positionService.findByTeacher(user.getId());
        for (Position p : positions) {
            p.setApprovedStudents(applicationService.findApprovedByPosition(p.getId()));
        }
        model.addAttribute("positions", positions);
        return "teacher/profile";
    }

    @PostMapping("/profile")
    public String updateProfile(@RequestParam("name") String name,
                                @RequestParam("number") String number,
                                @RequestParam("email") String email,
                                @RequestParam("phone") String phone,
                                HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        user.setName(name.trim());
        user.setNumber(number.trim());
        user.setEmail(email != null ? email.trim() : "");
        user.setPhone(phone != null ? phone.trim() : "");
        userService.update(user);
        session.setAttribute("user", user);
        model.addAttribute("success", "个人信息已更新！");
        model.addAttribute("profile", user);
        List<Position> positions = positionService.findByTeacher(user.getId());
        for (Position p : positions) {
            p.setApprovedStudents(applicationService.findApprovedByPosition(p.getId()));
        }
        model.addAttribute("positions", positions);
        return "teacher/profile";
    }

    @GetMapping("/positions")
    public String listPositions(HttpSession session,
                                @RequestParam(name = "action", required = false) String action,
                                @RequestParam(name = "id", required = false) Integer id,
                                Model model) {
        User user = (User) session.getAttribute("user");
        if ("edit".equals(action)) {
            if (id != null) {
                Position p = positionService.findById(id);
                if (p != null && p.getTeacherId() == user.getId()) {
                    model.addAttribute("position", p);
                }
            }
            return "teacher/editPosition";
        }
        if ("delete".equals(action) && id != null) {
            Position p = positionService.findById(id);
            if (p != null && p.getTeacherId() == user.getId()) {
                positionService.delete(id);
            }
            return "redirect:/teacher/positions";
        }
        model.addAttribute("positions", positionService.findByTeacher(user.getId()));
        return "teacher/positions";
    }

    @PostMapping("/positions")
    public String savePosition(HttpSession session,
                               @RequestParam(name = "id", required = false) Integer id,
                               @RequestParam("title") String title,
                               @RequestParam(name = "department", required = false) String department,
                               @RequestParam("description") String description,
                               @RequestParam(name = "requirements", required = false) String requirements,
                               @RequestParam(name = "location", required = false) String location,
                               @RequestParam("maxStudents") int maxStudents,
                               @RequestParam(name = "status", required = false, defaultValue = "open") String status,
                               Model model) {
        User user = (User) session.getAttribute("user");
        Position p = new Position();
        p.setTitle(title);
        p.setDepartment(department != null ? department : "");
        p.setDescription(description);
        p.setRequirements(requirements != null ? requirements : "");
        p.setLocation(location != null ? location : "");
        p.setMaxStudents(maxStudents);
        p.setStatus(status);
        p.setTeacherId(user.getId());

        if (id != null) {
            p.setId(id);
            Position existing = positionService.findById(id);
            if (existing != null && existing.getTeacherId() == user.getId()) {
                positionService.update(p);
            }
        } else {
            positionService.create(p);
        }
        return "redirect:/teacher/positions";
    }

    @GetMapping("/students")
    public String manageStudents(HttpSession session,
                                 @RequestParam(name = "action", required = false) String action,
                                 @RequestParam(name = "appId", required = false) Integer appId,
                                 @RequestParam(name = "positionId", required = false) Integer positionId,
                                 Model model) {
        User user = (User) session.getAttribute("user");
        if ("approve".equals(action) && appId != null) {
            applicationService.updateStatus(appId, "approved");
            return "redirect:/teacher/students?positionId=" + positionId;
        }
        if ("reject".equals(action) && appId != null) {
            applicationService.updateStatus(appId, "rejected");
            return "redirect:/teacher/students?positionId=" + positionId;
        }
        if (positionId != null) {
            List<Application> apps = applicationService.findByPosition(positionId);
            for (Application app : apps) {
                app.setFiles(applicationService.getFilesByApplication(app.getId()));
            }
            model.addAttribute("applications", apps);
            model.addAttribute("position", positionService.findById(positionId));
        }
        model.addAttribute("positions", positionService.findByTeacher(user.getId()));
        return "teacher/students";
    }

    @GetMapping("/tasks")
    public String listTasks(HttpSession session,
                            @RequestParam(name = "action", required = false) String action,
                            @RequestParam(name = "taskId", required = false) Integer taskId,
                            Model model) {
        User user = (User) session.getAttribute("user");
        if ("delete".equals(action) && taskId != null) {
            taskService.delete(taskId);
            return "redirect:/teacher/tasks";
        }
        model.addAttribute("tasks", taskService.findByTeacher(user.getId()));
        List<Position> positions = positionService.findByTeacher(user.getId());
        for (Position p : positions) {
            p.setApprovedStudents(applicationService.findApprovedByPosition(p.getId()));
        }
        model.addAttribute("positions", positions);
        return "teacher/tasks";
    }

    @PostMapping("/tasks")
    public String saveTask(@RequestParam(name = "taskId", required = false) Integer taskId,
                           @RequestParam("positionId") int positionId,
                           @RequestParam("studentId") int studentId,
                           @RequestParam("title") String title,
                           @RequestParam(name = "description", required = false) String description,
                           @RequestParam(name = "status", required = false, defaultValue = "pending") String status,
                           @RequestParam(name = "deadline", required = false) String deadline) {
        Task t = new Task();
        t.setPositionId(positionId);
        t.setStudentId(studentId);
        t.setTitle(title);
        t.setDescription(description != null ? description : "");
        t.setStatus(status);
        if (deadline != null && !deadline.isEmpty()) {
            t.setDeadline(Date.valueOf(deadline));
        }
        if (taskId != null) {
            t.setId(taskId);
            taskService.update(t);
        } else {
            taskService.create(t);
        }
        return "redirect:/teacher/tasks";
    }

    @GetMapping("/work")
    public String work(HttpSession session,
                       @RequestParam(name = "action", required = false) String action,
                       @RequestParam(name = "scheduleId", required = false) Integer scheduleId,
                       @RequestParam(name = "taskId", required = false) Integer taskId,
                       Model model) {
        User user = (User) session.getAttribute("user");
        if ("deleteSchedule".equals(action) && scheduleId != null) {
            scheduleService.delete(scheduleId);
            return "redirect:/teacher/work";
        }
        if ("deleteTask".equals(action) && taskId != null) {
            taskService.delete(taskId);
            return "redirect:/teacher/work";
        }
        model.addAttribute("schedules", scheduleService.findByTeacher(user.getId()));
        model.addAttribute("tasks", taskService.findByTeacher(user.getId()));
        List<Position> positions = positionService.findByTeacher(user.getId());
        for (Position p : positions) {
            p.setApprovedStudents(applicationService.findApprovedByPosition(p.getId()));
        }
        model.addAttribute("positions", positions);
        return "teacher/work";
    }

    @GetMapping("/schedule")
    public String listSchedules(HttpSession session,
                                @RequestParam(name = "action", required = false) String action,
                                @RequestParam(name = "scheduleId", required = false) Integer scheduleId,
                                Model model) {
        User user = (User) session.getAttribute("user");
        if ("delete".equals(action) && scheduleId != null) {
            scheduleService.delete(scheduleId);
            return "redirect:/teacher/schedule";
        }
        model.addAttribute("schedules", scheduleService.findByTeacher(user.getId()));
        List<Position> positions = positionService.findByTeacher(user.getId());
        for (Position p : positions) {
            p.setApprovedStudents(applicationService.findApprovedByPosition(p.getId()));
        }
        model.addAttribute("positions", positions);
        return "teacher/schedule";
    }

    @PostMapping("/schedule")
    public String saveSchedule(@RequestParam(name = "scheduleId", required = false) Integer scheduleId,
                               @RequestParam("positionId") int positionId,
                               @RequestParam("studentId") int studentId,
                               @RequestParam("weekDay") String weekDay,
                               @RequestParam("timeSlot") String timeSlot,
                               @RequestParam(name = "location", required = false) String location) {
        if (positionId == 0 || studentId == 0) {
            return "redirect:/teacher/schedule";
        }
        Schedule s = new Schedule();
        s.setPositionId(positionId);
        s.setStudentId(studentId);
        s.setWeekDay(weekDay);
        s.setTimeSlot(timeSlot);
        s.setLocation(location != null ? location : "");
        if (scheduleId != null) {
            s.setId(scheduleId);
            scheduleService.update(s);
        } else {
            scheduleService.create(s);
        }
        return "redirect:/teacher/schedule";
    }
}
