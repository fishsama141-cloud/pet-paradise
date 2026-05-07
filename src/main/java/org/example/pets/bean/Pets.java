package org.example.pets.bean;


import java.util.Date;
import java.util.LinkedList;
import java.util.List;

public class Pets {
    private String name = "小乖乖";      // 宠物名字
    private int hunger = 60;            // 饥饿度 0-100，越高越饱
    private int mood = 60;              // 心情 0-100
    private Date lastFeedTime;          // 上次喂食时间
    private List<String> feedLog;       // 喂食时间记录（字符串）

    public Pets() {
        lastFeedTime = new Date();
        feedLog = new LinkedList<>();
        addLog("宠物诞生啦！初始饥饿度60，心情60");
    }

    // 喂食操作
    public void feed() {
        Date now = new Date();
        // 如果死亡状态，不能喂食（需要在Servlet判断）
        // 增加饥饿度（最多100）
        hunger = Math.min(100, hunger + 20);
        // 心情上升
        mood = Math.min(100, mood + 10);
        lastFeedTime = now;
        addLog("喂食成功！饥饿度 +20，心情 +10 → 现在饥饿度:" + hunger + " 心情:" + mood);
    }

    // 计算当前实际状态（根据时间流逝衰减）
    public void updateStatus() {
        Date now = new Date();
        long diffMillis = now.getTime() - lastFeedTime.getTime();
        long diffHours = diffMillis / (1000 * 60 * 60);

        if (diffHours >= 24) {
            // 宠物死亡：饥饿度和心情降为 0
            hunger = 0;
            mood = 0;
        } else if (diffHours > 0) {
            // 每小时饥饿度减少 5，心情减少 3
            int lossHunger = (int) (diffHours * 5);
            int lossMood = (int) (diffHours * 3);
            hunger = Math.max(0, hunger - lossHunger);
            mood = Math.max(0, mood - lossMood);
        }
    }

    // 检查是否存活
    public boolean isAlive() {
        return hunger > 0 && mood > 0;
    }

    // 重置宠物（复活）
    public void reset() {
        hunger = 60;
        mood = 60;
        lastFeedTime = new Date();
        feedLog.clear();
        addLog("宠物复活了！所有状态重置。");
    }

    private void addLog(String msg) {
        String timeStr = new java.text.SimpleDateFormat("HH:mm:ss").format(new Date());
        feedLog.add(0, "[" + timeStr + "] " + msg);  // 最新记录在前面
        if (feedLog.size() > 20) feedLog.remove(20);
    }

    // ---------- getter / setter ----------
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getHunger() { return hunger; }
    public void setHunger(int hunger) { this.hunger = hunger; }

    public int getMood() { return mood; }
    public void setMood(int mood) { this.mood = mood; }

    public Date getLastFeedTime() { return lastFeedTime; }
    public void setLastFeedTime(Date lastFeedTime) { this.lastFeedTime = lastFeedTime; }

    public List<String> getFeedLog() { return feedLog; }
}