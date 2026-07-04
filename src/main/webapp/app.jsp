<%-- 应用主页面，登录后的Vue单页应用入口 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园助管申请管理平台</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <style>
        [v-cloak] { display: none; }
        #app-loading { text-align:center; padding:100px 20px; color:#999; font-size:1.1em; }
    </style>
</head>
<body>
<div id="app" v-cloak>
    <router-view></router-view>
</div>
<div id="app-loading">加载中...</div>
<div id="app-error" style="display:none;text-align:center;padding:80px 20px;color:#e74c3c;">
    <h2>应用加载失败</h2>
    <p style="margin:10px 0;">请尝试刷新页面，或检查浏览器控制台（F12）查看错误详情</p>
    <pre id="error-detail" style="text-align:left;max-width:600px;margin:20px auto;background:#f8d7da;padding:15px;border-radius:4px;font-size:0.85em;overflow:auto;color:#721c24;"></pre>
</div>
<noscript>
    <div style="text-align:center;padding:100px 20px;color:#e74c3c;">
        <h2>需要启用 JavaScript</h2><p>请启用浏览器的 JavaScript 功能后刷新页面</p>
    </div>
</noscript>

<script>
window.__CONTEXT_PATH__ = '${pageContext.request.contextPath}';
window.__INITIAL_USER__ = {
    id: ${sessionScope.user.id},
    name: '<c:out value="${sessionScope.user.name}"/>',
    role: '<c:out value="${sessionScope.user.role}"/>',
    number: '<c:out value="${sessionScope.user.number}"/>',
    email: '<c:out value="${sessionScope.user.email}"/>',
    phone: '<c:out value="${sessionScope.user.phone}"/>',
    className: '<c:out value="${sessionScope.user.className}"/>',
    resumePath: '<c:out value="${sessionScope.user.resumePath}"/>',
    courseSchedulePath: '<c:out value="${sessionScope.user.courseSchedulePath}"/>'
};
console.log('[ZiXuan] User data:', window.__INITIAL_USER__);
</script>

<!-- Vue 3 CDN with fallback -->
<script src="https://unpkg.com/vue@3/dist/vue.global.prod.js"
    onerror="this.onerror=null;this.src='https://cdn.jsdelivr.net/npm/vue@3/dist/vue.global.prod.js';">
</script>
<!-- Vue Router 4 CDN with fallback -->
<script src="https://unpkg.com/vue-router@4/dist/vue-router.global.prod.js"
    onerror="this.onerror=null;this.src='https://cdn.jsdelivr.net/npm/vue-router@4/dist/vue-router.global.prod.js';">
</script>

<!-- Check if Vue loaded -->
<script>
(function() {
    if (typeof Vue === 'undefined' || typeof VueRouter === 'undefined') {
        var errEl = document.getElementById('app-error');
        var loadEl = document.getElementById('app-loading');
        var detailEl = document.getElementById('error-detail');
        if (errEl) errEl.style.display = 'block';
        if (loadEl) loadEl.style.display = 'none';
        if (detailEl) detailEl.textContent = 'Vue.js 或 Vue Router 未能加载。\n可能原因：网络无法访问 CDN\n请尝试使用 VPN 或联系管理员。';
        return;
    }
    console.log('[ZiXuan] Vue loaded OK, version:', Vue.version);
})();
</script>

<script src="${pageContext.request.contextPath}/js/app.js"
    onerror="(function(){var e=document.getElementById('app-error');var l=document.getElementById('app-loading');if(e)e.style.display='block';if(l)l.style.display='none';var d=document.getElementById('error-detail');if(d)d.textContent='app.js 加载失败，文件路径：'+this.src;})()">
</script>
</body>
</html>
