import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddNotePage extends StatelessWidget {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final db = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Note")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: InputDecoration(labelText: "Content"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await db.insertNote(
                  titleController.text,
                  contentController.text,
                );
                Navigator.pop(context);
              },
              child: Text("Save Note"),
            )
          ],
        ),
      ),
    );
  }
}