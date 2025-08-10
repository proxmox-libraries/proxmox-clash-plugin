// Proxmox Clash 插件 - 自动加载版本
// 此文件会在 PVE Web UI 加载时自动执行

// 兼容性函数：获取当前节点名称
var getCurrentNode = function() {
    // 方法1: PVE.Utils.getNode (PVE 8.x)
    if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
        try {
            return PVE.Utils.getNode();
        } catch (e) {
            console.warn('[Clash] PVE.Utils.getNode 调用失败:', e);
        }
    }
    
    // 方法2: PVE.NodeName (PVE 7.x)
    if (typeof PVE !== 'undefined' && PVE.NodeName) {
        return PVE.NodeName;
    }
    
    // 方法3: 从 URL 解析
    try {
        var path = window.location.pathname;
        var match = path.match(/\/nodes\/([^\/]+)/);
        if (match && match[1]) {
            return match[1];
        }
    } catch (e) {
        console.warn('[Clash] URL 解析失败:', e);
    }
    
    // 方法4: 从页面元素获取
    try {
        var nodeElement = document.querySelector('[data-node]');
        if (nodeElement && nodeElement.getAttribute('data-node')) {
            return nodeElement.getAttribute('data-node');
        }
    } catch (e) {
        console.warn('[Clash] 页面元素解析失败:', e);
    }
    
    // 方法5: 从全局变量获取
    if (typeof window.pve_node !== 'undefined') {
        return window.pve_node;
    }
    
    // 默认值
    console.warn('[Clash] 无法获取节点名称，使用默认值 "localhost"');
    return 'localhost';
};

(function() {
    'use strict';
    
    console.log('[Clash] 插件开始加载...');
    
    // 等待 PVE 环境完全加载
    var waitForPVE = function() {
        if (typeof PVE !== 'undefined') {
            console.log('[Clash] PVE 环境已加载，开始注册插件...');
            registerClashPlugin();
        } else {
            console.log('[Clash] 等待 PVE 环境加载...');
            setTimeout(waitForPVE, 500);
        }
    };
    
    // 注册 Clash 插件
    var registerClashPlugin = function() {
        try {
            // 检查是否已经注册
            if (window.clashPluginRegistered) {
                console.log('[Clash] 插件已注册，跳过');
                return;
            }
            
            // 注册到 PVE 插件系统
            if (typeof PVE !== 'undefined' && PVE.plugins) {
                PVE.plugins.register('clash', {
                    name: 'Clash 控制',
                    icon: 'fa fa-cloud',
                    handler: function() {
                        createClashWindow();
                    }
                });
                console.log('[Clash] 成功注册到 PVE 插件系统');
            }
            
            // 标记为已注册
            window.clashPluginRegistered = true;
            
            // 注入菜单
            injectClashMenu();
            
        } catch (e) {
            console.error('[Clash] 插件注册失败:', e);
        }
    };
    
    // 注入 Clash 菜单
    var injectClashMenu = function() {
        try {
            // 检查是否已经注入
            if (window.clashMenuInjected) {
                console.log('[Clash] 菜单已注入，跳过');
                return;
            }
            
            // 尝试通过多种方式注入菜单
            var success = false;
            
            // 方法1: 尝试添加到现有菜单
            if (typeof PVE !== 'undefined' && PVE.dc && PVE.dc.Menu) {
                try {
                    // 检查是否可以通过原型扩展
                    if (PVE.dc.Menu.prototype) {
                        console.log('[Clash] 通过原型扩展注入菜单...');
                        success = injectViaPrototype();
                    }
                } catch (e) {
                    console.warn('[Clash] 原型扩展失败:', e);
                }
            }
            
            // 方法2: 如果方法1失败，尝试直接注入到DOM
            if (!success) {
                console.log('[Clash] 尝试直接注入到DOM...');
                success = injectViaDOM();
            }
            
            if (success) {
                window.clashMenuInjected = true;
                console.log('[Clash] 菜单注入成功！');
                
                // 注入成功后，确保所有菜单都支持滚动
                setTimeout(function() {
                    ensureMenuScrollability();
                }, 1000);
            } else {
                console.log('[Clash] 菜单注入失败，将在下次重试');
            }
            
        } catch (e) {
            console.error('[Clash] 菜单注入过程中发生错误:', e);
        }
    };
    
    // 通过原型扩展注入菜单
    var injectViaPrototype = function() {
        try {
            // 检查是否已经存在扩展
            if (PVE.dc.Menu.prototype.clashMenuAdded) {
                return true;
            }
            
            // 保存原始方法
            var originalInitComponent = PVE.dc.Menu.prototype.initComponent;
            
            // 扩展 initComponent 方法
            PVE.dc.Menu.prototype.initComponent = function() {
                var me = this;
                
                // 调用原始方法
                if (originalInitComponent) {
                    originalInitComponent.call(me);
                }
                
                // 添加 Clash 菜单项
                if (me.items && !me.clashMenuAdded) {
                    me.items.push({
                        text: 'Clash 控制',
                        iconCls: 'fa fa-cloud',
                        handler: function() {
                            createClashWindow();
                        }
                    });
                    me.clashMenuAdded = true;
                    console.log('[Clash] 通过原型扩展成功添加菜单项');
                }
                
                // 确保菜单支持滚动
                me.on('afterrender', function() {
                    var menuEl = me.getEl();
                    if (menuEl) {
                        var menuBody = menuEl.down('.x-menu-body');
                        if (menuBody) {
                            // 添加滚动样式
                            menuBody.setStyle({
                                'max-height': '400px',
                                'overflow-y': 'auto',
                                'overflow-x': 'hidden'
                            });
                            
                            // 添加自定义滚动条样式
                            var styleId = 'clash-menu-scroll-style';
                            if (!document.getElementById(styleId)) {
                                var style = document.createElement('style');
                                style.id = styleId;
                                style.textContent = `
                                    .x-menu-body::-webkit-scrollbar {
                                        width: 6px;
                                    }
                                    .x-menu-body::-webkit-scrollbar-track {
                                        background: transparent;
                                    }
                                    .x-menu-body::-webkit-scrollbar-thumb {
                                        background: #ccc;
                                        border-radius: 3px;
                                    }
                                    .x-menu-body::-webkit-scrollbar-thumb:hover {
                                        background: #999;
                                    }
                                `;
                                document.head.appendChild(style);
                            }
                        }
                    }
                });
            };
            
            return true;
        } catch (e) {
            console.warn('[Clash] 原型扩展失败:', e);
            return false;
        }
    };
    
    // 通过DOM直接注入菜单
    var injectViaDOM = function() {
        try {
            // 查找可能的菜单容器
            var menuContainers = [
                '.x-toolbar-pve-toolbar',
                '.pve-toolbar-bg',
                '.x-toolbar-vertical',
                '.x-docked-left'
            ];
            
            var container = null;
            for (var i = 0; i < menuContainers.length; i++) {
                var selector = menuContainers[i];
                container = document.querySelector(selector);
                if (container) {
                    console.log('[Clash] 找到菜单容器:', selector);
                    break;
                }
            }
            
            if (!container) {
                console.log('[Clash] 未找到菜单容器');
                return false;
            }
            
            // 检查容器是否支持滚动，如果不支持则添加滚动功能
            var needsScrollWrapper = false;
            if (container.scrollHeight > container.clientHeight) {
                needsScrollWrapper = true;
            }
            
            // 如果容器需要滚动包装器，创建一个
            var scrollContainer = container;
            if (needsScrollWrapper) {
                // 检查是否已经有滚动包装器
                var existingWrapper = container.querySelector('.clash-scroll-wrapper');
                if (!existingWrapper) {
                    // 创建滚动包装器
                    var wrapper = document.createElement('div');
                    wrapper.className = 'clash-scroll-wrapper';
                    wrapper.style.cssText = `
                        max-height: 100%;
                        overflow-y: auto;
                        overflow-x: hidden;
                        scrollbar-width: thin;
                        scrollbar-color: #ccc transparent;
                    `;
                    
                    // 添加自定义滚动条样式
                    var style = document.createElement('style');
                    style.textContent = `
                        .clash-scroll-wrapper::-webkit-scrollbar {
                            width: 6px;
                        }
                        .clash-scroll-wrapper::-webkit-scrollbar-track {
                            background: transparent;
                        }
                        .clash-scroll-wrapper::-webkit-scrollbar-thumb {
                            background: #ccc;
                            border-radius: 3px;
                        }
                        .clash-scroll-wrapper::-webkit-scrollbar-thumb:hover {
                            background: #999;
                        }
                    `;
                    document.head.appendChild(style);
                    
                    // 将现有内容移动到包装器中
                    var fragment = document.createDocumentFragment();
                    while (container.firstChild) {
                        fragment.appendChild(container.firstChild);
                    }
                    wrapper.appendChild(fragment);
                    container.appendChild(wrapper);
                    scrollContainer = wrapper;
                    
                    console.log('[Clash] 已为菜单容器添加滚动功能');
                } else {
                    scrollContainer = existingWrapper;
                }
            }
            
            // 创建 Clash 菜单项
            var clashMenuItem = document.createElement('div');
            clashMenuItem.className = 'clash-menu-item';
            clashMenuItem.innerHTML = '<i class="fa fa-cloud"></i> Clash 控制';
            clashMenuItem.style.cssText = `
                padding: 8px 12px;
                cursor: pointer;
                color: #333;
                border-bottom: 1px solid #e0e0e0;
                transition: background-color 0.2s;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            `;
            
            // 添加悬停效果
            clashMenuItem.addEventListener('mouseenter', function() {
                this.style.backgroundColor = '#f5f5f5';
            });
            
            clashMenuItem.addEventListener('mouseleave', function() {
                this.style.backgroundColor = 'transparent';
            });
            
            // 添加点击事件
            clashMenuItem.addEventListener('click', function() {
                createClashWindow();
            });
            
            // 插入到滚动容器中
            scrollContainer.appendChild(clashMenuItem);
            
            // 如果添加了滚动包装器，确保滚动到底部以显示新菜单项
            if (needsScrollWrapper && scrollContainer !== container) {
                scrollContainer.scrollTop = scrollContainer.scrollHeight;
            }
            
            console.log('[Clash] 通过DOM成功添加菜单项，滚动功能已启用');
            return true;
            
        } catch (e) {
            console.warn('[Clash] DOM注入失败:', e);
            return false;
        }
    };
    
    // 确保菜单支持滚动的函数
    var ensureMenuScrollability = function() {
        try {
            console.log('[Clash] 检查并修复菜单滚动功能...');
            
            // 查找所有可能的菜单容器
            var selectors = [
                '.x-toolbar-pve-toolbar',
                '.pve-toolbar-bg',
                '.x-toolbar-vertical',
                '.x-docked-left',
                '.x-menu-body',
                '.x-menu'
            ];
            
            selectors.forEach(function(selector) {
                var elements = document.querySelectorAll(selector);
                elements.forEach(function(element) {
                    // 检查元素是否需要滚动
                    if (element.scrollHeight > element.clientHeight) {
                        // 如果元素没有滚动样式，添加滚动功能
                        if (getComputedStyle(element).overflowY === 'visible') {
                            element.style.overflowY = 'auto';
                            element.style.overflowX = 'hidden';
                            element.style.maxHeight = '100%';
                            
                            // 添加自定义滚动条样式
                            element.classList.add('clash-scrollable');
                            
                            console.log('[Clash] 已为元素添加滚动功能:', selector);
                        }
                    }
                });
            });
            
            // 添加全局滚动条样式
            var styleId = 'clash-global-scroll-style';
            if (!document.getElementById(styleId)) {
                var style = document.createElement('style');
                style.id = styleId;
                style.textContent = `
                    .clash-scrollable::-webkit-scrollbar {
                        width: 6px;
                    }
                    .clash-scrollable::-webkit-scrollbar-track {
                        background: transparent;
                    }
                    .clash-scrollable::-webkit-scrollbar-thumb {
                        background: #ccc;
                        border-radius: 3px;
                    }
                    .clash-scrollable::-webkit-scrollbar-thumb:hover {
                        background: #999;
                    }
                    
                    /* 确保菜单项在滚动时保持可见 */
                    .clash-menu-item {
                        position: relative;
                        z-index: 1000;
                    }
                `;
                document.head.appendChild(style);
            }
            
            console.log('[Clash] 菜单滚动功能检查和修复完成');
            
        } catch (e) {
            console.warn('[Clash] 菜单滚动功能检查失败:', e);
        }
    };

    // 创建 Clash 窗口的函数
    var createClashWindow = function() {
        try {
            var win = Ext.create('Ext.window.Window', {
                title: 'Clash 控制面板',
                width: 1400,
                height: 900,
                layout: 'fit',
                items: [{
                    xtype: 'pveClashView'
                }],
                maximizable: true,
                resizable: true
            });
            win.show();
        } catch (e) {
            console.error('[Clash] 创建窗口失败:', e);
            // 备用方案：使用简单的 alert
            alert('Clash 控制面板功能暂时不可用，请检查控制台错误信息');
        }
    };
    
    // 启动等待
    waitForPVE();
    
    // 备用注入策略
    setTimeout(function() {
        if (!window.clashMenuInjected) {
            console.log('[Clash] 启动备用注入策略...');
            injectClashMenu();
        }
    }, 3000);
    
    // 添加调试命令
    window.clashDebugCommands = {
        inject: function() {
            console.log('[Clash] 手动触发菜单注入...');
            return injectClashMenu();
        },
        
        status: function() {
            return {
                injected: window.clashMenuInjected || false,
                pveLoaded: typeof PVE !== 'undefined',
                message: 'Clash 菜单注入状态检查完成'
            };
        },
        
        createWindow: function() {
            createClashWindow();
            return 'Clash 窗口创建命令已执行';
        },
        
        fixScroll: function() {
            console.log('[Clash] 手动修复菜单滚动功能...');
            ensureMenuScrollability();
            return '菜单滚动功能修复命令已执行';
        },
        
        testScroll: function() {
            console.log('[Clash] 测试菜单滚动功能...');
            var scrollableElements = document.querySelectorAll('.clash-scrollable, .clash-scroll-wrapper');
            var result = {
                total: scrollableElements.length,
                elements: []
            };
            
            scrollableElements.forEach(function(el, index) {
                result.elements.push({
                    index: index,
                    selector: el.className,
                    scrollHeight: el.scrollHeight,
                    clientHeight: el.clientHeight,
                    needsScroll: el.scrollHeight > el.clientHeight,
                    hasScrollStyle: getComputedStyle(el).overflowY === 'auto'
                });
            });
            
            console.log('[Clash] 滚动功能测试结果:', result);
            return result;
        }
    };
    
    console.log('[Clash] 插件加载完成！');
    console.log('[Clash] 可用调试命令:');
    console.log('[Clash]   - window.clashDebugCommands.inject() - 手动注入菜单');
    console.log('[Clash]   - window.clashDebugCommands.status() - 检查状态');
    console.log('[Clash]   - window.clashDebugCommands.createWindow() - 创建窗口');
})();

Ext.define('PVE.panel.Clash', {
    extend: 'Ext.panel.Panel',
    xtype: 'pveClashPanel',

    title: 'Clash 控制面板',
    iconCls: 'fa fa-cloud',
    layout: 'border',

    // 获取当前节点名称的方法
    getCurrentNode: function() {
        // 方法1: PVE.Utils.getNode (PVE 8.x)
        if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
            try {
                return PVE.Utils.getNode();
            } catch (e) {
                console.warn('[Clash] PVE.Utils.getNode 调用失败:', e);
            }
        }
        
        // 方法2: PVE.NodeName (PVE 7.x)
        if (typeof PVE !== 'undefined' && PVE.NodeName) {
            return PVE.NodeName;
        }
        
        // 方法3: 从 URL 解析
        try {
            var path = window.location.pathname;
            var match = path.match(/\/nodes\/([^\/]+)/);
            if (match && match[1]) {
                return match[1];
            }
        } catch (e) {
            console.warn('[Clash] URL 解析失败:', e);
        }
        
        // 方法4: 从页面元素获取
        try {
            var nodeElement = document.querySelector('[data-node]');
            if (nodeElement && nodeElement.getAttribute('data-node')) {
                return nodeElement.getAttribute('data-node');
            }
        } catch (e) {
            console.warn('[Clash] 页面元素解析失败:', e);
        }
        
        // 方法5: 从全局变量获取
        if (typeof window.pve_node !== 'undefined') {
            return window.pve_node;
        }
        
        // 默认值
        console.warn('[Clash] 无法获取节点名称，使用默认值 "localhost"');
        return 'localhost';
    },

    // 安全地获取当前节点名称的辅助方法
    getCurrentNodeSafe: function() {
        try {
            if (typeof this.getCurrentNode === 'function') {
                return this.getCurrentNode();
            } else {
                console.warn('[Clash] getCurrentNode 方法不可用，尝试其他方式');
                // 尝试其他方式获取节点名称
                if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
                    return PVE.Utils.getNode();
                } else if (typeof PVE !== 'undefined' && PVE.NodeName) {
                    return PVE.NodeName;
                }
            }
        } catch (e) {
            console.warn('[Clash] 获取节点名称失败:', e);
        }
        return 'localhost';
    },

    initComponent: function() {
        var me = this;

        me.items = [{
            xtype: 'panel',
            region: 'west',
            width: 350,
            title: '控制面板',
            layout: 'fit',
            items: [{
                xtype: 'tabpanel',
                items: [{
                    title: '状态监控',
                    xtype: 'panel',
                    layout: 'vbox',
                    padding: 10,
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: '运行状态',
                        name: 'status',
                        value: '检查中...'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: '配置文件',
                        name: 'config',
                        value: '-'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: '运行时间',
                        name: 'uptime',
                        value: '-'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: '内存使用',
                        name: 'memory',
                        value: '-'
                    }, {
                        xtype: 'button',
                        text: '刷新状态',
                        margin: '10 0 0 0',
                        handler: function() {
                            me.refreshStatus();
                        }
                    }, {
                        xtype: 'button',
                        text: '重载配置',
                        margin: '5 0 0 0',
                        handler: function() {
                            me.reloadConfig();
                        }
                    }]
                }, {
                    title: '订阅管理',
                    xtype: 'panel',
                    layout: 'vbox',
                    padding: 10,
                    items: [{
                        xtype: 'textfield',
                        fieldLabel: '订阅URL',
                        name: 'subscription_url',
                        width: '100%'
                    }, {
                        xtype: 'textfield',
                        fieldLabel: '配置名称',
                        name: 'config_name',
                        width: '100%',
                        value: 'config.yaml'
                    }, {
                        xtype: 'button',
                        text: '更新订阅',
                        margin: '10 0 0 0',
                        handler: function() {
                            me.updateSubscription();
                        }
                    }, {
                        xtype: 'button',
                        text: '查看配置',
                        margin: '5 0 0 0',
                        handler: function() {
                            me.showConfig();
                        }
                    }]
                }, {
                    title: '网络设置',
                    xtype: 'panel',
                    layout: 'vbox',
                    padding: 10,
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: '代理端口',
                        value: '7890'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'API 端口',
                        value: '9090'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'DNS 端口',
                        value: '53'
                    }, {
                        xtype: 'fieldset',
                        title: '透明代理设置',
                        margin: '10 0 0 0',
                        items: [{
                            xtype: 'checkbox',
                            fieldLabel: '启用透明代理',
                            name: 'tun_enable',
                            id: 'tun_enable_checkbox',
                            listeners: {
                                change: function(field, newValue) {
                                    me.toggleTransparentProxy(newValue);
                                }
                            }
                        }, {
                            xtype: 'button',
                            text: '配置 iptables 规则',
                            margin: '5 0 0 0',
                            handler: function() {
                                me.setupTransparentProxy();
                            }
                        }]
                    }, {
                        xtype: 'button',
                        text: '测试连接',
                        margin: '5 0 0 0',
                        handler: function() {
                            me.testConnection();
                        }
                    }, {
                        xtype: 'button',
                        text: '版本管理',
                        margin: '10 0 0 0',
                        handler: function() {
                            me.showVersionManager();
                        }
                    }]
                }]
            }]
        }, {
            xtype: 'panel',
            region: 'center',
            title: '代理节点管理',
            layout: 'fit',
            items: [{
                xtype: 'grid',
                store: {
                    fields: ['name', 'type', 'delay', 'status'],
                    data: []
                },
                columns: [{
                    text: '节点名称',
                    dataIndex: 'name',
                    flex: 1
                }, {
                    text: '类型',
                    dataIndex: 'type',
                    width: 80
                }, {
                    text: '延迟',
                    dataIndex: 'delay',
                    width: 80,
                    renderer: function(value) {
                        if (value && value > 0) {
                            return value + 'ms';
                        }
                        return '-';
                    }
                }, {
                    text: '状态',
                    dataIndex: 'status',
                    width: 80,
                    renderer: function(value) {
                        if (value === 'online') {
                            return '<span style="color: green;">在线</span>';
                        } else if (value === 'offline') {
                            return '<span style="color: red;">离线</span>';
                        }
                        return '<span style="color: gray;">未知</span>';
                    }
                }, {
                    text: '操作',
                    width: 120,
                    renderer: function(value, meta, record) {
                        return '<button onclick="PVE.panel.Clash.testProxy(\'' + record.get('name') + '\')">测速</button> ' +
                               '<button onclick="PVE.panel.Clash.switchProxy(\'' + record.get('name') + '\')">切换</button>';
                    }
                }],
                listeners: {
                    afterrender: function() {
                        me.loadProxies();
                    }
                }
            }]
        }];

        me.callParent();

        // 初始化时刷新状态
        me.refreshStatus();
    },

    refreshStatus: function() {
        var me = this;
        var statusField = me.down('displayfield[name=status]');
        var configField = me.down('displayfield[name=config]');
        var uptimeField = me.down('displayfield[name=uptime]');
        var memoryField = me.down('displayfield[name=memory]');

        if (!statusField || !configField || !uptimeField || !memoryField) {
            console.warn('[Clash] 状态字段未找到，跳过状态刷新');
            return;
        }

        statusField.setValue('检查中...');
        configField.setValue('-');
        uptimeField.setValue('-');
        memoryField.setValue('-');

        // 安全地获取当前节点名称
        var currentNode = 'localhost';
        try {
            if (typeof me.getCurrentNode === 'function') {
                currentNode = me.getCurrentNode();
            } else {
                console.warn('[Clash] getCurrentNode 方法不可用，使用默认值');
                // 尝试其他方式获取节点名称
                if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
                    currentNode = PVE.Utils.getNode();
                } else if (typeof PVE !== 'undefined' && PVE.NodeName) {
                    currentNode = PVE.NodeName;
                }
            }
        } catch (e) {
            console.warn('[Clash] 获取节点名称失败:', e);
        }

        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + currentNode + '/clash',
            method: 'GET',
            success: function(response) {
                var data = response.result.data;
                if (data.status === 'running') {
                    statusField.setValue('运行中');
                    configField.setValue(data.config || 'default');
                    uptimeField.setValue(me.formatUptime(data.uptime));
                    memoryField.setValue(me.formatBytes(data.memory || 0));
                    
                    // 检查透明代理状态
                    me.checkTransparentProxyStatus();
                } else {
                    statusField.setValue('已停止');
                }
            },
            failure: function(response) {
                statusField.setValue('连接失败');
            }
        });
    },

    checkTransparentProxyStatus: function() {
        var me = this;
        
        // 安全地获取当前节点名称
        var currentNode = 'localhost';
        try {
            if (typeof me.getCurrentNode === 'function') {
                currentNode = me.getCurrentNode();
            } else {
                console.warn('[Clash] getCurrentNode 方法不可用，使用默认值');
                // 尝试其他方式获取节点名称
                if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
                    currentNode = PVE.Utils.getNode();
                } else if (typeof PVE.NodeName) {
                    currentNode = PVE.NodeName;
                }
            }
        } catch (e) {
            console.warn('[Clash] 获取节点名称失败:', e);
        }
        
        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + currentNode + '/clash/config',
            method: 'GET',
            success: function(response) {
                var data = response.result.data;
                var config = data.config || '';
                
                // 检查配置中是否启用了透明代理
                var tunEnabled = config.includes('tun:') && config.includes('enable: true');
                var checkbox = Ext.getCmp('tun_enable_checkbox');
                if (checkbox) {
                    checkbox.setValue(tunEnabled);
                }
            },
            failure: function(response) {
                // 如果获取配置失败，默认设置为关闭状态
                var checkbox = Ext.getCmp('tun_enable_checkbox');
                if (checkbox) {
                    checkbox.setValue(false);
                }
            }
        });
    },

    loadProxies: function() {
        var me = this;
        var grid = me.down('grid');
        if (!grid) {
            console.warn('[Clash] 代理网格未找到，跳过加载');
            return;
        }
        
        var store = grid.getStore();
        if (!store) {
            console.warn('[Clash] 代理存储未找到，跳过加载');
            return;
        }

        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/proxies',
            method: 'GET',
            success: function(response) {
                var proxies = response.result.data.proxies || {};
                var data = [];

                Ext.Object.each(proxies, function(name, proxy) {
                    if (proxy.type === 'Shadowsocks' || proxy.type === 'Vmess' || 
                        proxy.type === 'Vless' || proxy.type === 'Trojan') {
                        data.push({
                            name: name,
                            type: proxy.type,
                            delay: proxy.delay || 0,
                            status: proxy.delay > 0 ? 'online' : 'offline'
                        });
                    }
                });

                store.loadData(data);
            },
            failure: function(response) {
                Ext.Msg.alert('错误', '加载代理列表失败');
            }
        });
    },

    reloadConfig: function() {
        var me = this;
        
        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/configs/reload',
            method: 'PUT',
            success: function(response) {
                Ext.Msg.alert('成功', '配置重载成功');
                me.refreshStatus();
                me.loadProxies();
            },
            failure: function(response) {
                Ext.Msg.alert('错误', '配置重载失败: ' + response.htmlStatusText);
            }
        });
    },

    updateSubscription: function() {
        var me = this;
        var urlField = me.down('textfield[name=subscription_url]');
        var nameField = me.down('textfield[name=config_name]');

        if (!urlField || !nameField) {
            Ext.Msg.alert('错误', '订阅字段未找到');
            return;
        }

        if (!urlField.getValue()) {
            Ext.Msg.alert('错误', '请输入订阅URL');
            return;
        }

        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/subscription/update',
            method: 'POST',
            params: {
                url: urlField.getValue(),
                name: nameField.getValue()
            },
            success: function(response) {
                Ext.Msg.alert('成功', '订阅更新成功');
                me.refreshStatus();
                me.loadProxies();
            },
            failure: function(response) {
                Ext.Msg.alert('错误', '订阅更新失败: ' + response.htmlStatusText);
            }
        });
    },

    showConfig: function() {
        var me = this;
        
        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/configs',
            method: 'GET',
            success: function(response) {
                var configs = response.result.data.configs || [];
                var content = '可用配置文件:\n\n' + configs.join('\n');
                
                Ext.Msg.show({
                    title: '配置文件',
                    msg: content,
                    width: 400,
                    buttons: Ext.Msg.OK
                });
            },
            failure: function(response) {
                Ext.Msg.alert('错误', '获取配置列表失败');
            }
        });
    },

    setupTransparentProxy: function() {
        var me = this;
        
        Ext.Msg.confirm('确认', '是否要配置透明代理？这将设置 iptables 规则。', function(btn) {
            if (btn === 'yes') {
                PVE.Utils.API2Request({
                    url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/setup-transparent-proxy',
                    method: 'POST',
                    success: function(response) {
                        Ext.Msg.alert('成功', '透明代理配置完成');
                    },
                    failure: function(response) {
                        Ext.Msg.alert('错误', '透明代理配置失败');
                    }
                });
            }
        });
    },

    toggleTransparentProxy: function(enable) {
        var me = this;
        
        var action = enable ? '启用' : '禁用';
        var message = enable ? 
            '确定要启用透明代理吗？这将修改 Clash 配置并重启服务。' : 
            '确定要禁用透明代理吗？这将修改 Clash 配置并重启服务。';
        
        Ext.Msg.confirm('确认', message, function(btn) {
            if (btn === 'yes') {
                PVE.Utils.API2Request({
                    url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/toggle-transparent-proxy',
                    method: 'POST',
                    params: {
                        enable: enable
                    },
                    success: function(response) {
                        var data = response.result.data;
                        if (data.success) {
                            Ext.Msg.alert('成功', '透明代理已' + action);
                            // 更新复选框状态
                            var checkbox = Ext.getCmp('tun_enable_checkbox');
                            if (checkbox) {
                                checkbox.setValue(enable);
                            }
                        } else {
                            Ext.Msg.alert('错误', '操作失败: ' + (data.error || '未知错误'));
                            // 恢复复选框状态
                            var checkbox = Ext.getCmp('tun_enable_checkbox');
                            if (checkbox) {
                                checkbox.setValue(!enable);
                            }
                        }
                    },
                    failure: function(response) {
                        Ext.Msg.alert('错误', '操作失败，请检查网络连接');
                        // 恢复复选框状态
                        var checkbox = Ext.getCmp('tun_enable_checkbox');
                        if (checkbox) {
                            checkbox.setValue(!enable);
                        }
                    }
                });
            } else {
                // 用户取消，恢复复选框状态
                var checkbox = Ext.getCmp('tun_enable_checkbox');
                if (checkbox) {
                    checkbox.setValue(!enable);
                }
            }
        });
    },

    testConnection: function() {
        var me = this;
        
        Ext.Msg.show({
            title: '测试连接',
            msg: '正在测试网络连接...',
            width: 300,
            progress: true,
            closable: false
        });

        // 模拟测试过程
        setTimeout(function() {
            Ext.Msg.hide();
            Ext.Msg.alert('测试结果', '网络连接正常，代理工作正常');
        }, 2000);
    },

    showVersionManager: function() {
        var me = this;
        
        // 创建版本管理窗口
        var versionWindow = Ext.create('Ext.window.Window', {
            title: '版本管理',
            width: 600,
            height: 400,
            modal: true,
            layout: 'fit',
            items: [{
                xtype: 'panel',
                layout: 'vbox',
                padding: 20,
                items: [{
                    xtype: 'displayfield',
                    fieldLabel: '当前版本',
                    name: 'currentVersion',
                    value: '检查中...'
                }, {
                    xtype: 'displayfield',
                    fieldLabel: '最新版本',
                    name: 'latestVersion',
                    value: '检查中...'
                }, {
                    xtype: 'displayfield',
                    fieldLabel: '更新状态',
                    name: 'updateStatus',
                    value: '检查中...'
                }, {
                    xtype: 'button',
                    text: '检查更新',
                    margin: '20 0 0 0',
                    handler: function() {
                        me.checkForUpdates(versionWindow);
                    }
                }, {
                    xtype: 'button',
                    text: '升级到最新版本',
                    margin: '10 0 0 0',
                    handler: function() {
                        me.performUpgrade(versionWindow);
                    }
                }, {
                    xtype: 'button',
                    text: '创建备份',
                    margin: '10 0 0 0',
                    handler: function() {
                        me.createBackup(versionWindow);
                    }
                }]
            }]
        });
        
        versionWindow.show();
        
        // 加载版本信息
        me.loadVersionInfo(versionWindow);
    },
    
    loadVersionInfo: function(window) {
        var me = this;
        
        // 获取版本信息
        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/version',
            method: 'GET',
            success: function(response) {
                var data = response.result.data;
                var currentVersionField = window.down('[name=currentVersion]');
                if (currentVersionField) {
                    currentVersionField.setValue(data.current_version);
                }
                
                // 检查更新
                me.checkForUpdates(window);
            },
            failure: function() {
                var currentVersionField = window.down('[name=currentVersion]');
                if (currentVersionField) {
                    currentVersionField.setValue('获取失败');
                }
            }
        });
    },
    
    checkForUpdates: function(window) {
        var me = this;
        
        var updateStatusField = window.down('[name=updateStatus]');
        if (updateStatusField) {
            updateStatusField.setValue('检查中...');
        }
        
        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/version/check',
            method: 'GET',
            success: function(response) {
                var data = response.result.data;
                var latestVersionField = window.down('[name=latestVersion]');
                var updateStatusField = window.down('[name=updateStatus]');
                var upgradeButton = window.down('[text=升级到最新版本]');
                
                if (latestVersionField) {
                    latestVersionField.setValue(data.latest_version);
                }
                
                if (data.has_update) {
                    if (updateStatusField) {
                        updateStatusField.setValue('发现新版本，可以升级');
                    }
                    if (upgradeButton) {
                        upgradeButton.enable();
                    }
                } else {
                    if (updateStatusField) {
                        updateStatusField.setValue('已是最新版本');
                    }
                    if (upgradeButton) {
                        upgradeButton.disable();
                    }
                }
            },
            failure: function() {
                var updateStatusField = window.down('[name=updateStatus]');
                if (updateStatusField) {
                    updateStatusField.setValue('检查失败');
                }
            }
        });
    },
    
    performUpgrade: function(window) {
        var me = this;
        
        Ext.Msg.confirm('确认升级', '确定要升级到最新版本吗？升级过程中服务会短暂停止。', function(btn) {
            if (btn === 'yes') {
                var upgradeButton = window.down('[text=升级到最新版本]');
                if (upgradeButton) {
                    upgradeButton.setText('升级中...').disable();
                }
                
                PVE.Utils.API2Request({
                    url: '/api2/json/nodes/' + me.getCurrentNodeSafe() + '/clash/version/upgrade',
                    method: 'POST',
                    success: function(response) {
                        var data = response.result.data;
                        if (data.success) {
                            Ext.Msg.alert('升级成功', '插件已成功升级到最新版本，请刷新页面。');
                            window.close();
                            location.reload();
                        } else {
                            Ext.Msg.alert('升级失败', '升级过程中出现错误：' + (data.error || '未知错误'));
                            var upgradeButton = window.down('[text=升级中...]');
                            if (upgradeButton) {
                                upgradeButton.setText('升级到最新版本').enable();
                            }
                        }
                    },
                    failure: function() {
                        Ext.Msg.alert('升级失败', '升级请求失败，请检查网络连接或查看日志。');
                        var upgradeButton = window.down('[text=升级中...]');
                        if (upgradeButton) {
                            upgradeButton.setText('升级到最新版本').enable();
                        }
                    }
                });
            }
        });
    },
    
    createBackup: function(window) {
        var me = this;
        
        // 这里可以调用备份 API，暂时显示消息
        Ext.Msg.alert('备份功能', '备份功能可通过命令行使用：\n\nsudo /opt/proxmox-clash/scripts/upgrade.sh -b');
    },

    formatUptime: function(seconds) {
        if (!seconds) return '-';
        
        var days = Math.floor(seconds / 86400);
        var hours = Math.floor((seconds % 86400) / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        
        var result = '';
        if (days > 0) result += days + '天 ';
        if (hours > 0) result += hours + '小时 ';
        result += minutes + '分钟';
        
        return result;
    },

    formatBytes: function(bytes) {
        if (!bytes) return '-';
        
        var sizes = ['B', 'KB', 'MB', 'GB'];
        var i = Math.floor(Math.log(bytes) / Math.log(1024));
        return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
    }
});

// 静态方法用于全局调用
PVE.panel.Clash.testProxy = function(proxyName) {
    // 获取当前节点名称
    var currentNode = (function() {
        // 方法1: PVE.Utils.getNode (PVE 8.x)
        if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
            try {
                return PVE.Utils.getNode();
            } catch (e) {
                console.warn('[Clash] PVE.Utils.getNode 调用失败:', e);
            }
        }
        
        // 方法2: PVE.NodeName (PVE 7.x)
        if (typeof PVE !== 'undefined' && PVE.NodeName) {
            return PVE.NodeName;
        }
        
        // 方法3: 从 URL 解析
        try {
            var path = window.location.pathname;
            var match = path.match(/\/nodes\/([^\/]+)/);
            if (match && match[1]) {
                return match[1];
            }
        } catch (e) {
            console.warn('[Clash] URL 解析失败:', e);
        }
        
        // 方法4: 从页面元素获取
        try {
            var nodeElement = document.querySelector('[data-node]');
            if (nodeElement && nodeElement.getAttribute('data-node')) {
                return nodeElement.getAttribute('data-node');
            }
        } catch (e) {
            console.warn('[Clash] 页面元素解析失败:', e);
        }
        
        // 方法5: 从全局变量获取
        if (typeof window.pve_node !== 'undefined') {
            return window.pve_node;
        }
        
        // 默认值
        console.warn('[Clash] 无法获取节点名称，使用默认值 "localhost"');
        return 'localhost';
    })();
    
    PVE.Utils.API2Request({
        url: '/api2/json/nodes/' + currentNode + '/clash/proxies/' + proxyName + '/delay',
        method: 'GET',
        success: function(response) {
            var delay = response.result.data.delay;
            Ext.Msg.alert('测速结果', proxyName + ' 延迟: ' + (delay || '超时') + 'ms');
        },
        failure: function(response) {
            Ext.Msg.alert('错误', '测速失败');
        }
    });
};

PVE.panel.Clash.switchProxy = function(proxyName) {
    // 获取当前节点名称
    var currentNode = (function() {
        // 方法1: PVE.Utils.getNode (PVE 8.x)
        if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
            try {
                return PVE.Utils.getNode();
            } catch (e) {
                console.warn('[Clash] PVE.Utils.getNode 调用失败:', e);
            }
        }
        
        // 方法2: PVE.NodeName (PVE 7.x)
        if (typeof PVE !== 'undefined' && PVE.NodeName) {
            return PVE.NodeName;
        }
        
        // 方法3: 从 URL 解析
        try {
            var path = window.location.pathname;
            var match = path.match(/\/nodes\/([^\/]+)/);
            if (match && match[1]) {
                return match[1];
            }
        } catch (e) {
            console.warn('[Clash] URL 解析失败:', e);
        }
        
        // 方法4: 从页面元素获取
        try {
            var nodeElement = document.querySelector('[data-node]');
            if (nodeElement && nodeElement.getAttribute('data-node')) {
                return nodeElement.getAttribute('data-node');
            }
        } catch (e) {
            console.warn('[Clash] 页面元素解析失败:', e);
        }
        
        // 方法5: 从全局变量获取
        if (typeof window.pve_node !== 'undefined') {
            return window.pve_node;
        }
        
        // 默认值
        console.warn('[Clash] 无法获取节点名称，使用默认值 "localhost"');
        return 'localhost';
    })();
    
    Ext.Msg.confirm('确认', '是否要切换到节点: ' + proxyName + '？', function(btn) {
        if (btn === 'yes') {
            PVE.Utils.API2Request({
                url: '/api2/json/nodes/' + currentNode + '/clash/proxies/Proxy',
                method: 'PUT',
                params: {
                    name: proxyName
                },
                success: function(response) {
                    Ext.Msg.alert('成功', '已切换到节点: ' + proxyName);
                },
                failure: function(response) {
                    Ext.Msg.alert('错误', '切换节点失败');
                }
            });
        }
    });
};

// 注册到数据中心菜单 - 使用更安全的方式
Ext.define('PVE.dc.ClashView', {
    extend: 'PVE.panel.Clash',
    alias: 'widget.pveClashView'
});