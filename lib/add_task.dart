import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddTaskPage extends StatelessWidget {
  final titleController = TextEditingController();
  final db = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Task")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Task Title"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await db.insertTask(titleController.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}