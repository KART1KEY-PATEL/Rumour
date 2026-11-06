import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.bubbleIncoming,
    required this.dateChip,
    required this.error,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color accent;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color bubbleIncoming;
  final Color dateChip;
  final Color error;

  static const dark = AppColors(
    background: Color(0xFF0A0A0C),
    surface: Color.fromRGBO(17, 24, 39, 0.8),
    surfaceVariant:Color.fromRGBO(17, 24, 39, 0.8),
    accent: Color(0xFFBFFF3D),
    onAccent: Color(0xFF101204),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFD1D5DB),
    bubbleIncoming: Color(0xFF1E2028),
    dateChip: Color(0xFF1C1C21),
    error: Color(0xFFFF6B6B),
  );

  static const light = AppColors(
    background: Color(0xFFF7F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEAEAF0),
    accent: Color(0xFFBFFF3D),
    onAccent: Color(0xFF101204),
    textPrimary: Color(0xFF15151B),
    textSecondary: Color(0xFF68686F),
    bubbleIncoming: Color(0xFFEAEAF0),
    dateChip: Color(0xFFE2E2EA),
    error: Color(0xFFD1453A),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? accent,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? bubbleIncoming,
    Color? dateChip,
    Color? error,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      bubbleIncoming: bubbleIncoming ?? this.bubbleIncoming,
      dateChip: dateChip ?? this.dateChip,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      bubbleIncoming: Color.lerp(bubbleIncoming, other.bubbleIncoming, t)!,
      dateChip: Color.lerp(dateChip, other.dateChip, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle title(AppColors c) => TextStyle(
    color: c.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );

  static TextStyle subtitle(AppColors c) => TextStyle(
    color: c.textSecondary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle headerTitle(AppColors c) => TextStyle(
    color: c.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headerSubtitle(AppColors c) =>
      TextStyle(color: c.textSecondary, fontSize: 13);

  static TextStyle identityLabel(AppColors c) =>
      TextStyle(color: c.textSecondary, fontSize: 14);

  static TextStyle identityName(AppColors c) => TextStyle(
    color: c.accent,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  static TextStyle identityHint(AppColors c) =>
      TextStyle(color: c.textSecondary, fontSize: 13, height: 1.4);

  static TextStyle buttonLabel(AppColors c) =>
      TextStyle(color: c.onAccent, fontSize: 16, fontWeight: FontWeight.w700);

  static TextStyle senderLabel(AppColors c) => TextStyle(
    color: c.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle messageText(AppColors c) =>
      TextStyle(color: c.textPrimary, fontSize: 15, height: 1.3);

  static TextStyle outgoingMessageText(AppColors c) =>
      TextStyle(color: c.onAccent, fontSize: 15, height: 1.3);

  static TextStyle timestamp(AppColors c) =>
      TextStyle(color: c.textSecondary, fontSize: 11);
}

ThemeData _buildTheme(AppColors colors, Brightness brightness) {
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: colors.background,
    colorScheme: base.colorScheme.copyWith(
      surface: colors.background,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      error: colors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: colors.textPrimary),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.accent,
      selectionColor: colors.accent,
      selectionHandleColor: colors.accent,
    ),
    splashFactory: NoSplash.splashFactory,
    extensions: [colors],
  );
}

ThemeData buildLightTheme() => _buildTheme(AppColors.light, Brightness.light);

ThemeData buildDarkTheme() => _buildTheme(AppColors.dark, Brightness.dark);
