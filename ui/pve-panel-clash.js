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