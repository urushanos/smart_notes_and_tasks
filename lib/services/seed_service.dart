import 'dart:math';

import '../models/app_user.dart';
import '../models/task_group.dart';
import '../models/task_item.dart';
import 'firestore_service.dart';

class SeedService {
  final FirestoreService _firestoreService;
  final _random = Random();

  SeedService(this._firestoreService);

  Future<void> ensureDefaultData(AppUser user, List<TaskGroup> existingGroups, List<TaskItem> existingTasks) async {
    if (existingGroups.isNotEmpty || existingTasks.isNotEmpty) {
      return;
    }

    final dailies = TaskGroup(
      id: '${user.uid}_dailies',
      name: 'Dailies',
      userId: user.uid,
      colorHex: '#4CAF50',
    );
    final study = TaskGroup(
      id: '${user.uid}_study',
      name: 'Study',
      userId: user.uid,
      colorHex: '#2196F3',
    );

    await _firestoreService.addGroup(dailies);
    await _firestoreService.addGroup(study);

    final now = DateTime.now();
    final seedTasks = <TaskItem>[
      _task(user.uid, 'Running', dailies.id, now, RepeatType.daily),
      _task(user.uid, 'Coursera', study.id, now.add(const Duration(days: 1)), RepeatType.custom, [1, 3, 5]),
      _task(user.uid, 'Leetcode Practice', study.id, now.add(const Duration(days: 2)), RepeatType.alternate),
    ];
    for (final task in seedTasks) {
      await _firestoreService.addTask(task);
    }

    for (var i = 1; i <= 14; i++) {
      final day = now.subtract(Duration(days: i));
      if (_random.nextBool()) {
        final doneTask = _task(
          user.uid,
          'Completed Day $i',
          dailies.id,
          day,
          RepeatType.once,
        ).copyWith(isCompleted: true, completedDate: day);
        await _firestoreService.addTask(doneTask);
      }
    }
  }

  TaskItem _task(
    String userId,
    String title,
    String groupId,
    DateTime date,
    RepeatType repeatType, [
    List<int> repeatDays = const [],
  ]) {
    final id = '${userId}_${title.toLowerCase().replaceAll(' ', '_')}_${date.millisecondsSinceEpoch}';
    return TaskItem(
      id: id,
      userId: userId,
      title: title,
      steps: const [],
      isCompleted: false,
      groupId: groupId,
      startDate: date,
      endDate: date.add(const Duration(days: 1)),
      repeatType: repeatType,
      repeatDays: repeatDays,
      completedDate: null,
    );
  }
}
