import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../local/hive_service.dart';
import '../remote/firestore_service.dart';
import '../services/sync_service.dart';

class MoodRepository {
  final Box<MoodEntry> _box = HiveService.getMoodBox();
  final FirestoreService _firestoreService = FirestoreService();
  final SyncService _syncService = SyncService();

  // Add mood entry - FAST: Save to Hive first, sync to Firestore in background
  Future<void> addMoodEntry(MoodEntry entry, String userId) async {
    // Add userId to entry
    final entryWithUser = entry.copyWith(userId: userId);

    // 1. Save to local storage IMMEDIATELY (fast!)
    await _box.add(entryWithUser);

    // 2. Trigger background sync (non-blocking)
    _syncService.syncPendingEntries();
  }

  // Start background sync service
  void startBackgroundSync() {
    _syncService.startBackgroundSync();
  }

  // Stop background sync service
  void stopBackgroundSync() {
    _syncService.stopBackgroundSync();
  }

  // Get pending sync count
  int getPendingSyncCount() {
    return _syncService.getPendingSyncCount();
  }

  // Force sync now
  Future<bool> forceSyncNow() {
    return _syncService.forceSyncNow();
  }

  // Get all entries from local storage
  List<MoodEntry> getAllEntries() {
    return _box.values.toList();
  }

  // Get entries for a specific user
  List<MoodEntry> getUserEntries(String userId) {
    return _box.values.where((entry) => entry.userId == userId).toList();
  }

  // Sync local entries to Firestore
  Future<void> syncToFirestore() async {
    final entries = _box.values.where((entry) => entry.id == null).toList();
    await _firestoreService.syncLocalEntries(entries);
  }

  // Fetch entries from Firestore and update local storage
  Future<void> syncFromFirestore(String userId) async {
    try {
      final cloudEntries = await _firestoreService.getUserMoodEntries(userId);

      // Clear local storage and replace with cloud data
      // (You might want a more sophisticated merge strategy)
      await _box.clear();
      for (final entry in cloudEntries) {
        await _box.add(entry);
      }
    } catch (e) {
      print('Failed to sync from Firestore: $e');
    }
  }

  // Stream entries from Firestore for real-time updates
  Stream<List<MoodEntry>> streamUserEntries(String userId) {
    return _firestoreService.streamUserMoodEntries(userId);
  }

  // Delete entry from both local and cloud
  Future<void> deleteEntry(int index) async {
    final entry = _box.getAt(index);
    if (entry != null && entry.id != null) {
      // Delete from Firestore
      await _firestoreService.deleteMoodEntry(entry.id!);
    }
    // Delete from local storage
    await _box.deleteAt(index);
  }

  // Delete entry by Firestore ID
  Future<void> deleteEntryById(String firestoreId) async {
    // Delete from Firestore
    await _firestoreService.deleteMoodEntry(firestoreId);

    // Delete from local storage
    final entries = _box.values.toList();
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].id == firestoreId) {
        await _box.deleteAt(i);
        break;
      }
    }
  }

  // Get entries for a date range
  Future<List<MoodEntry>> getEntriesInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _firestoreService.getMoodEntriesInRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      // Fallback to local storage
      return _box.values
          .where((entry) =>
              entry.userId == userId &&
              entry.timestamp.isAfter(startDate) &&
              entry.timestamp.isBefore(endDate))
          .toList();
    }
  }
}
