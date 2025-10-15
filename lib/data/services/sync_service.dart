import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/hive_service.dart';
import '../remote/firestore_service.dart';

class SyncService {
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();
  Timer? _syncTimer;
  bool _isSyncing = false;

  void startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncPendingEntries();
    });

    try {
      _connectivity.onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) {
          syncPendingEntries();
        }
      });
    } catch (_) {
    }
  }

  void stopBackgroundSync() {
    _syncTimer?.cancel();
  }

  Future<void> syncPendingEntries() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final box = HiveService.getMoodBox();
      final entries = box.values.toList();

      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        
        if (entry.id == null && entry.userId != null) {
          final docId = await _firestoreService.addMoodEntry(entry);
          
          if (docId != null) {
            final updatedEntry = entry.copyWith(id: docId);
            await box.putAt(i, updatedEntry);
          }
        }
      }
    } catch (_) {
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> forceSyncNow() async {
    try {
      await syncPendingEntries();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool hasPendingSyncs() {
    final box = HiveService.getMoodBox();
    return box.values.any((entry) => entry.id == null && entry.userId != null);
  }

  int getPendingSyncCount() {
    final box = HiveService.getMoodBox();
    return box.values.where((entry) => entry.id == null && entry.userId != null).length;
  }
}
