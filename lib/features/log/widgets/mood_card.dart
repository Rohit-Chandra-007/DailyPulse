import 'package:flutter/material.dart';
import '../models/mood_option.dart';

class MoodCard extends StatelessWidget {
  final MoodOption mood;
  final VoidCallback onTap;

  const MoodCard({
    super.key,
    required this.mood,
    required this.onTap,
  });

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
