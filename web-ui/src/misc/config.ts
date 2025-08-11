// 应用配置
export const APP_CONFIG = {
  // 是否强制使用本机地址
  FORCE_LOCALHOST: import.meta.env.VITE_FORCE_LOCALHOST === 'true' || true,
  
  // 默认的Clash API端口
  DEFAULT_CLASH_PORT: import.meta.env.VITE_DEFAULT_CLASH_PORT || '9090',
  
  // 默认的Clash API协议
  DEFAULT_CLASH_PROTOCOL: import.meta.env.VITE_DEFAULT_CLASH_PROTOCOL || 'http',
};

// 获取默认的Clash API URL
export function getDefaultClashURL(): string {
  return `${APP_CONFIG.DEFAULT_CLASH_PROTOCOL}://127.0.0.1:${APP_CONFIG.DEFAULT_CLASH_PORT}`;
}

// 强制URL使用本机地址
export function forceLocalhost(url: string): string {
  if (!APP_CONFIG.FORCE_LOCALHOST) {
    return url;
  }
  
  try {
    const urlObj = new URL(url);
    urlObj.hostname = '127.0.0.1';
    return urlObj.href;
  } catch (e) {
    // 如果URL解析失败，尝试直接替换
    if (url.includes('://')) {
      const parts = url.split('://');
      if (parts.length === 2) {
        const hostPort = parts[1].split('/')[0];
        const port = hostPort.includes(':') ? hostPort.split(':')[1] : '';
        return `${parts[0]}://127.0.0.1${port ? ':' + port : ''}`;
      }
    }
    return url;
  }
}
