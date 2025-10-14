import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';
import '../../core/constants.dart';
import '../widgets/empty_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MoodRepository();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: Hive.box<MoodEntry>(AppConstants.hiveBoxName).listenable(),
        builder: (context, Box<MoodEntry> box, _) {
          final entries = repository.getAllEntries();

          if (entries.isEmpty) {
            return const EmptyState(message: 'Log some moods to see insights');
          }

          // Calculate mood distribution
          final moodCounts = <int, int>{};
          for (var entry in entries) {
            moodCounts[entry.moodLevel] = (moodCounts[entry.moodLevel] ?? 0) + 1;
          }

          final totalEntries = entries.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  'Mood Distribution',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 80,
                          sections: _buildPieChartSections(moodCounts, totalEntries),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalEntries',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ..._buildMoodLegend(moodCounts, totalEntries),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<int, int> moodCounts,
    int total,
  ) {
    final sections = <PieChartSectionData>[];

    for (int i = 0; i < 5; i++) {
      final count = moodCounts[i] ?? 0;
      if (count > 0) {
        final percentage = (count / total) * 100;
        sections.add(
          PieChartSectionData(
            color: AppConstants.moodColorsDark[i],
            value: count.toDouble(),
            title: '',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    return sections;
  }

  List<Widget> _buildMoodLegend(Map<int, int> moodCounts, int total) {
    final items = <Widget>[];

    for (int i = 0; i < 5; i++) {
      final count = moodCounts[i] ?? 0;
      if (count > 0) {
        final percentage = ((count / total) * 100).round();
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppConstants.moodColorsDark[i],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.moodLabels[i],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '$count entries',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
