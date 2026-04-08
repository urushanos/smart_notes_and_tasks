import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/task_group.dart';
import '../models/task_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _tasks => _firestore.collection('tasks');
  CollectionReference<Map<String, dynamic>> get _groups => _firestore.collection('groups');

  Future<void> saveUser(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Stream<AppUser?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!);
    });
  }

  Stream<List<TaskGroup>> groupsStream(String uid) {
    return _groups
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => TaskGroup.fromMap(e.data())).toList());
  }

  Stream<List<TaskItem>> tasksStream(String uid) {
    return _tasks
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => TaskItem.fromMap(e.data())).toList());
  }

  Future<void> addGroup(TaskGroup group) => _groups.doc(group.id).set(group.toMap());

  Future<void> addTask(TaskItem task) => _tasks.doc(task.id).set(task.toMap());

  Future<void> updateTask(TaskItem task) => _tasks.doc(task.id).set(task.toMap(), SetOptions(merge: true));

  Future<void> deleteTask(String taskId) => _tasks.doc(taskId).delete();
}
