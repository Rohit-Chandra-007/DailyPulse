import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../local/hive_service.dart';

class MoodRepository {
  final Box<MoodEntry> _box = HiveService.getMoodBox();

  Future<void> addMoodEntry(MoodEntry entry) async {
    await _box.add(entry);
  }

  List<MoodEntry> getAllEntries() {
    return _box.values.toList();
  }

  Future<void> deleteEntry(int index) async {
    await _box.deleteAt(index);
  }
}
