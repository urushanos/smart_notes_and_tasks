import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/task_group.dart';
import '../models/task_item.dart';
import 'firestore_service.dart';

class SeedService {
  final FirestoreService _firestoreService;
  final _random = Random();
  final _uuid = const Uuid();

  SeedService(this._firestoreService);

  Future<void> ensureDefaultData(AppUser user, List<TaskGroup> existingGroups, List<TaskItem> existingTasks) async {
    if (existingGroups.isNotEmpty || existingTasks.isNotEmpty) return;

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
      colorHex: '#CDDC39',
    );

    await _firestoreService.addGroup(dailies);
    await _firestoreService.addGroup(study);

    final now = DateTime.now();
    final seedTasks = <TaskItem>[
      _task(user.uid, 'Running', dailies.id, now, RepeatType.daily),
      _task(user.uid, 'Coursera', study.id, now, RepeatType.alternate),
      _task(user.uid, 'Leetcode', study.id, now, RepeatType.daily),
    ];
    for (final task in seedTasks) {
      await _firestoreService.addTask(task);
    }

    await _seedRecentRandomProgress(user.uid, dailies.id, study.id, now);
  }

  Future<void> _seedRecentRandomProgress(
    String userId,
    String dailiesGroupId,
    String studyGroupId,
    DateTime now,
  ) async {
    for (var i = 1; i <= 14; i++) {
      final day = DateUtils.dateOnly(now.subtract(Duration(days: i)));
      final completedCount = _random.nextInt(4); // 0..3 tasks completed on a day
      if (completedCount == 0) continue;
      final candidates = <TaskItem>[
        _historyTask(userId, 'Running', dailiesGroupId, RepeatType.daily, day),
        _historyTask(userId, 'Coursera', studyGroupId, RepeatType.alternate, day),
        _historyTask(userId, 'Leetcode', studyGroupId, RepeatType.daily, day),
      ]..shuffle(_random);
      final take = completedCount > 2 ? 2 : completedCount;
      for (var j = 0; j < take; j++) {
        await _firestoreService.addTask(candidates[j]);
      }
    }
  }

  TaskItem _historyTask(String userId, String title, String groupId, RepeatType repeatType, DateTime day) {
    return TaskItem(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      steps: const [],
      isCompleted: true,
      groupId: groupId,
      startDate: day,
      endDate: day,
      repeatType: repeatType,
      repeatDays: const [],
      completedDate: day,
    );
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
      endDate: date,
      repeatType: repeatType,
      repeatDays: repeatDays,
      completedDate: null,
    );
  }
}
