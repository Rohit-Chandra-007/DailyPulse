import 'package:flutter/foundation.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';
import '../utils/app_logger.dart';

class MoodProvider extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();
  bool _isLoading = false;
  List<MoodEntry> _entries = [];

  bool get isLoading => _isLoading;
  List<MoodEntry> get entries => _entries;

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
      appLogger.i('Mood saved successfully: level $moodLevel');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      appLogger.e('Error saving mood', error: e, stackTrace: stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch mood entries from Firebase
  Future<void> fetchMoodEntries(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _repository.fetchAndSyncFromFirebase(userId);
      appLogger.d('Fetched ${_entries.length} mood entries');
    } catch (e, stackTrace) {
      appLogger.e('Error fetching mood entries', error: e, stackTrace: stackTrace);
      _entries = _repository.getAllEntries();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get stream of mood entries from Firebase
  Stream<List<MoodEntry>> streamMoodEntries(String userId) {
    return _repository.streamMoodEntries(userId);
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
