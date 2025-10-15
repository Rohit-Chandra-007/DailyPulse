import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/constants.dart';
import '../../../core/providers/history_provider.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../data/models/mood_entry.dart';
import '../widgets/date_selector.dart';
import '../widgets/empty_history_state.dart';
import '../widgets/mood_history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        return Column(
          children: [
            DateSelector(
              selectedDate: historyProvider.selectedDate,
              onDateChange: historyProvider.selectDate,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date_utils.DateUtils.formatDate(
                        historyProvider.selectedDate),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<MoodEntry>(AppConstants.hiveBoxName)
                    .listenable(),
                builder: (context, Box<MoodEntry> box, _) {
                  final entries = historyProvider.getEntriesForSelectedDate();

                  if (entries.isEmpty) {
                    return EmptyHistoryState(
                      selectedDate: historyProvider.selectedDate,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return MoodHistoryCard(entry: entries[index]);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
