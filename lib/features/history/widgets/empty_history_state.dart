import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart' as date_utils;

class EmptyHistoryState extends StatelessWidget {
  final DateTime selectedDate;

  const EmptyHistoryState({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No moods logged',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'on ${date_utils.DateUtils.formatShortDate(selectedDate)}',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
