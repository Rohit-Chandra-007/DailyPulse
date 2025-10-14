import 'package:flutter/material.dart';
import '../../data/repo/mood_repository.dart';
import '../widgets/empty_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MoodRepository();
    final entries = repository.getAllEntries();

    if (entries.isEmpty) {
      return const EmptyState(message: 'Log some moods to see insights');
    }

    final avgMood = entries.map((e) => e.moodLevel).reduce((a, b) => a + b) / entries.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Average Mood', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('${avgMood.toStringAsFixed(1)} / 4.0', style: const TextStyle(fontSize: 32)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Entries', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('${entries.length}', style: const TextStyle(fontSize: 32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
