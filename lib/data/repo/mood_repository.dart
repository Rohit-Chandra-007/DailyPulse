import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../local/hive_service.dart';
import '../services/sync_service.dart';
import '../remote/firestore_service.dart';
import '../../core/utils/app_logger.dart';

class MoodRepository {
  final Box<MoodEntry> _box = HiveService.getMoodBox();
  final SyncService _syncService = SyncService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> addMoodEntry(MoodEntry entry, String userId) async {
    final entryWithUser = entry.copyWith(userId: userId);
    await _box.add(entryWithUser);
    appLogger.d('Added mood entry locally for user: $userId');
    _syncService.syncPendingEntries();
  }

  void startBackgroundSync() {
    _syncService.startBackgroundSync();
  }

  void stopBackgroundSync() {
    _syncService.stopBackgroundSync();
  }

  int getPendingSyncCount() {
    return _syncService.getPendingSyncCount();
  }

  Future<bool> forceSyncNow() {
    return _syncService.forceSyncNow();
  }

  List<MoodEntry> getAllEntries() {
    return _box.values.toList();
  }

  // Fetch mood entries from Firebase and sync to local storage
  Future<List<MoodEntry>> fetchAndSyncFromFirebase(String userId) async {
    try {
      appLogger.i('Starting Firebase fetch for user: $userId');
      final firebaseEntries = await _firestoreService.fetchMoodEntries(userId);
      
      appLogger.i('Fetched ${firebaseEntries.length} entries from Firebase');
      
      // Clear local storage and add all Firebase entries
      await _box.clear();
      for (var entry in firebaseEntries) {
        await _box.add(entry);
      }
      
      appLogger.i('Synced ${firebaseEntries.length} entries to local Hive');
      return firebaseEntries;
    } catch (e, stackTrace) {
      appLogger.e('Error in fetchAndSyncFromFirebase', error: e, stackTrace: stackTrace);
      // Return local entries if Firebase fetch fails
      return getAllEntries();
    }
  }

  // Stream mood entries from Firebase
  Stream<List<MoodEntry>> streamMoodEntries(String userId) {
    return _firestoreService.streamMoodEntries(userId);
  }
}
