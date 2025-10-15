import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _moodsCollection = 'moods';

  Future<String?> addMoodEntry(MoodEntry entry) async {
    try {
      final docRef = await _firestore.collection(_moodsCollection).add(
            entry.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      print('Error adding mood to Firestore: $e');
      return null;
    }
  }

  Future<List<MoodEntry>> getUserMoodEntries(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_moodsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching moods from Firestore: $e');
      return [];
    }
  }

  Stream<List<MoodEntry>> streamUserMoodEntries(String userId) {
    return _firestore
        .collection(_moodsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList());
  }

  Future<bool> updateMoodEntry(String docId, MoodEntry entry) async {
    try {
      await _firestore.collection(_moodsCollection).doc(docId).update(
            entry.toFirestore(),
          );
      return true;
    } catch (e) {
      print('Error updating mood in Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteMoodEntry(String docId) async {
    try {
      await _firestore.collection(_moodsCollection).doc(docId).delete();
      return true;
    } catch (e) {
      print('Error deleting mood from Firestore: $e');
      return false;
    }
  }

  Future<void> syncLocalEntries(List<MoodEntry> entries) async {
    for (final entry in entries) {
      if (entry.id == null) {
        await addMoodEntry(entry);
      }
    }
  }

  Future<List<MoodEntry>> getMoodEntriesInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_moodsCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching mood range from Firestore: $e');
      return [];
    }
  }
}
