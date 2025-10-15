import 'package:flutter/material.dart';
import '../constant/constants.dart';

class EmojiGrid extends StatelessWidget {
  final int? selectedMood;
  final Function(int) onMoodSelected;

  const EmojiGrid({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final isSelected = selectedMood == index;
        return GestureDetector(
          onTap: () => onMoodSelected(index),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(AppConstants.moodEmojis[index], style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 4),
                Text(AppConstants.moodLabels[index], style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
