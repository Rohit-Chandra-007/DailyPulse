import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/fade_page_route.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/mood_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../models/mood_option.dart';
import '../widgets/mood_card.dart';
import 'add_note_screen.dart';

class LogMoodScreen extends StatelessWidget {
  const LogMoodScreen({super.key});

  void _onMoodSelected(BuildContext context, MoodOption mood) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      SnackbarUtils.showError(context, 'Please sign in to log your mood');
      return;
    }

    Navigator.push(
      context,
      FadePageRoute(
        page: AddNoteScreen(
          mood: mood,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moods = MoodUtils.getMoodOptions();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a mood to log your feelings',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    final mood = moods[index];
                    return MoodCard(
                      mood: mood,
                      onTap: () => _onMoodSelected(context, mood),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
