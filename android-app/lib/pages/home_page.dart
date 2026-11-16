/// 首页：Helixbox 品牌头图 + 状态概览 + 功能入口卡片
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<StorageService> _storage;

  @override
  void initState() {
    super.initState();
    _storage = StorageService.create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helixbox'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () => Navigator.pushNamed(context, '/about')),
        ],
      ),
      body: FutureBuilder<StorageService>(
        future: _storage,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final storage = snap.data!;
          final routers = storage.getRouters();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _hero(routers.isNotEmpty),
              const SizedBox(height: 22),
              _sectionTitle('功能'),
              const SizedBox(height: 8),
              _entry(
                icon: Icons.speed_rounded,
                tone: AppTheme.success,
                title: '测速选 IP',
                subtitle: '让软路由跑 v3 快测，按运营商挑最快节点并下发',
                onTap: () => Navigator.pushNamed(context, '/speedtest'),
              ),
              _entry(
                icon: Icons.router_rounded,
                tone: const Color(0xFF5B8DEF),
                title: '控制路由器',
                subtitle: '已保存 ${routers.length} 台设备，WiFi 局域网远程开关 / 自检 / 部署',
                onTap: () => Navigator.pushNamed(context, '/control'),
              ),
              _entry(
                icon: Icons.description_rounded,
                tone: AppTheme.warning,
                title: '生成配置',
                subtitle: '备用：导出 OpenWrt / hosts / Nginx 配置文本',
                onTap: () => Navigator.pushNamed(context, '/config'),
              ),
              const SizedBox(height: 20),
              _tip(),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String s) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(s, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
      );

  Widget _hero(bool hasRouter) => AppTheme.brandBanner(
        child: Stack(
          children: [
            Positioned(
              right: -30, top: -50,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Center(
                        child: Text('H', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Helixbox', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF04251F), letterSpacing: .5)),
                      Text('软路由下载加速 · 手机遥控器', style: TextStyle(fontSize: 12, color: Color(0xFF0B4A40))),
                    ]),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.22), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(hasRouter ? Icons.check_circle : Icons.info_outline, size: 14, color: const Color(0xFF04251F)),
                      const SizedBox(width: 6),
                      Text(
                        hasRouter ? '已配置路由器 · 可远程控制' : '尚未添加路由器 · 点下方“控制路由器”开始',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF04251F)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '测速在软路由上跑（宽带出口，最准），手机只通过 WiFi 查看结果并点选下发。',
                    style: TextStyle(fontSize: 12, color: Color(0xFF083C34), height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _entry({
    required IconData icon,
    required Color tone,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: tone.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: tone, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5, height: 1.35)),
            ])),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ]),
        ),
      ),
    );
  }

  Widget _tip() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A3542), width: .8),
        ),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.lightbulb_outline, size: 17, color: AppTheme.warning),
          SizedBox(width: 10),
          Expanded(child: Text(
            '本 App 是 Helixbox 的手机遥控器，需连家里 WiFi 并配合已装 Helixbox 插件的软路由使用。测速在路由器上跑，手机只负责看结果和点选下发。',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5, height: 1.6),
          )),
        ]),
      );
}
