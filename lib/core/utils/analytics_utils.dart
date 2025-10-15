import '../../data/models/mood_entry.dart';

class AnalyticsUtils {
  static Map<String, dynamic> calculateAnalytics(List<MoodEntry> entries) {
    if (entries.isEmpty) return {};

    return {
      'moodCounts': _calculateMoodCounts(entries),
      'avgMood': _calculateAverageMood(entries),
      'totalEntries': entries.length,
    };
  }

  static Map<int, int> _calculateMoodCounts(List<MoodEntry> entries) {
    final moodCounts = <int, int>{};
    for (var entry in entries) {
      moodCounts[entry.moodLevel] = (moodCounts[entry.moodLevel] ?? 0) + 1;
    }
    return moodCounts;
  }

  static double _calculateAverageMood(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0.0;
    return entries.map((e) => e.moodLevel).reduce((a, b) => a + b) /
        entries.length;
  }
}
