# Proxmox Clash 插件 v1.2.3 发布说明

**发布日期**: 2025-08-09  
**版本**: v1.2.3  
**代号**: Gzip Fix & Final Polishing

## 🎯 版本概述

v1.2.3 针对 mihomo 最新版下载与解压流程进行最终打磨，修复了 `.gz` 文件识别分支未命中导致的“压缩包被当作可执行文件”问题，并新增二次解压保险，确保最终落盘为 ELF 可执行文件。

## 🛠️ 关键修复与优化

- 修复 `.gz` 判定转义错误，确保压缩包路径命中解压分支。
- 新增“保险二次解压”：若目标仍被识别为 gzip 数据，将再次尝试解压，防止中间链路导致的直存压缩包。
- 继续保留尺寸阈值（>1MB）与 `file` 类型（必须 ELF）双重校验，失败时给出明确错误信息。
- 安装日志完整打印：
  - 插件源码：优先使用最新 Release tag，并打印“下载地址: …”。
  - mihomo 内核：打印“最新 Release/资产名”“解析到资产 URL”“使用下载地址”。

> 说明：v1.2.1/v1.2.2 已实现 Latest tag 解析、命名适配（v1/v2/v3/compatible/go120/go123）、镜像与直链回退、PVE 7/8 UI 目录自动检测、`--kernel-variant` 参数（默认 v1）等。本次在此基础上解决了最后一个压缩包边界问题。

## 📚 使用示例

```bash
# 最新版本（默认 v1 内核变体）
sudo bash /opt/proxmox-clash/scripts/install/install_direct.sh -l

# 指定 mihomo 变体（如 v3）
sudo bash /opt/proxmox-clash/scripts/install/install_direct.sh -l --kernel-variant v3

# 指定插件版本（自动标准化为 v 前缀）
sudo bash /opt/proxmox-clash/scripts/install/install_direct.sh v1.2.3
```

## 🔧 升级指南

```bash
# 升级到最新
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -l

# 或重新拉取并执行最新安装脚本（受限网络建议附加代理与 no-cache）
curl -H "Cache-Control: no-cache" -sSL \
  https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install_direct.sh \
  | sudo bash -s -- -l
```

## ✅ 升级后验证

```bash
# 刷新 PVE Web 静态资源
sudo systemctl restart pveproxy

# 核心可执行文件检查（应为 ELF）
file /opt/proxmox-clash/clash-meta
/opt/proxmox-clash/clash-meta -v || true

# 服务状态
sudo systemctl restart clash-meta
sudo systemctl status --no-pager clash-meta | cat
```

## 🔗 相关
- 版本索引与历史：`docs/releases/index.md`
- 安装指南：`docs/installation/`
- 故障排除：`docs/troubleshooting/`

---

若在镜像/代理环境仍遇下载或解压异常，请根据安装日志中的“解析到资产 URL/使用下载地址”先行验证该直链在代理环境下可直接访问；必要时可在具备 GitHub 访问能力的机器预先下载对应架构的 gzip 包并手动解压至 `/opt/proxmox-clash/clash-meta`（记得 `chmod +x`）。

