import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), "tasks.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute(
            "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, status TEXT)"
        );

        await database.execute(
            "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT)"
        );
      },
    );
  }

  Future<void> insertTask(String title) async {
    final database = await db;

    await database.insert("tasks", {
      "title": title,
      "status": "pending"
    });
    //await database.insert("tasks", {"title": title});
    //print("Inserted task with id:");
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final database = await db;
    return await database.query("tasks");
  }

  // Insert Note
  Future<void> insertNote(String title, String content) async {
    final database = await db;
    await database.insert("notes", {
      "title": title,
      "content": content,
    });
  }

// Get Notes
  Future<List<Map<String, dynamic>>> getNotes() async {
    final database = await db;
    return await database.query("notes");
  }
}