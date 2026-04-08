import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/task_item.dart';
import '../providers/app_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  final Set<String> _filters = {};

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final groups = {for (final g in app.groups) g.id: g};
    final now = DateTime.now();
    final horizon = now.add(const Duration(days: 14));
    final upcoming = app.tasks.where((t) => !t.startDate.isBefore(now) && !t.startDate.isAfter(horizon)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focused,
            selectedDayPredicate: (day) => isSameDay(_selected, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selected = selectedDay;
                _focused = focusedDay;
              });
            },
            eventLoader: (day) => app.tasks.where((t) => isSameDay(day, t.startDate)).toList(),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                final task = events.first as TaskItem;
                final group = groups[task.groupId];
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: group?.color ?? Colors.blue, shape: BoxShape.circle),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: app.groups
                .map(
                  (g) => FilterChip(
                    label: Text(g.name),
                    selected: _filters.contains(g.id),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _filters.add(g.id);
                        } else {
                          _filters.remove(g.id);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Next 2 Weeks', style: TextStyle(fontWeight: FontWeight.bold)),
          ...upcoming
              .where((t) => _filters.isEmpty || _filters.contains(t.groupId))
              .map(
                (t) => ListTile(
                  leading: CircleAvatar(backgroundColor: groups[t.groupId]?.color ?? Colors.grey),
                  title: Text(t.title),
                  subtitle: Text(t.startDate.toLocal().toString().split(' ').first),
                ),
              ),
        ],
      ),
    );
  }
}
