import 'package:flutter/material.dart';

class StudyCategoryInfo {
  final String label;
  final String? difficulty;
  final Color color;
  final String icon;
  final String subtitle;

  const StudyCategoryInfo({
    required this.label,
    required this.difficulty,
    required this.color,
    required this.icon,
    required this.subtitle,
  });
}
