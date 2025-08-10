# Proxmox Clash 插件 v1.2.2 发布说明

**发布日期**: 2025-08-09  
**版本**: v1.2.2  
**代号**: Latest Kernel & Robust Downloader

## 🎯 版本概述

v1.2.2 聚焦于 mihomo 最新版资产命名适配与下载器健壮性提升，彻底解决 `latest/download` 404、小体积错误文件、API 异常与镜像环境下的安装失败问题。同时改进插件源码获取为优先按最新 Release tag 下载，并在日志中完整打印下载 URL，便于定位问题。

## 🛠️ 关键改进

### 1) mihomo (Clash.Meta) 获取完全适配最新命名
- 默认选择内核变体：`v1`（可通过 `--kernel-variant v1|v2|v3|compatible|auto` 指定）。
- 使用 GitHub Releases API 精确获取 Latest `tag` 与资产名，直接采用 `browser_download_url`。
- 支持 v1/v2/v3、go120/go123、compatible 等命名变体与 `.gz` 自动解压。
- 若 API 可用但未解析到资产，基于 tag 生成真实命名的直链候选（如 `mihomo-linux-amd64-v1.19.12.gz`、`mihomo-linux-amd64-v3-v1.19.12.gz`、`mihomo-linux-amd64-compatible-v1.19.12.gz`），并追加 ghproxy 镜像项。
- 全链路日志增强：
  - 解析到资产时：打印 “最新 Release: <tag>，资产: <name>” 和 “解析到资产 URL: <url>”。
  - 下载完成：打印 “使用下载地址: <url>”。
- 文件完整性校验：
  - 尺寸阈值（>1MB）+ `file` 检测必须为 ELF 可执行。
  - 失败时明确报错并引导检查代理/镜像。

### 2) 插件源码下载按最新 Release tag 优先
- `-l/--latest`：优先获取仓库最新 Release 的 `tag`，并打印“下载地址: <url>”。
- 获取 tag 失败时回退 `main` 分支压缩包，仍打印完整 URL。
- 指定版本：自动标准化 tag（支持 `1.2.0`、`v1.2.0`、`V1.2.0` → `v1.2.0`），并打印完整 URL。
- 解压前使用 `tar -tzf` 验证 gzip，有效避免 “not in gzip format”。

### 3) 其他稳健性提升
- 修复 `jq: Cannot index string with number`：在解析前校验 JSON 结构（object 且含 assets 数组），异常时自动走回退策略。
- 代理环境指引优化：日志明确建议为 root 传递 `ALL_PROXY=socks5h://...` 或 `HTTP(S)_PROXY=http://...`，避免外层 curl 走代理而内层不走的问题。

## 📚 使用示例

```bash
# 最新版本（默认 v1 变体）
sudo bash /opt/proxmox-clash/scripts/install/install.sh -l

# 指定 mihomo 变体（如 v3）
sudo bash /opt/proxmox-clash/scripts/install/install.sh -l --kernel-variant v3

# 指定插件版本（自动标准化为 v 前缀）
sudo bash /opt/proxmox-clash/scripts/install/install.sh v1.2.2
```

## 🔧 升级指南

- 升级到最新：
```bash
sudo /opt/proxmox-clash/scripts/management/upgrade.sh -l
```
- 或重新拉取并执行最新安装脚本（受限网络建议附加代理与 no-cache）：
```bash
curl -H "Cache-Control: no-cache" -sSL \
  https://raw.githubusercontent.com/proxmox-libraries/proxmox-clash-plugin/main/scripts/install/install.sh \
  | sudo bash -s -- -l
```
- 升级后验证：
```bash
sudo systemctl restart pveproxy
file /opt/proxmox-clash/clash-meta
/opt/proxmox-clash/clash-meta -v || true
sudo systemctl restart clash-meta
sudo systemctl status --no-pager clash-meta | cat
```

## 🔗 相关
- 版本索引与历史：`docs/releases/index.md`
- 安装指南：`docs/installation/`
- 故障排除：`docs/troubleshooting/`

---

如在镜像/代理环境下载失败，请参考安装日志中的“解析到资产 URL/使用下载地址”，优先验证该 URL 在代理环境下可直接访问；必要时可在具备 GitHub 访问能力的机器下载对应二进制后手动上传至 `/opt/proxmox-clash/clash-meta`。

