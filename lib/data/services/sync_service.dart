import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/hive_service.dart';
import '../remote/firestore_service.dart';

class SyncService {
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();
  Timer? _syncTimer;
  bool _isSyncing = false;

  // Start background sync (checks every 30 seconds)
  void startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncPendingEntries();
    });

    // Also listen to connectivity changes (with error handling)
    try {
      _connectivity.onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) {
          syncPendingEntries();
        }
      });
    } catch (e) {
      // Connectivity listener failed, but timer-based sync will still work
    }
  }

  // Stop background sync
  void stopBackgroundSync() {
    _syncTimer?.cancel();
  }

  // Sync all entries that don't have a Firestore ID
  Future<void> syncPendingEntries() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final box = HiveService.getMoodBox();
      final entries = box.values.toList();

      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        
        // If entry doesn't have Firestore ID, sync it
        if (entry.id == null && entry.userId != null) {
          final docId = await _firestoreService.addMoodEntry(entry);
          
          if (docId != null) {
            // Update local entry with Firestore ID
            final updatedEntry = entry.copyWith(id: docId);
            await box.putAt(i, updatedEntry);
          }
        }
      }
    } catch (e) {
      // Silently fail, will retry on next sync
    } finally {
      _isSyncing = false;
    }
  }

  // Force immediate sync
  Future<bool> forceSyncNow() async {
    try {
      await syncPendingEntries();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if there are pending syncs
  bool hasPendingSyncs() {
    final box = HiveService.getMoodBox();
    return box.values.any((entry) => entry.id == null && entry.userId != null);
  }

  // Get count of pending syncs
  int getPendingSyncCount() {
    final box = HiveService.getMoodBox();
    return box.values.where((entry) => entry.id == null && entry.userId != null).length;
  }
}
