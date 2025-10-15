import 'package:dailypulse/data/models/mood_entry.dart';
import 'package:flutter/material.dart';
import '../../../data/repo/mood_repository.dart';
import '../../../core/constant/constants.dart';
import '../../../core/routes/fade_page_route.dart';


class LogMoodScreen extends StatefulWidget {
  const LogMoodScreen({super.key});

  @override
  State<LogMoodScreen> createState() => _LogMoodScreenState();
}

class _LogMoodScreenState extends State<LogMoodScreen> {
  final _repository = MoodRepository();

  late final List<MoodOption> _moods = [
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

  void _onMoodSelected(MoodOption mood) {
    Navigator.push(
      context,
      FadePageRoute(
        page: AddNoteScreen(mood: mood, repository: _repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                // Use 3 columns if width is sufficient, otherwise 2
                final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    return _MoodCard(
                      mood: mood,
                      onTap: () => _onMoodSelected(mood),
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

class _MoodCard extends StatelessWidget {
  final MoodOption mood;
  final VoidCallback onTap;

  const _MoodCard({required this.mood, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? mood.color.withValues(alpha: 0.2)
              : mood.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: mood.color.withValues(alpha: isDark ? 0.5 : 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: mood.color.withValues(alpha: isDark ? 0.15 : 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: mood.color.withValues(alpha: isDark ? 0.4 : 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Hero(
                  tag: 'mood_emoji_${mood.level}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      mood.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: mood.color.withValues(alpha: isDark ? 0.3 : 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tap to log',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodOption {
  final String label;
  final String emoji;
  final Color color;
  final int level;

  MoodOption({
    required this.label,
    required this.emoji,
    required this.color,
    required this.level,
  });
}

class AddNoteScreen extends StatefulWidget {
  final MoodOption mood;
  final MoodRepository repository;

  const AddNoteScreen({
    super.key,
    required this.mood,
    required this.repository,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    final entry = MoodEntry(
      timestamp: DateTime.now(),
      moodLevel: widget.mood.level,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    await widget.repository.addMoodEntry(entry);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mood logged!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomSheetColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: widget.mood.color,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.mood.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            // Emoji and Text Section
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'mood_emoji_${widget.mood.level}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              widget.mood.emoji,
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Feeling ${widget.mood.label.toLowerCase()}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Add a note to remember this moment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Sheet
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: bottomSheetColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your thoughts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'What made you feel this way?',
                      hintStyle: TextStyle(color: hintColor, fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: widget.mood.color.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      filled: true,
                      fillColor: fillColor,
                    ),
                    maxLines: 4,
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveMood,
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.mood.color,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Mood',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
