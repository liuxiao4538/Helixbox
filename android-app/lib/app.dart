import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'pages/home_page.dart';
import 'pages/speedtest_page.dart';
import 'pages/config_page.dart';
import 'pages/control_page.dart';
import 'pages/about_page.dart';

/// 根 Widget：配置主题 + 四个主页面 + 关于页
class XboxDownloadApp extends StatelessWidget {
  const XboxDownloadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XboxDownload 加速器',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/speedtest': (_) => const SpeedTestPage(),
        '/config': (_) => const ConfigPage(),
        '/control': (_) => const ControlPage(),
        '/about': (_) => const AboutPage(),
      },
    );
  }
}
