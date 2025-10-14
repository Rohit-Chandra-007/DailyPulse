import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';
import '../../core/constants.dart';
import '../widgets/empty_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MoodRepository();

    return ValueListenableBuilder(
      valueListenable: Hive.box<MoodEntry>(AppConstants.hiveBoxName).listenable(),
      builder: (context, Box<MoodEntry> box, _) {
        final entries = repository.getAllEntries().reversed.toList();

        if (entries.isEmpty) {
          return const EmptyState(message: 'No mood entries yet');
        }

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              leading: Text(AppConstants.moodEmojis[entry.moodLevel], style: const TextStyle(fontSize: 32)),
              title: Text(AppConstants.moodLabels[entry.moodLevel]),
              subtitle: Text(entry.note ?? ''),
              trailing: Text(_formatDate(entry.timestamp)),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
