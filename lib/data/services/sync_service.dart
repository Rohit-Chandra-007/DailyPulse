import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dailypulse/data/models/mood_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/app_logger.dart';
import '../local/hive_service.dart';
import '../remote/firestore_service.dart';

class SyncService {
  SyncService({
    FirestoreService? firestoreService,
    Connectivity? connectivity,
    FirebaseAuth? auth,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _connectivity = connectivity ?? Connectivity(),
        _auth = auth ?? FirebaseAuth.instance;

  final FirestoreService _firestoreService;
  final Connectivity _connectivity;
  final FirebaseAuth _auth;

  Timer? _syncTimer;
  bool _isSyncing = false;
  StreamSubscription<dynamic>? _connectivitySubscription;

  void startBackgroundSync() {
    _startTimerIfNeeded();

    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (event) {
        if (_auth.currentUser == null) {
          return;
        }

        if (_hasConnection(event)) {
          appLogger.d('Connectivity restored, triggering sync');
          unawaited(syncPendingEntries());
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        appLogger.e(
          'Connectivity listener error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    appLogger.i('Background sync listener active');
  }

  void _startTimerIfNeeded() {
    if (_auth.currentUser == null) {
      _stopTimer();
      return;
    }

    if (!hasPendingSyncs()) {
      return;
    }

    if (_syncTimer != null) {
      return;
    }

    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(syncPendingEntries());

      if (!hasPendingSyncs()) {
        _stopTimer();
        appLogger.d('No pending entries, timer stopped');
      }
    });

    appLogger.d('Sync timer started');
  }

  void _stopTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  void stopBackgroundSync() {
    _stopTimer();
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    appLogger.i('Background sync stopped');
  }

  Future<void> syncPendingEntries() async {
    final user = _auth.currentUser;
    if (user == null) {
      appLogger.d('Sync skipped: no authenticated user.');
      _stopTimer();
      return;
    }

    final currentStatus = await _connectivity.checkConnectivity();
    final hasConnection = _hasConnection(currentStatus);
    if (!hasConnection) {
      appLogger.d('Sync postponed: no network connection.');
      _startTimerIfNeeded();
      return;
    }

    if (_isSyncing) {
      appLogger.d('Sync already in progress, skip new run.');
      return;
    }
    _isSyncing = true;

    try {
      final box = HiveService.getMoodBox();
      final pendingEntries = <dynamic, MoodEntry>{};

      for (final key in box.keys) {
        final entry = box.get(key);
        if (entry != null &&
            entry.id == null &&
            entry.userId != null &&
            entry.userId == user.uid) {
          pendingEntries[key] = entry;
        }
      }

      if (pendingEntries.isEmpty) {
        return;
      }

      appLogger.d(
        'Starting sync for ${pendingEntries.length} pending entries',
      );

      for (final entry in pendingEntries.entries) {
        final docId = await _firestoreService.addMoodEntry(entry.value);

        if (docId != null) {
          final updatedEntry = entry.value.copyWith(id: docId);
          await box.put(entry.key, updatedEntry);
          appLogger.d('Synced entry with key ${entry.key}');
        }
      }

      appLogger.i('Sync completed for ${pendingEntries.length} entries');
    } catch (e, stackTrace) {
      appLogger.e('Error during sync', error: e, stackTrace: stackTrace);
    } finally {
      _isSyncing = false;

      if (!hasPendingSyncs()) {
        _stopTimer();
      } else {
        _startTimerIfNeeded();
      }
    }
  }

  Future<bool> forceSyncNow() async {
    try {
      await syncPendingEntries();
      return true;
    } catch (e, stackTrace) {
      appLogger.e('Force sync failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  bool hasPendingSyncs() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }

    final box = HiveService.getMoodBox();
    return box.values.any(
      (entry) =>
          entry.id == null &&
          entry.userId != null &&
          entry.userId == userId,
    );
  }

  int getPendingSyncCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return 0;
    }

    final box = HiveService.getMoodBox();
    return box.values
        .where(
          (entry) =>
              entry.id == null &&
              entry.userId != null &&
              entry.userId == userId,
        )
        .length;
  }

  bool _hasConnection(dynamic event) {
    if (event is Iterable<ConnectivityResult>) {
      return event.any((result) => result != ConnectivityResult.none);
    }

    if (event is ConnectivityResult) {
      return event != ConnectivityResult.none;
    }

    return false;
  }
}
