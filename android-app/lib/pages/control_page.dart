/// 控制页：管理路由器设备列表 → 远程开关加速 / 自检 / 刷新 IP
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/router_device.dart';
import '../services/router_api.dart';
import '../services/storage_service.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});
  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late StorageService _storage;
  List<RouterDevice> _routers = [];
  String _log = '点击设备卡片下方的按钮进行控制。';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _storage = await StorageService.create();
    if (mounted) setState(() => _routers = _storage.getRouters());
  }

  Future<void> _addDevice() async {
    final nameCtrl = TextEditingController(text: '家里路由器');
    final hostCtrl = TextEditingController(text: '192.168.1.1');
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加路由器'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '名称')),
          TextField(controller: hostCtrl, decoration: const InputDecoration(labelText: '地址（IP 或 http://IP:8080）')),
          TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'LuCI 用户名（可留空）')),
          TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'LuCI 密码（可留空）'), obscureText: true),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('保存')),
        ],
      ),
    );
    if (ok == true && hostCtrl.text.trim().isNotEmpty) {
      final d = RouterDevice(
        name: nameCtrl.text.trim().isEmpty ? '路由器' : nameCtrl.text.trim(),
        host: hostCtrl.text.trim(),
        username: userCtrl.text.trim().isEmpty ? null : userCtrl.text.trim(),
        password: passCtrl.text.isEmpty ? null : passCtrl.text,
      );
      final list = List<RouterDevice>.from(_routers)..add(d);
      await _storage.saveRouters(list);
      if (mounted) setState(() => _routers = list);
    }
  }

  Future<void> _removeAt(int i) async {
    final list = List<RouterDevice>.from(_routers)..removeAt(i);
    await _storage.saveRouters(list);
    if (mounted) setState(() => _routers = list);
  }

  Future<void> _act(RouterDevice d, String action, String label) async {
    setState(() { _busy = true; _log = '正在 $label …'; });
    final r = await RouterApi.call(d, action);
    var text = '[$label] ${r.ok ? "成功" : "失败"}：${r.msg.isEmpty ? (r.ok ? "完成" : "无返回") : r.msg}';
    if (r.raw['ip'] != null) text += '（IP ${r.raw['ip']}, ${r.raw['latency_ms']}ms）';
    if (mounted) setState(() { _busy = false; _log = text; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('控制路由器'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _addDevice),
      ]),
      body: Column(children: [
        Expanded(
          child: _routers.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.router, size: 56, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  const Text('还没有设备，点右上角 + 添加'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _addDevice, child: const Text('添加路由器')),
                ]))
              : ListView.builder(
                  itemCount: _routers.length,
                  itemBuilder: (context, i) {
                    final d = _routers[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Icon(Icons.router, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _removeAt(i)),
                          ]),
                          Text(d.baseUrl, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, children: [
                            ActionChip(label: const Text('状态'), onPressed: _busy ? null : () => _act(d, 'status', '读取状态')),
                            ActionChip(label: const Text('开启'), onPressed: _busy ? null : () => _act(d, 'start', '开启加速')),
                            ActionChip(label: const Text('关闭'), onPressed: _busy ? null : () => _act(d, 'stop', '关闭加速')),
                            ActionChip(label: const Text('自检'), onPressed: _busy ? null : () => _act(d, 'selfcheck', '自检跳转')),
                            ActionChip(label: const Text('测速'), onPressed: () => Navigator.pushNamed(context, '/speedtest')),
                            ActionChip(label: const Text('部署'), onPressed: _busy ? null : () => _act(d, 'deploy', '一键部署')),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppTheme.cardDark,
          child: Text(_log, style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
      ]),
    );
  }
}
