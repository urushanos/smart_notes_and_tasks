import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_group.dart';
import '../models/task_item.dart';
import '../providers/app_state.dart';
import 'task_editor_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selected = 'Dailies';
  bool _showCompleted = false;

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

    final now = DateTime.now();
    final comingSoonDate = now.add(const Duration(days: 14));

    final pending = app.tasks.where((t) {
      if (t.isCompleted) return false;
      if (_selected == 'Upcoming') return t.startDate.isAfter(now);
      if (_selected == 'Dailies') return true;
      return selectedGroup != null ? t.groupId == selectedGroup.id : true;
    }).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));

    final completed = app.tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
        actions: [
          IconButton(
            onPressed: () => app.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
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
              ...groups.map((g) => DropdownMenuItem(value: g.name, child: Text(g.name))),
            ],
            onChanged: (v) => setState(() => _selected = v ?? 'Dailies'),
          ),
          if (_selected == 'Upcoming') ...[
            const SizedBox(height: 12),
            const Text('Coming Soon (next 2 weeks)', style: TextStyle(fontWeight: FontWeight.bold)),
            ...pending.where((t) => t.startDate.isBefore(comingSoonDate)).map(_tile),
            const SizedBox(height: 8),
            const Text('Coming Later', style: TextStyle(fontWeight: FontWeight.bold)),
            ...pending.where((t) => t.startDate.isAfter(comingSoonDate)).map(_tile),
          ] else ...[
            const SizedBox(height: 12),
            const Text('Pending', style: TextStyle(fontWeight: FontWeight.bold)),
            ...pending.map(_tile),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _showCompleted = !_showCompleted),
            child: Text(_showCompleted ? 'Hide Completed' : 'Show Completed'),
          ),
          if (_showCompleted) ...[
            const Text('Completed', style: TextStyle(fontWeight: FontWeight.bold)),
            ...completed.map(_tile),
          ],
        ],
      ),
    );
  }

  Widget _tile(TaskItem task) {
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
          subtitle: Text(task.endDate.toLocal().toString().split(' ').first),
        ),
      ),
    );
  }
}
