import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';
import '../../core/constants.dart';
import '../widgets/empty_state.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _selectedTimeWindow = 0; // 0: All, 1: 7 days, 2: 30 days

  @override
  Widget build(BuildContext context) {
    final repository = MoodRepository();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: Hive.box<MoodEntry>(
          AppConstants.hiveBoxName,
        ).listenable(),
        builder: (context, Box<MoodEntry> box, _) {
          final allEntries = repository.getAllEntries();

          if (allEntries.isEmpty) {
            return const EmptyState(message: 'Log some moods to see insights');
          }

          final filteredEntries = _getFilteredEntries(allEntries);
          final analytics = _calculateAnalytics(filteredEntries);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Insights',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Understand your emotional patterns',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Time Window Selector
                _buildTimeWindowSelector(isDark),
                const SizedBox(height: 24),

                // Average Mood Score
                _buildAverageMoodCard(analytics, isDark),
                const SizedBox(height: 16),

                // Mood Distribution Pie Chart
                _buildMoodDistribution(analytics, isDark),
                const SizedBox(height: 24),

                // Weekday Pattern
                _buildWeekdayPattern(analytics, isDark),
                const SizedBox(height: 24),

                // Time of Day Pattern
                _buildTimeOfDayPattern(analytics, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  List<MoodEntry> _getFilteredEntries(List<MoodEntry> entries) {
    final now = DateTime.now();
    switch (_selectedTimeWindow) {
      case 1: // Last 7 days
        return entries
            .where((e) => now.difference(e.timestamp).inDays <= 7)
            .toList();
      case 2: // Last 30 days
        return entries
            .where((e) => now.difference(e.timestamp).inDays <= 30)
            .toList();
      default: // All time
        return entries;
    }
  }

  Map<String, dynamic> _calculateAnalytics(List<MoodEntry> entries) {
    if (entries.isEmpty) return {};

    // Mood distribution
    final moodCounts = <int, int>{};
    for (var entry in entries) {
      moodCounts[entry.moodLevel] = (moodCounts[entry.moodLevel] ?? 0) + 1;
    }

    // Average mood score
    final avgMood =
        entries.map((e) => e.moodLevel).reduce((a, b) => a + b) /
        entries.length;

    // Weekday pattern
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

    // Time of day pattern
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

    return {
      'moodCounts': moodCounts,
      'avgMood': avgMood,
      'weekdayAvg': weekdayAvg,
      'timeOfDayAvg': timeOfDayAvg,
      'totalEntries': entries.length,
    };
  }

  Widget _buildTimeWindowSelector(bool isDark) {
    return Row(
      children: [
        _TimeWindowChip(
          label: 'All Time',
          isSelected: _selectedTimeWindow == 0,
          onTap: () => setState(() => _selectedTimeWindow = 0),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _TimeWindowChip(
          label: '7 Days',
          isSelected: _selectedTimeWindow == 1,
          onTap: () => setState(() => _selectedTimeWindow = 1),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _TimeWindowChip(
          label: '30 Days',
          isSelected: _selectedTimeWindow == 2,
          onTap: () => setState(() => _selectedTimeWindow = 2),
          isDark: isDark,
        ),
      ],
    );
  }


  Widget _buildAverageMoodCard(Map<String, dynamic> analytics, bool isDark) {
    final avgMood = analytics['avgMood'] as double;
    final totalEntries = analytics['totalEntries'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.analytics_outlined,
              color: const Color(0xFF2196F3),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Mood',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${avgMood.toStringAsFixed(1)} / 5.0',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '$totalEntries entries logged',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(Map<String, dynamic> analytics, bool isDark) {
    final moodCounts = analytics['moodCounts'] as Map<int, int>;
    final total = analytics['totalEntries'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _buildPieChartSections(moodCounts, total),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildMoodLegend(moodCounts, total, isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayPattern(Map<String, dynamic> analytics, bool isDark) {
    final weekdayAvg = analytics['weekdayAvg'] as Map<int, double>;
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekday Pattern',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final day = index + 1;
            final avg = weekdayAvg[day] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      weekdays[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: avg / 5.0,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppConstants.moodColorsDark[avg.round().clamp(
                                    0,
                                    5,
                                  )],
                                  AppConstants
                                      .moodColorsDark[avg.round().clamp(0, 5)]
                                      .withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayPattern(Map<String, dynamic> analytics, bool isDark) {
    final timeOfDayAvg = analytics['timeOfDayAvg'] as Map<String, double>;
    final icons = {
      'Morning': Icons.wb_sunny,
      'Afternoon': Icons.wb_sunny_outlined,
      'Evening': Icons.wb_twilight,
      'Night': Icons.nightlight_round,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time of Day Pattern',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...timeOfDayAvg.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icons[entry.key],
                      color: const Color(0xFF2196F3),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: entry.value / 5.0,
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            AppConstants.moodColorsDark[entry.value
                                .round()
                                .clamp(0, 5)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<int, int> moodCounts,
    int total,
  ) {
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < 6; i++) {
      final count = moodCounts[i] ?? 0;
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: AppConstants.moodColorsDark[i],
            value: count.toDouble(),
            title: '',
            radius: 40,
          ),
        );
      }
    }
    return sections;
  }

  List<Widget> _buildMoodLegend(
    Map<int, int> moodCounts,
    int total,
    bool isDark,
  ) {
    final items = <Widget>[];
    for (int i = 0; i < 6; i++) {
      final count = moodCounts[i] ?? 0;
      if (count > 0) {
        final percentage = ((count / total) * 100).round();
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppConstants.moodColorsDark[i],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppConstants.moodLabels[i],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return items;
  }
}

class _TimeWindowChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TimeWindowChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
