package PVE::API2::Clash;

use strict;
use warnings;
use PVE::SafeSyslog;
use PVE::Tools;
use PVE::JSONSchema;
use LWP::UserAgent;
use JSON;
use HTTP::Request;
use POSIX qw(strftime);

use base qw(PVE::RESTHandler);

# Clash API 基础配置
my $CLASH_API_BASE = "http://127.0.0.1:9090";
my $CLASH_CONFIG_DIR = "/opt/proxmox-clash";
my $LOG_FILE = "/var/log/proxmox-clash.log";

# 日志函数
sub log_message {
    my ($level, $message) = @_;
    my $timestamp = strftime("%Y-%m-%d %H:%M:%S", localtime);
    my $log_entry = "[$timestamp] [$level] $message\n";
    
    # 写入日志文件
    eval {
        open(my $fh, '>>', $LOG_FILE) or die "Cannot open log file: $!";
        print $fh $log_entry;
        close($fh);
    };
    
    # 同时输出到 syslog
    if ($level eq 'ERROR') {
        syslog('err', "Clash API: $message");
    } elsif ($level eq 'WARN') {
        syslog('warning', "Clash API: $message");
    } else {
        syslog('info', "Clash API: $message");
    }
}

__PACKAGE__->register_method ({
    name => 'get_status',
    path => '',
    method => 'GET',
    description => "获取 Clash 运行状态",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始获取 Clash 状态");
        
        my $ua = LWP::UserAgent->new;
        $ua->timeout(5);
        
        eval {
            log_message('DEBUG', "尝试连接 Clash API: $CLASH_API_BASE/configs");
            my $res = $ua->get("$CLASH_API_BASE/configs");
            
            if ($res->is_success) {
                my $data = decode_json($res->decoded_content);
                my $status = {
                    status => 'running',
                    config => $data->{config}->{name} || 'default',
                    uptime => $data->{uptime} || 0
                };
                log_message('INFO', "Clash 状态获取成功: " . encode_json($status));
                return $status;
            } else {
                log_message('WARN', "Clash API 请求失败: " . $res->status_line);
            }
        };
        
        if ($@) {
            log_message('ERROR', "获取 Clash 状态时发生错误: $@");
        }
        
        log_message('INFO', "Clash 服务未运行");
        return { status => 'stopped' };
    }});

__PACKAGE__->register_method ({
    name => 'get_proxies',
    path => 'proxies',
    method => 'GET',
    description => "获取所有代理节点",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始获取代理列表");
        
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        
        eval {
            log_message('DEBUG', "尝试获取代理列表: $CLASH_API_BASE/proxies");
            my $res = $ua->get("$CLASH_API_BASE/proxies");
            
            if ($res->is_success) {
                my $data = decode_json($res->decoded_content);
                my $proxy_count = scalar(keys %{$data->{proxies} || {}});
                log_message('INFO', "成功获取代理列表，共 $proxy_count 个代理");
                return $data;
            } else {
                log_message('ERROR', "获取代理列表失败: " . $res->status_line);
                die "获取代理列表失败: " . $res->status_line;
            }
        };
        
        if ($@) {
            log_message('ERROR', "获取代理列表时发生错误: $@");
            die $@;
        }
    }});

__PACKAGE__->register_method ({
    name => 'switch_proxy',
    path => 'proxies/{name}',
    method => 'PUT',
    description => "切换代理节点",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            name => {
                type => 'string',
                description => '代理组名称',
            },
            proxy => {
                type => 'string',
                description => '要切换到的代理名称',
            },
        },
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        my $group_name = $param->{name};
        my $proxy_name = $param->{proxy};
        
        log_message('INFO', "开始切换代理: 组=$group_name, 代理=$proxy_name");
        
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        
        eval {
            my $url = "$CLASH_API_BASE/proxies/" . $group_name;
            my $json_data = encode_json({ name => $proxy_name });
            
            log_message('DEBUG', "切换代理请求: $url, 数据: $json_data");
            
            my $req = HTTP::Request->new('PUT', $url);
            $req->header('Content-Type' => 'application/json');
            $req->content($json_data);
            
            my $res = $ua->request($req);
            
            if ($res->is_success) {
                log_message('INFO', "代理切换成功: $group_name -> $proxy_name");
                return { success => 1 };
            } else {
                log_message('ERROR', "代理切换失败: " . $res->status_line);
                die "切换代理失败: " . $res->status_line;
            }
        };
        
        if ($@) {
            log_message('ERROR', "切换代理时发生错误: $@");
            die $@;
        }
    }});

__PACKAGE__->register_method ({
    name => 'test_proxy',
    path => 'proxies/{name}/delay',
    method => 'GET',
    description => "测试代理延迟",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            name => {
                type => 'string',
                description => '代理名称',
            },
            url => {
                type => 'string',
                description => '测试URL',
                optional => 1,
            },
            timeout => {
                type => 'integer',
                description => '超时时间(ms)',
                optional => 1,
            },
        },
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        my $proxy_name = $param->{name};
        my $test_url = $param->{url} || 'http://www.gstatic.com/generate_204';
        my $timeout = $param->{timeout} || 5000;
        
        log_message('INFO', "开始测试代理延迟: 代理=$proxy_name, URL=$test_url, 超时=${timeout}ms");
        
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        
        eval {
            my $url = "$CLASH_API_BASE/proxies/" . $proxy_name . "/delay";
            my $params = {};
            $params->{url} = $test_url;
            $params->{timeout} = $timeout;
            
            if (keys %$params) {
                $url .= "?" . join("&", map { "$_=$params->{$_}" } keys %$params);
            }
            
            log_message('DEBUG', "测试代理请求: $url");
            my $res = $ua->get($url);
            
            if ($res->is_success) {
                my $data = decode_json($res->decoded_content);
                my $delay = $data->{delay} || 'timeout';
                log_message('INFO', "代理延迟测试完成: $proxy_name = ${delay}ms");
                return $data;
            } else {
                log_message('ERROR', "测试代理失败: " . $res->status_line);
                die "测试代理失败: " . $res->status_line;
            }
        };
        
        if ($@) {
            log_message('ERROR', "测试代理时发生错误: $@");
            die $@;
        }
    }});

__PACKAGE__->register_method ({
    name => 'reload_config',
    path => 'configs/reload',
    method => 'PUT',
    description => "重载 Clash 配置",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始重载 Clash 配置");
        
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        
        eval {
            log_message('DEBUG', "发送重载配置请求: $CLASH_API_BASE/configs/reload");
            my $req = HTTP::Request->new('PUT', "$CLASH_API_BASE/configs/reload");
            my $res = $ua->request($req);
            
            if ($res->is_success) {
                log_message('INFO', "配置重载成功");
                return { success => 1 };
            } else {
                log_message('ERROR', "重载配置失败: " . $res->status_line);
                die "重载配置失败: " . $res->status_line;
            }
        };
        
        if ($@) {
            log_message('ERROR', "重载配置时发生错误: $@");
            die $@;
        }
    }});

__PACKAGE__->register_method ({
    name => 'get_configs',
    path => 'configs',
    method => 'GET',
    description => "获取所有配置文件",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始获取配置文件列表");
        
        my @configs = ();
        my $config_dir = "$CLASH_CONFIG_DIR/config";
        
        if (-d $config_dir) {
            log_message('DEBUG', "扫描配置目录: $config_dir");
            opendir(my $dh, $config_dir) or die "无法打开配置目录: $!";
            while (my $file = readdir($dh)) {
                next if $file =~ /^\./;
                next unless $file =~ /\.(yaml|yml)$/;
                push @configs, $file;
                log_message('DEBUG', "发现配置文件: $file");
            }
            closedir($dh);
            log_message('INFO', "找到 " . scalar(@configs) . " 个配置文件");
        } else {
            log_message('WARN', "配置目录不存在: $config_dir");
        }
        
        return { configs => \@configs };
    }});

__PACKAGE__->register_method ({
    name => 'update_subscription',
    path => 'subscription/update',
    method => 'POST',
    description => "更新订阅",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            url => {
                type => 'string',
                description => '订阅URL',
            },
            name => {
                type => 'string',
                description => '配置名称',
                optional => 1,
            },
        },
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        my $url = $param->{url};
        my $name = $param->{name} || 'config.yaml';
        
        log_message('INFO', "开始更新订阅: URL=$url, 配置名称=$name");
        
        # 这里可以调用外部脚本更新订阅
        my $script = "$CLASH_CONFIG_DIR/scripts/update_subscription.sh";
        if (-x $script) {
            log_message('DEBUG', "执行订阅更新脚本: $script");
            my $cmd = "$script " . $url;
            $cmd .= " " . $name if defined $param->{name};
            
            log_message('DEBUG', "执行命令: $cmd");
            my $output = PVE::Tools::run_command($cmd);
            log_message('INFO', "订阅更新完成，输出: $output");
            return { success => 1, output => $output };
        } else {
            log_message('ERROR', "订阅更新脚本不存在或不可执行: $script");
            return { success => 0, error => "更新脚本不存在" };
        }
    }});

__PACKAGE__->register_method ({
    name => 'setup_transparent_proxy',
    path => 'setup-transparent-proxy',
    method => 'POST',
    description => "配置透明代理",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始配置透明代理");
        
        # 调用透明代理配置脚本
        my $script = "$CLASH_CONFIG_DIR/scripts/setup_transparent_proxy.sh";
        if (-x $script) {
            log_message('DEBUG', "执行透明代理配置脚本: $script");
            my $output = PVE::Tools::run_command($script);
            log_message('INFO', "透明代理配置完成，输出: $output");
            return { success => 1, output => $output };
        } else {
            log_message('ERROR', "透明代理配置脚本不存在或不可执行: $script");
            return { success => 0, error => "透明代理配置脚本不存在" };
        }
    }});

__PACKAGE__->register_method ({
    name => 'get_traffic',
    path => 'traffic',
    method => 'GET',
    description => "获取流量统计",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始获取流量统计");
        
        my $ua = LWP::UserAgent->new;
        $ua->timeout(5);
        
        eval {
            log_message('DEBUG', "尝试获取流量统计: $CLASH_API_BASE/traffic");
            my $res = $ua->get("$CLASH_API_BASE/traffic");
            
            if ($res->is_success) {
                my $data = decode_json($res->decoded_content);
                log_message('INFO', "流量统计获取成功: " . encode_json($data));
                return $data;
            } else {
                log_message('WARN', "获取流量统计失败: " . $res->status_line);
            }
        };
        
        if ($@) {
            log_message('ERROR', "获取流量统计时发生错误: $@");
        }
        
        log_message('INFO', "返回默认流量统计");
        return { upload => 0, download => 0 };
    }});

__PACKAGE__->register_method ({
    name => 'get_logs',
    path => 'logs',
    method => 'GET',
    description => "获取连接日志",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            level => {
                type => 'string',
                description => '日志级别',
                optional => 1,
            },
            limit => {
                type => 'integer',
                description => '日志条数限制',
                optional => 1,
            },
        },
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        my $level = $param->{level} || 'info';
        my $limit = $param->{limit} || 100;
        
        log_message('INFO', "开始获取连接日志: 级别=$level, 限制=$limit");
        
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        
        eval {
            my $url = "$CLASH_API_BASE/logs";
            my $params = {};
            $params->{level} = $level;
            $params->{limit} = $limit;
            
            if (keys %$params) {
                $url .= "?" . join("&", map { "$_=$params->{$_}" } keys %$params);
            }
            
            log_message('DEBUG', "获取日志请求: $url");
            my $res = $ua->get($url);
            
            if ($res->is_success) {
                my $data = decode_json($res->decoded_content);
                my $log_count = scalar(@{$data->{logs} || []});
                log_message('INFO', "成功获取连接日志，共 $log_count 条记录");
                return $data;
            } else {
                log_message('ERROR', "获取日志失败: " . $res->status_line);
                die "获取日志失败: " . $res->status_line;
            }
        };
        
        if ($@) {
            log_message('ERROR', "获取日志时发生错误: $@");
            die $@;
        }
    }});

__PACKAGE__->register_method ({
    name => 'get_version',
    path => 'version',
    method => 'GET',
    description => "获取插件版本信息",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始获取版本信息");
        
        my $current_version = "unknown";
        my $version_file = "$CLASH_CONFIG_DIR/version";
        
        if (-f $version_file) {
            open(my $fh, '<', $version_file) or die "Cannot open version file: $!";
            chomp($current_version = <$fh>);
            close($fh);
        }
        
        my $result = {
            current_version => $current_version,
            plugin_name => "Proxmox Clash Plugin",
            api_version => "1.0"
        };
        
        log_message('INFO', "版本信息获取成功: " . encode_json($result));
        return $result;
    }});

__PACKAGE__->register_method ({
    name => 'check_updates',
    path => 'version/check',
    method => 'GET',
    description => "检查可用更新",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        log_message('INFO', "开始检查可用更新");
        
        # 调用升级脚本检查更新
        my $script = "$CLASH_CONFIG_DIR/scripts/upgrade.sh";
        if (-x $script) {
            log_message('DEBUG', "执行版本检查脚本: $script -c");
            my $output = PVE::Tools::run_command("$script -c");
            log_message('INFO', "版本检查完成，输出: $output");
            
            # 解析输出判断是否有更新
            my $has_update = ($output =~ /发现新版本/);
            my $latest_version = "unknown";
            
            if ($output =~ /最新版本:\s*([^\s]+)/) {
                $latest_version = $1;
            }
            
            return {
                has_update => $has_update,
                latest_version => $latest_version,
                output => $output
            };
        } else {
            log_message('ERROR', "升级脚本不存在或不可执行: $script");
            return { has_update => 0, error => "升级脚本不存在" };
        }
    }});

__PACKAGE__->register_method ({
    name => 'perform_upgrade',
    path => 'version/upgrade',
    method => 'POST',
    description => "执行插件升级",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            version => {
                type => 'string',
                description => '目标版本 (latest 表示最新版本)',
                optional => 1,
            },
        },
    },
    returns => { type => 'object' },
    code => sub {
        my ($param) = @_;
        
        my $target_version = $param->{version} || 'latest';
        
        log_message('INFO', "开始执行插件升级: 目标版本=$target_version");
        
        # 调用升级脚本
        my $script = "$CLASH_CONFIG_DIR/scripts/upgrade.sh";
        if (-x $script) {
            log_message('DEBUG', "执行升级脚本: $script -l");
            my $output = PVE::Tools::run_command("$script -l");
            log_message('INFO', "升级完成，输出: $output");
            
            # 判断升级是否成功
            my $success = ($output =~ /升级完成/);
            
            return {
                success => $success,
                output => $output
            };
        } else {
            log_message('ERROR', "升级脚本不存在或不可执行: $script");
            return { success => 0, error => "升级脚本不存在" };
        }
    }});

1; 