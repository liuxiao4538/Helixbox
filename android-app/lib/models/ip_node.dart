/// 一个候选 CDN IP 节点：IP + 地区 + 运营商 + 测速结果
/// 字段与 exe v3 / Helixbox 插件 speedtest 返回一致
class IpNode {
  final String ip;
  final String location; // 例：中国广东深圳
  final String isp; // 例：电信
  final int? latencyMs; // ping 延迟，越小越好；null 表示未测/不可达
  final int bytes; // 10MB 分片实际下载字节数（越大越快）
  final bool isWinner; // 抢跑赢家

  const IpNode({
    required this.ip,
    required this.location,
    required this.isp,
    this.latencyMs,
    this.bytes = 0,
    this.isWinner = false,
  });

  IpNode copyWith({int? latencyMs, int? bytes, bool? isWinner}) => IpNode(
        ip: ip,
        location: location,
        isp: isp,
        latencyMs: latencyMs ?? this.latencyMs,
        bytes: bytes ?? this.bytes,
        isWinner: isWinner ?? this.isWinner,
      );

  /// 官方 IP 库是单行，形如：114.105.125.22 (中国安徽阜阳 电信) 60.167.226.211 (...)
  static List<IpNode> parseFromRaw(String raw) {
    final reg = RegExp(r'(\d{1,3}(?:\.\d{1,3}){3})\s*\(([^)]*)\)');
    final nodes = <IpNode>[];
    for (final m in reg.allMatches(raw)) {
      final ip = m.group(1)!;
      final info = m.group(2)!.trim().split(RegExp(r'\s+'));
      final location = info.isNotEmpty ? info[0] : '';
      final isp = info.length > 1 ? info.sublist(1).join(' ') : '';
      nodes.add(IpNode(ip: ip, location: location, isp: isp));
    }
    return nodes;
  }

  /// 从 Helixbox 插件 speedtest API 的 results 数组解析
  static List<IpNode> fromSpeedResults(List<dynamic> results) {
    return results.map((e) {
      final m = e as Map<String, dynamic>;
      return IpNode(
        ip: (m['ip'] ?? '').toString(),
        location: (m['loc'] ?? '').toString(),
        isp: (m['isp'] ?? '').toString(),
        latencyMs: m['ms'] is int ? m['ms'] as int : int.tryParse('${m['ms']}'),
        bytes: m['bytes'] is int ? m['bytes'] as int : int.tryParse('${m['bytes']}') ?? 0,
        isWinner: m['win'] == true,
      );
    }).toList();
  }

  /// 下载量换算成 MB 文本
  String get speedText => '${(bytes / 1048576).toStringAsFixed(1)} MB';

  @override
  String toString() => '$ip $location $isp ${latencyMs == null ? '' : '${latencyMs}ms'}';
}
