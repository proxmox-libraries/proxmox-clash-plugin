# Proxmox Clash 插件 v1.2.4 发布说明

**发布日期**: 2025-08-10  
**版本**: v1.2.4  
**代号**: PVE 8.4 UI 兼容

## 🎯 版本概述

本次更新重点适配 Proxmox VE 8.4 的 Web UI 菜单结构变化，确保“Clash 控制”入口在 PVE 8.4 正常显示与使用；同时延续近期对安装器稳定性与日志可观测性的改进。

## 🧩 PVE 8.4 前端兼容
- 旧版通过 `override: 'PVE.dc.Menu'` 注入菜单；在 PVE 8.4 中该类名通常不存在。
- 新增 onReady 兼容逻辑：若检测不到 `PVE.dc.Menu`，则在主界面顶部工具栏动态添加“Clash 控制”按钮，点击弹出控制面板窗口。
- 不改动 PVE 系统文件，注入仅由 `pve-panel-clash.js` 完成；对 PVE 7/旧 8 保持原行为。

## 🛠️ 安装与下载（延续 v1.2.1~v1.2.3 改进）
- 插件源码：优先按最新 Release tag 下载，并打印完整 URL；失败时回退 `main` 压缩包。
- mihomo 内核：
  - 通过 Releases API 精确获取 Latest `tag` 与资产名；支持 v1/v2/v3、go120/go123、compatible；默认选择 `v1`。
  - 失败时按真实命名生成直链候选并追加镜像项；下载完成打印“使用下载地址”。
  - `.gz` 正确解压到 `/opt/proxmox-clash/clash-meta`，并进行尺寸和 ELF 校验；包含二次解压保险。

## 📚 使用提示
```bash
# 刷新 PVE Web 端静态资源
sudo systemctl restart pveproxy
# 强制刷新浏览器缓存（隐身窗口或 Ctrl/Cmd+Shift+R）
```

## ✅ 验证项
- 顶部工具栏出现“Clash 控制”按钮；点击可打开控制面板。
- 服务端可执行：`/opt/proxmox-clash/clash-meta -v` 正常输出；`systemctl status clash-meta` 为 active。

## 🔗 相关
- 版本索引与历史：`docs/releases/index.md`
- 安装指南：`docs/installation/`
- 故障排除：`docs/troubleshooting/`

---

如仍未显示菜单，请在浏览器 Console 检查是否加载了 `pve-panel-clash.js`，并将相关报错反馈到项目 issue。

