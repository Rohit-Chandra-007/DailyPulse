import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constant/constants.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../data/models/mood_entry.dart';
import '../../../data/repo/mood_repository.dart';
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
  final MoodRepository _repository = MoodRepository();

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  List<MoodEntry> _getEntriesForSelectedDate() {
    final allEntries = _repository.getAllEntries();
    return allEntries.where((entry) {
      return date_utils.DateUtils.isSameDay(entry.timestamp, _selectedDate);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        DateSelector(
          selectedDate: _selectedDate,
          onDateChange: _selectDate,
        ),
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
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<MoodEntry>(AppConstants.hiveBoxName)
                .listenable(),
            builder: (context, Box<MoodEntry> box, _) {
              final entries = _getEntriesForSelectedDate();

              if (entries.isEmpty) {
                return EmptyHistoryState(
                  selectedDate: _selectedDate,
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
  }
}
