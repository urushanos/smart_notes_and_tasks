import 'package:flutter/material.dart';

class ProgressHeatmap extends StatelessWidget {
  final Map<DateTime, int> completionLevels;
  const ProgressHeatmap({super.key, required this.completionLevels});

  @override
  Widget build(BuildContext context) {
    final dates = completionLevels.keys.toList()..sort();
    if (dates.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: dates.map((d) {
        final level = completionLevels[d] ?? 0;
        final color = switch (level) {
          0 => Colors.grey.shade200,
          1 => Colors.green.shade200,
          2 => Colors.green.shade400,
          _ => Colors.green.shade700,
        };
        return Tooltip(
          message: '${d.toLocal().toString().split(' ').first} - Level $level',
          child: Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        );
      }).toList(),
    );
  }
}
