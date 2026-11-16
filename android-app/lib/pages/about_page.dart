/// 关于页：说明 App 定位、使用步骤、数据来源、V1 边界
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('Helixbox · Android 遥控器'),
          subtitle: Text('V1.0 · WiFi 局域网控制端'),
        ),
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
          '本 App 是 Helixbox（基于开源项目 skydevil88/XboxDownload 原理）的手机遥控器。'
          '原理是把国外下载域名跳转国内 CDN，加速 Xbox / 微软商店 / PS / NS 下载。'
          '测速引擎跑在软路由上（宽带出口，测的就是游戏机下载走的那条路，最准），'
          '手机只通过 WiFi 局域网查看结果、按运营商筛选、点选下发。',
          style: TextStyle(height: 1.7),
        ))),
        const SizedBox(height: 12),
        const Text('测速在哪做？', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('推荐路由器测速：测的是“宽带出口→CDN”，与游戏机下载同一条路，7×24 在线可定时自动测。\n'
            '手机测速多走一跳 WiFi、且只在打开 App 时有效，只作参考（右上角图标可切换本机测速）。',
            style: TextStyle(height: 1.8, color: Colors.grey)),
        const SizedBox(height: 12),
        const Text('使用四步', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('1. 软路由安装 luci-app-Helixbox.ipk 并“一键部署”。\n'
            '2. 手机连同一 WiFi，在“控制路由器”添加设备（地址填 路由器IP:8080）。\n'
            '3. “测速选 IP”让路由器跑 v3 快测，按运营商挑最快节点，点“下发”。\n'
            '4. Xbox 的 DNS 设为路由器 IP，开始下载；下完改回自动。', style: TextStyle(height: 1.8)),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('开源项目主页'),
          subtitle: const Text('github.com/skydevil88/XboxDownload'),
          onTap: () => launchUrl(Uri.parse('https://github.com/skydevil88/XboxDownload')),
        ),
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
          '免责声明：本项目为技术学习与个人使用目的，加速效果取决于运营商与 CDN 节点，'
          '不保证所有地区/游戏有效。请遵守当地法律法规与平台服务条款。',
          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.6),
        ))),
      ]),
    );
  }
}
