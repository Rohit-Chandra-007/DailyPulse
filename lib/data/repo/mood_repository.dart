import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../local/hive_service.dart';
import '../remote/firestore_service.dart';
import '../services/sync_service.dart';

class MoodRepository {
  final Box<MoodEntry> _box = HiveService.getMoodBox();
  final FirestoreService _firestoreService = FirestoreService();
  final SyncService _syncService = SyncService();

  Future<void> addMoodEntry(MoodEntry entry, String userId) async {
    final entryWithUser = entry.copyWith(userId: userId);
    await _box.add(entryWithUser);
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

  List<MoodEntry> getUserEntries(String userId) {
    return _box.values.where((entry) => entry.userId == userId).toList();
  }

  Future<void> syncToFirestore() async {
    final entries = _box.values.where((entry) => entry.id == null).toList();
    await _firestoreService.syncLocalEntries(entries);
  }

  Future<void> syncFromFirestore(String userId) async {
    try {
      final cloudEntries = await _firestoreService.getUserMoodEntries(userId);
      await _box.clear();
      for (final entry in cloudEntries) {
        await _box.add(entry);
      }
    } catch (e) {
      print('Failed to sync from Firestore: $e');
    }
  }

  Stream<List<MoodEntry>> streamUserEntries(String userId) {
    return _firestoreService.streamUserMoodEntries(userId);
  }

  Future<void> deleteEntry(int index) async {
    final entry = _box.getAt(index);
    if (entry != null && entry.id != null) {
      await _firestoreService.deleteMoodEntry(entry.id!);
    }
    await _box.deleteAt(index);
  }

  Future<void> deleteEntryById(String firestoreId) async {
    await _firestoreService.deleteMoodEntry(firestoreId);
    final entries = _box.values.toList();
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].id == firestoreId) {
        await _box.deleteAt(i);
        break;
      }
    }
  }

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
      return _box.values
          .where((entry) =>
              entry.userId == userId &&
              entry.timestamp.isAfter(startDate) &&
              entry.timestamp.isBefore(endDate))
          .toList();
    }
  }
}
