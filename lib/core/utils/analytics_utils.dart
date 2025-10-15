import '../../data/models/mood_entry.dart';

class AnalyticsUtils {
  static Map<String, dynamic> calculateAnalytics(List<MoodEntry> entries) {
    if (entries.isEmpty) return {};

    return {
      'moodCounts': _calculateMoodCounts(entries),
      'avgMood': _calculateAverageMood(entries),
      'weekdayAvg': _calculateWeekdayAverage(entries),
      'timeOfDayAvg': _calculateTimeOfDayAverage(entries),
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

  static Map<int, double> _calculateWeekdayAverage(List<MoodEntry> entries) {
    final weekdayCounts = <int, List<int>>{};
    
    for (var entry in entries) {
      final weekday = entry.timestamp.weekday;
      weekdayCounts[weekday] = [
        ...(weekdayCounts[weekday] ?? []),
        entry.moodLevel,
      ];
    }

    final weekdayAvg = <int, double>{};
    weekdayCounts.forEach((day, moods) {
      weekdayAvg[day] = moods.reduce((a, b) => a + b) / moods.length;
    });

    return weekdayAvg;
  }

  static Map<String, double> _calculateTimeOfDayAverage(
      List<MoodEntry> entries) {
    final timeOfDayCounts = <String, List<int>>{
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
      'Night': [],
    };

    for (var entry in entries) {
      final hour = entry.timestamp.hour;
      if (hour >= 5 && hour < 12) {
        timeOfDayCounts['Morning']!.add(entry.moodLevel);
      } else if (hour >= 12 && hour < 17) {
        timeOfDayCounts['Afternoon']!.add(entry.moodLevel);
      } else if (hour >= 17 && hour < 21) {
        timeOfDayCounts['Evening']!.add(entry.moodLevel);
      } else {
        timeOfDayCounts['Night']!.add(entry.moodLevel);
      }
    }

    final timeOfDayAvg = <String, double>{};
    timeOfDayCounts.forEach((time, moods) {
      if (moods.isNotEmpty) {
        timeOfDayAvg[time] = moods.reduce((a, b) => a + b) / moods.length;
      }
    });

    return timeOfDayAvg;
  }
}
