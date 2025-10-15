import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/constants.dart';
import '../../../core/providers/insights_provider.dart';
import '../../../core/utils/analytics_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/mood_entry.dart';
import '../widgets/average_mood_card.dart';
import '../widgets/mood_distribution_chart.dart';
import '../widgets/time_of_day_pattern_chart.dart';
import '../widgets/time_window_selector.dart';
import '../widgets/weekday_pattern_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<InsightsProvider>(
      builder: (context, insightsProvider, _) {
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
              final allEntries = insightsProvider.getAllEntries();

              if (allEntries.isEmpty) {
                return const EmptyState(
                    message: 'Log some moods to see insights');
              }

              final filteredEntries = insightsProvider.getFilteredEntries();
              final analytics =
                  AnalyticsUtils.calculateAnalytics(filteredEntries);

              if (analytics.isEmpty) {
                return const EmptyState(
                    message: 'No data for selected time period');
              }

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
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TimeWindowSelector(
                      selectedWindow: insightsProvider.selectedTimeWindow,
                      onWindowChanged: insightsProvider.selectTimeWindow,
                    ),
                    const SizedBox(height: 24),
                    AverageMoodCard(
                      avgMood: analytics['avgMood'] as double,
                      totalEntries: analytics['totalEntries'] as int,
                    ),
                    const SizedBox(height: 16),
                    MoodDistributionChart(
                      moodCounts: analytics['moodCounts'] as Map<int, int>,
                      totalEntries: analytics['totalEntries'] as int,
                    ),
                    const SizedBox(height: 24),
                    WeekdayPatternChart(
                      weekdayAvg: analytics['weekdayAvg'] as Map<int, double>,
                    ),
                    const SizedBox(height: 24),
                    TimeOfDayPatternChart(
                      timeOfDayAvg:
                          analytics['timeOfDayAvg'] as Map<String, double>,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
