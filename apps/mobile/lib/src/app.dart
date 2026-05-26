import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_core/neo_core.dart';
import 'router/app_router.dart';

class FireflyNeoApp extends ConsumerWidget {
  const FireflyNeoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeStr = ref.watch(themeModeProvider);
    final themeMode = themeStr == 'dark'
        ? ThemeMode.dark
        : themeStr == 'light'
            ? ThemeMode.light
            : ThemeMode.system;

    return MaterialApp.router(
      title: 'FireflyIII Neo',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      colorSchemeSeed: const Color(0xFF6750A4),
      brightness: Brightness.light,
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xFFF6F5FB),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
        surface: const Color(0xFF0D0D12),
        onSurface: Colors.white,
      ),
      brightness: Brightness.dark,
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0D12),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
    );
  }
}
