import 'package:flutter/material.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';
import '../../core/constants.dart';

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
        level: 0),
    MoodOption(
        label: AppConstants.moodLabels[1],
        emoji: AppConstants.moodEmojis[1],
        color: AppConstants.moodColorsDark[1],
        level: 1),
    MoodOption(
        label: AppConstants.moodLabels[2],
        emoji: AppConstants.moodEmojis[2],
        color: AppConstants.moodColorsDark[2],
        level: 2),
    MoodOption(
        label: AppConstants.moodLabels[3],
        emoji: AppConstants.moodEmojis[3],
        color: AppConstants.moodColorsDark[3],
        level: 3),
    MoodOption(
        label: AppConstants.moodLabels[4],
        emoji: AppConstants.moodEmojis[4],
        color: AppConstants.moodColorsDark[4],
        level: 4),
  ];

  void _onMoodSelected(MoodOption mood) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(mood: mood, repository: _repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  return GestureDetector(
                    onTap: () => _onMoodSelected(mood),
                    child: Container(
                      decoration: BoxDecoration(
                        color: mood.color,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: mood.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood.emoji, style: const TextStyle(fontSize: 56)),
                          const SizedBox(height: 8),
                          Text(
                            mood.label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  const AddNoteScreen({super.key, required this.mood, required this.repository});

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood logged!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.mood.color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mood.label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.mood.emoji, style: const TextStyle(fontSize: 100)),
                  const SizedBox(height: 16),
                  Text(
                    'Feeling ${widget.mood.label.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Add a note about how you feel...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveMood,
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.mood.color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Mood',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
