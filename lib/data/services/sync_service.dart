import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dailypulse/data/models/mood_entry.dart';
import '../local/hive_service.dart';
import '../remote/firestore_service.dart';
import '../../core/utils/app_logger.dart';

class SyncService {
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();
  Timer? _syncTimer;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void startBackgroundSync() {
    // Only start timer if there are pending entries
    _startTimerIfNeeded();

    try {
      _connectivitySubscription?.cancel();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        results,
      ) {
        if (!results.contains(ConnectivityResult.none)) {
          appLogger.d('Connectivity restored, triggering sync');
          syncPendingEntries();
        }
      });
      appLogger.i('Background sync started');
    } catch (e, stackTrace) {
      appLogger.e(
        'Error setting up connectivity listener',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _startTimerIfNeeded() {
    if (hasPendingSyncs() && _syncTimer == null) {
      _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        syncPendingEntries();
        // Stop timer if no more pending entries
        if (!hasPendingSyncs()) {
          _syncTimer?.cancel();
          _syncTimer = null;
          appLogger.d('No pending entries, timer stopped');
        }
      });
      appLogger.d('Sync timer started');
    }
  }

  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    appLogger.i('Background sync stopped');
  }

  Future<void> syncPendingEntries() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final box = HiveService.getMoodBox();
      final pendingEntries = <dynamic, MoodEntry>{};

      // Collect all pending entries with their keys
      for (var key in box.keys) {
        final entry = box.get(key);
        if (entry != null && entry.id == null && entry.userId != null) {
          pendingEntries[key] = entry;
        }
      }

      if (pendingEntries.isNotEmpty) {
        appLogger.d(
          'Starting sync for ${pendingEntries.length} pending entries',
        );
      }

      for (var entry in pendingEntries.entries) {
        final key = entry.key;
        final moodEntry = entry.value;

        final docId = await _firestoreService.addMoodEntry(moodEntry);

        if (docId != null) {
          final updatedEntry = moodEntry.copyWith(id: docId);
          await box.put(key, updatedEntry);
          appLogger.d('Synced entry with key $key');
        }
      }

      if (pendingEntries.isNotEmpty) {
        appLogger.i('Sync completed for ${pendingEntries.length} entries');
      }
    } catch (e, stackTrace) {
      appLogger.e('Error during sync', error: e, stackTrace: stackTrace);
    } finally {
      _isSyncing = false;
      // Restart timer if needed after sync completes
      _startTimerIfNeeded();
    }
  }

  Future<bool> forceSyncNow() async {
    try {
      appLogger.i('Force sync initiated');
      await syncPendingEntries();
      return true;
    } catch (e, stackTrace) {
      appLogger.e('Force sync failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  bool hasPendingSyncs() {
    final box = HiveService.getMoodBox();
    return box.values.any((entry) => entry.id == null && entry.userId != null);
  }

  int getPendingSyncCount() {
    final box = HiveService.getMoodBox();
    return box.values
        .where((entry) => entry.id == null && entry.userId != null)
        .length;
  }
}
