import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_note.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {

  final db = DBHelper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: db.getNotes(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var notes = snapshot.data as List;

        if (notes.isEmpty) {
          return Center(
            child: Text(
              "Add a note...",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notes[index]['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(notes[index]['content']),
                ],
              ),
            );
          },
        );
      },
    );
  }
}