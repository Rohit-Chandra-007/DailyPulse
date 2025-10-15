import 'package:flutter/material.dart';
import '../../../core/providers/insights_provider.dart';

class TimeWindowSelector extends StatelessWidget {
  final TimeWindow selectedWindow;
  final Function(TimeWindow) onWindowChanged;

  const TimeWindowSelector({
    super.key,
    required this.selectedWindow,
    required this.onWindowChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _TimeWindowChip(
          label: 'All Time',
          isSelected: selectedWindow == TimeWindow.all,
          onTap: () => onWindowChanged(TimeWindow.all),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _TimeWindowChip(
          label: '7 Days',
          isSelected: selectedWindow == TimeWindow.sevenDays,
          onTap: () => onWindowChanged(TimeWindow.sevenDays),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _TimeWindowChip(
          label: '30 Days',
          isSelected: selectedWindow == TimeWindow.thirtyDays,
          onTap: () => onWindowChanged(TimeWindow.thirtyDays),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _TimeWindowChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TimeWindowChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
