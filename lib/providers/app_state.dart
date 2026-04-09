import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/task_group.dart';
import '../models/task_item.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _userSub;
  StreamSubscription<List<TaskGroup>>? _groupsSub;
  StreamSubscription<List<TaskItem>>? _tasksSub;

  AppUser? currentProfile;
  User? currentAuthUser;
  List<TaskGroup> groups = [];
  List<TaskItem> tasks = [];
  bool loading = true;
  bool firstLogin = false;
  bool _seedChecked = false;

  Future<void> initialize() async {
    _authSub = _authService.authStateChanges().listen((authUser) async {
      currentAuthUser = authUser;
      if (authUser == null) {
        if (!_seedChecked) {
          await ensureSeedUser();
          _seedChecked = true;
        }
        currentProfile = null;
        groups = [];
        tasks = [];
        loading = false;
        notifyListeners();
        return;
      }
      await _bindUser(authUser.uid);
    });
  }

  Future<void> _bindUser(String uid) async {
    await _userSub?.cancel();
    await _groupsSub?.cancel();
    await _tasksSub?.cancel();

    loading = true;
    notifyListeners();

    _userSub = _firestoreService.userStream(uid).listen((user) {
      currentProfile = user;
      notifyListeners();
    });
    _groupsSub = _firestoreService.groupsStream(uid).listen((value) async {
      groups = value;
      notifyListeners();
    });
    _tasksSub = _firestoreService.tasksStream(uid).listen((value) async {
      tasks = value;
      loading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) => _authService.signIn(email: email, password: password);

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final cred = await _authService.signUp(email: email, password: password);
    final profile = AppUser(uid: cred.user!.uid, username: username, email: email);
    await _firestoreService.saveUser(profile);
    firstLogin = true;
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> ensureSeedUser() async {
    final alreadyInitialized = await _firestoreService.getSeedInitialized();
    if (!alreadyInitialized) {
      await _firestoreService.clearCollection('tasks');
      await _firestoreService.clearCollection('groups');
      await _firestoreService.clearCollection('users');
      await _firestoreService.setSeedInitialized(true);
    }
  }

  Future<void> addGroup(String name, Color color) async {
    final uid = currentAuthUser?.uid;
    if (uid == null) return;
    final group = TaskGroup(
      id: _uuid.v4(),
      name: name,
      userId: uid,
      colorHex: '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    );
    await _firestoreService.addGroup(group);
  }

  Future<TaskGroup?> addGroupAndReturn(String name, Color color) async {
    final uid = currentAuthUser?.uid;
    if (uid == null) return null;
    final group = TaskGroup(
      id: _uuid.v4(),
      name: name,
      userId: uid,
      colorHex: '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    );
    await _firestoreService.addGroup(group);
    return group;
  }

  Future<void> saveTask(TaskItem task) async {
    if (task.id.isEmpty) {
      await _firestoreService.addTask(task.copyWith(id: _uuid.v4()));
      return;
    }
    await _firestoreService.updateTask(task);
  }

  Future<void> deleteTask(String id) => _firestoreService.deleteTask(id);

  Future<void> toggleTask(TaskItem task) async {
    final completed = !task.isCompleted;
    await _firestoreService.updateTask(
      task.copyWith(
        isCompleted: completed,
        completedDate: completed ? DateTime.now() : null,
        clearCompletedDate: !completed,
      ),
    );
  }

  Future<void> updateProfilePhotoPath(String? photoPath) async {
    final profile = currentProfile;
    if (profile == null) return;
    final updated = profile.copyWith(
      photoPath: photoPath,
      clearPhotoPath: photoPath == null,
    );
    await _firestoreService.saveUser(updated);
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
  int get overdueCount => tasks.where((t) => !t.isCompleted && t.endDate.isBefore(DateTime.now())).length;

  int get currentStreak {
    var streak = 0;
    var day = DateUtils.dateOnly(DateTime.now());
    while (tasks.any((t) => t.completedDate != null && DateUtils.isSameDay(t.completedDate!, day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    final completedDays = tasks
        .where((t) => t.completedDate != null)
        .map((t) => DateUtils.dateOnly(t.completedDate!))
        .toSet()
        .toList()
      ..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final day in completedDays) {
      if (prev == null || day.difference(prev).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = day;
    }
    return best;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    _groupsSub?.cancel();
    _tasksSub?.cancel();
    super.dispose();
  }
}
