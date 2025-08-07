---
layout: page-with-sidebar
title: UI 开发
---

# 🎨 UI 开发指南

Proxmox Clash 插件的用户界面基于 Proxmox VE 的 Web UI 框架开发，提供直观的 Clash 管理界面。

## 📋 技术栈

### 前端技术
- **框架**: ExtJS 6.x (Proxmox VE 标准)
- **语言**: JavaScript ES6+
- **样式**: CSS3, SCSS
- **构建工具**: Webpack
- **包管理**: npm

### 开发环境
- **Node.js**: 16.x 或更高版本
- **npm**: 8.x 或更高版本
- **编辑器**: VS Code (推荐)
- **浏览器**: Chrome, Firefox, Safari

## 🏗️ 项目结构

```
ui/
├── pve-panel-clash.js      # 主界面文件
├── components/             # 组件目录
│   ├── StatusPanel.js      # 状态面板
│   ├── ConfigEditor.js     # 配置编辑器
│   ├── ProxyList.js        # 代理列表
│   └── SubscriptionManager.js  # 订阅管理
├── styles/                 # 样式文件
│   ├── main.scss          # 主样式
│   └── components.scss    # 组件样式
└── assets/                # 静态资源
    ├── icons/             # 图标文件
    └── images/            # 图片文件
```

## 🔧 开发环境搭建

### 1. 安装依赖
```bash
# 克隆项目
git clone https://github.com/proxmox-libraries/proxmox-clash-plugin.git
cd proxmox-clash-plugin

# 安装依赖
npm install
```

### 2. 开发服务器
```bash
# 启动开发服务器
npm run dev

# 构建生产版本
npm run build
```

### 3. 调试配置
```javascript
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug UI",
      "type": "chrome",
      "request": "launch",
      "url": "https://your-pve-host:8006",
      "webRoot": "${workspaceFolder}/ui"
    }
  ]
}
```

## 📦 核心组件

### 1. 主界面 (pve-panel-clash.js)

```javascript
Ext.define('PVE.panel.Clash', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.pveClashPanel',
    
    title: 'Clash 管理',
    layout: 'border',
    
    initComponent: function() {
        var me = this;
        
        me.items = [
            {
                xtype: 'pveClashStatusPanel',
                region: 'north',
                height: 100
            },
            {
                xtype: 'tabpanel',
                region: 'center',
                items: [
                    {
                        xtype: 'pveClashConfigEditor',
                        title: '配置管理'
                    },
                    {
                        xtype: 'pveClashProxyList',
                        title: '代理管理'
                    },
                    {
                        xtype: 'pveClashSubscriptionManager',
                        title: '订阅管理'
                    }
                ]
            }
        ];
        
        me.callParent();
    }
});
```

### 2. 状态面板组件

```javascript
Ext.define('PVE.panel.ClashStatus', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.pveClashStatusPanel',
    
    title: '服务状态',
    layout: 'hbox',
    
    initComponent: function() {
        var me = this;
        
        me.items = [
            {
                xtype: 'displayfield',
                name: 'status',
                fieldLabel: '状态',
                value: '检查中...'
            },
            {
                xtype: 'displayfield',
                name: 'version',
                fieldLabel: '版本',
                value: '未知'
            },
            {
                xtype: 'button',
                text: '启动',
                handler: me.startService,
                scope: me
            },
            {
                xtype: 'button',
                text: '停止',
                handler: me.stopService,
                scope: me
            }
        ];
        
        me.callParent();
        me.loadStatus();
    },
    
    loadStatus: function() {
        var me = this;
        PVE.Utils.API2Request({
            url: '/nodes/' + me.node + '/clash/status',
            method: 'GET',
            success: function(response) {
                var data = response.result.data;
                me.down('[name=status]').setValue(data.status);
                me.down('[name=version]').setValue(data.version);
            }
        });
    }
});
```

### 3. 配置编辑器组件

```javascript
Ext.define('PVE.panel.ClashConfigEditor', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.pveClashConfigEditor',
    
    layout: 'border',
    
    initComponent: function() {
        var me = this;
        
        me.items = [
            {
                xtype: 'textarea',
                region: 'center',
                name: 'config',
                fieldLabel: '配置文件',
                enableKeyEvents: true,
                listeners: {
                    keyup: me.onConfigChange,
                    scope: me
                }
            },
            {
                xtype: 'toolbar',
                region: 'south',
                items: [
                    {
                        xtype: 'button',
                        text: '加载配置',
                        handler: me.loadConfig,
                        scope: me
                    },
                    {
                        xtype: 'button',
                        text: '保存配置',
                        handler: me.saveConfig,
                        scope: me
                    },
                    {
                        xtype: 'button',
                        text: '验证配置',
                        handler: me.validateConfig,
                        scope: me
                    }
                ]
            }
        ];
        
        me.callParent();
    }
});
```

## 🎨 样式开发

### 1. 主样式文件 (main.scss)

```scss
// 主容器样式
.pve-clash-panel {
    background: #f5f5f5;
    
    .x-panel-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        font-weight: bold;
    }
}

// 状态面板样式
.clash-status-panel {
    .status-indicator {
        display: inline-block;
        width: 12px;
        height: 12px;
        border-radius: 50%;
        margin-right: 8px;
        
        &.running {
            background-color: #52c41a;
        }
        
        &.stopped {
            background-color: #ff4d4f;
        }
        
        &.starting {
            background-color: #faad14;
        }
    }
}

// 配置编辑器样式
.clash-config-editor {
    .x-form-textarea {
        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 13px;
        line-height: 1.5;
    }
}
```

### 2. 响应式设计

```scss
// 移动端适配
@media (max-width: 768px) {
    .pve-clash-panel {
        .x-panel-header {
            font-size: 14px;
        }
        
        .x-toolbar {
            .x-btn {
                margin: 2px;
            }
        }
    }
}

// 平板适配
@media (min-width: 769px) and (max-width: 1024px) {
    .clash-status-panel {
        .x-displayfield {
            margin-right: 15px;
        }
    }
}
```

## 🔍 调试技巧

### 1. 浏览器开发者工具

```javascript
// 在代码中添加调试信息
console.log('Clash Panel loaded:', this);

// 使用 ExtJS 的调试工具
Ext.log('Config loaded:', configData);
```

### 2. 网络请求调试

```javascript
// 添加请求拦截器
Ext.override('PVE.Utils.API2Request', {
    request: function(options) {
        console.log('API Request:', options);
        
        var originalCallback = options.callback;
        options.callback = function(success, response, options) {
            console.log('API Response:', response);
            if (originalCallback) {
                originalCallback(success, response, options);
            }
        };
        
        this.callParent([options]);
    }
});
```

### 3. 组件调试

```javascript
// 获取组件引用
var panel = Ext.ComponentQuery.query('pveClashPanel')[0];
console.log('Panel instance:', panel);

// 检查组件状态
console.log('Panel items:', panel.items);
console.log('Panel layout:', panel.layout);
```

## 📝 最佳实践

### 1. 代码组织
- 使用模块化设计
- 遵循单一职责原则
- 保持代码简洁可读

### 2. 性能优化
- 避免频繁的 DOM 操作
- 使用事件委托
- 合理使用缓存

### 3. 用户体验
- 提供加载状态指示
- 实现错误处理和提示
- 支持键盘快捷键

### 4. 兼容性
- 测试不同浏览器
- 支持不同屏幕尺寸
- 考虑无障碍访问

## 🚀 部署

### 1. 构建生产版本
```bash
npm run build
```

### 2. 安装到 Proxmox VE
```bash
# 复制构建文件
sudo cp dist/pve-panel-clash.js /usr/share/pve-manager/ext6/

# 重启 Web 服务
sudo systemctl restart pveproxy
```

### 3. 验证安装
- 访问 Proxmox Web UI
- 检查 Clash 面板是否正常显示
- 测试各项功能

## 🔗 相关资源

- [ExtJS 6 文档](https://docs.sencha.com/extjs/6.8.0/)
- [Proxmox VE API 文档](https://pve.proxmox.com/pve-docs/api-viewer/)
- [JavaScript ES6+ 指南](https://es6.ruanyifeng.com/)
- [CSS3 参考手册](https://developer.mozilla.org/zh-CN/docs/Web/CSS)
