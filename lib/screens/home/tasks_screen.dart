import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class TasksScreen extends StatelessWidget {
  final FirestoreService _db = FirestoreService();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;

    return StreamBuilder(
      stream: _db.getTasks(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final tasks = snapshot.data!.docs;

        return ListView(
          children: tasks.map((task) {
            return ListTile(
              title: Text(task['title']),
              trailing: Checkbox(
                value: task['completed'],
                onChanged: (_) {},
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
