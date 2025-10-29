import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';
import '../../core/utils/app_logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _moodsCollection = 'moods';

  Future<String?> addMoodEntry(MoodEntry entry) async {
    try {
      final docRef = await _firestore.collection(_moodsCollection).add(
            entry.toFirestore(),
          );
      appLogger.d('Added mood entry to Firestore: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      appLogger.e('Error adding mood entry to Firestore', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Fetch all mood entries for a specific user
  Future<List<MoodEntry>> fetchMoodEntries(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_moodsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      appLogger.i('Fetched ${querySnapshot.docs.length} entries from Firebase');
      return querySnapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      appLogger.w('Error fetching from Firebase with orderBy', error: e);
      // If orderBy fails (missing index), try without orderBy
      try {
        final querySnapshot = await _firestore
            .collection(_moodsCollection)
            .where('userId', isEqualTo: userId)
            .get();
        
        appLogger.i('Fetched ${querySnapshot.docs.length} entries (without orderBy)');
        final entries = querySnapshot.docs
            .map((doc) => MoodEntry.fromFirestore(doc.data(), doc.id))
            .toList();
        // Sort locally
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return entries;
      } catch (e2, stackTrace2) {
        appLogger.e('Error fetching without orderBy', error: e2, stackTrace: stackTrace2);
        return [];
      }
    }
  }

  // Stream mood entries for real-time updates
  Stream<List<MoodEntry>> streamMoodEntries(String userId) {
    return _firestore
        .collection(_moodsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodEntry.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
