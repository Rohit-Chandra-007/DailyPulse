import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'DailyPulse';
  static const String hiveBoxName = 'mood_box';
  
  static const List<String> moodEmojis = ['😢', '😕', '😐', '🙂', '😄', '😡'];
  static const List<String> moodLabels = ['Terrible', 'Bad', 'Okay', 'Good', 'Great', 'Angry'];
  
  static const List<Color> moodColors = [
    Color(0xFFFFB3BA),
    Color(0xFFFFCC80),
    Color(0xFFFFF59D),
    Color(0xFFA5D6A7),
    Color(0xFFCE93D8),
    Color(0xFFEF9A9A),
  ];
  
  static const List<Color> moodColorsDark = [
    Color(0xFFEF9A9A),
    Color(0xFFFFB74D),
    Color(0xFFFFF176),
    Color(0xFF81C784),
    Color(0xFFBA68C8),
    Color(0xFFE57373),
  ];
}
