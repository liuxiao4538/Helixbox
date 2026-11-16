/// 本地存储：保存选中的 IP、路由器列表、上次拉取的 IP 缓存
/// 用 SharedPreferences（轻量 key-value，App 卸载后清除）
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ip_node.dart';
import '../models/router_device.dart';

class StorageService {
  static const _kSelectedIps = 'selected_ips'; // json: {group: ip}
  static const _kRouters = 'routers'; // json: [router...]
  static const _kIpCache = 'ip_cache'; // json: [ip, location, isp, latency]
  static const _kCacheTime = 'ip_cache_time';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  // ---------- 选中的 IP ----------
  Map<String, String> getSelectedIps() {
    final raw = _prefs.getString(_kSelectedIps);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveSelectedIps(Map<String, String> ips) =>
      _prefs.setString(_kSelectedIps, jsonEncode(ips));

  // ---------- 路由器设备 ----------
  List<RouterDevice> getRouters() {
    final raw = _prefs.getString(_kRouters);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => RouterDevice.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveRouters(List<RouterDevice> routers) =>
      _prefs.setString(_kRouters, jsonEncode(routers.map((r) => r.toJson()).toList()));

  // ---------- IP 列表缓存（离线也能看）----------
  List<IpNode> getIpCache() {
    final raw = _prefs.getString(_kIpCache);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) {
      final m = e as Map;
      return IpNode(
        ip: m['ip'] as String,
        location: m['location'] as String? ?? '',
        isp: m['isp'] as String? ?? '',
        latencyMs: m['latency'] as int?,
      );
    }).toList();
  }

  Future<void> saveIpCache(List<IpNode> nodes) => _prefs.setString(
        _kIpCache,
        jsonEncode(nodes.map((n) => {
              'ip': n.ip,
              'location': n.location,
              'isp': n.isp,
              'latency': n.latencyMs,
            }).toList()),
      );

  DateTime? getCacheTime() {
    final ms = _prefs.getInt(_kCacheTime);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> touchCacheTime() =>
      _prefs.setInt(_kCacheTime, DateTime.now().millisecondsSinceEpoch);
}
