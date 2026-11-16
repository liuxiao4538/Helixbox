/// 全局常量：官方数据源、域名分组、API 路径
class AppConstants {
  AppConstants._();

  /// 产品命名
  static const String productName = 'Helixbox';

  /// 测速 URL（与 exe v3 / 插件引擎一致，本地降级测速用）
  static const List<String> speedTestUrls = [
    'http://xvcf1.xboxlive.com/Z/routing/extraextralarge.txt',
    'http://gst.prod.dl.playstation.net/networktest/get_192m',
    'http://ctest-dl-lp1.cdn.nintendo.net/30m',
  ];

  /// 常见运营商（筛选 chip）
  static const List<String> commonIsps = ['电信', '联通', '移动', '长城', '教育网'];

  /// 官方 IP 库（单行格式：IP (地区 运营商) IP (地区 运营商) ...）
  static const String ipSourceCn1 =
      'https://raw.githubusercontent.com/skydevil88/XboxDownload/master/IP/IP.XboxCn1.txt';
  static const String ipSourceCn2 =
      'https://raw.githubusercontent.com/skydevil88/XboxDownload/master/IP/IP.XboxCn2.txt';
  static const String ipSourceAkamai =
      'https://raw.githubusercontent.com/skydevil88/XboxDownload/master/IP/IP.Akamai.txt';

  /// 测速目标端口：HTTP 80（对应下载域名）
  static const int speedTestPort = 80;

  /// 需要被劫持跳转的国外域名 -> 国内目标域名
  static const Map<String, String> redirectMap = {
    'assets1.xboxlive.com': 'assets1.xboxlive.cn',
    'assets2.xboxlive.com': 'assets1.xboxlive.cn',
    'd1.xboxlive.com': 'assets1.xboxlive.cn',
    'd2.xboxlive.com': 'assets1.xboxlive.cn',
    'xvcf1.xboxlive.com': 'assets1.xboxlive.cn',
    'xvcf2.xboxlive.com': 'assets1.xboxlive.cn',
    'dlassets.xboxlive.com': 'dlassets.xboxlive.cn',
    'dlassets2.xboxlive.com': 'dlassets.xboxlive.cn',
    '5.xb.delivery.microsoft.com': 'assets1.xboxlive.cn',
    'assets1.xboxlive.com.edgesuite.net': 'assets1.xboxlive.cn',
    'cl-glcb907925.gcdn.co': 'assets1.xboxlive.cn',
    'fg.microsoft.map.fastly.net': 'assets1.xboxlive.cn',
  };

  /// 三类 IP 分组（与 OpenWrt 插件 UCI 配置一致）
  static const List<String> ipGroups = ['primary', 'legacy', 'storeapp'];
  static const Map<String, String> ipGroupLabels = {
    'primary': '主下载域名 (assets/d1/d2)',
    'legacy': '老游戏域名 (dlassets)',
    'storeapp': '应用与 PC 游戏域名',
  };

  /// 插件 JSON API 路径（拼在路由器地址后面）
  static const String pluginApiPath = '/cgi-bin/luci/admin/services/helixbox/api';
}
