import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/constants.dart';
import '../../../core/providers/insights_provider.dart';
import '../../../core/utils/analytics_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/mood_entry.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedTimeWindow = 'all'; // 'week', 'month', 'all'

  void _changeTimeWindow(String window) {
    setState(() {
      _selectedTimeWindow = window;
    });
  }

  List<MoodEntry> _getFilteredEntries(List<MoodEntry> allEntries) {
    final now = DateTime.now();
    switch (_selectedTimeWindow) {
      case 'week':
        return allEntries.where((e) => 
          now.difference(e.timestamp).inDays <= 7
        ).toList();
      case 'month':
        return allEntries.where((e) => 
          now.difference(e.timestamp).inDays <= 30
        ).toList();
      default:
        return allEntries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<InsightsProvider>(
      builder: (context, insightsProvider, _) {
        return ValueListenableBuilder(
          valueListenable: Hive.box<MoodEntry>(
            AppConstants.hiveBoxName,
          ).listenable(),
          builder: (context, Box<MoodEntry> box, _) {
            final allEntries = _getFilteredEntries(
              insightsProvider.getAllEntries(),
            );

            if (allEntries.isEmpty) {
              return const EmptyState(message: 'Log some moods to see insights');
            }

            final analytics = AnalyticsUtils.calculateAnalytics(allEntries);

            if (analytics.isEmpty) {
              return const EmptyState(message: 'No data available');
            }

            final avgMood = analytics['avgMood'] as double;
            final totalEntries = analytics['totalEntries'] as int;
            final moodCounts = analytics['moodCounts'] as Map<int, int>;

            return Padding(
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
                    'Your emotional journey at a glance',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTimeWindowFilter(isDark),
                  const SizedBox(height: 24),
                  
                  _buildAverageMoodCard(avgMood, totalEntries, isDark),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: _buildMoodDistribution(moodCounts, totalEntries, isDark),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeWindowFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterButton('Week', 'week', isDark),
          _buildFilterButton('Month', 'month', isDark),
          _buildFilterButton('All Time', 'all', isDark),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value, bool isDark) {
    final isSelected = _selectedTimeWindow == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeTimeWindow(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.blue.shade700 : Colors.blue.shade600)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAverageMoodCard(double avgMood, int totalEntries, bool isDark) {
    final moodIndex = avgMood.round().clamp(0, 5);
    final moodColor = AppConstants.moodColorsDark[moodIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  AppConstants.moodEmojis[moodIndex],
                  style: const TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Mood',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.moodLabels[moodIndex],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${avgMood.toStringAsFixed(1)} / 5.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: moodColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalEntries mood entries logged',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(
      Map<int, int> moodCounts, int totalEntries, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How often you feel each mood',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                final count = moodCounts[index] ?? 0;
                if (count == 0) return const SizedBox.shrink();
                
                final percentage = ((count / totalEntries) * 100).round();
                final color = AppConstants.moodColorsDark[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppConstants.moodEmojis[index],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppConstants.moodLabels[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
