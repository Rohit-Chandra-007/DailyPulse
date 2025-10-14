import 'package:flutter/material.dart';

class MoodOption {
  final String label;
  final String emoji;
  final Color color;
  final int level;

  MoodOption({
    required this.label,
    required this.emoji,
    required this.color,
    required this.level,
  });
}
