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
      return null;
    }
  }
}
