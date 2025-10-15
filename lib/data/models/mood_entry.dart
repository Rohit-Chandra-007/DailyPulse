import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final int moodLevel;

  @HiveField(2)
  final String? note;

  @HiveField(3)
  final String? id; // Firestore document ID

  @HiveField(4)
  final String? userId; // User who created this entry

  MoodEntry({
    required this.timestamp,
    required this.moodLevel,
    this.note,
    this.id,
    this.userId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'moodLevel': moodLevel,
      'note': note,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  MoodEntry copyWith({
    DateTime? timestamp,
    int? moodLevel,
    String? note,
    String? id,
    String? userId,
  }) {
    return MoodEntry(
      timestamp: timestamp ?? this.timestamp,
      moodLevel: moodLevel ?? this.moodLevel,
      note: note ?? this.note,
      id: id ?? this.id,
      userId: userId ?? this.userId,
    );
  }
}
