import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';

class DBProvider {
  static const _dbName = 'chess_app.db';
  static const _dbVersion = 2;
  static const tableGameRoom = 'game_room';
  static const tableMatchHistory = 'match_history';

  static final DBProvider instance = DBProvider._internal();
  DBProvider._internal();

  late Database _db;

  @factoryMethod
  static Future<DBProvider> create() async {
    final instance = DBProvider.instance;
    await instance.init();
    return instance;
  }

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE $tableMatchHistory (
        id TEXT PRIMARY KEY,
        gameId TEXT NOT NULL,
        whitePlayer TEXT NOT NULL,
        blackPlayer TEXT NOT NULL,
        winner TEXT NOT NULL,
        moveHistory TEXT NOT NULL,
        date TEXT NOT NULL,
        isAiOpponent INTEGER NOT NULL,
        aiDifficulty INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $tableMatchHistory (
          id TEXT PRIMARY KEY,
          gameId TEXT NOT NULL,
          whitePlayer TEXT NOT NULL,
          blackPlayer TEXT NOT NULL,
          winner TEXT NOT NULL,
          moveHistory TEXT NOT NULL,
          date TEXT NOT NULL,
          isAiOpponent INTEGER NOT NULL,
          aiDifficulty INTEGER
        )
      ''');
    }
  }
}
