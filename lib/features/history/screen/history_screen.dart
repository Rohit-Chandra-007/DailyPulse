import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/mood_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../data/models/mood_entry.dart';
import '../widgets/date_selector.dart';
import '../widgets/empty_history_state.dart';
import '../widgets/mood_history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    final moodProvider = context.read<MoodProvider>();

    if (authProvider.user != null) {
      await moodProvider.fetchMoodEntries(authProvider.user!.uid);
    }
  }

  List<MoodEntry> _getEntriesForSelectedDate(List<MoodEntry> allEntries) {
    appLogger.d('📊 Total entries from provider: ${allEntries.length}');
    appLogger.d('📅 Selected date: $_selectedDate');

    final filtered = allEntries.where((entry) {
      final isSame = date_utils.DateUtils.isSameDay(
        entry.timestamp,
        _selectedDate,
      );
      if (allEntries.length <= 10) {
        appLogger.d('  Entry: ${entry.timestamp} | Same day: $isSame');
      }
      return isSame;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    appLogger.d('✅ Filtered entries for selected date: ${filtered.length}');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
   // final moodProvider = context.read<MoodProvider>();

    return Column(
      children: [
        DateSelector(selectedDate: _selectedDate, onDateChange: _selectDate),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date_utils.DateUtils.formatDate(_selectedDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Consumer<MoodProvider>(
                builder: (context, provider, _) => IconButton(
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: provider.isLoading ? null : _refreshData,
                  tooltip: 'Refresh from Firebase',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<MoodEntry>(
              AppConstants.hiveBoxName,
            ).listenable(),
            builder: (context, Box<MoodEntry> box, _) {
              final allEntries = box.values.toList();
              final entries = _getEntriesForSelectedDate(allEntries);

              if (entries.isEmpty) {
                return EmptyHistoryState(selectedDate: _selectedDate);
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
  }
}
