import '../../core/constant/constants.dart';
import '../../features/home/models/mood_option.dart';

class MoodUtils {
  static List<MoodOption> getMoodOptions() {
    return [
      MoodOption(
        label: AppConstants.moodLabels[0],
        emoji: AppConstants.moodEmojis[0],
        color: AppConstants.moodColorsDark[0],
        level: 0,
      ),
      MoodOption(
        label: AppConstants.moodLabels[1],
        emoji: AppConstants.moodEmojis[1],
        color: AppConstants.moodColorsDark[1],
        level: 1,
      ),
      MoodOption(
        label: AppConstants.moodLabels[2],
        emoji: AppConstants.moodEmojis[2],
        color: AppConstants.moodColorsDark[2],
        level: 2,
      ),
      MoodOption(
        label: AppConstants.moodLabels[3],
        emoji: AppConstants.moodEmojis[3],
        color: AppConstants.moodColorsDark[3],
        level: 3,
      ),
      MoodOption(
        label: AppConstants.moodLabels[4],
        emoji: AppConstants.moodEmojis[4],
        color: AppConstants.moodColorsDark[4],
        level: 4,
      ),
      MoodOption(
        label: AppConstants.moodLabels[5],
        emoji: AppConstants.moodEmojis[5],
        color: AppConstants.moodColorsDark[5],
        level: 5,
      ),
    ];
  }
}
