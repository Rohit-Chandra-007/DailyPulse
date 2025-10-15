import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'DailyPulse';
  static const String hiveBoxName = 'mood_box';
  
  static const List<String> moodEmojis = ['😢', '😕', '😐', '🙂', '😄', '😡'];
  static const List<String> moodLabels = ['Terrible', 'Bad', 'Okay', 'Good', 'Great', 'Angry'];
  
  // Consistent pastel color palette for all screens
  static const List<Color> moodColors = [
    Color(0xFFFFB3BA), // Terrible - soft red/pink
    Color(0xFFFFCC80), // Bad - soft orange
    Color(0xFFFFF59D), // Okay - soft yellow
    Color(0xFFA5D6A7), // Good - soft green
    Color(0xFFCE93D8), // Great - soft purple
    Color(0xFFEF9A9A), // Angry - red
  ];
  
  // Darker versions for cards and buttons
  static const List<Color> moodColorsDark = [
    Color(0xFFEF9A9A), // Terrible - darker pink
    Color(0xFFFFB74D), // Bad - darker orange
    Color(0xFFFFF176), // Okay - darker yellow
    Color(0xFF81C784), // Good - darker green
    Color(0xFFBA68C8), // Great - darker purple
    Color(0xFFE57373), // Angry - darker red
  ];
}
