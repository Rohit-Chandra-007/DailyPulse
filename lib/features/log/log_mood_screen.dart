import 'package:flutter/material.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repo/mood_repository.dart';
import '../widgets/emoji_grid.dart';

class LogMoodScreen extends StatefulWidget {
  const LogMoodScreen({super.key});

  @override
  State<LogMoodScreen> createState() => _LogMoodScreenState();
}

class _LogMoodScreenState extends State<LogMoodScreen> {
  final _repository = MoodRepository();
  final _noteController = TextEditingController();
  int? _selectedMood;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) return;

    final entry = MoodEntry(
      timestamp: DateTime.now(),
      moodLevel: _selectedMood!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    await _repository.addMoodEntry(entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood logged!')),
      );
      _noteController.clear();
      setState(() => _selectedMood = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('How are you feeling?', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 24),
          EmojiGrid(
            selectedMood: _selectedMood,
            onMoodSelected: (mood) => setState(() => _selectedMood = mood),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Add a note (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _selectedMood == null ? null : _saveMood,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
