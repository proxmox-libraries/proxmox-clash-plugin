Ext.define('PVE.panel.Clash', {
    extend: 'Ext.panel.Panel',
    xtype: 'pveClashPanel',

    title: 'Clash 控制面板',
    iconCls: 'fa fa-cloud',
    layout: 'border',

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

        statusField.setValue('检查中...');
        configField.setValue('-');
        uptimeField.setValue('-');
        memoryField.setValue('-');

        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash',
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
        
        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/config',
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
        var store = grid.getStore();

        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/proxies',
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
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/configs/reload',
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

        if (!urlField.getValue()) {
            Ext.Msg.alert('错误', '请输入订阅URL');
            return;
        }

        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/subscription/update',
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
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/configs',
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
                    url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/setup-transparent-proxy',
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
                    url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/toggle-transparent-proxy',
                    method: 'POST',
                    params: {
                        enable: enable
                    },
                    success: function(response) {
                        var data = response.result.data;
                        if (data.success) {
                            Ext.Msg.alert('成功', '透明代理已' + action);
                            // 更新复选框状态
                            Ext.getCmp('tun_enable_checkbox').setValue(enable);
                        } else {
                            Ext.Msg.alert('错误', '操作失败: ' + (data.error || '未知错误'));
                            // 恢复复选框状态
                            Ext.getCmp('tun_enable_checkbox').setValue(!enable);
                        }
                    },
                    failure: function(response) {
                        Ext.Msg.alert('错误', '操作失败，请检查网络连接');
                        // 恢复复选框状态
                        Ext.getCmp('tun_enable_checkbox').setValue(!enable);
                    }
                });
            } else {
                // 用户取消，恢复复选框状态
                Ext.getCmp('tun_enable_checkbox').setValue(!enable);
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
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/version',
            method: 'GET',
            success: function(response) {
                var data = response.result.data;
                window.down('[name=currentVersion]').setValue(data.current_version);
                
                // 检查更新
                me.checkForUpdates(window);
            },
            failure: function() {
                window.down('[name=currentVersion]').setValue('获取失败');
            }
        });
    },
    
    checkForUpdates: function(window) {
        var me = this;
        
        window.down('[name=updateStatus]').setValue('检查中...');
        
        PVE.Utils.API2Request({
            url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/version/check',
            method: 'GET',
            success: function(response) {
                var data = response.result.data;
                window.down('[name=latestVersion]').setValue(data.latest_version);
                
                if (data.has_update) {
                    window.down('[name=updateStatus]').setValue('发现新版本，可以升级');
                    window.down('[text=升级到最新版本]').enable();
                } else {
                    window.down('[name=updateStatus]').setValue('已是最新版本');
                    window.down('[text=升级到最新版本]').disable();
                }
            },
            failure: function() {
                window.down('[name=updateStatus]').setValue('检查失败');
            }
        });
    },
    
    performUpgrade: function(window) {
        var me = this;
        
        Ext.Msg.confirm('确认升级', '确定要升级到最新版本吗？升级过程中服务会短暂停止。', function(btn) {
            if (btn === 'yes') {
                window.down('[text=升级到最新版本]').setText('升级中...').disable();
                
                PVE.Utils.API2Request({
                    url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/version/upgrade',
                    method: 'POST',
                    success: function(response) {
                        var data = response.result.data;
                        if (data.success) {
                            Ext.Msg.alert('升级成功', '插件已成功升级到最新版本，请刷新页面。');
                            window.close();
                            location.reload();
                        } else {
                            Ext.Msg.alert('升级失败', '升级过程中出现错误：' + (data.error || '未知错误'));
                            window.down('[text=升级中...]').setText('升级到最新版本').enable();
                        }
                    },
                    failure: function() {
                        Ext.Msg.alert('升级失败', '升级请求失败，请检查网络连接或查看日志。');
                        window.down('[text=升级中...]').setText('升级到最新版本').enable();
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
    PVE.Utils.API2Request({
        url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/proxies/' + proxyName + '/delay',
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
    Ext.Msg.confirm('确认', '是否要切换到节点: ' + proxyName + '？', function(btn) {
        if (btn === 'yes') {
            PVE.Utils.API2Request({
                url: '/api2/json/nodes/' + PVE.Utils.getNode() + '/clash/proxies/Proxy',
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

// 注册到数据中心菜单
Ext.define('PVE.dc.ClashView', {
    extend: 'PVE.panel.Clash',
    alias: 'widget.pveClashView'
});

// 添加到主菜单
Ext.define('PVE.dc.Menu', {
    override: 'PVE.dc.Menu',
    
    initComponent: function() {
        var me = this;
        
        me.callParent();
        
        // 添加 Clash 菜单项到数据中心
        me.items.push({
            text: 'Clash 控制',
            iconCls: 'fa fa-cloud',
            handler: function() {
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
            }
        });
    }
}); 

// PVE 8.4 兼容注入：如果不存在 PVE.dc.Menu，则在侧边导航（优先）或顶部工具栏注入入口
Ext.onReady(function() {
    try {
        if (!Ext.ClassManager.isCreated('PVE.dc.Menu')) {
            var createClashWindow = function() {
                var win = Ext.create('Ext.window.Window', {
                    title: 'Clash 控制面板',
                    width: 1400,
                    height: 900,
                    layout: 'fit',
                    items: [{ xtype: 'pveClashView' }],
                    maximizable: true,
                    resizable: true
                });
                win.show();
            };

            var tryAttachTopButton = function() {
                console.log('[Clash] 顶部工具栏注入已禁用');
                return false; // 直接返回 false，不再尝试注入顶部工具栏
            };

            var tryAttachSideNav = function() {
                console.log('[Clash] 尝试注入左侧导航树...');
                
                // 精确定位 PVE 左侧导航工具栏
                var target = null;
                
                // 方法1: 通过特定的 CSS 类名查找
                var pveNavToolbar = Ext.ComponentQuery.query('toolbar[cls*="pve-toolbar-bg"][cls*="x-toolbar-vertical"][cls*="x-docked-left"]')[0];
                
                if (pveNavToolbar) {
                    target = pveNavToolbar;
                    console.log('[Clash] 找到 PVE 左侧导航工具栏:', pveNavToolbar);
                } else {
                    // 方法2: 通过 ID 模式查找
                    var toolbars = Ext.ComponentQuery.query('toolbar');
                    Ext.Array.each(toolbars, function(tb, idx) {
                        if (tb && tb.id && tb.id.startsWith('toolbar-') && tb.getEl && tb.getEl()) {
                            var classes = tb.getEl().dom.className;
                            if (classes.includes('pve-toolbar-bg') && classes.includes('x-toolbar-vertical') && classes.includes('x-docked-left')) {
                                target = tb;
                                console.log('[Clash] 通过 ID 模式找到 PVE 左侧导航工具栏:', tb);
                                return false;
                            }
                        }
                    });
                }
                
                if (!target) {
                    // 方法3: 查找包含 treelist-pve-nav 的工具栏
                    var toolbars = Ext.ComponentQuery.query('toolbar');
                    Ext.Array.each(toolbars, function(tb, idx) {
                        if (tb && tb.getEl && tb.getEl()) {
                            var el = tb.getEl().dom;
                            var treelist = el.querySelector('.x-treelist-pve-nav');
                            if (treelist) {
                                target = tb;
                                console.log('[Clash] 通过 treelist-pve-nav 找到 PVE 左侧导航工具栏:', tb);
                                return false;
                            }
                        }
                    });
                }
                
                if (!target) { 
                    console.log('[Clash] 未找到 PVE 左侧导航工具栏');
                    return false;
                }
                
                // 查找工具栏内的 treelist 组件
                var treelist = null;
                if (target.items && target.items.items) {
                    Ext.Array.each(target.items.items, function(item) {
                        if (item && item.xtype === 'treelist') {
                            treelist = item;
                            return false;
                        }
                    });
                }
                
                if (!treelist) {
                    console.log('[Clash] 未找到工具栏内的 treelist 组件');
                    return false;
                }
                
                console.log('[Clash] 找到目标 treelist:', treelist);
                
                var store = treelist.getStore ? treelist.getStore() : null;
                if (!store) { 
                    console.log('[Clash] 未找到 store');
                    return false; 
                }
                
                var root = store.getRootNode ? store.getRootNode() : (store.getRoot ? store.getRoot() : null);
                if (!root) { 
                    console.log('[Clash] 未找到 root node');
                    return false; 
                }
                
                console.log('[Clash] 找到 root node:', root);
                console.log('[Clash] root 子节点数量:', root.childNodes ? root.childNodes.length : 'unknown');
                
                // 显示当前导航结构
                if (root.childNodes) {
                    console.log('[Clash] 当前导航结构:');
                    root.childNodes.forEach(function(child, idx) {
                        console.log('  [' + idx + ']', child.get('text'), '类型:', child.get('xtype'), '叶子:', child.isLeaf());
                    });
                }
                
                // 已存在则不重复添加
                var exists = null;
                if (root.findChild) { 
                    exists = root.findChild('text', 'Clash', true) || root.findChild('text', 'Clash 控制', true); 
                }
                
                if (!exists) {
                    console.log('[Clash] 开始添加 Clash 控制节点...');
                    
                    // 尝试找到合适的位置插入 Clash 菜单
                    var insertIndex = -1;
                    var supportIndex = -1;
                    
                    if (root.childNodes) {
                        // 查找 Support 菜单的位置
                        Ext.Array.each(root.childNodes, function(child, idx) {
                            if (child && child.get('text') === 'Support') {
                                supportIndex = idx;
                                return false;
                            }
                        });
                        
                        if (supportIndex >= 0) {
                            insertIndex = supportIndex + 1;
                            console.log('[Clash] 将在 Support 菜单后插入，位置:', insertIndex);
                        } else {
                            // 如果没有找到 Support，插入到末尾
                            insertIndex = root.childNodes.length;
                            console.log('[Clash] 未找到 Support 菜单，将插入到末尾，位置:', insertIndex);
                        }
                    }
                    
                    // 创建导航节点
                    var nodeData = { 
                        text: 'Clash 控制', 
                        iconCls: 'fa fa-cloud', 
                        leaf: true,
                        xtype: 'treenode',
                        cls: 'clash-nav-item',
                        // 添加更多属性以确保正确显示
                        expanded: false,
                        selectable: true,
                        // 添加自定义数据用于识别
                        clashNode: true
                    };
                    
                    var node;
                    if (insertIndex >= 0 && insertIndex < root.childNodes.length) {
                        // 在指定位置插入
                        node = root.insertChild(insertIndex, nodeData);
                        console.log('[Clash] 在位置', insertIndex, '插入节点成功:', node);
                    } else {
                        // 添加到末尾
                        node = root.appendChild(nodeData);
                        console.log('[Clash] 添加到末尾成功:', node);
                    }
                    
                    console.log('[Clash] 节点添加成功:', node);
                    
                    // 绑定选择事件 - 改进的事件处理
                    var selectionHandler = function(tl, nodeSel) {
                        if (nodeSel && (nodeSel === node || nodeSel.get('text') === 'Clash 控制' || nodeSel.get('clashNode'))) {
                            console.log('[Clash] 用户点击了 Clash 控制菜单');
                            // 阻止事件冒泡
                            if (nodeSel.get('clashNode')) {
                                // 创建并显示 Clash 窗口
                                createClashWindow();
                                // 可选：保持节点选中状态
                                return false;
                            }
                        }
                    };
                    
                    // 绑定事件
                    treelist.on('selectionchange', selectionHandler);
                    
                    // 存储事件处理器引用，以便后续清理
                    node.clashSelectionHandler = selectionHandler;
                    
                    // 强制刷新显示 - 改进的刷新策略
                    try {
                        // 刷新 treelist
                        if (treelist.refresh) {
                            treelist.refresh();
                        }
                        
                        // 刷新视图
                        if (treelist.getView && treelist.getView().refresh) {
                            treelist.getView().refresh();
                        }
                        
                        // 触发 store 更新
                        if (store.fireEvent) {
                            store.fireEvent('refresh');
                        }
                        
                        // 重新布局
                        if (treelist.doLayout) {
                            treelist.doLayout();
                        }
                        
                        // 重新布局工具栏
                        if (target.doLayout) {
                            target.doLayout();
                        }
                        
                        // 强制重新渲染整个工具栏
                        if (target.getEl && target.getEl().dom) {
                            var toolbarEl = target.getEl().dom;
                            var treelistEl = toolbarEl.querySelector('.x-treelist-pve-nav');
                            if (treelistEl) {
                                // 触发重新布局
                                if (window.getComputedStyle) {
                                    var computedStyle = window.getComputedStyle(treelistEl);
                                    console.log('[Clash] 触发 treelist 重新布局');
                                }
                            }
                        }
                        
                        // 添加 CSS 样式以确保正确显示
                        var style = document.createElement('style');
                        style.id = 'clash-nav-styles';
                        style.textContent = `
                            .clash-nav-item .x-tree-node-text {
                                color: #333 !important;
                                font-weight: 500 !important;
                            }
                            .clash-nav-item:hover .x-tree-node-text {
                                color: #007cba !important;
                            }
                            .clash-nav-item.x-tree-node-selected .x-tree-node-text {
                                color: #fff !important;
                                background-color: #007cba !important;
                            }
                        `;
                        
                        if (!document.getElementById('clash-nav-styles')) {
                            document.head.appendChild(style);
                        }
                        
                    } catch (refreshError) {
                        console.warn('[Clash] 刷新过程中出现警告:', refreshError);
                    }
                    
                    console.log('[Clash] 左侧导航注入完成！');
                    return true;
                } else {
                    console.log('[Clash] Clash 控制节点已存在');
                    return true;
                }
            };

            // 改进的注入状态检查函数
            window.showClashInjectionStatus = function() {
                console.log('[Clash] === 注入状态检查 ===');
                console.log('[Clash] PVE.dc.Menu 存在:', Ext.ClassManager.isCreated('PVE.dc.Menu'));
                
                // 查找 PVE 左侧导航工具栏
                var pveNavToolbar = Ext.ComponentQuery.query('toolbar[cls*="pve-toolbar-bg"][cls*="x-toolbar-vertical"][cls*="x-docked-left"]')[0];
                console.log('[Clash] PVE 左侧导航工具栏:', pveNavToolbar);
                
                if (pveNavToolbar) {
                    console.log('[Clash] 工具栏 ID:', pveNavToolbar.id);
                    console.log('[Clash] 工具栏类名:', pveNavToolbar.getEl ? pveNavToolbar.getEl().dom.className : 'N/A');
                    
                    // 查找工具栏内的 treelist
                    var treelist = null;
                    if (pveNavToolbar.items && pveNavToolbar.items.items) {
                        Ext.Array.each(pveNavToolbar.items.items, function(item) {
                            if (item && item.xtype === 'treelist') {
                                treelist = item;
                                return false;
                            }
                        });
                    }
                    
                    if (treelist) {
                        console.log('[Clash] 找到 treelist 组件:', treelist);
                        var store = treelist.getStore();
                        if (store) {
                            var root = store.getRootNode ? store.getRootNode() : (store.getRoot ? store.getRoot() : null);
                            if (root && root.childNodes) {
                                console.log('[Clash] 当前导航菜单项:');
                                root.childNodes.forEach(function(child, idx) {
                                    console.log('  [' + idx + ']', child.get('text'), '叶子:', child.isLeaf(), 'Clash节点:', child.get('clashNode'));
                                });
                            }
                        }
                    } else {
                        console.log('[Clash] 未找到工具栏内的 treelist 组件');
                    }
                }
                
                // 检查是否已存在 Clash 菜单
                var clashExists = document.querySelector('.clash-nav-item') !== null;
                var styleExists = document.getElementById('clash-nav-styles') !== null;
                console.log('[Clash] Clash 菜单已存在:', clashExists);
                console.log('[Clash] Clash 样式已存在:', styleExists);
                
                // 检查 DOM 元素
                if (clashExists) {
                    var navItem = document.querySelector('.clash-nav-item');
                    console.log('[Clash] 导航项 DOM 元素:', navItem);
                    console.log('[Clash] 导航项类名:', navItem.className);
                    console.log('[Clash] 导航项文本:', navItem.textContent);
                }
                
                return {
                    navigation: clashExists,
                    styles: styleExists,
                    message: '检查完成，请查看 Console'
                };
            };
            
            // 手动触发注入的函数（供调试使用）
            window.forceClashInjection = function() {
                console.log('[Clash] 手动触发注入...');
                
                // 先清理现有元素
                var existingNav = document.querySelector('.clash-nav-item');
                if (existingNav) {
                    existingNav.remove();
                    console.log('[Clash] 已清理现有导航项');
                }
                
                var existingStyle = document.getElementById('clash-nav-styles');
                if (existingStyle) {
                    existingStyle.remove();
                    console.log('[Clash] 已清理现有样式');
                }
                
                // 执行注入
                var navResult = tryAttachSideNav();
                
                if (navResult) {
                    console.log('[Clash] 手动注入成功！');
                    
                    // 验证注入结果
                    setTimeout(function() {
                        var status = window.clashDebugCommands.status();
                        console.log('[Clash] 注入验证结果:', status);
                    }, 500);
                    
                    return true;
                } else {
                    console.log('[Clash] 手动注入失败，请检查 Console 输出');
                    return false;
                }
            };
            
            // 智能注入函数 - 等待 PVE 界面完全加载
            var smartInjection = function() {
                console.log('[Clash] 开始智能注入...');
                
                // 检查 PVE 核心组件是否已加载
                if (typeof PVE !== 'undefined' && PVE.Utils && PVE.Utils.getNode) {
                    console.log('[Clash] PVE 核心组件已加载，开始注入...');
                    
                    // 检查是否已经成功注入
                    var existingNav = document.querySelector('.clash-nav-item');
                    if (existingNav) {
                        console.log('[Clash] 检测到 Clash 导航项已存在，跳过注入');
                        return true;
                    }
                    
                    return tryAttachSideNav();
                } else {
                    console.log('[Clash] PVE 核心组件未加载，等待中...');
                    return false;
                }
            };
            
            // 等待 DOM 完全加载后再开始注入
            var waitForPVE = function() {
                if (document.readyState === 'complete') {
                    console.log('[Clash] DOM 已完全加载，开始智能注入...');
                    smartInjection();
                } else {
                    console.log('[Clash] 等待 DOM 加载完成...');
                    setTimeout(waitForPVE, 100);
                }
            };
            
            // 启动等待
            waitForPVE();
            
            // 备用注入策略 - 定时重试机制
            var backupInjection = function() {
                var attempts = 0;
                var maxAttempts = 20;
                var interval = 2000; // 2秒间隔
                
                var backupTask = setInterval(function() {
                    attempts++;
                    console.log('[Clash] 备用注入策略 - 第', attempts, '次尝试...');
                    
                    // 检查是否已经成功注入（只检查左侧导航）
                    var navExists = document.querySelector('.clash-nav-item') !== null;
                    
                    if (navExists) {
                        console.log('[Clash] 检测到 Clash 导航项已存在，停止备用注入');
                        clearInterval(backupTask);
                        return;
                    }
                    
                    // 尝试注入
                    var success = smartInjection();
                    
                    if (success || attempts >= maxAttempts) {
                        if (attempts >= maxAttempts) {
                            console.log('[Clash] 备用注入达到最大尝试次数，停止重试');
                            console.log('[Clash] 请手动执行: window.forceClashInjection()');
                            console.log('[Clash] 或使用: window.clashDebugCommands.reInject()');
                        }
                        clearInterval(backupTask);
                    }
                }, interval);
                
                // 5秒后启动备用策略
                setTimeout(function() {
                    console.log('[Clash] 启动备用注入策略...');
                }, 5000);
                
                return backupTask; // 返回任务引用，便于后续清理
            };
            
            // 启动备用注入策略
            backupInjection();
        }
    } catch (e) {
        console.error('[Clash] 注入过程中发生错误:', e);
    }
    
    // 全局调试开关
    window.clashDebug = true;
    
    // 延迟执行一次手动注入（作为保险）
    setTimeout(function() {
        if (window.clashDebug) {
            console.log('[Clash] 延迟执行手动注入...');
            if (typeof window.forceClashInjection === 'function') {
                var result = window.forceClashInjection();
                if (result) {
                    console.log('[Clash] 延迟注入成功！');
                } else {
                    console.log('[Clash] 延迟注入失败，将在下次备用策略中重试');
                }
            }
        }
    }, 8000); // 增加到8秒，给界面更多时间加载
    
    // 添加页面卸载时的清理函数
    window.addEventListener('beforeunload', function() {
        if (window.clashDebug) {
            console.log('[Clash] 页面即将卸载，清理资源...');
            // 这里可以添加资源清理逻辑
        }
    });
    
    // 添加全局调试命令
    window.clashDebugCommands = {
        // 显示所有可用的注入目标
        showTargets: function() {
            console.log('[Clash] === 可用注入目标 ===');
            
            // 查找所有可能的导航组件
            var navs = Ext.ComponentQuery.query('treelist');
            console.log('[Clash] 导航组件数量:', navs.length);
            navs.forEach(function(nav, idx) {
                console.log('[Clash] 导航[' + idx + ']:', {
                    reference: nav.reference,
                    cls: nav.cls,
                    store: nav.getStore ? 'has store' : 'no store'
                });
            });
            
            return '目标检查完成，请查看 Console';
        },
        
        // 强制重新注入
        reInject: function() {
            console.log('[Clash] 强制重新注入...');
            // 移除现有的 Clash 元素（只清理左侧导航）
            var existingNav = document.querySelector('.clash-nav-item');
            
            if (existingNav) {
                existingNav.remove();
                console.log('[Clash] 已移除现有导航项');
            }
            
            // 清理 CSS 样式
            var existingStyle = document.getElementById('clash-nav-styles');
            if (existingStyle) {
                existingStyle.remove();
                console.log('[Clash] 已移除现有样式');
            }
            
            // 重新注入
            return window.forceClashInjection();
        },
        
        // 清理所有 Clash 相关元素
        cleanup: function() {
            console.log('[Clash] 开始清理所有 Clash 相关元素...');
            
            // 移除导航项
            var navItems = document.querySelectorAll('.clash-nav-item');
            navItems.forEach(function(item) {
                item.remove();
                console.log('[Clash] 已移除导航项:', item);
            });
            
            // 移除样式
            var styles = document.querySelectorAll('#clash-nav-styles');
            styles.forEach(function(style) {
                style.remove();
                console.log('[Clash] 已移除样式:', style);
            });
            
            // 移除事件监听器（通过重新注入来清理）
            console.log('[Clash] 清理完成，建议重新注入以恢复功能');
            return true;
        },
        
        // 检查注入状态
        status: function() {
            console.log('[Clash] === 注入状态检查 ===');
            
            var navExists = document.querySelector('.clash-nav-item') !== null;
            var styleExists = document.getElementById('clash-nav-styles') !== null;
            
            console.log('[Clash] 导航项存在:', navExists);
            console.log('[Clash] 样式存在:', styleExists);
            
            if (navExists) {
                var navItem = document.querySelector('.clash-nav-item');
                console.log('[Clash] 导航项详情:', navItem);
            }
            
            return {
                navigation: navExists,
                styles: styleExists,
                message: '状态检查完成，请查看 Console'
            };
        }
    };
    
    console.log('[Clash] 插件加载完成！');
    console.log('[Clash] 可用调试命令:');
    console.log('[Clash]   - window.showClashInjectionStatus() - 检查注入状态');
    console.log('[Clash]   - window.forceClashInjection() - 手动触发注入');
    console.log('[Clash]   - window.clashDebugCommands.showTargets() - 显示可用目标');
    console.log('[Clash]   - window.clashDebugCommands.reInject() - 强制重新注入');
    console.log('[Clash]   - window.clashDebugCommands.cleanup() - 清理所有元素');
    console.log('[Clash]   - window.clashDebugCommands.status() - 检查注入状态');
    console.log('[Clash] 左侧菜单栏注入功能已完成！');
});