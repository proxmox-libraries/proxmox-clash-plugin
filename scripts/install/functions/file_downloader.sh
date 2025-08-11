#!/bin/bash

# 文件下载功能模块
# 负责下载项目文件和mihomo可执行文件

# 下载项目文件
download_files() {
    log_step "下载项目文件..."
    
    # 创建安装目录
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
        log_info "创建安装目录: $INSTALL_DIR"
    fi
    
    # 创建临时目录
    local temp_dir=$(create_temp_dir)
    log_info "创建临时目录: $temp_dir"
    
    # 根据版本类型下载文件
    if [ "$VERSION" = "latest" ]; then
        download_latest_files "$temp_dir"
    else
        download_specific_version "$temp_dir"
    fi
    
    # 检查下载结果
    if [ $? -eq 0 ]; then
        log_info "✅ 项目文件下载完成"
        
        # 清理临时目录
        cleanup_temp_dir "$temp_dir"
    else
        log_error "❌ 项目文件下载失败"
        cleanup_temp_dir "$temp_dir"
        exit 1
    fi
}

# 下载最新版本文件
download_latest_files() {
    local temp_dir="$1"
    local download_url=""
    
    if [ "$BRANCH" = "main" ]; then
        download_url="$REPO_URL/archive/refs/heads/main.tar.gz"
    else
        download_url="$REPO_URL/archive/refs/heads/$BRANCH.tar.gz"
    fi
    
    log_info "下载分支: $BRANCH"
    log_info "下载地址: $download_url"
    
    # 下载文件
    if ! download_with_progress "$download_url" "$temp_dir/project.tar.gz"; then
        return 1
    fi
    
    # 解压文件
    if ! extract_project_files "$temp_dir/project.tar.gz" "$temp_dir"; then
        return 1
    fi
    
    # 复制文件到安装目录
    if ! copy_project_files "$temp_dir" "$INSTALL_DIR"; then
        return 1
    fi
    
    return 0
}

# 下载指定版本文件
download_specific_version() {
    local temp_dir="$1"
    local download_url="$REPO_URL/archive/refs/tags/$VERSION.tar.gz"
    
    log_info "下载版本: $VERSION"
    log_info "下载地址: $download_url"
    
    # 下载文件
    if ! download_with_progress "$download_url" "$temp_dir/project.tar.gz"; then
        return 1
    fi
    
    # 解压文件
    if ! extract_project_files "$temp_dir/project.tar.gz" "$temp_dir"; then
        return 1
    fi
    
    # 复制文件到安装目录
    if ! copy_project_files "$temp_dir" "$INSTALL_DIR"; then
        return 1
    fi
    
    return 0
}

# 带进度显示的下载
download_with_progress() {
    local url="$1"
    local output_file="$2"
    
    log_info "开始下载: $(basename "$output_file")"
    
    # 尝试使用 curl 下载
    if command_exists curl; then
        if curl -L -o "$output_file" --progress-bar "$url"; then
            return 0
        fi
    fi
    
    # 尝试使用 wget 下载
    if command_exists wget; then
        if wget -O "$output_file" --progress=bar:force "$url"; then
            return 0
        fi
    fi
    
    log_error "下载失败: $url"
    return 1
}

# 解压项目文件
extract_project_files() {
    local archive_file="$1"
    local extract_dir="$2"
    
    log_info "解压项目文件..."
    
    if ! tar -xzf "$archive_file" -C "$extract_dir"; then
        log_error "解压失败: $archive_file"
        return 1
    fi
    
    # 查找解压后的目录
    local extracted_dir=$(find "$extract_dir" -maxdepth 1 -type d -name "proxmox-clash-plugin-*" | head -n1)
    if [ -z "$extracted_dir" ]; then
        log_error "无法找到解压后的项目目录"
        return 1
    fi
    
    log_info "项目文件解压到: $extracted_dir"
    return 0
}

# 复制项目文件
copy_project_files() {
    local source_dir="$1"
    local target_dir="$2"
    
    log_info "复制项目文件到安装目录..."
    
    # 查找解压后的目录
    local extracted_dir=$(find "$source_dir" -maxdepth 1 -type d -name "proxmox-clash-plugin-*" | head -n1)
    if [ -z "$extracted_dir" ]; then
        log_error "无法找到解压后的项目目录"
        return 1
    fi
    
    # 复制所有文件
    if ! cp -r "$extracted_dir"/* "$target_dir/"; then
        log_error "复制项目文件失败"
        return 1
    fi
    
    # 设置权限
    chmod -R 755 "$target_dir"
    
    log_info "✅ 项目文件复制完成"
    return 0
}

# 下载 mihomo
download_mihomo() {
    log_step "下载 mihomo..."
    
    # 检查是否跳过此步骤
    if should_skip_step "mihomo"; then
        log_info "跳过 mihomo 下载"
        return 0
    fi
    
    local arch=$(check_system_architecture)
    local mihomo_dir="$INSTALL_DIR/clash-meta"
    
    # 创建 mihomo 目录
    if [ ! -d "$mihomo_dir" ]; then
        mkdir -p "$mihomo_dir"
    fi
    
    # 获取最新版本
    local latest_version=$(get_mihomo_latest_version)
    if [ -z "$latest_version" ]; then
        log_error "无法获取 mihomo 最新版本"
        return 1
    fi
    
    log_info "mihomo 最新版本: $latest_version"
    
    # 构建下载 URL
    local download_url="https://github.com/MetaCubeX/mihomo/releases/download/$latest_version/mihomo-linux-$arch-$latest_version.gz"
    
    log_info "下载地址: $download_url"
    
    # 下载 mihomo
    local temp_file="$mihomo_dir/mihomo.gz"
    if ! download_with_progress "$download_url" "$temp_file"; then
        return 1
    fi
    
    # 解压并设置权限
    if ! gunzip -f "$temp_file"; then
        log_error "解压 mihomo 失败"
        return 1
    fi
    
    # 重命名文件
    mv "$mihomo_dir/mihomo" "$mihomo_dir/mihomo"
    
    # 设置执行权限
    chmod +x "$mihomo_dir/mihomo"
    
    # 创建版本文件
    echo "$latest_version" > "$mihomo_dir/version.txt"
    
    log_info "✅ mihomo 下载完成"
    return 0
}

# 获取 mihomo 最新版本
get_mihomo_latest_version() {
    # 尝试从 GitHub API 获取最新版本
    local api_url="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
    
    if command_exists curl; then
        local version=$(curl -s "$api_url" | grep '"tag_name"' | cut -d'"' -f4)
        if [ -n "$version" ]; then
            echo "$version"
            return 0
        fi
    fi
    
    # 如果 API 获取失败，使用默认版本
    log_warn "无法从 GitHub API 获取版本，使用默认版本"
    echo "v1.18.0"
}
