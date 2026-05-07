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

    // Compute max pet level for level-check display
    int maxPetLevel = 0;
    for (Pet p : userPets) if (p.getLevel() > maxPetLevel) maxPetLevel = p.getLevel();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🗺️ 世界探索 - 宠物乐园</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
            background: linear-gradient(180deg, #1b2838 0%, #1a2a1a 40%, #1b2838 100%);
            min-height: 100vh; color: #e8dcc8;
        }
        .nav {
            background: #2d1f10; padding: 14px 28px; display: flex;
            align-items: center; justify-content: space-between;
            box-shadow: 0 4px 20px rgba(0,0,0,0.5); position: sticky; top: 0; z-index: 100;
            border-bottom: 2px solid #5a3e28;
        }
        .nav .brand { font-size: 22px; font-weight: 700; color: #f0c27a; text-decoration: none; }
        .nav-links { display: flex; gap: 10px; align-items: center; }
        .nav-links a {
            color: #d4b896; text-decoration: none; padding: 8px 16px; border-radius: 20px;
            font-weight: 600; font-size: 15px; background: rgba(255,255,255,0.08); transition: all 0.3s;
        }
        .nav-links a:hover, .nav-links a.active { background: #5a3e28; color: #f0c27a; }
        .main { max-width: 1100px; margin: 0 auto; padding: 24px 20px; }
        .page-header { text-align: center; margin-bottom: 20px; }
        .page-header h1 { font-size: 34px; color: #f0c27a; }
        .page-header p { color: #9a8a6a; font-size: 15px; margin-top: 4px; }
        .alert-error { background: #3d1010; color: #ff9090; padding: 14px 20px; border-radius: 12px; margin-bottom: 18px; font-weight: 600; font-size: 15px; border-left: 4px solid #ff5252; }
        .alert-info { background: #1a2a3d; color: #90caf9; padding: 14px 20px; border-radius: 12px; margin-bottom: 18px; font-weight: 600; font-size: 15px; border-left: 4px solid #42a5f5; white-space: pre-line; animation: fadeIn 0.5s ease; }
        .alert-success { background: #1a3a1a; color: #90c090; padding: 14px 20px; border-radius: 12px; margin-bottom: 18px; font-weight: 600; font-size: 15px; border-left: 4px solid #66bb6a; white-space: pre-line; animation: fadeIn 0.5s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .unlock-hint {
            background: linear-gradient(135deg, #2a2a10, #3a3a1a);
            border: 1px dashed #f0c27a; border-radius: 14px;
            padding: 14px 20px; margin-bottom: 20px;
            display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
        }
        .unlock-hint .hint-text { color: #f0c27a; font-weight: 600; font-size: 15px; }
        .unlock-hint .hint-req { color: #a0a060; font-size: 13px; }

        .mini-map {
            position: relative; width: 100%; max-width: 800px; margin: 0 auto 28px;
            height: 200px; background: #1a2a1a; border-radius: 16px;
            border: 3px solid #3a5a3a; overflow: hidden;
            box-shadow: 0 8px 30px rgba(0,0,0,0.5), inset 0 0 40px rgba(0,0,0,0.4);
        }
        .mini-map .dot {
            position: absolute; transform: translate(-50%, -50%);
            width: 20px; height: 20px; border-radius: 50%; border: 2px solid #fff;
            box-shadow: 0 0 10px rgba(255,255,255,0.5); transition: all 0.3s;
        }
        .mini-map .dot.locked { border-color: #666; box-shadow: none; opacity: 0.4; }
        .mini-map .dot-label {
            position: absolute; transform: translate(-50%, -50%);
            font-size: 13px; font-weight: 700; white-space: nowrap;
            text-shadow: 0 1px 3px rgba(0,0,0,0.9);
        }

        .region-list { display: flex; flex-direction: column; gap: 18px; }
        .region-row {
            display: flex; align-items: center; gap: 20px;
            background: #1e2d1e; border-radius: 18px; padding: 22px 26px;
            border: 2px solid #2a3a2a; transition: all 0.3s;
        }
        .region-row.unlocked { border-color: #4a5a3a; background: #1e2d1e; }
        .region-row.unlocked:hover { border-color: #6a8a5a; }
        .region-row.locked-row { opacity: 0.65; background: #151d15; }
        .region-row.can-unlock { opacity: 1; background: #1e2d10; border-color: #5a6a2a; }
        .region-icon-box {
            width: 72px; height: 72px; border-radius: 16px;
            display: flex; align-items: center; justify-content: center;
            font-size: 36px; flex-shrink: 0;
        }
        .region-info { flex: 1; min-width: 0; }
        .region-info .rname { font-size: 20px; font-weight: 700; color: #f0c27a; }
        .region-info .rloc { font-size: 14px; color: #8a9a7a; margin: 2px 0; }
        .region-info .rdesc { font-size: 14px; color: #a0b090; margin-top: 4px; line-height: 1.5; }
        .region-info .ranimals { margin-top: 8px; display: flex; gap: 10px; flex-wrap: wrap; }
        .region-info .ranimals .achip { background: #2a3a2a; padding: 5px 12px; border-radius: 10px; font-size: 14px; color: #c0d0b0; }
        .region-info .rfoods { margin-top:6px; display:flex; gap:8px; flex-wrap:wrap; }
        .region-info .level-warn { margin-top:8px; padding:6px 12px; background:#3a2a10; border-radius:8px; font-size:13px; color:#ffb74d; display:inline-block; }
        .region-action { flex-shrink: 0; text-align: center; min-width: 120px; }
        .btn-explore {
            display: inline-block; padding: 14px 30px; border-radius: 14px;
            font-weight: 700; font-size: 17px; cursor: pointer; transition: all 0.3s;
            color: white; font-family: inherit; border: none; text-decoration: none;
            box-shadow: 0 4px 14px rgba(0,0,0,0.3); width: 100%;
        }
        .btn-explore:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.5); }
        .btn-locked { background: #3a3a3a !important; color: #888 !important; font-size: 15px; padding: 14px 20px; cursor: not-allowed !important; }
        .btn-unlock { background: linear-gradient(135deg, #f0c27a, #d4a54a) !important; color: #3d2f10 !important; font-size: 15px; padding: 14px 20px; cursor: pointer !important; }
        .btn-unlock:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(240,194,122,0.4) !important; }
        .locked-req { font-size: 12px; color: #8a8a6a; margin-top: 4px; }

        /* Modal */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.7); z-index: 200;
            align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }
        .modal {
            background: linear-gradient(180deg, #2d2418, #3d2f1f);
            border-radius: 20px; padding: 28px; max-width: 480px; width: 90%;
            border: 2px solid #5a3e28; box-shadow: 0 20px 60px rgba(0,0,0,0.6);
            animation: modalIn 0.3s ease;
        }
        @keyframes modalIn { from { opacity:0; transform:scale(0.9); } to { opacity:1; transform:scale(1); } }
        .modal h3 { color: #f0c27a; font-size: 20px; margin-bottom: 6px; text-align: center; }
        .modal .modal-sub { color: #8a9a7a; font-size: 13px; text-align: center; margin-bottom: 18px; }
        .modal .pet-list { display: flex; flex-direction: column; gap: 10px; max-height: 360px; overflow-y: auto; margin-bottom: 18px; }
        .modal .pet-option {
            display: flex; align-items: center; gap: 14px; padding: 14px 16px;
            background: #1e2d1e; border: 2px solid #2a3a2a; border-radius: 14px;
            cursor: pointer; transition: all 0.25s;
        }
        .modal .pet-option:hover { border-color: #5a7a4a; background: #1a2a1a; }
        .modal .pet-option.selected { border-color: #f0c27a; background: #2a3520; box-shadow: 0 0 0 3px rgba(240,194,122,0.2); }
        .modal .pet-option .po-emoji { font-size: 40px; flex-shrink: 0; }
        .modal .pet-option .po-info { flex:1; min-width:0; }
        .modal .pet-option .po-name { font-size: 16px; font-weight: 700; color: #f0c27a; }
        .modal .pet-option .po-meta { font-size: 12px; color: #8a9a7a; margin-top: 2px; }
        .modal .pet-option .po-level { background: #FF8C42; color: white; padding: 4px 12px; border-radius: 12px; font-size: 14px; font-weight: 700; flex-shrink: 0; }
        .modal .btn-row { display: flex; gap: 12px; }
        .modal .btn {
            flex:1; padding: 14px; border:none; border-radius:14px;
            font-size:16px; font-weight:700; cursor:pointer; transition:all 0.3s; font-family:inherit;
        }
        .modal .btn-confirm { background: linear-gradient(135deg, #FF8C42, #FF6B6B); color: white; }
        .modal .btn-confirm:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(255,140,66,0.4); }
        .modal .btn-confirm:disabled { background: #555; color: #888; cursor: not-allowed; transform: none; box-shadow: none; }
        .modal .btn-cancel { background: #3a3a3a; color: #aaa; }
        .modal .btn-cancel:hover { background: #4a4a4a; }

        @media (max-width: 768px) {
            .region-row { flex-direction: column; text-align: center; }
            .region-action { width: 100%; }
        }
    </style>
</head>
<body>
    <nav class="nav">
        <a href="<%= request.getContextPath() %>/dashboard" class="brand">🐾 宠物乐园</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard">🏠 我的宠物</a>
            <a href="<%= request.getContextPath() %>/map" class="active">🗺️ 世界地图</a>
            <a href="<%= request.getContextPath() %>/encyclopedia">📖 图鉴</a>
            <a href="<%= request.getContextPath() %>/auth?action=logout">🚪 退出</a>
        </div>
    </nav>

    <div class="main">
        <div class="page-header">
            <h1>🗺️ 世界探索</h1>
            <p>培养宠物提升等级 · 收集物种解锁新大陆 · 已解锁 <%= unlockedCount %> / <%= allRegions.size() %> 个区域</p>
        </div>

        <% if (exploreError != null) { %><div class="alert-error"><%= exploreError %></div><% } %>
        <% String encounterResult = (String) request.getAttribute("encounterResult");
           if (encounterResult != null) { %>
        <div class="alert-info"><%= encounterResult %></div>
        <% } %>
        <% String newRegionMsg = (String) request.getAttribute("newRegionMsg");
           if (newRegionMsg != null) { %>
        <div class="alert-success"><%= newRegionMsg %></div>
        <% } %>

        <!-- Unlock hint -->
        <% if (!locked.isEmpty() && canUnlock) { %>
        <div class="unlock-hint">
            <div>
                <div class="hint-text">🔓 你已满足解锁新区域的条件！</div>
                <div class="hint-req">解锁下一个区域：<%= unlockReqText %></div>
            </div>
        </div>
        <% } else if (!locked.isEmpty()) { %>
        <div class="unlock-hint" style="opacity:0.6;">
            <div>
                <div class="hint-text">🔒 解锁更多区域</div>
                <div class="hint-req">下一个区域解锁条件：<%= unlockReqText %></div>
            </div>
        </div>
        <% } %>

        <!-- Mini world map -->
        <div class="mini-map">
            <% for (PetSpecies.RegionDef rd : allRegions) {
                boolean lu = unlockedIds.contains(rd.id());
            %>
            <div class="dot <%= lu ? "" : "locked" %>"
                 style="top:<%= rd.topPct() %>%; left:<%= rd.leftPct() %>%;
                        background:<%= lu ? rd.color() : "#555" %>;"></div>
            <div class="dot-label" style="top:<%= rd.topPct()-6 %>%; left:<%= rd.leftPct() %>%;
                        color:<%= lu ? "#f0c27a" : "#777" %>;">
                <%= rd.emoji() %> <%= rd.name() %>
            </div>
            <% } %>
        </div>

        <!-- Region list -->
        <div class="region-list">
            <% for (PetSpecies.RegionDef rd : allRegions) {
                boolean isUnlocked = unlockedIds.contains(rd.id());
                boolean thisCanUnlock = !isUnlocked && canUnlock;
                List<PetSpecies> regionSpecies = new ArrayList<>();
                for (PetSpecies sp : PetSpecies.ALL) if (sp.getRegionId().equals(rd.id())) regionSpecies.add(sp);

                // Calculate min required level for this region
                int regionMinLevel = 999;
                for (PetSpecies sp : regionSpecies) {
                    if (sp.getRequiredLevel() < regionMinLevel) regionMinLevel = sp.getRequiredLevel();
                }
                if (regionMinLevel == 999) regionMinLevel = 0;
                boolean levelTooLow = isUnlocked && maxPetLevel < regionMinLevel;
            %>
            <div class="region-row <%= isUnlocked ? "unlocked" : thisCanUnlock ? "can-unlock" : "locked-row" %>">
                <div class="region-icon-box" style="background:<%= rd.color() %>33; border:2px solid <%= rd.color() %>;">
                    <%= rd.emoji() %>
                </div>
                <div class="region-info">
                    <div class="rname"><%= rd.name() %></div>
                    <div class="rloc">📍 <%= rd.realLocation() %> · 🌡️ <%= rd.climate() %></div>
                    <div class="rdesc"><%= rd.desc() %></div>
                    <div class="ranimals">
                        <% for (PetSpecies sp : regionSpecies) { %>
                        <span class="achip"><%= sp.getEmoji() %> <%= sp.getName() %> <small>(<%= sp.getRarityLabel() %>)</small></span>
                        <% } %>
                    </div>
                    <%
                        List<FoodDef> regionFoods = FoodDef.getFoodsByRegion(rd.name());
                        if (!regionFoods.isEmpty()) {
                    %>
                    <div class="rfoods">
                        <span style="font-size:12px;color:#8a9a7a;">🎁 可获得：</span>
                        <% for (FoodDef fd : regionFoods) { %>
                        <span style="background:#2a3a1a;padding:3px 10px;border-radius:8px;font-size:13px;color:#c0d0b0;"><%= fd.getEmoji() %> <%= fd.getName() %></span>
                        <% } %>
                    </div>
                    <% } %>
                    <% if (!isUnlocked) { %>
                    <div class="locked-req">🔒 <%= PetSpecies.getUnlockRequirementsText(unlockedCount) %></div>
                    <% } else if (levelTooLow) { %>
                    <div class="level-warn">⚠️ 需要 Lv.<%= regionMinLevel %>+ 的宠物才能探索此区域（当前最高 Lv.<%= maxPetLevel %>）</div>
                    <% } %>
                </div>
                <div class="region-action">
                    <% if (isUnlocked && !levelTooLow) { %>
                    <button type="button" class="btn-explore" style="background:<%= rd.color() %>;"
                            onclick="openCompanionModal('<%= rd.id() %>', '<%= rd.name() %>')">🔍 探索</button>
                    <% } else if (isUnlocked && levelTooLow) { %>
                    <button class="btn-explore btn-locked" disabled>🔒 等级不够</button>
                    <% } else if (thisCanUnlock) { %>
                    <form method="post" action="<%= request.getContextPath() %>/map">
                        <input type="hidden" name="action" value="unlock_region">
                        <input type="hidden" name="region" value="<%= rd.id() %>">
                        <button type="submit" class="btn-explore btn-unlock">🔓 解锁此区域</button>
                    </form>
                    <% } else { %>
                    <button class="btn-explore btn-locked" disabled>🔒 未解锁</button>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Companion Selection Modal -->
    <div class="modal-overlay" id="companionModal">
        <div class="modal">
            <h3>🐾 选择同行宠物</h3>
            <div class="modal-sub" id="modalRegionLabel">探索区域</div>
            <div class="pet-list" id="petList">
                <% for (Pet p : userPets) {
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
                     data-attr="&#x2764;<%= p.getAffinity() %> &#x1F91D;<%= p.getBond() %> Lv.<%= p.getLevel() %>"
                     onclick="selectPet(this)">
                    <span class="po-emoji"><%= p.getEmoji() %></span>
                    <div class="po-info">
                        <div class="po-name"><%= p.getName() %></div>
                        <div class="po-meta"><%= p.getSpecies() %> · <%= p.getPersonality() %> · &#x2764;<%= p.getAffinity() %> &#x1F91D;<%= p.getBond() %></div>
                        <% if (ct != null) { %>
                        <div style="margin-top:3px;">
                            <span style="font-size:10px; background:#3a5a2a; color:#c0e080; padding:2px 8px; border-radius:8px; font-weight:600;">&#x2B50; <%= ct.getName() %> · <%= ct.getPositioning() %></span>
                        </div>
                        <% } %>
                    </div>
                    <span class="po-level">Lv.<%= p.getLevel() %></span>
                </div>
                <% } %>
            </div>
            <!-- Trait detail panel -->
            <div id="traitDetail" style="display:none; background:#1a2a10; border-radius:14px; padding:14px 16px; margin:8px 0; border:1px solid #3a5a2a; animation:fadeIn 0.3s;">
                <div style="display:flex; align-items:center; gap:10px; margin-bottom:6px;">
                    <span id="tdEmoji" style="font-size:28px;"></span>
                    <div>
                        <div id="tdName" style="font-weight:700; color:#f0c27a; font-size:15px;"></div>
                        <div id="tdMeta" style="font-size:12px; color:#8a9a7a;"></div>
                    </div>
                </div>
                <div id="tdTraitName" style="font-size:14px; font-weight:700; color:#c0e080; margin-bottom:4px;"></div>
                <div id="tdTraitDesc" style="font-size:12px; color:#a0b080; line-height:1.6; margin-bottom:4px;"></div>
                <div style="display:flex; gap:8px; flex-wrap:wrap;">
                    <span id="tdType" style="font-size:10px; background:#2a3a1a; color:#90c090; padding:2px 10px; border-radius:8px;"></span>
                    <span id="tdPosition" style="font-size:10px; background:#2a2a3a; color:#90a0c0; padding:2px 10px; border-radius:8px;"></span>
                </div>
                <div id="tdHidden" style="font-size:11px; color:#8090a0; margin-top:4px; display:none;"></div>
            </div>

            <div class="btn-row">
                <button type="button" class="btn btn-cancel" onclick="closeModal()">取消</button>
                <button type="submit" class="btn btn-confirm" id="confirmBtn" disabled
                        onclick="startExplore()">✅ 出发探险</button>
            </div>
        </div>
    </div>

    <!-- Hidden form for exploration -->
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

            // Show trait detail
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
                    document.getElementById('tdHidden').textContent = '🔒 隐藏倾向：' + parts[4];
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

        // Close modal on overlay click
        document.getElementById('companionModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>
</body>
</html>
