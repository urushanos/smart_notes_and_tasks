import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_group.dart';
import '../models/task_item.dart';
import '../providers/app_state.dart';
import '../utils/date_formatters.dart';
import 'task_editor_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selected = 'Dailies';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final groups = app.groups;
    TaskGroup? selectedGroup;
    for (final g in groups) {
      if (g.name == _selected) {
        selectedGroup = g;
        break;
      }
    }

    final today = DateUtils.dateOnly(DateTime.now());
    TaskGroup? dailiesGroup;
    TaskGroup? upcomingGroup;
    for (final group in groups) {
      final name = group.name.trim().toLowerCase();
      if (name == 'dailies') dailiesGroup = group;
      if (name == 'upcoming') upcomingGroup = group;
    }

    final pending = app.tasks.where((t) {
      if (t.isCompleted) return false;
      if (_selected == 'Upcoming') {
        if (upcomingGroup != null) return t.groupId == upcomingGroup.id;
        return t.startDate.isAfter(today);
      }
      if (_selected == 'Dailies') {
        if (dailiesGroup != null) return t.groupId == dailiesGroup.id;
        return true;
      }
      return selectedGroup != null ? t.groupId == selectedGroup.id : true;
    }).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));

    final completed = app.tasks.where((task) {
      if (!task.isCompleted || task.completedDate == null) return false;
      if (!DateUtils.isSameDay(task.completedDate, today)) return false;
      if (_selected == 'Dailies' && dailiesGroup != null) return task.groupId == dailiesGroup.id;
      if (_selected == 'Upcoming') return upcomingGroup != null ? task.groupId == upcomingGroup.id : false;
      if (selectedGroup != null) return task.groupId == selectedGroup.id;
      return true;
    }).toList()
      ..sort((a, b) => b.completedDate!.compareTo(a.completedDate!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskEditorScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _selected,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              const DropdownMenuItem(value: 'Dailies', child: Text('Dailies')),
              const DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
              ...groups
                  .where((g) => g.name.trim().toLowerCase() != 'dailies' && g.name.trim().toLowerCase() != 'upcoming')
                  .map((g) => DropdownMenuItem(value: g.name, child: Text(g.name))),
            ],
            onChanged: (v) => setState(() => _selected = v ?? 'Dailies'),
          ),
          if (_selected == 'Upcoming') ...[
            const SizedBox(height: 12),
            const Text('Upcoming', style: TextStyle(fontWeight: FontWeight.bold)),
            ...pending.map((task) => _tile(task, groups)),
          ] else ...[
            const SizedBox(height: 12),
            const Text('Pending', style: TextStyle(fontWeight: FontWeight.bold)),
            if (pending.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("You're done for the day!"),
              ),
            ...pending.map((task) => _tile(task, groups)),
          ],
          const SizedBox(height: 8),
          if (completed.isNotEmpty) ...[
            const Text('Completed', style: TextStyle(fontWeight: FontWeight.bold)),
            ...completed.map((task) => _tile(task, groups)),
          ],
        ],
      ),
    );
  }

  Widget _tile(TaskItem task, List<TaskGroup> groups) {
    TaskGroup? group;
    for (final g in groups) {
      if (g.id == task.groupId) {
        group = g;
        break;
      }
    }
    final edgeColor = group?.color ?? Colors.blueGrey;

    return Consumer<AppState>(
      builder: (_, app, __) => Card(
        child: ListTile(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskEditorScreen(initialTask: task))),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => app.toggleTask(task),
          ),
          title: Text(
            task.title,
            style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(formatDateDdMmYyyy(task.endDate)),
          trailing: Container(
            width: 6,
            height: 36,
            decoration: BoxDecoration(
              color: edgeColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}
