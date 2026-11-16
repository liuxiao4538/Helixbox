/// 路由器 API 客户端：手机通过 WiFi 局域网调用 Helixbox 插件的 JSON API
/// 手机是遥控器；测速由路由器执行（宽带出口，测的就是游戏机下载走的那条路）
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/router_device.dart';

class RouterResult {
  final bool ok;
  final String msg;
  final Map<String, dynamic> raw;
  RouterResult({required this.ok, required this.msg, required this.raw});

  factory RouterResult.fromJson(Map<String, dynamic> j) => RouterResult(
        ok: j['ok'] == true || j['ok'] == 1,
        msg: (j['msg'] ?? '').toString(),
        raw: j,
      );
}

class RouterApi {
  /// 通用调用：action + 可选 query 参数
  static Future<RouterResult> call(
    RouterDevice device,
    String action, {
    Map<String, String>? params,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final query = <String, String>{'action': action, ...?params};
    final uri = Uri.parse('${device.baseUrl}${AppConstants.pluginApiPath}')
        .replace(queryParameters: query);
    final headers = <String, String>{'Accept': 'application/json'};
    if (device.username != null && device.password != null) {
      final cred = base64Encode(utf8.encode('${device.username}:${device.password}'));
      headers['Authorization'] = 'Basic $cred';
    }
    try {
      final resp = await http.get(uri, headers: headers).timeout(timeout);
      if (resp.statusCode == 401) {
        return RouterResult(ok: false, msg: '需要 LuCI 用户名/密码', raw: {});
      }
      if (resp.statusCode != 200) {
        return RouterResult(ok: false, msg: 'HTTP ${resp.statusCode}（确认用 :8080 且已部署）', raw: {});
      }
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return RouterResult.fromJson(json);
    } on http.ClientException catch (e) {
      return RouterResult(ok: false, msg: '连接失败：$e', raw: {});
    } catch (e) {
      return RouterResult(ok: false, msg: '请求异常：$e', raw: {});
    }
  }

  /// 让路由器执行 v3 抢跑测速（约 10 秒）
  static Future<RouterResult> speedtest(RouterDevice device) =>
      call(device, 'speedtest', timeout: const Duration(seconds: 25));

  /// 把选中的 IP 下发给路由器某分组生效
  static Future<RouterResult> applyIp(
    RouterDevice device, {
    required String group,
    required String ip,
    required String isp,
  }) =>
      call(device, 'apply_ip',
          params: {'group': group, 'ip': ip, 'isp': isp},
          timeout: const Duration(seconds: 15));

  static Future<RouterResult> testConnection(RouterDevice device) => call(device, 'status');
}
