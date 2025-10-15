import 'package:flutter/foundation.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';
import '../utils/date_utils.dart' as date_utils;

class HistoryProvider extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<MoodEntry> getAllEntries() {
    return _repository.getAllEntries();
  }

  List<MoodEntry> getEntriesForSelectedDate() {
    final allEntries = getAllEntries();

    return allEntries.where((entry) {
      return date_utils.DateUtils.isSameDay(entry.timestamp, _selectedDate);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MoodEntry> getEntriesForDate(DateTime date) {
    final allEntries = getAllEntries();

    return allEntries.where((entry) {
      return date_utils.DateUtils.isSameDay(entry.timestamp, date);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
