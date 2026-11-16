/// 配置生成器：根据选中的最优 IP 生成三种可复制的配置文本
/// 1) OpenWrt / dnsmasq（address=/域名/IP）
/// 2) hosts 文件
/// 3) Nginx 重定向配置（给已有 Nginx 的路由器/NAS 用）
import '../core/constants.dart';

class ConfigGenerator {
  ConfigGenerator._();

  /// OpenWrt dnsmasq 配置：国外域名劫持到路由器 + 国内域名指向最优 IP
  /// [routerIp] 路由器 LAN IP；[selected] {group: ip}
  static String openwrt(String routerIp, Map<String, String> selected) {
    final b = StringBuffer()
      ..writeln('# ===== XboxDownload 加速配置（dnsmasq 自定义配置）=====')
      ..writeln('# 用法：OpenWrt 网络->DHCP/DNS->附加配置文件 指向本文件，')
      ..writeln('#      或加入 /etc/dnsmasq.conf 后重启 dnsmasq')
      ..writeln()
      ..writeln('# 1) 把要跳转的国外域名劫持到路由器自己（由插件的 lighttpd 302 跳转）');
    for (final d in AppConstants.redirectMap.keys) {
      b.writeln('address=/$d/$routerIp');
    }
    b..writeln()..writeln('# 2) 国内 CDN 域名指向测速最快 IP（分三组）');
    _writeGroup(b, 'primary', ['assets1.xboxlive.cn', 'assets2.xboxlive.cn', 'd1.xboxlive.cn', 'd2.xboxlive.cn'], selected);
    _writeGroup(b, 'legacy', ['dlassets.xboxlive.cn', 'dlassets2.xboxlive.cn'], selected);
    _writeGroup(b, 'storeapp', ['dl.delivery.mp.microsoft.com', 'tlu.dl.delivery.mp.microsoft.com'], selected);
    b..writeln()..writeln('# 提示：Xbox 需关闭 IPv6；下载完成后把 DNS 改回自动获取。');
    return b.toString();
  }

  /// hosts 文件格式（给不支持 dnsmasq 的设备）
  static String hosts(String routerIp, Map<String, String> selected) {
    final b = StringBuffer()
      ..writeln('# XboxDownload 加速 hosts（需设备支持自定义 hosts）')
      ..writeln('# 注意：hosts 无法做 302 跳转，国外域名需配合路由器 lighttpd 使用');
    for (final d in AppConstants.redirectMap.keys) {
      b.writeln('$routerIp $d');
    }
    b.writeln();
    for (final entry in selected.entries) {
      final domains = _domainsForGroup(entry.key);
      if (domains.isEmpty) continue;
      b.writeln('# ${AppConstants.ipGroupLabels[entry.key] ?? entry.key}')
        ..writeln('${entry.value} ${domains.join(' ')}');
    }
    return b.toString();
  }

  /// Nginx 302 重定向配置
  static String nginx() {
    final names = AppConstants.redirectMap.keys.toList();
    final nameLines = names.join('\n        ');
    final b = StringBuffer()
      ..writeln('server_names_hash_bucket_size 64;')
      ..writeln('server {')
      ..writeln('    listen 80;')
      ..writeln('    server_name')
      ..writeln('        $nameLines;')
      ..writeln()
      ..writeln('    # dlassets 老游戏域名单独跳转')
      ..writeln('    if (\$host ~* "^dlassets2?\\.xboxlive\\.com\$") {')
      ..writeln('        return 302 http://dlassets.xboxlive.cn\$request_uri;')
      ..writeln('    }')
      ..writeln('    # 其余域名统一跳转到 assets1 国内 CDN')
      ..writeln('    return 302 http://assets1.xboxlive.cn\$request_uri;')
      ..writeln('}');
    return b.toString();
  }

  static void _writeGroup(StringBuffer b, String group, List<String> domains, Map<String, String> selected) {
    final ip = selected[group];
    if (ip == null || ip.isEmpty) {
      b.writeln('# $group：未选择 IP，跳过');
      return;
    }
    for (final d in domains) {
      b.writeln('address=/$d/$ip');
    }
  }

  static List<String> _domainsForGroup(String group) {
    switch (group) {
      case 'primary':
        return ['assets1.xboxlive.cn', 'assets2.xboxlive.cn', 'd1.xboxlive.cn', 'd2.xboxlive.cn'];
      case 'legacy':
        return ['dlassets.xboxlive.cn', 'dlassets2.xboxlive.cn'];
      case 'storeapp':
        return ['dl.delivery.mp.microsoft.com', 'tlu.dl.delivery.mp.microsoft.com'];
      default:
        return [];
    }
  }
}
