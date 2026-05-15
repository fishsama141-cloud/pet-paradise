<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.pets.bean.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    List<PetSpecies.RegionDef> unlocked = (List<PetSpecies.RegionDef>) request.getAttribute("unlockedRegions");
    List<PetSpecies.RegionDef> locked = (List<PetSpecies.RegionDef>) request.getAttribute("lockedRegions");
    List<PetSpecies.RegionDef> allRegions = (List<PetSpecies.RegionDef>) request.getAttribute("allRegions");
    List<Pet> userPets = (List<Pet>) request.getAttribute("userPets");
    String exploreError = (String) request.getAttribute("exploreError");
    boolean canUnlock = request.getAttribute("canUnlock") != null && (Boolean) request.getAttribute("canUnlock");
    String unlockReqText = (String) request.getAttribute("unlockReqText");
    int unlockedCount = request.getAttribute("unlockedCount") != null ? (Integer) request.getAttribute("unlockedCount") : 0;
    Set<String> unlockedIds = (Set<String>) request.getAttribute("unlockedRegionIds");
    if (unlocked == null) unlocked = new ArrayList<>();
    if (locked == null) locked = new ArrayList<>();
    if (allRegions == null) allRegions = new ArrayList<>(PetSpecies.REGIONS);
    if (userPets == null) userPets = new ArrayList<>();
    if (unlockedIds == null) unlockedIds = new HashSet<>();

    int maxPetLevel = 0;
    for (Pet p : userPets) if (p.getLevel() > maxPetLevel) maxPetLevel = p.getLevel();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>世界探索 - 宠物乐园</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/common.css">
    <style>
        .mini-map {
            position: relative; width: 100%; max-width: 800px; margin: 0 auto 28px;
            height: 200px; background: url('<%= request.getContextPath() %>/assets/images/bg/map-bg.png') center/cover no-repeat;
            background-color: #E8DDCA; border-radius: var(--radius-lg);
            border: 1px solid var(--border); overflow: hidden;
            box-shadow: var(--shadow);
        }
        .mini-map .dot {
            position: absolute; transform: translate(-50%, -50%);
            width: 16px; height: 16px; border-radius: 50%; border: 2px solid #fff;
            box-shadow: 0 0 6px rgba(0,0,0,0.15);
        }
        .mini-map .dot.locked { border-color: #B0A590; box-shadow: none; opacity: 0.5; }
        .mini-map .dot-label {
            position: absolute; transform: translate(-50%, -50%);
            font-size: 12px; font-weight: 600; white-space: nowrap;
            text-shadow: 0 1px 2px rgba(255,255,255,0.9);
        }

        .unlock-hint {
            background: #FDF9F2; border: 1px dashed #D0C0A0; border-radius: var(--radius);
            padding: 14px 20px; margin-bottom: 20px;
            display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
        }
        .unlock-hint .hint-text { color: var(--text); font-weight: 600; font-size: 14px; }
        .unlock-hint .hint-req { color: var(--text-secondary); font-size: 13px; }

        .region-list { display: flex; flex-direction: column; gap: 14px; }
        .region-row {
            display: flex; align-items: center; gap: 20px;
            background: var(--card-bg); border-radius: var(--radius-lg); padding: 20px 24px;
            border: 1px solid var(--border); box-shadow: var(--shadow-xs); transition: all var(--transition);
        }
        .region-row.locked-row { opacity: 0.6; }
        .region-row.can-unlock { border-color: #D0C8A0; }
        .region-row:hover { box-shadow: var(--shadow); }
        .region-icon-box {
            width: 64px; height: 64px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 30px; flex-shrink: 0; border: 2px solid transparent;
        }
        .region-info { flex: 1; min-width: 0; }
        .region-info .rname { font-size: 17px; font-weight: 600; color: var(--text); }
        .region-info .rloc { font-size: 13px; color: var(--text-secondary); margin: 2px 0; }
        .region-info .rdesc { font-size: 13px; color: var(--text-secondary); margin-top: 2px; line-height: 1.5; }
        .region-info .ranimals { margin-top: 8px; display: flex; gap: 8px; flex-wrap: wrap; }
        .region-info .ranimals .achip {
            background: #F5F0E8; padding: 4px 10px; border-radius: 6px;
            font-size: 13px; color: var(--text-secondary);
        }
        .region-info .achip img { width: 20px; height: 20px; vertical-align: -4px; object-fit: contain; }
        .region-info .rfoods { margin-top:4px; display:flex; gap:6px; flex-wrap:wrap; }
        .region-info .level-warn {
            margin-top:6px; padding:5px 10px; background:#FEF5F0; border-radius:6px;
            font-size:12px; color:var(--accent-red); display:inline-block;
        }
        .region-action { flex-shrink: 0; text-align: center; min-width: 110px; }
        .region-action .btn { width: 100%; }
        .locked-req { font-size: 11px; color: var(--text-muted); margin-top: 4px; }

        /* Modal */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(60,40,20,0.4); z-index: 200;
            align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }
        .modal {
            background: var(--card-bg); border-radius: var(--radius-lg); padding: 28px;
            max-width: 440px; width: 90%; border: 1px solid var(--border);
            box-shadow: var(--shadow-lg); animation: fadeIn 0.2s ease;
        }
        .modal h3 { color: var(--text); font-size: 18px; margin-bottom: 4px; text-align: center; font-weight: 600; }
        .modal .modal-sub { color: var(--text-secondary); font-size: 13px; text-align: center; margin-bottom: 16px; }
        .modal .pet-list { display: flex; flex-direction: column; gap: 8px; max-height: 300px; overflow-y: auto; margin-bottom: 16px; }
        .modal .pet-option {
            display: flex; align-items: center; gap: 12px; padding: 12px 14px;
            border: 1px solid var(--border-light); border-radius: var(--radius);
            cursor: pointer; transition: all var(--transition);
        }
        .modal .pet-option:hover { border-color: #C5B8A0; background: #FAF7F0; }
        .modal .pet-option.selected { border-color: var(--accent-warm); background: #FDF5EC; }
        .modal .pet-option .po-img { width: 44px; height: 44px; object-fit: contain; flex-shrink: 0; background: #F5F0E8; border-radius: 6px; }
        .modal .pet-option .po-info { flex:1; min-width:0; }
        .modal .pet-option .po-name { font-size: 14px; font-weight: 600; color: var(--text); }
        .modal .pet-option .po-meta { font-size: 11px; color: var(--text-secondary); margin-top: 1px; }
        .modal .pet-option .po-level {
            background: var(--accent-warm); color: #fff; padding: 3px 10px;
            border-radius: 10px; font-size: 12px; font-weight: 600; flex-shrink: 0;
        }
        .modal .btn-row { display: flex; gap: 10px; }
        .modal .btn { flex:1; padding: 12px; font-size: 14px; }
        .btn-cancel { background: #F5F0E8; color: var(--text-secondary); border-color: var(--border-light); }
        .btn-confirm { background: var(--accent-warm); color: #fff; border-color: var(--accent-warm); font-weight: 600; }
        .btn-confirm:disabled { background: #D5C8B5; border-color: #D5C8B5; cursor: not-allowed; }
        .btn-cancel:hover { background: #EDE5D8; }

        @media (max-width: 768px) {
            .region-row { flex-direction: column; text-align: center; }
            .region-action { width: 100%; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">
            <img src="<%= request.getContextPath() %>/assets/images/ui/logo.png" alt="logo" onerror="this.style.display='none'">
            宠物乐园
        </a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard">我的宠物</a>
            <a href="<%= request.getContextPath() %>/map" class="active">世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia">图鉴</a>
            <a href="<%= request.getContextPath() %>/help">帮助</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="page-header">
            <h1>世界探索</h1>
            <p>培养宠物提升等级 · 收集物种解锁新大陆 · 已解锁 <%= unlockedCount %> / <%= allRegions.size() %> 个区域</p>
        </div>

        <% if (exploreError != null) { %><div class="alert alert-error"><%= exploreError %></div><% } %>
        <% String encounterResult = (String) request.getAttribute("encounterResult");
           if (encounterResult != null) { %>
        <div class="alert alert-info"><%= encounterResult %></div>
        <% } %>
        <% String newRegionMsg = (String) request.getAttribute("newRegionMsg");
           if (newRegionMsg != null) { %>
        <div class="alert alert-success"><%= newRegionMsg %></div>
        <% } %>

        <!-- 解锁提示 -->
        <% if (!locked.isEmpty() && canUnlock) { %>
        <div class="unlock-hint">
            <div>
                <div class="hint-text">你已满足解锁新区域的条件</div>
                <div class="hint-req">解锁下一个区域：<%= unlockReqText %></div>
            </div>
        </div>
        <% } else if (!locked.isEmpty()) { %>
        <div class="unlock-hint" style="opacity:0.6;">
            <div>
                <div class="hint-text">解锁更多区域</div>
                <div class="hint-req">下一个区域解锁条件：<%= unlockReqText %></div>
            </div>
        </div>
        <% } %>

        <!-- 迷你世界地图 -->
        <div class="mini-map">
            <% for (PetSpecies.RegionDef rd : allRegions) {
                boolean lu = unlockedIds.contains(rd.id());
            %>
            <div class="dot <%= lu ? "" : "locked" %>"
                 style="top:<%= rd.topPct() %>%; left:<%= rd.leftPct() %>%;
                        background:<%= lu ? rd.color() : "#B0A590" %>;"></div>
            <div class="dot-label" style="top:<%= rd.topPct()-6 %>%; left:<%= rd.leftPct() %>%;
                        color:<%= lu ? "#5C4A3A" : "#B5A898" %>;">
                <%= rd.emoji() %> <%= rd.name() %>
            </div>
            <% } %>
        </div>

        <!-- 区域列表 -->
        <div class="region-list">
            <% for (PetSpecies.RegionDef rd : allRegions) {
                boolean isUnlocked = unlockedIds.contains(rd.id());
                boolean thisCanUnlock = !isUnlocked && canUnlock;
                List<PetSpecies> regionSpecies = new ArrayList<>();
                for (PetSpecies sp : PetSpecies.ALL) if (sp.getRegionId().equals(rd.id())) regionSpecies.add(sp);

                int regionMinLevel = 999;
                for (PetSpecies sp : regionSpecies) {
                    if (sp.getRequiredLevel() < regionMinLevel) regionMinLevel = sp.getRequiredLevel();
                }
                if (regionMinLevel == 999) regionMinLevel = 0;
                boolean levelTooLow = isUnlocked && maxPetLevel < regionMinLevel;
            %>
            <div class="region-row <%= isUnlocked ? "" : thisCanUnlock ? "can-unlock" : "locked-row" %>">
                <div class="region-icon-box" style="background:<%= rd.color() %>18; border-color:<%= rd.color() %>40;">
                    <%= rd.emoji() %>
                </div>
                <div class="region-info">
                    <div class="rname"><%= rd.name() %></div>
                    <div class="rloc"><%= rd.realLocation() %> · <%= rd.climate() %></div>
                    <div class="rdesc"><%= rd.desc() %></div>
                    <div class="ranimals">
                        <% for (PetSpecies sp : regionSpecies) { %>
                        <span class="achip">
                            <img src="<%= request.getContextPath() %>/assets/images/animals/<%= sp.getImagePath() %>"
                                 alt="<%= sp.getName() %>" onerror="this.style.display='none'">
                            <%= sp.getName() %> <small>(<%= sp.getRarityLabel() %>)</small>
                        </span>
                        <% } %>
                    </div>
                    <%
                        List<FoodDef> regionFoods = FoodDef.getFoodsByRegion(rd.name());
                        if (!regionFoods.isEmpty()) {
                    %>
                    <div class="rfoods">
                        <span style="font-size:11px;color:var(--text-muted);">可获得：</span>
                        <% for (FoodDef fd : regionFoods) { %>
                        <span style="background:#F5F0E8;padding:2px 8px;border-radius:4px;font-size:12px;color:var(--text-secondary);"><%= fd.getEmoji() %> <%= fd.getName() %></span>
                        <% } %>
                    </div>
                    <% } %>
                    <% if (!isUnlocked) { %>
                    <div class="locked-req"><%= PetSpecies.getUnlockRequirementsText(unlockedCount) %></div>
                    <% } else if (levelTooLow) { %>
                    <div class="level-warn">需要 Lv.<%= regionMinLevel %>+ 宠物才能探索（当前最高 Lv.<%= maxPetLevel %>）</div>
                    <% } %>
                </div>
                <div class="region-action">
                    <% if (isUnlocked && !levelTooLow) { %>
                    <button type="button" class="btn btn-primary"
                            onclick="openCompanionModal('<%= rd.id() %>', '<%= rd.name() %>')">探索</button>
                    <% } else if (isUnlocked && levelTooLow) { %>
                    <button class="btn" disabled>等级不够</button>
                    <% } else if (thisCanUnlock) { %>
                    <form method="post" action="<%= request.getContextPath() %>/map">
                        <input type="hidden" name="action" value="unlock_region">
                        <input type="hidden" name="region" value="<%= rd.id() %>">
                        <button type="submit" class="btn btn-green">解锁此区域</button>
                    </form>
                    <% } else { %>
                    <button class="btn" disabled>未解锁</button>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- 同行宠物选择弹窗 -->
    <div class="modal-overlay" id="companionModal">
        <div class="modal">
            <h3>选择同行宠物</h3>
            <div class="modal-sub" id="modalRegionLabel">探索区域</div>
            <div class="pet-list" id="petList">
                <% for (Pet p : userPets) {
                    String imgPath = p.getImagePath();
                    CompanionTrait ct = CompanionTrait.forPet(p);
                    String traitData = ct != null ?
                        ct.getName() + "|" + ct.getDescription() + "|" + ct.getType().label + "|" +
                        ct.getPositioning() + "|" + (ct.getHiddenTendency() != null ? ct.getHiddenTendency() : "") : "";
                %>
                <div class="pet-option" data-pet-id="<%= p.getId() %>"
                     data-trait="<%= traitData %>"
                     data-emoji="<%= p.getEmoji() %>"
                     data-name="<%= p.getName() %>"
                     data-species="<%= p.getSpecies() %>"
                     data-attr="❤<%= p.getAffinity() %> 🤝<%= p.getBond() %> Lv.<%= p.getLevel() %>"
                     onclick="selectPet(this)">
                    <img class="po-img"
                         src="<%= request.getContextPath() %>/assets/images/animals/<%= imgPath != null ? imgPath : "" %>"
                         alt="<%= p.getName() %>"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                    <span style="display:none;width:44px;height:44px;align-items:center;justify-content:center;font-size:28px;flex-shrink:0;"><%= p.getEmoji() %></span>
                    <div class="po-info">
                        <div class="po-name"><%= p.getName() %></div>
                        <div class="po-meta"><%= p.getSpecies() %> · <%= p.getPersonality() %> · ❤<%= p.getAffinity() %> 🤝<%= p.getBond() %></div>
                        <% if (ct != null) { %>
                        <div style="margin-top:2px;">
                            <span style="font-size:10px; background:#F0EDE0; color:var(--text-secondary); padding:2px 8px; border-radius:6px;">⭐ <%= ct.getName() %> · <%= ct.getPositioning() %></span>
                        </div>
                        <% } %>
                    </div>
                    <span class="po-level">Lv.<%= p.getLevel() %></span>
                </div>
                <% } %>
            </div>
            <!-- 特性详情 -->
            <div id="traitDetail" style="display:none; background:#FDF9F2; border-radius:var(--radius); padding:12px 14px; margin-bottom:12px; border:1px solid var(--border-light); animation:fadeIn 0.2s;">
                <div style="display:flex; align-items:center; gap:10px; margin-bottom:4px;">
                    <span id="tdEmoji" style="font-size:24px;"></span>
                    <div>
                        <div id="tdName" style="font-weight:600; color:var(--text); font-size:14px;"></div>
                        <div id="tdMeta" style="font-size:11px; color:var(--text-secondary);"></div>
                    </div>
                </div>
                <div id="tdTraitName" style="font-size:13px; font-weight:600; color:#6A8A5A; margin-bottom:2px;"></div>
                <div id="tdTraitDesc" style="font-size:12px; color:var(--text-secondary); line-height:1.5; margin-bottom:4px;"></div>
                <div style="display:flex; gap:6px; flex-wrap:wrap;">
                    <span id="tdType" style="font-size:10px; background:#F0F5EC; color:#6A8A5A; padding:2px 8px; border-radius:6px;"></span>
                    <span id="tdPosition" style="font-size:10px; background:#F0F4F8; color:#5A6A8A; padding:2px 8px; border-radius:6px;"></span>
                </div>
                <div id="tdHidden" style="font-size:11px; color:var(--text-muted); margin-top:2px; display:none;"></div>
            </div>
            <div class="btn-row">
                <button type="button" class="btn btn-cancel" onclick="closeModal()">取消</button>
                <button type="submit" class="btn btn-confirm" id="confirmBtn" disabled onclick="startExplore()">出发探险</button>
            </div>
        </div>
    </div>

    <form id="exploreForm" method="post" action="<%= request.getContextPath() %>/map" style="display:none;">
        <input type="hidden" name="action" value="explore">
        <input type="hidden" name="region" id="exploreRegion">
        <input type="hidden" name="companionId" id="exploreCompanionId">
    </form>

    <script>
        var selectedPetId = null;
        var currentRegionId = null;

        function openCompanionModal(regionId, regionName) {
            currentRegionId = regionId;
            selectedPetId = null;
            document.getElementById('modalRegionLabel').textContent = '前往「' + regionName + '」探险';
            document.getElementById('confirmBtn').disabled = true;
            document.querySelectorAll('#petList .pet-option').forEach(function(el) { el.classList.remove('selected'); });
            document.getElementById('traitDetail').style.display = 'none';
            document.getElementById('companionModal').classList.add('show');
        }

        function selectPet(el) {
            document.querySelectorAll('#petList .pet-option').forEach(function(e) { e.classList.remove('selected'); });
            el.classList.add('selected');
            selectedPetId = el.getAttribute('data-pet-id');
            document.getElementById('confirmBtn').disabled = false;

            var traitData = el.getAttribute('data-trait');
            var detail = document.getElementById('traitDetail');
            if (traitData) {
                var parts = traitData.split('|');
                document.getElementById('tdEmoji').textContent = el.getAttribute('data-emoji');
                document.getElementById('tdName').textContent = el.getAttribute('data-name');
                document.getElementById('tdMeta').textContent = el.getAttribute('data-species') + ' · ' + el.getAttribute('data-attr');
                document.getElementById('tdTraitName').textContent = '⭐ ' + parts[0];
                document.getElementById('tdTraitDesc').textContent = parts[1];
                document.getElementById('tdType').textContent = parts[2];
                document.getElementById('tdPosition').textContent = '定位：' + parts[3];
                if (parts[4]) {
                    document.getElementById('tdHidden').style.display = 'block';
                    document.getElementById('tdHidden').textContent = '隐藏倾向：' + parts[4];
                } else {
                    document.getElementById('tdHidden').style.display = 'none';
                }
                detail.style.display = 'block';
            } else {
                detail.style.display = 'none';
            }
        }

        function closeModal() {
            document.getElementById('companionModal').classList.remove('show');
        }

        function startExplore() {
            if (!selectedPetId || !currentRegionId) return;
            document.getElementById('exploreRegion').value = currentRegionId;
            document.getElementById('exploreCompanionId').value = selectedPetId;
            document.getElementById('exploreForm').submit();
        }

        document.getElementById('companionModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>
</body>
</html>
