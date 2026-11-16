/// 测速页：默认让软路由跑 v3 抢跑测速（最准），手机只显示结果 + 下发
/// 无路由器时可切“本机测速”降级（走 WiFi 多一跳，仅供参考）
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/ip_node.dart';
import '../models/router_device.dart';
import '../services/ip_service.dart';
import '../services/router_api.dart';
import '../services/storage_service.dart';

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});
  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  final _ipService = IpService();
  late StorageService _storage;
  List<RouterDevice> _routers = [];
  RouterDevice? _device;

  List<IpNode> _nodes = [];
  String? _ispFilter;
  String _status = '连接路由器后点“路由器测速”，结果由软路由给出';
  bool _running = false;
  bool _localMode = false; // false=路由器测速（推荐），true=本机降级

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _storage = await StorageService.create();
    final routers = _storage.getRouters();
    final cached = _storage.getIpCache();
    if (mounted) setState(() {
      _routers = routers;
      if (routers.isNotEmpty) _device = routers.first;
      _nodes = cached;
    });
  }

  /// 路由器测速（主路径）
  Future<void> _runRouter() async {
    final d = _device;
    if (d == null) {
      _hint('请先在“控制路由器”页添加设备');
      return;
    }
    setState(() { _running = true; _status = '软路由正在并发测速：ping 预筛 → 10MB 分片抢跑，约 10 秒…'; });
    final r = await RouterApi.speedtest(d);
    if (!mounted) return;
    if (!r.ok) {
      setState(() { _running = false; _status = '测速失败：${r.msg}'; });
      return;
    }
    final results = (r.raw['results'] as List?) ?? [];
    final nodes = IpNode.fromSpeedResults(results);
    nodes.sort((a, b) => b.bytes.compareTo(a.bytes));
    await _storage.saveIpCache(nodes);
    await _storage.touchCacheTime();
    setState(() {
      _nodes = nodes;
      _running = false;
      _status = '完成！赢家 ${r.raw['winner'] ?? '-'} · ${nodes.length} 个 IP 响应 · 按运营商筛选后点“下发”';
    });
  }

  /// 本机降级测速（无路由器时，仅供参考）
  Future<void> _runLocal() async {
    setState(() { _running = true; _status = '本机拉取官方 IP 库并 TCP 测速（多走一跳 WiFi，仅供参考）…'; });
    try {
      final fetched = await _ipService.fetchIpList();
      final measured = await _ipService.measureAll(fetched);
      await _storage.saveIpCache(measured);
      await _storage.touchCacheTime();
      if (mounted) setState(() {
        _nodes = measured;
        _running = false;
        _status = '本机测速完成（${measured.length} 个）。注意这测的是手机→CDN，建议用路由器测速更准。';
      });
    } catch (e) {
      if (mounted) setState(() { _running = false; _status = '失败：$e'; });
    }
  }

  /// 下发选中 IP 到路由器 primary 组
  Future<void> _apply(IpNode n) async {
    final d = _device;
    if (d == null) { _hint('请先添加路由器'); return; }
    setState(() { _running = true; _status = '正在下发 ${n.ip} 到路由器…'; });
    final r = await RouterApi.applyIp(d, group: 'primary', ip: n.ip, isp: n.isp);
    if (mounted) setState(() {
      _running = false;
      _status = r.ok ? '已下发 ${n.ip}（${n.isp}），正在生效' : '下发失败：${r.msg}';
    });
  }

  void _hint(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _nodes.where((n) {
      if (_ispFilter == null) return true;
      return n.isp == _ispFilter;
    }).toList();
    final isps = _nodes.map((n) => n.isp).where((s) => s.isNotEmpty).toSet().toList()..sort();
    final maxBytes = _nodes.fold<int>(1, (m, n) => n.bytes > m ? n.bytes : m);

    return Scaffold(
      appBar: AppBar(
        title: const Text('测速选 IP'),
        actions: [
          IconButton(
            icon: Icon(_localMode ? Icons.router : Icons.router_outlined),
            tooltip: _localMode ? '切到路由器测速' : '切到本机测速',
            onPressed: () => setState(() => _localMode = !_localMode),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _running ? null : (_localMode ? _runLocal : _runRouter),
        icon: const Icon(Icons.speed),
        label: Text(_localMode ? '本机测速' : '路由器测速'),
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          color: AppTheme.cardDark,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(_localMode ? Icons.phone_android : Icons.router, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(_localMode ? '本机模式（仅参考）' : '路由器模式（推荐）',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text(_status, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            if (!_localMode && _device != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: DropdownButton<RouterDevice>(
                  value: _device,
                  dropdownColor: AppTheme.cardDark,
                  isDense: true,
                  items: _routers.map((d) => DropdownMenuItem(value: d, child: Text(d.name, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (d) => setState(() => _device = d),
                ),
              ),
          ]),
        ),
        if (isps.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: isps.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == 0) return FilterChip(label: const Text('全部'), selected: _ispFilter == null, onSelected: (_) => setState(() => _ispFilter = null));
                final isp = isps[i - 1];
                return FilterChip(label: Text(isp), selected: _ispFilter == isp, onSelected: (_) => setState(() => _ispFilter = isp));
              },
            ),
          ),
        if (_running) const LinearProgressIndicator(minHeight: 3),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('暂无结果，点右下角开始测速'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final n = filtered[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      color: n.isWinner ? AppTheme.primary.withOpacity(0.12) : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: n.isWinner ? AppTheme.primary : AppTheme.cardDark,
                          child: Icon(n.isWinner ? Icons.emoji_events : Icons.dns,
                              size: 16, color: n.isWinner ? Colors.black : AppTheme.textMuted),
                        ),
                        title: Text('${n.ip}   ${n.location} ${n.isp}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('延迟 ${n.latencyMs ?? '-'} ms　下载 ${n.speedText}${n.isWinner ? '　最快' : ''}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            if (n.bytes > 0)
                              LinearProgressIndicator(
                                value: (n.bytes / maxBytes).clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: AppTheme.cardDark,
                                color: AppTheme.primary,
                              ),
                          ]),
                        ),
                        trailing: TextButton(
                          onPressed: _localMode ? null : () => _apply(n),
                          child: const Text('下发'),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
