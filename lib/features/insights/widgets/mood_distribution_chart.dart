import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constant/constants.dart';

class MoodDistributionChart extends StatelessWidget {
  final Map<int, int> moodCounts;
  final int totalEntries;

  const MoodDistributionChart({
    super.key,
    required this.moodCounts,
    required this.totalEntries,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      sections: _buildPieChartSections(),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildMoodLegend(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
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

  List<Widget> _buildMoodLegend(bool isDark) {
    final items = <Widget>[];
    for (int i = 0; i < 6; i++) {
      final count = moodCounts[i] ?? 0;
      if (count > 0) {
        final percentage = ((count / totalEntries) * 100).round();
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
