import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static const _dbName = 'chess_app.db';
  static const _dbVersion = 1;
  static const tableGameRoom = 'game_room';

  static final DBProvider instance = DBProvider._internal();

  DBProvider._internal();

  late Database _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Database get database => _db;

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableGameRoom (
        id TEXT PRIMARY KEY,
        json TEXT NOT NULL
      )
    ''');
  }
}
