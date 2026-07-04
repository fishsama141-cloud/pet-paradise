// ===== Guard =====
if (typeof Vue === 'undefined' || typeof VueRouter === 'undefined') {
    console.error('[ZiXuan] Vue or VueRouter not loaded');
    (document.getElementById('app-error')||{}).style={display:'block'};
    (document.getElementById('app-loading')||{}).style={display:'none'};
    throw new Error('Vue/VueRouter not loaded');
}

// ===== API Client =====
const API = {
    async request(url, options = {}) {
        const ctx = window.__CONTEXT_PATH__ || '';
        const fullUrl = url.startsWith('/') ? ctx + url : url;
        const headers = options.headers || {};
        if (!(options.body instanceof FormData)) {
            headers['Content-Type'] = 'application/json';
        }
        const resp = await fetch(fullUrl, { ...options, headers });
        if (resp.status === 401) { window.location.href = (window.__CONTEXT_PATH__||'')+'/login.jsp'; throw new Error('未登录'); }
        const text = await resp.text();
        let result;
        try { result = JSON.parse(text); }
        catch (e) {
            console.error('[ZiXuan] Non-JSON from', fullUrl, ':', text.substring(0,200));
            throw new Error('服务器错误，URL: '+fullUrl+'，响应: '+text.substring(0,150));
        }
        if (result.code !== 200) throw new Error(result.message || '请求失败');
        return result;
    },
    get(url) { return this.request(url); },
    post(url, data) { return this.request(url, { method:'POST', body: data instanceof FormData ? data : JSON.stringify(data) }); },
    put(url, data) { return this.request(url, { method:'PUT', body: JSON.stringify(data) }); },
    del(url) { return this.request(url, { method:'DELETE' }); },
    upload(url, formData) { return this.request(url, { method:'POST', body: formData }); }
};

// ===== Toast System =====
const Toast = {
    toasts: Vue.reactive([]),
    _id: 0,
    show(message, type) {
        type = type || 'success';
        var id = ++this._id;
        this.toasts.push({ id: id, message: message, type: type });
        setTimeout(function() {
            var idx = Toast.toasts.findIndex(function(t) { return t.id === id; });
            if (idx >= 0) Toast.toasts.splice(idx, 1);
        }, 3500);
    },
    success(msg) { this.show(msg, 'success'); },
    error(msg) { this.show(msg, 'error'); },
    warning(msg) { this.show(msg, 'warning'); }
};

// ===== Icons (inline SVG strings) =====
var I = {
    dashboard: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>',
    briefcase: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/><circle cx="12" cy="14" r="2"/><path d="M10 14H6.5"/><path d="M17.5 14H14"/></svg>',
    user: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 00-16 0"/></svg>',
    calendar: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>',
    clipboard: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="8" y="2" width="8" height="4" rx="1"/><path d="M16 4h2a2 2 0 012 2v14a2 2 0 01-2 2H6a2 2 0 01-2-2V6a2 2 0 012-2h2"/></svg>',
    users: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="7" r="3"/><path d="M1 20v-1a7 7 0 017-7h2a7 7 0 017 7v1"/><circle cx="17" cy="7" r="3"/><path d="M23 20v-1a5 5 0 00-2-4"/></svg>',
    clock: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>',
    pin: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>',
    check: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>',
    xmark: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>',
    plus: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>',
    trash: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4a1 1 0 011-1h4a1 1 0 011 1v2"/></svg>',
    edit: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>',
    bell: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>',
    logout: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>',
    graduation: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10l-10-5-10 5 10 5 10-5z"/><path d="M6 12v5c0 2 2.7 4 6 4s6-2 6-4v-5"/></svg>',
    upload: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>',
    mail: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M22 4l-10 7L2 4"/></svg>',
    file: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>',
    settings: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>',
    menu: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>',
    sparkles: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3l2 4 4 0.5-3 3 1 4.5-4-2.5-4 2.5 1-4.5-3-3 4-0.5z"/></svg>',
    book: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>'
};

// ===== Reusable Components =====

// StatCard
var StatCard = {
    props: ['label','value','hint','accent'],
    template: '\
    <div class="card stat-card">\
        <div class="stat-card-inner">\
            <div>\
                <div class="stat-label">{{ label }}</div>\
                <div class="stat-value">{{ value }}</div>\
                <div v-if="hint" class="stat-hint">{{ hint }}</div>\
            </div>\
            <div :class="\'stat-icon \'+(accent||\'primary\')" v-html="I[accent||\'primary\']||I.dashboard"></div>\
        </div>\
    </div>'
};

// StatusBadge
var StatusBadge = {
    props: ['status'],
    computed: {
        cls: function() {
            return 'badge badge-' + (this.status === 'pending' ? 'pending' : this.status === 'approved' ? 'approved' : 'rejected');
        },
        label: function() {
            return this.status === 'pending' ? '待审批' : this.status === 'approved' ? '已通过' : '已拒绝';
        }
    },
    template: '<span :class="cls">{{ label }}</span>'
};

// ProgressBar
var ProgressBar = {
    props: ['value','max','color'],
    computed: {
        pct: function() { return this.max > 0 ? Math.round(this.value/this.max*100) : 0; }
    },
    template: '<div class="progress"><div :class="\'progress-bar \'+(color||\'\')" :style="{width:pct+\'%\'}"></div></div>'
};

// Avatar
var Avatar = {
    props: ['name'],
    template: '<div class="user-avatar">{{ (name||"?")[0] }}</div>'
};

// Tabs
var TabsComponent = {
    props: ['tabs','active'],
    emits: ['select'],
    template: '\
    <div class="tabs">\
        <div class="tabs-list">\
            <button v-for="t in tabs" :key="t.key" :class="\'tabs-trigger \'+(active===t.key?\'active\':\'\')" @click="$emit(\'select\',t.key)">\
                {{ t.label }}<span v-if="t.count!==undefined" class="tabs-count">({{ t.count }})</span>\
            </button>\
        </div>\
    </div>'
};

// Modal
var ModalComponent = {
    props: ['title','description','showFooter'],
    emits: ['close'],
    template: '\
    <teleport to="body">\
        <div class="modal-overlay" @click.self="$emit(\'close\')">\
            <div class="modal">\
                <div class="modal-header">\
                    <div><h3>{{ title }}</h3><p v-if="description">{{ description }}</p></div>\
                    <button class="modal-close" @click="$emit(\'close\')" v-html="I.xmark"></button>\
                </div>\
                <div class="modal-body"><slot></slot></div>\
                <div v-if="showFooter!==false" class="modal-footer"><slot name="footer"></slot></div>\
            </div>\
        </div>\
    </teleport>'
};

// ===== Toast Container =====
var ToastContainer = {
    setup: function() {
        return { toasts: Toast.toasts, I: I };
    },
    methods: {
        remove: function(id) {
            var idx = this.toasts.findIndex(function(t) { return t.id === id; });
            if (idx >= 0) this.toasts.splice(idx, 1);
        }
    },
    template: '\
    <div class="toast-container">\
        <div v-for="t in toasts" :key="t.id" :class="\'toast \'+t.type">\
            <span class="toast-icon" v-html="t.type===\'success\'?I.check:t.type===\'error\'?I.xmark:I.check"></span>\
            <span class="toast-msg">{{ t.message }}</span>\
            <button class="toast-close" @click="remove(t.id)" v-html="I.xmark"></button>\
        </div>\
    </div>'
};

// ===== AppSidebar =====
var AppSidebar = {
    inject: ['user'],
    props: ['view','open'],
    emits: ['navigate','toggle'],
    computed: {
        isStudent: function() { return this.user.role === 'student'; },
        navItems: function() {
            return this.isStudent ? [
                { key: 'dashboard', label: '数据总览', icon: 'dashboard' },
                { key: 'positions', label: '岗位浏览', icon: 'briefcase' },
                { key: 'profile', label: '我的页面', icon: 'user' },
                { key: 'work', label: '排班与任务', icon: 'calendar' }
            ] : [
                { key: 'dashboard', label: '管理总览', icon: 'dashboard' },
                { key: 'positions', label: '岗位管理', icon: 'clipboard' },
                { key: 'applications', label: '申请审批', icon: 'users' },
                { key: 'work', label: '排班管理', icon: 'calendar' }
            ];
        }
    },
    methods: {
        nav: function(key) { this.$emit('navigate', key); if (window.innerWidth <= 768) this.$emit('toggle', false); }
    },
    template: '\
    <div>\
        <div :class="\'sidebar-overlay \'+(open?\'show\':\'\')" @click="$emit(\'toggle\',false)"></div>\
        <aside :class="\'sidebar \'+(open?\'open\':\'\')">\
            <div class="sidebar-header">\
                <div class="sidebar-logo-icon" v-html="I.graduation"></div>\
                <div class="sidebar-logo-text">\
                    <div class="brand">ZiXuan</div>\
                    <div class="subtitle">校园助理管理平台</div>\
                </div>\
            </div>\
            <div class="sidebar-content">\
                <div class="sidebar-group">\
                    <div class="sidebar-group-label">{{ isStudent ? \'学生工作台\' : \'教师工作台\' }}</div>\
                    <div class="sidebar-menu">\
                        <button v-for="item in navItems" :key="item.key"\
                            :class="\'sidebar-menu-btn \'+(view===item.key?\'active\':\'\')" @click="nav(item.key)">\
                            <span class="icon" v-html="I[item.icon]"></span>\
                            {{ item.label }}\
                        </button>\
                    </div>\
                </div>\
            </div>\
            <div class="sidebar-footer">\
                <div class="sidebar-progress-card">\
                    <div class="title">欢迎使用</div>\
                    <div class="desc">{{ isStudent ? \'浏览岗位，提交申请\' : \'管理岗位，审核申请\' }}</div>\
                </div>\
            </div>\
        </aside>\
    </div>'
};

// ===== TopNavbar =====
var TopNavbar = {
    inject: ['user'],
    props: ['sidebarOpen'],
    emits: ['toggle-sidebar','switch-role'],
    data: function() {
        return { showUserMenu: false, showNotif: false };
    },
    computed: {
        isStudent: function() { return this.user.role === 'student'; },
        initials: function() { return (this.user.name||'?')[0]; },
        subtitle: function() {
            return this.isStudent ? (this.user.className || '学生') : '教师';
        }
    },
    methods: {
        toggleRole: function(role) {
            if (role !== this.user.role) this.$emit('switch-role', role);
        },
        logout: async function() {
            await API.post('/api/logout');
            window.location.href = (window.__CONTEXT_PATH__||'') + '/login.jsp';
        },
        closeMenus: function(e) {
            if (!this.$el.contains(e.target)) { this.showUserMenu = false; this.showNotif = false; }
        }
    },
    mounted: function() {
        document.addEventListener('click', this.closeMenus);
    },
    beforeUnmount: function() {
        document.removeEventListener('click', this.closeMenus);
    },
    template: '\
    <header class="topnav">\
        <div class="topnav-left">\
            <button class="sidebar-trigger" @click="$emit(\'toggle-sidebar\',!sidebarOpen)" v-html="I.menu"></button>\
            <div class="topnav-brand">\
                <div class="topnav-brand-icon" v-html="I.graduation"></div>\
                <span>ZiXuan</span>\
            </div>\
        </div>\
        <div class="topnav-right">\
            <div class="role-switch">\
                <button :class="isStudent?\'active\':\'\'" @click="toggleRole(\'student\')">学生</button>\
                <button :class="!isStudent?\'active\':\'\'" @click="toggleRole(\'teacher\')">教师</button>\
            </div>\
            <div style="position:relative;">\
                <button class="user-menu-btn" @click.stop="showUserMenu=!showUserMenu">\
                    <div class="user-avatar">{{ initials }}</div>\
                    <div class="user-info-text">\
                        <span class="name">{{ user.name }}</span>\
                        <span class="role-tag">{{ subtitle }}</span>\
                    </div>\
                </button>\
                <div v-if="showUserMenu" class="dropdown" @click.stop>\
                    <div style="padding:8px 12px;font-size:0.85rem;">\
                        <div style="font-weight:500;">{{ user.name }}</div>\
                        <div style="font-size:0.75rem;color:var(--muted-foreground);">{{ subtitle }}</div>\
                    </div>\
                    <div class="dropdown-divider"></div>\
                    <a :href="\'#\'+(isStudent?\'/student/profile\':\'/teacher/profile\')" class="dropdown-item" @click="showUserMenu=false">\
                        <span v-html="I.user"></span> 个人资料\
                    </a>\
                    <div class="dropdown-divider"></div>\
                    <button class="dropdown-item danger" @click="logout">\
                        <span v-html="I.logout"></span> 退出登录\
                    </button>\
                </div>\
            </div>\
        </div>\
    </header>'
};

// ===== DashboardShell (Root Layout) =====
var DashboardShell = {
    inject: ['user'],
    data: function() {
        return { sidebarOpen: false };
    },
    methods: {
        switchRole: function(role) {
            if (role === this.user.role) return;
            var currentRoute = this.$route.path;
            this.user.role = role;
            if (role === 'student') {
                if (currentRoute.startsWith('/teacher/')) this.$router.push('/student/dashboard');
            } else {
                if (currentRoute.startsWith('/student/')) this.$router.push('/teacher/dashboard');
            }
        }
    },
    template: '\
    <div class="app-layout">\
        <app-sidebar :view="currentView" :open="sidebarOpen" @navigate="navigateTo" @toggle="v=>sidebarOpen=v"></app-sidebar>\
        <div class="main-area">\
            <top-navbar :sidebar-open="sidebarOpen" @toggle-sidebar="v=>sidebarOpen=v" @switch-role="switchRole"></top-navbar>\
            <main class="content">\
                <div class="content-inner">\
                    <router-view></router-view>\
                </div>\
            </main>\
            <div class="app-footer">&copy; 2026 ZiXuan 校园助管申请管理平台</div>\
        </div>\
        <toast-container></toast-container>\
    </div>',
    computed: {
        currentView: function() {
            var p = this.$route.path;
            if (p.includes('/dashboard')) return 'dashboard';
            if (p.includes('/positions')) return 'positions';
            if (p.includes('/profile')) return 'profile';
            if (p.includes('/work')) return 'work';
            if (p.includes('/applications')) return 'applications';
            return 'dashboard';
        }
    },
    methods: {
        navigateTo: function(key) {
            var role = this.user.role;
            this.$router.push('/'+role+'/'+key);
        }
    }
};

// ===== Student Components =====

// StudentDashboard
var StudentDashboard = {
    inject: ['user'],
    data: function() {
        return { loading: true, error: null, schedules: [], tasks: [], applications: [] };
    },
    computed: {
        pendingTasks: function() { return (this.tasks||[]).filter(function(t){return t.status==='pending';}).slice(0,4); },
        recentApps: function() { return (this.applications||[]).slice(0,3); },
        taskDone: function() { var t=this.tasks||[]; return t.length?t.filter(function(x){return x.status==='completed';}).length:0; },
        taskPct: function() { var t=this.tasks||[]; return t.length?Math.round(this.taskDone/t.length*100):0; }
    },
    async mounted() {
        try {
            var w = await API.get('/api/student/work');
            this.schedules = w.data.schedules || [];
            this.tasks = w.data.tasks || [];
            var a = await API.get('/api/student/applications');
            this.applications = a.data || [];
        } catch(e) { this.error = e.message; }
        finally { this.loading = false; }
    },
    template: '\
    <div>\
        <div class="page-header"><h1>数据总览</h1><p>欢迎回来，{{ user.name }}！查看你的助管工作概览。</p></div>\
        <div v-if="error" class="alert alert-danger">{{ error }}</div>\
        <div v-if="loading" class="loading">加载中...</div>\
        <div v-else>\
            <div class="stat-grid">\
                <stat-card label="申请总数" :value="applications.length" hint="累计提交的岗位申请" accent="primary"></stat-card>\
                <stat-card label="已通过" :value="applications.filter(function(a){return a.status==\'approved\';}).length" hint="审核通过的申请" accent="emerald"></stat-card>\
                <stat-card label="本周排班" :value="schedules.length" hint="当前排班次数" accent="sky"></stat-card>\
                <stat-card label="任务完成" :value="taskDone+\'/\'+tasks.length" :hint="\'完成率 \'+taskPct+\'%\'" accent="amber"></stat-card>\
            </div>\
            <div class="grid-2">\
                <div class="card">\
                    <div class="card-header"><h3>待办任务</h3></div>\
                    <div class="card-body">\
                        <div v-if="!pendingTasks.length" style="color:var(--muted-foreground);text-align:center;padding:20px;">太棒了，暂无待办任务！</div>\
                        <div v-for="t in pendingTasks" :key="t.id" style="display:flex;align-items:center;gap:10px;padding:8px 0;border-bottom:1px solid var(--border);">\
                            <span v-html="I.clock" style="color:var(--muted-foreground);flex-shrink:0;"></span>\
                            <div style="flex:1;"><div style="font-weight:500;font-size:0.875rem;">{{ t.title }}</div><div style="font-size:0.75rem;color:var(--muted-foreground);">{{ t.deadline }} &middot; {{ t.location }}</div></div>\
                            <span class="badge badge-pending">待处理</span>\
                        </div>\
                    </div>\
                </div>\
                <div class="card">\
                    <div class="card-header"><h3>我的申请</h3></div>\
                    <div class="card-body">\
                        <div v-if="!recentApps.length" style="color:var(--muted-foreground);text-align:center;padding:20px;">暂无申请记录</div>\
                        <div v-for="a in recentApps" :key="a.id" style="display:flex;align-items:center;gap:10px;padding:8px 0;border-bottom:1px solid var(--border);">\
                            <span v-html="I.file" style="color:var(--muted-foreground);flex-shrink:0;"></span>\
                            <div style="flex:1;"><div style="font-size:0.875rem;">{{ a.positionTitle||\'岗位\' }}</div><div style="font-size:0.75rem;color:var(--muted-foreground);">{{ formatDate(a.appliedAt) }}</div></div>\
                            <status-badge :status="a.status"></status-badge>\
                        </div>\
                    </div>\
                </div>\
            </div>\
        </div>\
    </div>',
    methods: {
        formatDate: function(d) { return d ? new Date(d).toLocaleDateString('zh-CN') : ''; }
    }
};

// StudentPositions
var StudentPositions = {
    inject: ['user'],
    data: function() {
        return { loading: true, error: null, positions: [], applications: [], showModal: false, activeJob: null, reason: '', files: [], submitting: false };
    },
    async mounted() {
        try {
            this.positions = (await API.get('/api/student/positions')).data || [];
            this.applications = (await API.get('/api/student/applications')).data || [];
        } catch(e) { this.error = e.message; }
        finally { this.loading = false; }
    },
    computed: {
        appliedIds: function() {
            var self = this;
            var set = {};
            (this.applications||[]).forEach(function(a) { set[a.positionId] = true; });
            return set;
        },
        canApply: function() {
            var self = this;
            return function(job) {
                if (self.appliedIds[job.id]) return false;
                if ((job.currentCount||0) >= job.maxStudents) return false;
                return true;
            };
        },
        btnLabel: function() {
            var self = this;
            return function(job) {
                if (self.appliedIds[job.id]) return '已申请';
                if ((job.currentCount||0) >= job.maxStudents) return '名额已满';
                return '立即申请';
            };
        }
    },
    methods: {
        openApply: function(job) {
            this.activeJob = job;
            this.reason = '';
            this.files = [{file:null}];
            this.showModal = true;
        },
        removeFile: function(i) { this.files.splice(i, 1); },
        addFile: function() { this.files.push({file:null}); },
        submitApply: async function() {
            if (!this.reason || this.reason.trim().length < 3) { Toast.warning('请填写申请理由（至少3个字）'); return; }
            this.submitting = true;
            try {
                var fd = new FormData();
                fd.append('positionId', this.activeJob.id);
                fd.append('reason', this.reason.trim());
                (this.files||[]).forEach(function(f) { if (f.file) fd.append('attachmentFiles', f.file); });
                await API.upload('/api/student/apply', fd);
                Toast.success('申请已提交！');
                this.showModal = false;
                this.applications = (await API.get('/api/student/applications')).data || [];
            } catch(e) { Toast.error(e.message); }
            finally { this.submitting = false; }
        }
    },
    template: '\
    <div>\
        <div class="page-header"><h1>岗位浏览</h1><p>浏览所有开放的校园助管岗位，选择心仪的岗位提交申请。</p></div>\
        <div v-if="error" class="alert alert-danger">{{ error }}</div>\
        <div v-if="loading" class="loading">加载中...</div>\
        <div v-else class="job-grid">\
            <div v-for="job in positions" :key="job.id" class="card job-card">\
                <div class="card-body">\
                    <div class="job-card-header">\
                        <div class="job-card-title">{{ job.title }}</div>\
                        <badge :status="(job.currentCount||0)>=job.maxStudents?\'rejected\':\'approved\'" :label="(job.currentCount||0)>=job.maxStudents?\'名额已满\':\'招募中\'"></badge>\
                    </div>\
                    <div class="job-meta"><span>{{ job.teacherName }}</span><span>&middot;</span><span v-html="I.pin" style="display:inline-flex;vertical-align:middle;"></span><span>{{ job.location }}</span></div>\
                    <div class="job-desc">{{ job.description }}</div>\
                    <div v-if="job.requirements" class="job-requirements"><strong>要求：</strong>{{ job.requirements }}</div>\
                    <div class="job-progress">\
                        <span>{{ job.currentCount||0 }}/{{ job.maxStudents }} 人</span>\
                        <progress-bar :value="job.currentCount||0" :max="job.maxStudents" :color="(job.currentCount||0)>=job.maxStudents?\'emerald\':\'sky\'"></progress-bar>\
                    </div>\
                </div>\
                <div class="card-footer">\
                    <button class="btn btn-primary btn-full" :disabled="!canApply(job)" @click="openApply(job)">{{ btnLabel(job) }}</button>\
                </div>\
            </div>\
            <div v-if="!positions.length" class="empty-state"><div class="empty-icon" v-html="I.briefcase"></div><h4>暂无岗位</h4><p>目前没有开放的助管岗位</p></div>\
        </div>\
        <modal-component v-if="showModal" :title="\'申请：\'+(activeJob?activeJob.title:\'\')" description="填写申请理由并提交申请材料" @close="showModal=false">\
            <div class="form-group"><label>申请理由 *</label><textarea v-model="reason" placeholder="请详细说明你申请这个岗位的理由..." rows="4"></textarea></div>\
            <div class="form-group"><label>附件（可选）</label>\
                <div v-for="(f,i) in files" :key="i" style="display:flex;gap:8px;margin-bottom:8px;">\
                    <input type="file" @change="e=>files[i].file=e.target.files[0]" style="flex:1;">\
                    <button type="button" class="btn btn-danger-ghost btn-sm" @click="removeFile(i)">移除</button>\
                </div>\
                <button type="button" class="btn btn-outline btn-sm" @click="addFile">+ 添加附件</button>\
            </div>\
            <template #footer>\
                <button class="btn btn-outline" @click="showModal=false">取消</button>\
                <button class="btn btn-primary" :disabled="submitting" @click="submitApply">{{ submitting ? \'提交中...\' : \'提交申请\' }}</button>\
            </template>\
        </modal-component>\
    </div>'
};

// StudentProfile
var StudentProfile = {
    inject: ['user'],
    data: function() {
        return {
            profile: {}, applications: [], loading: true, error: null,
            editing: false, editForm: {}, saving: false
        };
    },
    async mounted() {
        try {
            var r = await API.get('/api/student/profile');
            this.profile = r.data.profile || r.data;
            this.applications = r.data.applications || [];
        } catch(e) { this.error = e.message; }
        finally { this.loading = false; }
    },
    methods: {
        startEdit: function() { this.editForm = Object.assign({}, this.profile); this.editing = true; },
        cancelEdit: function() { this.editing = false; },
        saveProfile: async function() {
            this.saving = true;
            try {
                var r = await API.put('/api/student/profile', this.editForm);
                this.profile = r.data;
                Toast.success('个人信息已更新');
                this.editing = false;
            } catch(e) { Toast.error(e.message); }
            finally { this.saving = false; }
        },
        statusClass: function(s) { return 'badge-' + (s==='pending'?'pending':s==='approved'?'approved':'rejected'); },
        statusLabel: function(s) { return s==='pending'?'审核中':s==='approved'?'已录取':'已拒绝'; },
        formatDate: function(d) { return d ? new Date(d).toLocaleDateString('zh-CN') : ''; }
    },
    template: '\
    <div>\
        <div class="page-header"><h1>我的页面</h1><p>管理个人信息、简历和课表文件。</p></div>\
        <div v-if="error" class="alert alert-danger">{{ error }}</div>\
        <div v-if="loading" class="loading">加载中...</div>\
        <div v-else class="grid-profile">\
            <div class="card">\
                <div class="card-body" style="text-align:center;">\
                    <avatar :name="profile.name" style="width:64px;height:64px;font-size:1.5em;margin:0 auto 12px;"></avatar>\
                    <div style="font-size:1.1rem;font-weight:600;">{{ profile.name }}</div>\
                    <div style="font-size:0.85rem;color:var(--muted-foreground);">{{ profile.number }}</div>\
                    <span class="badge badge-secondary" style="margin-top:8px;">学生</span>\
                </div>\
                <div class="separator"></div>\
                <div class="card-body">\
                    <div v-if="!editing">\
                        <div class="info-list">\
                            <div class="info-row"><span class="info-label" v-html="I.book"></span><span>班级</span><span class="info-value">{{ profile.className }}</span></div>\
                            <div class="info-row"><span class="info-label" v-html="I.mail"></span><span>邮箱</span><span class="info-value">{{ profile.email }}</span></div>\
                            <div class="info-row"><span class="info-label" v-html="I.settings"></span><span>手机</span><span class="info-value">{{ profile.phone }}</span></div>\
                        </div>\
                        <button class="btn btn-outline btn-full" style="margin-top:12px;" @click="startEdit">编辑资料</button>\
                    </div>\
                    <div v-else>\
                        <div class="form-group"><label>姓名</label><input v-model="editForm.name"></div>\
                        <div class="form-group"><label>学号</label><input v-model="editForm.number"></div>\
                        <div class="form-group"><label>班级</label><input v-model="editForm.className"></div>\
                        <div class="form-group"><label>邮箱</label><input v-model="editForm.email" type="email"></div>\
                        <div class="form-group"><label>手机</label><input v-model="editForm.phone"></div>\
                        <div style="display:flex;gap:8px;">\
                            <button class="btn btn-success btn-full" :disabled="saving" @click="saveProfile">{{ saving?\'保存中...\':\'保存\' }}</button>\
                            <button class="btn btn-outline btn-full" @click="cancelEdit">取消</button>\
                        </div>\
                    </div>\
                </div>\
            </div>\
            <div>\
                <div class="card">\
                    <div class="card-header"><h3>我的申请</h3></div>\
                    <div class="card-body">\
                        <div v-if="!applications.length" class="empty-state" style="padding:20px;"><p>暂无申请记录</p></div>\
                        <table v-else>\
                            <thead><tr><th>岗位</th><th>理由</th><th>状态</th><th>时间</th></tr></thead>\
                            <tbody>\
                                <tr v-for="a in applications" :key="a.id">\
                                    <td>{{ a.positionTitle }}</td>\
                                    <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ a.reason }}</td>\
                                    <td><span :class="\'badge \'+statusClass(a.status)">{{ statusLabel(a.status) }}</span></td>\
                                    <td>{{ formatDate(a.appliedAt) }}</td>\
                                </tr>\
                            </tbody>\
                        </table>\
                    </div>\
                </div>\
            </div>\
        </div>\
    </div>'
};

// TeacherProfile
var TeacherProfile = {
    inject: ['user'],
    data: function() {
        return {
            profile: {}, positions: [], loading: true, error: null,
            editing: false, editForm: {}, saving: false
        };
    },
    async mounted() {
        try {
            var r = await API.get('/api/teacher/profile');
            this.profile = r.data.profile || r.data;
            this.positions = r.data.positions || [];
        } catch(e) { this.error = e.message; }
        finally { this.loading = false; }
    },
    methods: {
        startEdit: function() { this.editForm = Object.assign({}, this.profile); this.editing = true; },
        cancelEdit: function() { this.editing = false; },
        saveProfile: async function() {
            this.saving = true;
            try {
                var r = await API.put('/api/teacher/profile', this.editForm);
                this.profile = r.data;
                Toast.success('个人信息已更新');
                this.editing = false;
            } catch(e) { Toast.error(e.message); }
            finally { this.saving = false; }
        }
    },
    template: '\
    <div>\
        <div class="page-header"><h1>我的页面</h1><p>管理个人信息与岗位概览。</p></div>\
        <div v-if="error" class="alert alert-danger">{{ error }}</div>\
        <div v-if="loading" class="loading">加载中...</div>\
        <div v-else class="grid-profile">\
            <div class="card">\
                <div class="card-body" style="text-align:center;">\
                    <avatar :name="profile.name" style="width:64px;height:64px;font-size:1.5em;margin:0 auto 12px;"></avatar>\
                    <div style="font-size:1.1rem;font-weight:600;">{{ profile.name }}</div>\
                    <div style="font-size:0.85rem;color:var(--muted-foreground);">{{ profile.number }}</div>\
                    <span class="badge badge-secondary" style="margin-top:8px;">教师</span>\
                </div>\
                <div class="separator"></div>\
                <div class="card-body">\
                    <div v-if="!editing">\
                        <div class="info-list">\
                            <div class="info-row"><span class="info-label" v-html="I.mail"></span><span>邮箱</span><span class="info-value">{{ profile.email }}</span></div>\
                            <div class="info-row"><span class="info-label" v-html="I.settings"></span><span>手机</span><span class="info-value">{{ profile.phone }}</span></div>\
                        </div>\
                        <button class="btn btn-outline btn-full" style="margin-top:12px;" @click="startEdit">编辑资料</button>\
                    </div>\
                    <div v-else>\
                        <div class="form-group"><label>姓名</label><input v-model="editForm.name"></div>\
                        <div class="form-group"><label>工号</label><input v-model="editForm.number"></div>\
                        <div class="form-group"><label>邮箱</label><input v-model="editForm.email" type="email"></div>\
                        <div class="form-group"><label>手机</label><input v-model="editForm.phone"></div>\
                        <div style="display:flex;gap:8px;">\
                            <button class="btn btn-success btn-full" :disabled="saving" @click="saveProfile">{{ saving?\'保存中...\':\'保存\' }}</button>\
                            <button class="btn btn-outline btn-full" @click="cancelEdit">取消</button>\
                        </div>\
                    </div>\
                </div>\
            </div>\
            <div class="card">\
                <div class="card-header"><h3>我发布的岗位</h3></div>\
                <div class="card-body">\
                    <div v-if="!positions.length" class="empty-state" style="padding:20px;">暂未发布岗位，<a :href="\'#/teacher/positions\'">去发布</a></div>\
                    <div v-for="p in positions" :key="p.id" style="background:#f8f9fa;border-radius:8px;padding:18px;margin-bottom:15px;border-left:4px solid #3498db;">\
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">\
                            <strong style="font-size:1.1em;color:#2c3e50;">{{ p.title }}</strong>\
                            <span style="font-size:0.9em;">\
                                录取 {{ (p.approvedStudents||[]).length }}/{{ p.maxStudents }} 人\
                                <span :class="\'badge \'+(p.status===\'open\'?\'badge-approved\':\'badge-rejected\')">{{ p.status===\'open\'?\'招募中\':\'已关闭\' }}</span>\
                            </span>\
                        </div>\
                        <p style="color:#666;font-size:0.9em;margin-bottom:8px;">{{ p.description }}</p>\
                        <div v-if="p.approvedStudents&&p.approvedStudents.length" style="display:flex;flex-wrap:wrap;gap:8px;">\
                            <span style="color:#555;font-weight:600;">已录取学生：</span>\
                            <span v-for="a in p.approvedStudents" :key="a.id" style="background:#d4edda;color:#155724;padding:3px 10px;border-radius:12px;font-size:0.85em;">{{ a.studentName }}</span>\
                        </div>\
                        <div v-else><span style="color:#999;font-size:0.85em;">暂未录取学生</span></div>\
                    </div>\
                </div>\
            </div>\
        </div>\
    </div>'
};

// StudentWork
var StudentWork = {
    inject: ['user'],
    data: function() {
        return { loading: true, error: null, schedules: [], tasks: [], weekDays: ['周一','周二','周三','周四','周五','周六','周日'] };
    },
    async mounted() {
        try {
            var w = await API.get('/api/student/work');
            this.schedules = w.data.schedules || [];
            this.tasks = w.data.tasks || [];
        } catch(e) { this.error = e.message; }
        finally { this.loading = false; }
    },
    methods: {
        getDayShifts: function(day) {
            var self = this;
            return (this.schedules||[]).filter(function(s) { return s.weekDay === day; });
        },
        toggleTask: async function(task) {
            var newStatus = task.status === 'completed' ? 'pending' : 'completed';
            try {
                await API.put('/api/student/tasks/'+task.id+'/status', { status: newStatus });
                task.status = newStatus;
                Toast.success(newStatus==='completed'?'任务已完成':'已标记为待处理');
            } catch(e) { Toast.error(e.message); }
        },
        taskFileDownloadUrl: function(t) { return (window.__CONTEXT_PATH__||'')+'/api/file/download?file='+encodeURIComponent(t.filePath||''); }
    },
    template: `
    <div>
        <div class="page-header"><h1>排班与任务</h1><p>查看你的每周排班和待完成任务。</p></div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="loading" class="loading">加载中...</div>
        <div v-else>
            <div class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3>本周排班</h3></div>
                <div class="card-body">
                    <div class="week-grid">
                        <div v-for="day in weekDays" :key="day" class="day-card">
                            <div class="day-name">{{ day }}</div>
                            <template v-for="s in getDayShifts(day)">
                                <div class="shift-block">
                                    <div class="shift-time">{{ s.timeSlot }}</div>
                                    <div style="font-size:0.75rem;">{{ s.positionTitle||'' }}</div>
                                    <div class="shift-loc">{{ s.location }}</div>
                                </div>
                            </template>
                            <div v-if="!getDayShifts(day).length" class="day-empty">休息</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="card">
                <div class="card-header"><h3>任务清单</h3><span style="font-size:0.8rem;color:var(--muted-foreground);">{{ tasks.filter(function(t){return t.status==='completed';}).length }}/{{ tasks.length }} 已完成</span></div>
                <div class="card-body">
                    <div v-if="!tasks.length" class="empty-state" style="padding:24px;"><p>暂无任务</p></div>
                    <div v-for="t in tasks" :key="t.id" class="task-item-wrapper" style="border-bottom:1px solid var(--border);padding:12px 0;">
                        <div :class="'task-item '+(t.status==='completed'?'completed':'')" @click="toggleTask(t)" style="border:none;padding:0;margin-bottom:0;">
                            <input type="checkbox" :checked="t.status==='completed'" @click.stop="toggleTask(t)">
                            <div class="task-info">
                                <div class="task-title">{{ t.title }}</div>
                                <div class="task-meta">{{ t.deadline }} &middot; {{ t.location }}</div>
                            </div>
                            <span :class="'badge '+(t.status==='completed'?'badge-approved':'badge-pending')">{{ t.status==='completed'?'已完成':'待处理' }}</span>
                        </div>
                        <div v-if="t.description" style="font-size:0.8rem;color:var(--muted-foreground);margin:4px 0 0 28px;">{{ t.description }}</div>
                        <div v-if="t.filePath" style="margin:4px 0 0 28px;">
                            <a :href="taskFileDownloadUrl(t)" style="font-size:0.8rem;color:var(--primary);">📎 下载任务附件</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>`
};

// ===== Teacher Components =====

// TeacherDashboard
var TeacherDashboard = {
    inject: ['user'],
    data: function() {
        return { loading: true, error: null, positions: [], schedules: [], tasks: [], applications: [] };
    },
    computed: {
        pendingApps: function() { return (this.applications||[]).filter(function(a){return a.status==='pending';}).slice(0,5); },
        totalSlots: function() { return (this.positions||[]).reduce(function(s,p){return s+(p.maxStudents||0);},0); },
        filledSlots: function() { return (this.positions||[]).reduce(function(s,p){return s+(p.currentCount||0);},0); },
        slotPct: function() { return this.totalSlots?Math.round(this.filledSlots/this.totalSlots*100):0; }
    },
    async mounted() {
        try {
            var r = await API.get('/api/teacher/work');
            this.positions = r.data.positions || [];
            this.schedules = r.data.schedules || [];
            this.tasks = r.data.tasks || [];
            var apps = [];
            for (var i=0; i<this.positions.length; i++) {
                try {
                    var ar = await API.get('/api/teacher/students/applications?positionId='+this.positions[i].id);
                    apps = apps.concat(ar.data.applications||[]);
                } catch(e) {}
            }
            this.applications = apps;
        } catch(e) { this.error = e.message; }
        finally { this.loading = false; }
    },
    template: '\
    <div>\
        <div class="page-header"><h1>管理总览</h1><p>掌握岗位发布、申请审批与排班的整体情况。</p></div>\
        <div v-if="error" class="alert alert-danger">{{ error }}</div>\
        <div v-if="loading" class="loading">加载中...</div>\
        <div v-else>\
            <div class="stat-grid">\
                <stat-card label="在招岗位" :value="positions.length" hint="当前发布的岗位数" accent="primary"></stat-card>\
                <stat-card label="待审批" :value="applications.filter(function(a){return a.status===\'pending\';}).length" hint="等待审核的申请" accent="amber"></stat-card>\
                <stat-card label="名额使用" :value="filledSlots+\'/\'+totalSlots" :hint="\'使用率 \'+slotPct+\'%\'" accent="emerald"></stat-card>\
                <stat-card label="本周排班" :value="schedules.length" hint="排班总次数" accent="sky"></stat-card>\
            </div>\
            <div class="grid-2">\
                <div class="card">\
                    <div class="card-header"><h3>最新申请</h3><span style="font-size:0.8rem;color:var(--muted-foreground);">等待你审批的学生申请</span></div>\
                    <div class="card-body">\
                        <div v-if="!pendingApps.length" style="color:var(--muted-foreground);text-align:center;padding:20px;">暂无待审批申请</div>\
                        <div v-for="a in pendingApps" :key="a.id" class="app-item" style="border:none;margin-bottom:0;">\
                            <avatar :name="a.studentName" style="width:36px;height:36px;font-size:0.8em;"></avatar>\
                            <div class="app-info">\
                                <div class="app-student">{{ a.studentName }}</div>\
                                <div class="app-job">申请：{{ a.positionTitle }}</div>\
                            </div>\
                            <status-badge :status="a.status"></status-badge>\
                        </div>\
                    </div>\
                </div>\
                <div class="card">\
                    <div class="card-header"><h3>岗位招募进度</h3><span style="font-size:0.8rem;color:var(--muted-foreground);">各岗位名额录用情况</span></div>\
                    <div class="card-body">\
                        <div v-for="p in positions.slice(0,5)" :key="p.id" class="recruit-item">\
                            <div class="recruit-info">\
                                <div class="recruit-title">{{ p.title }}</div>\
                                <div class="recruit-count">{{ p.currentCount||0 }}/{{ p.maxStudents }}</div>\
                            </div>\
                            <progress-bar :value="p.currentCount||0" :max="p.maxStudents" :color="((p.currentCount||0)>=p.maxStudents)?\'emerald\':\'sky\'" style="width:120px;"></progress-bar>\
                        </div>\
                        <div v-if="!positions.length" style="color:var(--muted-foreground);text-align:center;padding:20px;">暂无岗位</div>\
                    </div>\
                </div>\
            </div>\
        </div>\
    </div>'
};

// TeacherPositions
var TeacherPositions = {
    inject: ['user'],
    data: function() {
        return {
            loading: true, error: null, positions: [],
            showModal: false, editingJob: null,
            form: { title:'', department:'', location:'', maxStudents:1, requirements:'', description:'' },
            submitting: false,
            showDelete: false, deleteTarget: null
        };
    },
    async mounted() { await this.loadData(); },
    methods: {
        async loadData() {
            this.loading = true;
            try { this.positions = (await API.get('/api/teacher/positions')).data || []; }
            catch(e) { this.error = e.message; }
            finally { this.loading = false; }
        },
        openCreate: function() {
            this.editingJob = null;
            this.form = { title:'', department:'', location:'', maxStudents:1, requirements:'', description:'' };
            this.showModal = true;
        },
        openEdit: function(job) {
            this.editingJob = job;
            this.form = {
                title: job.title, department: job.department||'',
                location: job.location, maxStudents: job.maxStudents,
                requirements: job.requirements||'', description: job.description||''
            };
            this.showModal = true;
        },
        confirmDelete: function(job) { this.deleteTarget = job; this.showDelete = true; },
        doDelete: async function() {
            try {
                await API.del('/api/teacher/positions/'+this.deleteTarget.id);
                Toast.success('岗位已删除');
                this.showDelete = false;
                await this.loadData();
            } catch(e) { Toast.error(e.message); }
        },
        submitForm: async function() {
            if (!this.form.title || !this.form.department) { Toast.warning('请填写岗位名称和所属部门'); return; }
            this.submitting = true;
            try {
                var payload = {
                    title: this.form.title, department: this.form.department||'',
                    description: this.form.description||'',
                    requirements: this.form.requirements||'', location: this.form.location||'',
                    maxStudents: parseInt(this.form.maxStudents) > 0 ? parseInt(this.form.maxStudents) : 1, status: 'open'
                };
                if (this.editingJob) {
                    await API.put('/api/teacher/positions/'+this.editingJob.id, payload);
                    Toast.success('岗位已更新');
                } else {
                    await API.post('/api/teacher/positions', payload);
                    Toast.success('岗位已发布');
                }
                this.showModal = false;
                await this.loadData();
            } catch(e) { Toast.error(e.message); }
            finally { this.submitting = false; }
        }
    },
    template: '\
    <div>\
        <div class="page-header" style="display:flex;justify-content:space-between;align-items:flex-start;">\
            <div><h1>岗位管理</h1><p>发布、编辑和下线勤工助学岗位。</p></div>\
            <button class="btn btn-primary" @click="openCreate"><span v-html="I.plus"></span> 发布新岗位</button>\
        </div>\
        <div v-if="error" class="alert alert-danger">{{ error }}</div>\
        <div v-if="loading" class="loading">加载中...</div>\
        <div v-else class="job-grid">\
            <div v-for="job in positions" :key="job.id" class="card job-card">\
                <div class="card-body">\
                    <div class="job-card-header">\
                        <div class="job-card-title">{{ job.title }}</div>\
                        <span class="badge badge-secondary">{{ job.teacherName }}</span>\
                    </div>\
                    <div class="job-meta"><span v-html="I.pin" style="display:inline-flex;vertical-align:middle;"></span><span>{{ job.location }}</span></div>\
                    <div class="job-desc">{{ job.description }}</div>\
                    <div class="job-progress">\
                        <span>{{ job.currentCount||0 }}/{{ job.maxStudents }} 人</span>\
                        <progress-bar :value="job.currentCount||0" :max="job.maxStudents" :color="(job.currentCount||0)>=job.maxStudents?\'emerald\':\'sky\'"></progress-bar>\
                    </div>\
                </div>\
                <div class="card-footer" style="justify-content:space-between;">\
                    <button class="btn btn-outline btn-sm" @click="openEdit(job)"><span v-html="I.edit"></span> 编辑</button>\
                    <button class="btn btn-danger-ghost btn-sm" @click="confirmDelete(job)"><span v-html="I.trash"></span></button>\
                </div>\
            </div>\
            <div v-if="!positions.length" class="empty-state" style="grid-column:1/-1;"><div class="empty-icon" v-html="I.clipboard"></div><h4>暂无岗位</h4><p>点击"发布新岗位"创建第一个岗位</p></div>\
        </div>\
        <modal-component v-if="showModal" :title="editingJob?\'编辑岗位\':\'发布新岗位\'" description="填写岗位信息，学生将在岗位浏览页看到。" @close="showModal=false">\
            <div class="form-group"><label>岗位名称 *</label><input v-model="form.title" placeholder="例：实验室管理助理"></div>\
            <div class="form-grid-2">\
                <div class="form-group"><label>所属部门 *</label><input v-model="form.department" placeholder="例：计算机学院"></div>\
                <div class="form-group"><label>招募名额</label><input v-model.number="form.maxStudents" type="number" min="1"></div>\
            </div>\
            <div class="form-group"><label>工作地点</label><input v-model="form.location" placeholder="例：信息楼 A305"></div>\
            <div class="form-group"><label>岗位要求</label><input v-model="form.requirements" placeholder="例：熟悉实验室设备操作"></div>\
            <div class="form-group"><label>岗位描述</label><textarea v-model="form.description" rows="3" placeholder="详细描述岗位职责和工作内容..."></textarea></div>\
            <template #footer>\
                <button class="btn btn-outline" @click="showModal=false">取消</button>\
                <button class="btn btn-primary" :disabled="submitting" @click="submitForm">{{ submitting?\'保存中...\':(editingJob?\'保存修改\':\'发布岗位\') }}</button>\
            </template>\
        </modal-component>\
        <modal-component v-if="showDelete" title="确认删除该岗位？" description="删除后该岗位及其所有申请记录将一并移除，此操作不可恢复。" :show-footer="true" @close="showDelete=false">\
            <template #footer>\
                <button class="btn btn-outline" @click="showDelete=false">取消</button>\
                <button class="btn btn-danger" @click="doDelete">确认删除</button>\
            </template>\
        </modal-component>\
    </div>'
};

// TeacherApplications
var TeacherApplications = {
    inject: ['user'],
    data: function() {
        return {
            loading: true, error: null, applications: [], positions: [],
            activeTab: 'pending'
        };
    },
    computed: {
        tabs: function() {
            var apps = this.applications;
            return [
                { key: 'pending', label: '待审批', count: apps.filter(function(a){return a.status==='pending';}).length },
                { key: 'approved', label: '已通过', count: apps.filter(function(a){return a.status==='approved';}).length },
                { key: 'rejected', label: '已拒绝', count: apps.filter(function(a){return a.status==='rejected';}).length },
                { key: 'all', label: '全部' }
            ];
        },
        filteredApps: function() {
            var self = this;
            return this.applications.filter(function(a) {
                return self.activeTab === 'all' || a.status === self.activeTab;
            });
        }
    },
    async mounted() {
        try {
            this.positions = (await API.get('/api/teacher/positions')).data || [];
            var apps = [];
            for (var i=0; i<this.positions.length; i++) {
                try {
                    var ar = await API.get('/api/teacher/students/applications?positionId='+this.positions[i].id);
                    var list = ar.data.applications || [];
                    apps = apps.concat(list);
                } catch(e) {}
            }
            this.applications = apps;
        } catch(e) { this.error = e.message; }
        finally { this.loading = false; }
    },
    methods: {
        setStatus: async function(app, status) {
            try {
                await API.put('/api/teacher/applications/'+app.id+'/status', { status: status });
                app.status = status;
                Toast.success(status==='approved'?'已通过该申请':'已拒绝该申请');
            } catch(e) { Toast.error(e.message); }
        },
        onTabSelect: function(v) { this.activeTab = v; },
        formatDate: function(d) { return d ? new Date(d).toLocaleDateString('zh-CN') : ''; },
        fileDownloadUrl: function(f) { return (window.__CONTEXT_PATH__||'')+'/api/file/download?file='+encodeURIComponent(f.filePath); }
    },
    template: `
    <div>
        <div class="page-header"><h1>申请审批</h1><p>审核学生的岗位申请，通过或拒绝。</p></div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="loading" class="loading">加载中...</div>
        <div v-else>
            <tabs-component :tabs="tabs" :active="activeTab" @select="onTabSelect"></tabs-component>
            <div v-if="!filteredApps.length" class="empty-state">
                <div class="empty-icon" v-html="I.file"></div>
                <h4>暂无申请</h4>
                <p>当前分类下还没有相关的学生申请记录。</p>
            </div>
            <div v-for="a in filteredApps" :key="a.id" class="app-item" style="flex-wrap:wrap;">
                <avatar :name="a.studentName"></avatar>
                <div class="app-info" style="flex:1;">
                    <div class="app-student">{{ a.studentName }} <status-badge :status="a.status"></status-badge></div>
                    <div class="app-job">申请岗位：{{ a.positionTitle }} &middot; {{ formatDate(a.appliedAt) }}</div>
                    <span v-if="a.studentNumber" style="font-size:0.8rem;color:var(--muted-foreground);margin-top:2px;">
                        学号：{{ a.studentNumber }}
                        <span v-if="a.studentClassName"> &middot; 班级：{{ a.studentClassName }}</span>
                        <span v-if="a.studentEmail"> &middot; 邮箱：{{ a.studentEmail }}</span>
                        <span v-if="a.studentPhone"> &middot; 手机：{{ a.studentPhone }}</span>
                    </span>
                    <div v-if="a.reason" class="app-reason" style="margin-top:6px;">申请理由：{{ a.reason }}</div>
                    <div v-if="a.files && a.files.length" style="margin-top:4px;">
                        <span style="font-size:0.8rem;color:var(--muted-foreground);">附件：</span>
                        <a v-for="(f,i) in a.files" :key="f.id" :href="fileDownloadUrl(f)" style="font-size:0.8rem;margin-right:8px;">{{ f.fileName }}</a>
                    </div>
                </div>
                <div v-if="a.status==='pending'" class="app-actions">
                    <button class="btn btn-success btn-sm" @click="setStatus(a,'approved')"><span v-html="I.check"></span> 通过</button>
                    <button class="btn btn-outline btn-sm" @click="setStatus(a,'rejected')"><span v-html="I.xmark"></span> 拒绝</button>
                </div>
            </div>
        </div>
    </div>`
};

// TeacherWork
var TeacherWork = {
    inject: ['user'],
    data: function() {
        return {
            loading: true, error: null,
            schedules: [], tasks: [], positions: [],
            weekDays: ['周一','周二','周三','周四','周五','周六','周日'],
            timeSlots: ['第1节 (08:30-09:15)','第2节 (09:20-10:05)','第3节 (10:10-10:55)','第4节 (11:00-11:45)','第5节 (11:50-12:35)','第6节 (14:40-15:25)','第7节 (15:30-16:15)','第8节 (16:20-17:05)','第9节 (17:10-17:55)','第10节 (18:30-19:15)','第11节 (19:20-20:05)','第12节 (20:10-20:55)'],
            showAddSchedule: false, scheduleForm: { studentId:'', positionId:'', weekDay:'周一', timeSlot:'第1节 (08:30-09:15)', location:'' },
            submittingSchedule: false,
            showTaskModal: false, taskForm: { title:'', description:'', deadline:'', location:'', studentId:'', positionId:'' }, taskFile: null, editingTask: null,
            submittingTask: false
        };
    },
    async mounted() { await this.loadData(); },
    methods: {
        async loadData() {
            this.loading = true;
            try {
                var s = await API.get('/api/teacher/schedules');
                this.schedules = s.data.schedules || [];
                this.positions = s.data.positions || [];
                var t = await API.get('/api/teacher/tasks');
                this.tasks = t.data.tasks || [];
            } catch(e) { this.error = e.message; }
            finally { this.loading = false; }
        },
        getDayShifts: function(day) {
            var self = this;
            return (this.schedules||[]).filter(function(s) { return s.weekDay === day; });
        },
        getApprovedStudents: function() {
            var set = {};
            var list = [];
            var self = this;
            (this.schedules||[]).forEach(function(s) { if (!set[s.studentId]) { set[s.studentId]=true; list.push({id:s.studentId, name:s.studentName}); } });
            return list;
        },
        getStudentsForPosition: function(posId) {
            if (!posId) return [];
            var pos = (this.positions||[]).find(function(p) { return p.id == posId; });
            if (!pos || !pos.approvedStudents) return [];
            return pos.approvedStudents.map(function(a) { return { id: a.studentId, name: a.studentName }; });
        },
        getSelectedPosition: function() {
            var pid = this.scheduleForm.positionId || this.taskForm.positionId;
            if (!pid) return null;
            return (this.positions||[]).find(function(p) { return p.id == pid; }) || null;
        },
        addSchedule: async function() {
            var f = this.scheduleForm;
            if (!f.positionId || !f.studentId || !f.timeSlot || !f.location) { Toast.warning('请填写岗位、学生、时间段和地点'); return; }
            this.submittingSchedule = true;
            try {
                await API.post('/api/teacher/schedules', {
                    positionId: parseInt(f.positionId)||0,
                    studentId: parseInt(f.studentId),
                    weekDay: f.weekDay,
                    timeSlot: f.timeSlot,
                    location: f.location
                });
                Toast.success('排班已添加');
                this.showAddSchedule = false;
                await this.loadData();
            } catch(e) { Toast.error(e.message); }
            finally { this.submittingSchedule = false; }
        },
        openTaskModal: function(task) {
            this.editingTask = task||null;
            this.taskForm = task ? { title:task.title, description:task.description||'', deadline:task.deadline||'', location:task.location||'', studentId:task.studentId||'', positionId:task.positionId||'' } : { title:'', description:'', deadline:'', location:'', studentId:'', positionId:'' };
            this.taskFile = null;
            this.showTaskModal = true;
        },
        onTaskFileChange: function(e) { this.taskFile = e.target.files[0] || null; },
        taskFileDownloadUrl: function(t) { return (window.__CONTEXT_PATH__||'')+'/api/file/download?file='+encodeURIComponent(t.filePath||''); },
        submitTask: async function() {
            if (!this.taskForm.title) { Toast.warning('请填写任务标题'); return; }
            this.submittingTask = true;
            try {
                var fd = new FormData();
                fd.append('title', this.taskForm.title);
                fd.append('description', this.taskForm.description||'');
                fd.append('location', this.taskForm.location||'');
                fd.append('deadline', this.taskForm.deadline||'');
                fd.append('studentId', parseInt(this.taskForm.studentId)||0);
                fd.append('positionId', parseInt(this.taskForm.positionId)||0);
                if (this.editingTask) fd.append('status', this.editingTask.status);
                if (this.taskFile) fd.append('taskFile', this.taskFile);
                if (this.editingTask) {
                    await API.upload('/api/teacher/tasks/'+this.editingTask.id, fd);
                    Toast.success('任务已更新');
                } else {
                    await API.upload('/api/teacher/tasks', fd);
                    Toast.success('任务已创建');
                }
                this.showTaskModal = false;
                await this.loadData();
            } catch(e) { Toast.error(e.message); }
            finally { this.submittingTask = false; }
        },
        deleteTask: async function(task) {
            if (!confirm('确定删除该任务？')) return;
            try { await API.del('/api/teacher/tasks/'+task.id); Toast.success('任务已删除'); await this.loadData(); }
            catch(e) { Toast.error(e.message); }
        },
        deleteSchedule: async function(schedule) {
            if (!confirm('确定删除该排班？')) return;
            try { await API.del('/api/teacher/schedules/'+schedule.id); Toast.success('排班已删除'); await this.loadData(); }
            catch(e) { Toast.error(e.message); }
        },
        formatDate: function(d) { return d ? new Date(d).toLocaleDateString('zh-CN') : ''; }
    },
    template: `
    <div>
        <div class="page-header" style="display:flex;justify-content:space-between;align-items:flex-start;">
            <div><h1>排班管理</h1><p>为已录用的学生安排每周值班时间，管理任务分配。</p></div>
            <div style="display:flex;gap:8px;">
                <button class="btn btn-primary" @click="showAddSchedule=true"><span v-html="I.plus"></span> 添加排班</button>
                <button class="btn btn-outline" @click="openTaskModal()"><span v-html="I.plus"></span> 新建任务</button>
            </div>
        </div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="loading" class="loading">加载中...</div>
        <div v-else>
            <div class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3>本周排班</h3></div>
                <div class="card-body">
                    <div class="week-grid">
                        <div v-for="day in weekDays" :key="day" class="day-card">
                            <div class="day-name">{{ day }}</div>
                            <template v-for="s in getDayShifts(day)">
                                <div class="shift-block" style="position:relative;">
                                    <button @click="deleteSchedule(s)" style="position:absolute;top:2px;right:2px;width:16px;height:16px;border:none;background:none;color:var(--muted-foreground);cursor:pointer;font-size:12px;line-height:1;">&times;</button>
                                    <div class="shift-student">{{ s.studentName }}</div>
                                    <div class="shift-time">{{ s.timeSlot }}</div>
                                    <div class="shift-loc">{{ s.location }}</div>
                                </div>
                            </template>
                            <div v-if="!getDayShifts(day).length" class="day-empty">无排班</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="card" style="margin-bottom:24px;">
                <div class="card-header"><h3>全部排班记录</h3><span style="font-size:0.8rem;color:var(--muted-foreground);">共 {{ schedules.length }} 条排班</span></div>
                <div class="card-body">
                    <div v-if="!schedules.length" class="empty-state" style="padding:24px;"><p>暂无排班记录</p></div>
                    <div v-for="s in schedules" :key="s.id" style="display:flex;align-items:center;gap:10px;padding:8px 0;border-bottom:1px solid var(--border);font-size:0.85rem;">
                        <span style="font-weight:500;">{{ s.studentName }}</span>
                        <span style="color:var(--muted-foreground);">{{ s.weekDay }} &middot; {{ s.timeSlot }}</span>
                        <span style="color:var(--muted-foreground);">{{ s.location }}</span>
                        <span style="color:var(--muted-foreground);margin-left:auto;">{{ s.positionTitle||'' }}</span>
                        <button class="btn btn-danger-ghost btn-sm" @click="deleteSchedule(s)"><span v-html="I.trash"></span></button>
                    </div>
                </div>
            </div>
            <div class="card">
                <div class="card-header"><h3>任务列表</h3></div>
                <div class="card-body">
                    <div v-if="!tasks.length" class="empty-state" style="padding:24px;"><p>暂无任务</p></div>
                    <table v-else>
                        <thead><tr><th>任务</th><th>学生</th><th>截止日期</th><th>地点</th><th>状态</th><th>附件</th><th>操作</th></tr></thead>
                        <tbody>
                            <tr v-for="t in tasks" :key="t.id">
                                <td>{{ t.title }}</td>
                                <td>{{ t.studentName||'' }}</td>
                                <td>{{ formatDate(t.deadline) }}</td>
                                <td>{{ t.location }}</td>
                                <td><span :class="'badge '+(t.status==='completed'?'badge-approved':'badge-pending')">{{ t.status==='completed'?'已完成':'待处理' }}</span></td>
                                <td><a v-if="t.filePath" :href="taskFileDownloadUrl(t)" style="font-size:0.8rem;">📎</a></td>
                                <td>
                                    <button class="btn btn-outline btn-sm" @click="openTaskModal(t)"><span v-html="I.edit"></span></button>
                                    <button class="btn btn-danger-ghost btn-sm" style="margin-left:4px;" @click="deleteTask(t)"><span v-html="I.trash"></span></button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <modal-component v-if="showAddSchedule" title="添加排班" description="为已录用学生安排具体值班时间与任务。" @close="showAddSchedule=false">
            <div class="form-group"><label>选择岗位</label>
                <select v-model="scheduleForm.positionId" @change="scheduleForm.studentId=''">
                    <option value="">选择岗位</option>
                    <option v-for="p in positions" :key="p.id" :value="p.id">{{ p.title }} ({{ p.currentCount||0 }}/{{ p.maxStudents }}人)</option>
                </select>
            </div>
            <div class="form-group"><label>学生</label>
                <select v-model="scheduleForm.studentId">
                    <option value="">选择学生</option>
                    <option v-for="s in (scheduleForm.positionId ? getStudentsForPosition(scheduleForm.positionId) : getApprovedStudents())" :key="s.id" :value="s.id">{{ s.name }}</option>
                </select>
            </div>
            <div class="form-grid-2">
                <div class="form-group"><label>值班日</label>
                    <select v-model="scheduleForm.weekDay"><option v-for="d in weekDays" :key="d" :value="d">{{ d }}</option></select>
                </div>
                <div class="form-group"><label>节次</label>
                    <select v-model="scheduleForm.timeSlot"><option v-for="t in timeSlots" :key="t" :value="t">{{ t }}</option></select></div>
            </div>
            <div class="form-group"><label>地点</label><input v-model="scheduleForm.location" placeholder="例：信息楼 A305"></div>
            <template #footer>
                <button class="btn btn-outline" @click="showAddSchedule=false">取消</button>
                <button class="btn btn-primary" :disabled="submittingSchedule" @click="addSchedule">{{ submittingSchedule?'添加中...':'添加排班' }}</button>
            </template>
        </modal-component>
        <modal-component v-if="showTaskModal" :title="editingTask?'编辑任务':'新建任务'" @close="showTaskModal=false">
            <div class="form-group"><label>任务标题 *</label><input v-model="taskForm.title" placeholder="例：整理实验器材"></div>
            <div class="form-group"><label>任务描述</label><textarea v-model="taskForm.description" placeholder="详细描述任务内容和要求" rows="3" style="width:100%;padding:8px;border:1px solid var(--border);border-radius:6px;"></textarea></div>
            <div class="form-group"><label>关联岗位</label>
                <select v-model="taskForm.positionId" @change="taskForm.studentId=''">
                    <option value="">选择岗位</option>
                    <option v-for="p in positions" :key="p.id" :value="p.id">{{ p.title }} ({{ p.currentCount||0 }}/{{ p.maxStudents }}人)</option>
                </select>
            </div>
            <div class="form-grid-2">
                <div class="form-group"><label>截止日期</label><input v-model="taskForm.deadline" type="date"></div>
                <div class="form-group"><label>地点</label><input v-model="taskForm.location" placeholder="例：信息楼 A305"></div>
            </div>
            <div class="form-group"><label>指派学生</label>
                <select v-model="taskForm.studentId">
                    <option value="">选择学生（可选）</option>
                    <option v-for="s in (taskForm.positionId ? getStudentsForPosition(taskForm.positionId) : getApprovedStudents())" :key="s.id" :value="s.id">{{ s.name }}</option>
                </select>
            </div>
            <div class="form-group"><label>附件（可选）</label>
                <input type="file" @change="onTaskFileChange">
                <small v-if="editingTask && editingTask.filePath" style="color:var(--muted-foreground);">已有附件，选择新文件将替换</small>
            </div>
            <template #footer>
                <button class="btn btn-outline" @click="showTaskModal=false">取消</button>
                <button class="btn btn-primary" :disabled="submittingTask" @click="submitTask">{{ submittingTask?'保存中...':(editingTask?'保存修改':'创建任务') }}</button>
            </template>
        </modal-component>
    </div>`
};

// NotFound
var NotFound = {
    inject: ['user'],
    template: '\
    <div class="empty-state" style="padding:80px 20px;">\
        <div class="empty-icon" style="font-size:4em;">404</div>\
        <h4>页面未找到</h4>\
        <p style="margin:12px 0;">你访问的页面不存在。</p>\
        <a :href="\'#/\'+(user.role||\'student\')+\'/dashboard\'" class="btn btn-primary">返回首页</a>\
    </div>'
};

// ===== Router =====
var routes = [
    { path: '/', redirect: function() { return '/' + (window.__INITIAL_USER__||{}).role + '/dashboard'; } },
    { path: '/student/dashboard', component: StudentDashboard, meta: { role: 'student' } },
    { path: '/student/positions', component: StudentPositions, meta: { role: 'student' } },
    { path: '/student/apply', redirect: '/student/positions' },
    { path: '/student/profile', component: StudentProfile, meta: { role: 'student' } },
    { path: '/student/work', component: StudentWork, meta: { role: 'student' } },
    { path: '/teacher/dashboard', component: TeacherDashboard, meta: { role: 'teacher' } },
    { path: '/teacher/positions', component: TeacherPositions, meta: { role: 'teacher' } },
    { path: '/teacher/applications', component: TeacherApplications, meta: { role: 'teacher' } },
    { path: '/teacher/profile', component: TeacherProfile, meta: { role: 'teacher' } },
    { path: '/teacher/work', component: TeacherWork, meta: { role: 'teacher' } },
    { path: '/:pathMatch(.*)*', component: NotFound }
];

var router = VueRouter.createRouter({
    history: VueRouter.createWebHashHistory(),
    routes: routes
});

// ===== App Initialization =====
console.log('[ZiXuan] App init start');

var user = window.__INITIAL_USER__ || null;
if (!user) {
    window.location.href = (window.__CONTEXT_PATH__ || '') + '/login.jsp';
    throw new Error('No user');
}

console.log('[ZiXuan] User:', user.name, user.role);

try {
    router.beforeEach(function(to, from, next) {
        if (to.meta && to.meta.role && user.role !== to.meta.role) {
            next('/' + user.role + '/dashboard');
        } else {
            next();
        }
    });

    var app = Vue.createApp({});

    // Register global components
    app.component('dashboard-shell', DashboardShell);
    app.component('app-sidebar', AppSidebar);
    app.component('top-navbar', TopNavbar);
    app.component('toast-container', ToastContainer);
    app.component('stat-card', StatCard);
    app.component('status-badge', StatusBadge);
    app.component('progress-bar', ProgressBar);
    app.component('avatar', Avatar);
    app.component('tabs-component', TabsComponent);
    app.component('modal-component', ModalComponent);

    // Provide user to all components
    app.provide('user', user);

    // Make I (icons) global
    app.config.globalProperties.I = I;

    app.use(router);

    // Mount to #app with inline template
    var rootEl = document.getElementById('app');
    rootEl.innerHTML = '<dashboard-shell></dashboard-shell>';
    app.mount('#app');

    console.log('[ZiXuan] App mounted OK');

    var loadingEl = document.getElementById('app-loading');
    if (loadingEl) loadingEl.style.display = 'none';

} catch(e) {
    console.error('[ZiXuan] Init error:', e.message, e.stack);
    var errorEl = document.getElementById('app-error');
    var loadingEl = document.getElementById('app-loading');
    if (errorEl) errorEl.style.display = 'block';
    if (loadingEl) loadingEl.style.display = 'none';
    var detailEl = document.getElementById('error-detail');
    if (detailEl) detailEl.textContent = e.message || '初始化失败';
}
