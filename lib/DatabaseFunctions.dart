import 'Notes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class PersistentData {
  static const DB_NAME = "notty_db.db";
  static const TABLE_NAME = "NOTTY_TABLE";

  late Database _database;

  PersistentData._create();

  static Future<PersistentData> create() async {
    PersistentData result = PersistentData._create();
    result._database = await openDatabase(path.join(await getDatabasesPath(), DB_NAME), version: 1, onCreate: (Database db, int version) {
      return db.execute("CREATE TABLE $TABLE_NAME(title TEXT NOT NULL PRIMARY KEY, body TEXT NOT NULL);");
    });

    return result;
  }

  Future<List<SingleNote>> readDatabase() async {
    List<Map> queryResult = await _database.rawQuery("SELECT * FROM $TABLE_NAME ORDER BY title ASC;");

    return List.generate(queryResult.length, (index) {
      return SingleNote(title: queryResult[index]["title"], body: queryResult[index]["body"]);
    });
  }

  Future<void> updateDatabase(final SingleNote note) async {
    await _database.insert(TABLE_NAME, note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromDatabase(final SingleNote note) async {
    await _database.delete(TABLE_NAME, where: "title = ?", whereArgs: [note.getTitle()]);
  }
}


