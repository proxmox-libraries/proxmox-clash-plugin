# Proxmox Clash 插件 v1.2.1 发布说明

**发布日期**: 2025-08-09  
**版本**: v1.2.1  
**代号**: Installer & Compatibility Fixes

## 🎯 版本概述

v1.2.1 聚焦于安装器稳定性与平台兼容性修复，显著提升在受限网络环境、不同 CPU 架构以及 PVE 7/8 混合环境下的安装成功率与可维护性。

## 🛠️ 安装脚本与版本获取改进

### 安装参数与版本解析
- 统一参数解析：支持 `-l/--latest`、`-v/--version <tag>`，并兼容直接传入版本字符串。
- 版本标准化：自动将 `V1.2.0` 规范为 `v1.2.0`；未带前缀时自动补 `v`。
- 打印完整下载地址：在日志中显示插件源码包的最终下载 URL，便于排查。
- 压缩包校验：解压前使用 `tar -tzf` 校验，避免“not in gzip format”。

### mihomo (Clash.Meta) 获取逻辑重构
- 使用 GitHub Releases API 精确获取 Latest 版本 `tag` 与匹配架构资产。
- 新增内核变体选择：默认 `v1`，可通过 `--kernel-variant v1|v2|v3|compatible|auto` 指定。
- 镜像与回退：主源失败时自动尝试 `ghproxy` 镜像与多候选命名；支持 `.gz` 自动解压。
- 文件校验：下载后进行大小阈值与 ELF 类型校验，拒绝 1KB 级错误文件。
- 明确日志：安装日志中打印“使用下载地址: ...”方便定位问题。

## 🧩 PVE 兼容性修复
- 自动检测 UI 目录：优先使用 PVE 8 的 `/usr/share/pve-manager/js`，兼容 PVE 7 的 `/usr/share/pve-manager/ext6`。
- 同步修复脚本：安装（install）、升级（upgrade）、卸载（uninstall）均采用统一检测逻辑。

## 🐞 问题修复
- 修复 `-l` 被误当作版本号导致的解压失败问题。
- 修复在 `sudo` 环境下未继承代理变量导致的下载失败（文档与日志提示更清晰）。
- 修复指定版本下载时的前缀歧义与错误压缩包问题。

## 📚 文档与可观测性
- 安装日志中新增：插件源码下载 URL、mihomo 实际使用的下载 URL。
- 失败时提供明确的重试/镜像建议与排查指引。

## 🔧 升级说明

### 影响范围
- 仅安装脚本与相关管理脚本逻辑变更，不影响已有配置与服务行为。

### 升级路径
```bash
# 升级到最新版本（推荐）
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -l

# 或重新拉取并执行最新安装脚本
curl -sSL https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh | \
  sudo bash -s -- -l

# 需要指定 mihomo 变体时（默认 v1）
sudo /opt/proxmox-clash/scripts/install/install.sh -l --kernel-variant v3
```

### 升级后验证
```bash
sudo systemctl restart pveproxy
file /opt/proxmox-clash/clash-meta
/opt/proxmox-clash/clash-meta -v || true
sudo systemctl restart clash-meta
sudo systemctl status --no-pager clash-meta | cat
```

## 🔗 相关链接
- 版本索引与历史：`docs/releases/index.md`
- 安装指南：`docs/installation/`
- 故障排除：`docs/troubleshooting/`

---

如在受限网络环境中安装，请参考日志中的“使用下载地址”并优先为 `root` 提供正确的代理环境变量（如 `ALL_PROXY=socks5h://...`）。

