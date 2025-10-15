import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../local/hive_service.dart';
import '../services/sync_service.dart';

class MoodRepository {
  final Box<MoodEntry> _box = HiveService.getMoodBox();
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
}
