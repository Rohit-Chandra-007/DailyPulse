import 'package:flutter/foundation.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';

class MoodProvider extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> saveMood({
    required int moodLevel,
    required String userId,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final entry = MoodEntry(
        timestamp: DateTime.now(),
        moodLevel: moodLevel,
        note: note?.isEmpty ?? true ? null : note,
        userId: userId,
      );

      await _repository.addMoodEntry(entry, userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void startBackgroundSync() {
    _repository.startBackgroundSync();
  }

  void stopBackgroundSync() {
    _repository.stopBackgroundSync();
  }

  int getPendingSyncCount() {
    return _repository.getPendingSyncCount();
  }
}
