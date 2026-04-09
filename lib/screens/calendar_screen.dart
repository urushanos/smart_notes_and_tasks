import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/task_group.dart';
import '../models/task_item.dart';
import '../providers/app_state.dart';
import '../utils/date_formatters.dart';

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
    final monthStart = DateTime(_focused.year, _focused.month, 1);
    final monthEnd = DateTime(_focused.year, _focused.month + 1, 0, 23, 59, 59);

    final filteredTasks = app.tasks.where((task) {
      if (_filters.isNotEmpty && !_filters.contains(task.groupId)) return false;
      return true;
    }).toList();

    final upcoming = filteredTasks.where((task) {
      if (task.isCompleted) return false;
      return !task.startDate.isBefore(monthStart) && !task.startDate.isAfter(monthEnd);
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TableCalendar<TaskItem>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focused,
            selectedDayPredicate: (day) => isSameDay(_selected, day),
            headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selected = selectedDay;
                _focused = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => setState(() => _focused = focusedDay),
            eventLoader: (day) => filteredTasks.where((task) => isSameDay(day, task.startDate)).toList(),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => _buildDayCell(
                day: day,
                events: filteredTasks.where((task) => isSameDay(day, task.startDate)).toList(),
                groups: groups,
                selected: false,
                isToday: DateUtils.isSameDay(day, DateTime.now()),
              ),
              selectedBuilder: (context, day, focusedDay) => _buildDayCell(
                day: day,
                events: filteredTasks.where((task) => isSameDay(day, task.startDate)).toList(),
                groups: groups,
                selected: true,
                isToday: DateUtils.isSameDay(day, DateTime.now()),
              ),
              todayBuilder: (context, day, focusedDay) => _buildDayCell(
                day: day,
                events: filteredTasks.where((task) => isSameDay(day, task.startDate)).toList(),
                groups: groups,
                selected: isSameDay(_selected, day),
                isToday: true,
              ),
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
          const Text('Upcoming tasks', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: upcoming.isEmpty
                ? const Center(child: Text('No upcoming tasks for this month'))
                : ListView.builder(
                    itemCount: upcoming.length,
                    itemBuilder: (context, index) {
                      final task = upcoming[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: groups[task.groupId]?.color ?? Colors.grey),
                        title: Text(task.title),
                        subtitle: Text(formatDateDdMmYyyy(task.startDate)),
                      );
                    },
                  ),
              ),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime day,
    required List<TaskItem> events,
    required Map<String, TaskGroup> groups,
    required bool selected,
    required bool isToday,
  }) {
    final TaskItem? task = events.isEmpty ? null : events.first;
    final Color bubbleColor = task == null
        ? (selected ? Colors.blue.shade600 : Colors.transparent)
        : (groups[task.groupId]?.color ?? Colors.blue.shade400);
    final Color textColor = task == null
        ? (selected ? Colors.white : (isToday ? Colors.blue.shade700 : Colors.black87))
        : Colors.white;

    final pendingTitles = events.where((event) => !event.isCompleted).map((event) => event.title).toSet().toList();
    final tooltip = pendingTitles.isEmpty ? 'No tasks' : pendingTitles.join('\n');

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 250),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bubbleColor,
          shape: BoxShape.circle,
          border: isToday ? Border.all(color: Colors.blue.shade700, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: (selected || task != null) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
