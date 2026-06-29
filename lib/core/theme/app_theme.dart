import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF1B5E20);
  static const primaryDark = Color(0xFF003300);
  static const primaryLight = Color(0xFF4C8C4A);
  static const primarySurface = Color(0xFFE8F5E9);

  static const accent = Color(0xFFFF6F00);
  static const accentSurface = Color(0xFFFFF3E0);

  static const success = Color(0xFF2E7D32);
  static const successSurface = Color(0xFFE8F5E9);

  static const warning = Color(0xFFE65100);
  static const warningSurface = Color(0xFFFFF3E0);

  static const error = Color(0xFFC62828);
  static const errorSurface = Color(0xFFFFEBEE);

  static const info = Color(0xFF0D47A1);
  static const infoSurface = Color(0xFFE3F2FD);

  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF3F4F6);
  static const disabled = Color(0xFFBDBDBD);
  static const disabledSurface = Color(0xFFF1F3F4);
  static const backgroundLight = Color(0xFFF8F9FA);
  static const divider = Color(0xFFE5E7EB);
  static const shadow = Color(0x0D000000);
  static const shadowMedium = Color(0x1A000000);
}

// ─── Text Styles ──────────────────────────────────────────────────────────────
class AppTextStyles {
  static const fontFamily = 'Ubuntu';

  static const _base =
      TextStyle(fontFamily: fontFamily, color: AppColors.textPrimary);

  static final displayLarge =
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  static final displayMedium =
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w700);
  static final headlineLarge =
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700);
  static final headlineMedium =
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w700);
  static final headlineSmall =
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
  static final titleLarge =
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
  static final titleMedium =
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
  static final bodyLarge =
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400);
  static final bodyMedium = _base.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary);
  static final bodySmall = _base.copyWith(
      fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
  static final labelLarge = _base.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static final moneyMedium =
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700);
  static final moneySmall =
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w700);
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: false,
        fontFamily: AppTextStyles.fontFamily,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        dividerTheme:
            const DividerThemeData(color: AppColors.divider, thickness: 1),
        tabBarTheme: const TabBarTheme(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      );
}
