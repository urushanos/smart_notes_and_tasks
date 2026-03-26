import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_task.dart';
import 'add_note.dart';
import 'calender.dart';
import 'notes.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int currentIndex = 0;
  final db = DBHelper();

  // 🔄 Fetch Tasks
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    return await db.getTasks();
  }

  // ✅ Toggle Task Status
  void toggleTask(int id, String currentStatus) async {
    final database = await db.db;

    await database.update(
      "tasks",
      {"status": currentStatus == "done" ? "pending" : "done"},
      where: "id = ?",
      whereArgs: [id],
    );

    setState(() {});
  }

  // 🗑 Delete Task
  void deleteTask(int id) async {
    final database = await db.db;

    await database.delete(
      "tasks",
      where: "id = ?",
      whereArgs: [id],
    );

    setState(() {});
  }

  Widget taskPage() {
    return FutureBuilder(
      future: fetchTasks(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var tasks = snapshot.data as List;

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              "No tasks yet. Add one!",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {

            var task = tasks[index];

            bool isDone = task['status'] == "done";

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              padding: EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // ✅ rounded
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  )
                ],
              ),

              child: Row(
                children: [

                  Checkbox(
                    value: isDone,
                    onChanged: (_) {
                      toggleTask(task['id'], task['status']);
                    },
                  ),

                  Expanded(
                    child: Text(
                      task['title'],
                      style: TextStyle(
                        fontSize: 16,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),

                  // Delete Button
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteTask(task['id']);
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> get pages => [
    taskPage(),
    CalendarPage(),
    NotesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Manager"),
      ),

      body: pages[currentIndex],

      // ➕ Dynamic FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (currentIndex == 0) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddTaskPage()),
            );
          } else if (currentIndex == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddNotePage()),
            );
          }

          setState(() {}); // 🔥 refresh after returning
        },
        child: Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.note), label: "Notes"),
        ],
      ),
    );
  }
}
/*
* title: Text(tasks[index]['title']),
                  value: _isChecked, // bool variable
                  onChanged: (bool? newValue) =>
                    setState(() {
                      _isChecked = newValue!;
                    }),

                  tileColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                ), margin: const EdgeInsets.all(7),
* */