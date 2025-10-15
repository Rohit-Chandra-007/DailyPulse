import 'package:flutter/foundation.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';

class InsightsProvider extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();

  List<MoodEntry> getAllEntries() {
    return _repository.getAllEntries();
  }
}
