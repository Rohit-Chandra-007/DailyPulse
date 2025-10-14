import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final int moodLevel;

  @HiveField(2)
  final String? note;

  MoodEntry({
    required this.timestamp,
    required this.moodLevel,
    this.note,
  });
}
