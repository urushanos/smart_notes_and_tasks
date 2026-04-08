import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../models/task_group.dart';
import '../models/task_item.dart';
import '../providers/app_state.dart';

class TaskEditorScreen extends StatefulWidget {
  final TaskItem? initialTask;
  const TaskEditorScreen({super.key, this.initialTask});

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final List<TextEditingController> _steps = [];
  final ConfettiController _confetti = ConfettiController(duration: const Duration(seconds: 1));
  RepeatType _repeat = RepeatType.once;
  List<int> _repeatDays = [];
  DateTime _start = DateTime.now();
  String? _groupId;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    if (task != null) {
      _title.text = task.title;
      _repeat = task.repeatType;
      _repeatDays = [...task.repeatDays];
      _start = task.startDate;
      _groupId = task.groupId;
      for (final step in task.steps) {
        _steps.add(TextEditingController(text: step));
      }
    }
    if (_steps.isEmpty) _steps.add(TextEditingController());
  }

  @override
  void dispose() {
    _confetti.dispose();
    _title.dispose();
    for (final step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final groups = app.groups;
    final orderedGroups = [...groups]
      ..sort((a, b) {
        final rankA = _groupRank(a.name);
        final rankB = _groupRank(b.name);
        if (rankA != rankB) return rankA.compareTo(rankB);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    _groupId ??= orderedGroups.isNotEmpty ? orderedGroups.first.id : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialTask == null ? 'Add Task' : 'Edit Task')),
      body: Stack(
        children: [
          Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null,
                ),
                const SizedBox(height: 12),
                ..._steps.asMap().entries.map((entry) {
                  final i = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: 'Step ${i + 1}',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _steps.length == 1 ? null : () => setState(() => _steps.removeAt(i)),
                        ),
                      ),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _steps.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                ),
                DropdownButtonFormField<RepeatType>(
                  value: _repeat,
                  items: RepeatType.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                  onChanged: (v) => setState(() => _repeat = v ?? RepeatType.once),
                  decoration: const InputDecoration(labelText: 'Repeat'),
                ),
                if (_repeat == RepeatType.custom)
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final selected = _repeatDays.contains(day);
                      return FilterChip(
                        selected: selected,
                        label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][index]),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _repeatDays.add(day);
                            } else {
                              _repeatDays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                Row(
                  children: [
                    Expanded(child: Text('Start: ${_start.toLocal().toString().split(' ').first}')),
                    TextButton(onPressed: _pickDate, child: const Text('Pick')),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _groupId,
                  decoration: const InputDecoration(labelText: 'Group'),
                  items: orderedGroups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                  onChanged: (v) => setState(() => _groupId = v),
                ),
                TextButton.icon(
                  onPressed: () => _showCreateGroup(context),
                  icon: const Icon(Icons.palette),
                  label: const Text('Create Group'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (!_form.currentState!.validate() || _groupId == null) return;
                    final existing = widget.initialTask;
                    final task = (existing ??
                            TaskItem(
                              id: '',
                              userId: app.currentAuthUser!.uid,
                              title: '',
                              steps: const [],
                              isCompleted: false,
                              groupId: _groupId!,
                              startDate: _start,
                              endDate: _start,
                              repeatType: _repeat,
                              repeatDays: _repeatDays,
                              completedDate: null,
                            ))
                        .copyWith(
                      title: _title.text.trim(),
                      steps: _steps.map((s) => s.text.trim()).where((e) => e.isNotEmpty).toList(),
                      groupId: _groupId!,
                      startDate: _start,
                      endDate: _start,
                      repeatType: _repeat,
                      repeatDays: _repeatDays,
                    );
                    await app.saveTask(task);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Task'),
                ),
                if (widget.initialTask != null) ...[
                  OutlinedButton(
                    onPressed: () async {
                      final task = widget.initialTask!;
                      final beforeDue = DateTime.now().isBefore(task.endDate);
                      _confetti.play();
                      await app.toggleTask(task.copyWith(isCompleted: false));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(beforeDue ? 'Hooray!!' : 'Task marked finished')),
                        );
                      }
                    },
                    child: const Text('Mark as Finished'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Task?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await app.deleteTask(widget.initialTask!.id);
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _start,
    );
    if (selected == null) return;
    setState(() {
      _start = selected;
    });
  }

  int _groupRank(String groupName) {
    final normalized = groupName.trim().toLowerCase();
    if (normalized == 'dailies') return 0;
    if (normalized == 'upcoming') return 1;
    return 2;
  }

  Future<void> _showCreateGroup(BuildContext context) async {
    final app = context.read<AppState>();
    final nameController = TextEditingController();
    Color selected = Colors.teal;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Group'),
        content: StatefulBuilder(
          builder: (context, setInner) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Group name')),
                const SizedBox(height: 12),
                ColorPicker(
                  pickerColor: selected,
                  onColorChanged: (c) => setInner(() => selected = c),
                  enableAlpha: false,
                  showLabel: false,
                  displayThumbColor: true,
                  pickerAreaHeightPercent: 0.7,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final group = await app.addGroupAndReturn(nameController.text.trim(), selected);
              if (group != null && mounted) {
                setState(() => _groupId = group.id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
