import 'package:flutter/material.dart';

/// App 主题：Helixbox 品牌视觉 —— 深墨底 + 青绿渐变 + 玻璃卡片
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF00D1B2);
  static const Color primaryDeep = Color(0xFF008C7A);
  static const Color accent = Color(0xFF6EE7D5);
  static const Color bgDark = Color(0xFF0F141A);
  static const Color cardDark = Color(0xFF181F28);
  static const Color cardRaised = Color(0xFF1E2732);
  static const Color textLight = Color(0xFFE8EFF5);
  static const Color textMuted = Color(0xFF8D9BAD);
  static const Color success = Color(0xFF00D1B2);
  static const Color danger = Color(0xFFFF5D6C);
  static const Color warning = Color(0xFFFFB020);

  /// 品牌渐变（横幅 / 主按钮 / 头图统一使用）
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF00D1B2), Color(0xFF008C7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: cardDark,
          onSurface: textLight,
          error: danger,
        ),
        scaffoldBackgroundColor: bgDark,
        cardColor: cardDark,
        cardTheme: CardTheme(
          color: cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF2A3542), width: 0.8),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgDark,
          foregroundColor: textLight,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: textLight,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Color(0xFF04251F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardRaised,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3542)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3542)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: cardRaised,
          selectedColor: primary.withOpacity(0.22),
          labelStyle: const TextStyle(fontSize: 12, color: textLight),
          secondaryLabelStyle: const TextStyle(fontSize: 12, color: textLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Color(0xFF2A3542), width: 0.8),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      );

  /// 品牌渐变横幅容器（各处复用，带圆形光晕装饰）
  static Widget brandBanner({required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: brandGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
}
