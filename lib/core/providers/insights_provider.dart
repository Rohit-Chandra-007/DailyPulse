import 'package:flutter/foundation.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';

enum TimeWindow { all, sevenDays, thirtyDays }

class InsightsProvider extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();
  TimeWindow _selectedTimeWindow = TimeWindow.all;

  TimeWindow get selectedTimeWindow => _selectedTimeWindow;

  void selectTimeWindow(TimeWindow window) {
    _selectedTimeWindow = window;
    notifyListeners();
  }

  List<MoodEntry> getAllEntries() {
    return _repository.getAllEntries();
  }

  List<MoodEntry> getFilteredEntries() {
    final entries = getAllEntries();
    final now = DateTime.now();

    switch (_selectedTimeWindow) {
      case TimeWindow.sevenDays:
        return entries
            .where((e) => now.difference(e.timestamp).inDays <= 7)
            .toList();
      case TimeWindow.thirtyDays:
        return entries
            .where((e) => now.difference(e.timestamp).inDays <= 30)
            .toList();
      case TimeWindow.all:
        return entries;
    }
  }
}
