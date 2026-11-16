/// IP 服务：拉官方 IP 库 + TCP 测速选最快
/// 测速方式：对 IP:80 发起 Socket 连接，记录握手耗时；并发分批跑，避免卡 UI
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/ip_node.dart';

class IpService {
  /// 拉取官方 CN1 IP 库并解析成节点列表
  Future<List<IpNode>> fetchIpList({String? sourceUrl}) async {
    final url = sourceUrl ?? AppConstants.ipSourceCn1;
    final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) {
      throw Exception('拉取 IP 库失败，HTTP ${resp.statusCode}');
    }
    // 官方文件是 UTF-8 中文
    final text = utf8.decode(resp.bodyBytes, allowMalformed: true);
    final nodes = IpNode.parseFromRaw(text);
    if (nodes.isEmpty) throw Exception('IP 库解析为空，官方格式可能已变化');
    return nodes;
  }

  /// 测单个 IP 的 TCP 连接延迟（毫秒），不可达返回 null
  Future<int?> measureLatency(IpNode node, {int port = AppConstants.speedTestPort}) async {
    final sw = Stopwatch()..start();
    Socket? socket;
    try {
      socket = await Socket.connect(node.ip, port,
              timeout: const Duration(seconds: 2));
      sw.stop();
      return sw.elapsedMilliseconds;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    } finally {
      socket?.destroy();
    }
  }

  /// 批量测速：每批并发 [batch] 个，测完一批回调进度
  /// 返回按延迟升序排好的节点（不可达的排在最后）
  Future<List<IpNode>> measureAll(
    List<IpNode> nodes, {
    int batch = 12,
    void Function(int done, int total)? onProgress,
  }) async {
    final result = <IpNode>[];
    int done = 0;
    for (int i = 0; i < nodes.length; i += batch) {
      final end = (i + batch < nodes.length) ? i + batch : nodes.length;
      final slice = nodes.sublist(i, end);
      final measured = await Future.wait(
        slice.map((n) async {
          final ms = await measureLatency(n);
          done++;
          onProgress?.call(done, nodes.length);
          return n.copyWith(latencyMs: ms);
        }),
      );
      result.addAll(measured);
    }
    result.sort((a, b) {
      final la = a.latencyMs ?? 1 << 30;
      final lb = b.latencyMs ?? 1 << 30;
      return la.compareTo(lb);
    });
    return result;
  }

  /// 从已测速列表里挑每组最快的 N 个
  Map<String, List<IpNode>> pickFastest(List<IpNode> measured, {int perGroup = 3}) {
    final usable = measured.where((n) => n.latencyMs != null).toList();
    // 简化策略：按延迟取前 perGroup*3 个，按地区轮转分给三组
    final top = usable.take(perGroup * 3).toList();
    return {
      'primary': top.where((n) => top.indexOf(n) % 3 == 0).take(perGroup).toList(),
      'legacy': top.where((n) => top.indexOf(n) % 3 == 1).take(perGroup).toList(),
      'storeapp': top.where((n) => top.indexOf(n) % 3 == 2).take(perGroup).toList(),
    };
  }
}
