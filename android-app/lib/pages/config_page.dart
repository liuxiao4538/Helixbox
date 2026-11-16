/// 配置生成页：输入路由器 IP → 生成 OpenWrt / hosts / Nginx 三种配置 → 复制/分享
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../services/config_generator.dart';
import '../services/storage_service.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});
  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _routerIpCtrl = TextEditingController(text: '192.168.1.1');
  late StorageService _storage;
  Map<String, String> _selected = {};
  String _tab = 'openwrt';
  String _text = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _storage = await StorageService.create();
    final sel = _storage.getSelectedIps();
    if (mounted) setState(() { _selected = sel; });
    _regen();
  }

  void _regen() {
    final ip = _routerIpCtrl.text.trim().isEmpty ? '192.168.1.1' : _routerIpCtrl.text.trim();
    setState(() {
      _text = _tab == 'openwrt'
          ? ConfigGenerator.openwrt(ip, _selected)
          : _tab == 'hosts'
              ? ConfigGenerator.hosts(ip, _selected)
              : ConfigGenerator.nginx();
    });
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('配置已复制到剪贴板')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成配置')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _routerIpCtrl,
              decoration: const InputDecoration(labelText: '路由器 LAN IP', prefixIcon: Icon(Icons.router)),
              onChanged: (_) => _regen(),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            if (_selected.isEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.orange.withOpacity(0.15),
                child: const Text('还没选 IP，配置里的国内域名将留空。建议先去“测速选 IP”。', style: TextStyle(fontSize: 12)),
              ),
            Row(
              children: ['openwrt', 'hosts', 'nginx'].map((t) {
                final label = {'openwrt': 'OpenWrt', 'hosts': 'hosts', 'nginx': 'Nginx'}[t]!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(label), selected: _tab == t, onSelected: (_) { setState(() => _tab = t); _regen(); }),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                child: SingleChildScrollView(child: SelectableText(_text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5))),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(onPressed: _copy, icon: const Icon(Icons.copy), label: const Text('复制配置')),
          ],
        ),
      ),
    );
  }
}
