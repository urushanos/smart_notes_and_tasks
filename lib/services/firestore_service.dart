import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTasks(String uid) {
    return _db.collection('users').doc(uid).collection('tasks').snapshots();
  }

  Future<void> addTask(String uid, Map<String, dynamic> task) async {
    await _db.collection('users').doc(uid).collection('tasks').add(task);
  }
}