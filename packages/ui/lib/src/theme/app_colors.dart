import 'package:flutter/material.dart';

/// FireflyIII Neo complete color system
abstract class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF); // Electric violet
  static const Color primaryVariant = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A43CC);
  static const Color secondary = Color(0xFF00D4AA); // Emerald teal
  static const Color secondaryVariant = Color(0xFF00F5C8);
  static const Color secondaryDark = Color(0xFF00A882);
  static const Color accent = Color(0xFFFF6B6B); // Coral red
  static const Color accentVariant = Color(0xFFFF9999);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color income = Color(0xFF00D4AA);
  static const Color incomeLight = Color(0xFF1AFFD5);
  static const Color expense = Color(0xFFFF6B6B);
  static const Color expenseLight = Color(0xFFFF9999);
  static const Color transfer = Color(0xFF6C63FF);
  static const Color transferLight = Color(0xFF9D97FF);
  static const Color warning = Color(0xFFFFB800);
  static const Color warningLight = Color(0xFFFFD060);
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFF69F0AE);
  static const Color error = Color(0xFFFF3D57);
  static const Color errorLight = Color(0xFFFF7687);
  static const Color info = Color(0xFF00B0FF);
  static const Color infoLight = Color(0xFF64CFFF);

  // ─── Dark theme surfaces ──────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF13131A);
  static const Color darkCard = Color(0xFF1A1A24);
  static const Color darkElevated = Color(0xFF22222F);
  static const Color darkHighlight = Color(0xFF2D2D3F);
  static const Color darkBorder = Color(0xFF2A2A3C);
  static const Color darkDivider = Color(0xFF1E1E2E);
  static const Color darkOverlay = Color(0x80000000);

  // ─── Light theme surfaces ─────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF0F0F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFAFAFF);
  static const Color lightElevated = Color(0xFFEEEEFA);
  static const Color lightBorder = Color(0xFFDDDDEE);
  static const Color lightDivider = Color(0xFFE8E8F0);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFF8888A8);
  static const Color darkTextDisabled = Color(0xFF44445A);
  static const Color darkTextHint = Color(0xFF55556B);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B8A);
  static const Color lightTextDisabled = Color(0xFFAAAAAD);
  static const Color lightTextHint = Color(0xFFBBBBCC);

  // ─── Glassmorphism ────────────────────────────────────────────────────────
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color glassBorderDark = Color(0x22000000);

  // ─── Chart palette ────────────────────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF00D4AA),
    Color(0xFFFF6B6B),
    Color(0xFFFFB800),
    Color(0xFF7B68EE),
    Color(0xFF20B2AA),
    Color(0xFFFF8C69),
    Color(0xFF9370DB),
    Color(0xFF3CB371),
    Color(0xFFFF69B4),
    Color(0xFF00CED1),
    Color(0xFFDC143C),
  ];

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF00F5C8)],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF1AFFD5)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF9999)],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A24), Color(0xFF13131A)],
  );

  static const LinearGradient assetCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
  );

  static const LinearGradient liabilityCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C1D1D), Color(0xFF7F1D1D)],
  );

  static const LinearGradient cashCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF065F46)],
  );

  /// Returns the semantic color for a transaction type string
  static Color transactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return income;
      case 'withdrawal':
        return expense;
      case 'transfer':
        return transfer;
      default:
        return primary;
    }
  }

  /// Returns a chart color by index (cycles through palette)
  static Color chartColorAt(int index) =>
      chartColors[index % chartColors.length];
}
