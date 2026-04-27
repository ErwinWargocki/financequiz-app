import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  const AppColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  static const dark = AppColors(
    success: Color(0xFF00E5A0),
    warning: Color(0xFFFFB800),
    danger: Color(0xFFFF4757),
    info: Color(0xFF4C6EF5),
  );

  static const light = AppColors(
    success: Color(0xFF00B87A),
    warning: Color(0xFFE6A200),
    danger: Color(0xFFD32F2F),
    info: Color(0xFF1F7AE0),
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
