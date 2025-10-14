import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';
import '../../core/constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MoodEntryAdapter());
    await Hive.openBox<MoodEntry>(AppConstants.hiveBoxName);
  }

  static Box<MoodEntry> getMoodBox() {
    return Hive.box<MoodEntry>(AppConstants.hiveBoxName);
  }
}
