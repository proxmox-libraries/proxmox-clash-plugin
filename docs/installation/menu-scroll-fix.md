# Clash 菜单滚动功能修复

## 问题描述

在之前的版本中，Clash 菜单存在以下问题：
- 菜单位置固定，无法通过鼠标滚轮滚动
- 当菜单项较多时，部分菜单项可能被隐藏
- 缺乏直观的滚动条指示器

## 修复内容

### 1. DOM 注入方式改进

在 `injectViaDOM` 函数中添加了智能滚动检测和包装器创建：

```javascript
// 检查容器是否支持滚动，如果不支持则添加滚动功能
var needsScrollWrapper = false;
if (container.scrollHeight > container.clientHeight) {
    needsScrollWrapper = true;
}

// 如果容器需要滚动包装器，创建一个
if (needsScrollWrapper) {
    var wrapper = document.createElement('div');
    wrapper.className = 'clash-scroll-wrapper';
    wrapper.style.cssText = `
        max-height: 100%;
        overflow-y: auto;
        overflow-x: hidden;
        scrollbar-width: thin;
        scrollbar-color: #ccc transparent;
    `;
    
    // 将现有内容移动到包装器中
    var fragment = document.createDocumentFragment();
    while (container.firstChild) {
        fragment.appendChild(container.firstChild);
    }
    wrapper.appendChild(fragment);
    container.appendChild(wrapper);
    scrollContainer = wrapper;
}
```

### 2. 原型扩展方式改进

在 `injectViaPrototype` 函数中添加了菜单滚动支持：

```javascript
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
        }
    }
});
```

### 3. 全局滚动功能检测

新增 `ensureMenuScrollability` 函数，自动检测和修复所有菜单的滚动问题：

```javascript
var ensureMenuScrollability = function() {
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
                    element.classList.add('clash-scrollable');
                }
            }
        });
    });
};
```

### 4. 自定义滚动条样式

为所有滚动容器添加了美观的自定义滚动条：

```css
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
```

## 使用方法

### 1. 自动修复

菜单滚动功能会在插件加载后自动启用，无需手动配置。

### 2. 手动修复

如果遇到滚动问题，可以使用浏览器控制台的调试命令：

```javascript
// 手动修复菜单滚动功能
window.clashDebugCommands.fixScroll();

// 测试菜单滚动功能
window.clashDebugCommands.testScroll();

// 检查插件状态
window.clashDebugCommands.status();
```

### 3. 测试验证

运行测试脚本验证修复效果：

```bash
sudo /opt/proxmox-clash/scripts/utils/test_menu_scroll.sh
```

## 技术特点

### 1. 智能检测

- 自动检测容器是否需要滚动功能
- 根据内容高度动态调整滚动设置
- 避免为不需要滚动的容器添加不必要的滚动条

### 2. 兼容性

- 支持多种菜单注入方式
- 兼容不同的 PVE 版本
- 不影响现有的菜单功能

### 3. 用户体验

- 美观的自定义滚动条
- 平滑的滚动效果
- 直观的滚动指示器

## 故障排除

### 1. 菜单仍然无法滚动

检查浏览器控制台是否有错误信息，使用以下命令进行诊断：

```javascript
window.clashDebugCommands.testScroll();
```

### 2. 滚动条样式异常

确保浏览器支持 CSS 自定义滚动条，某些旧版本浏览器可能显示默认滚动条。

### 3. 菜单项重叠

检查是否有 CSS 冲突，确保菜单项设置了正确的 `z-index` 值。

## 版本要求

- PVE 7.x 或更高版本
- 现代浏览器（支持 CSS 自定义滚动条）
- Clash 插件 v1.2.7 或更高版本

## 更新日志

### v1.2.7
- 新增菜单滚动功能
- 智能滚动检测和包装器创建
- 自定义滚动条样式
- 全局滚动功能修复

## 相关文档

- [安装指南](../index.md)
- [快速参考](../quick-reference.md)
- [HTML 改进说明](html-improvements.md)
- [故障排除指南](../troubleshooting.md)
