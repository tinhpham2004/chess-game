import 'package:chess_game/data/entities/match_history_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'db_provider.dart';

@injectable
class MatchHistoryDao {
  final Database db;

  MatchHistoryDao(this.db);

  Future<void> insertMatchHistory(MatchHistoryEntity matchHistory) async {
    await db.insert(
      DBProvider.tableMatchHistory,
      matchHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MatchHistoryEntity?> getMatchHistory(String id) async {
    final result = await db.query(
      DBProvider.tableMatchHistory,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return MatchHistoryEntity.fromMap(result.first);
    }
    return null;
  }

  Future<List<MatchHistoryEntity>> getMatchHistoryByGameId(String gameId) async {
    final result = await db.query(
      DBProvider.tableMatchHistory,
      where: 'gameId = ?',
      whereArgs: [gameId],
      orderBy: 'date DESC',
    );

    return result.map((map) => MatchHistoryEntity.fromMap(map)).toList();
  }

  Future<List<MatchHistoryEntity>> getAllMatchHistory() async {
    final result = await db.query(
      DBProvider.tableMatchHistory,
      orderBy: 'date DESC',
    );
    return result.map((map) => MatchHistoryEntity.fromMap(map)).toList();
  }

  Future<void> deleteMatchHistory(String id) async {
    await db.delete(
      DBProvider.tableMatchHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMatchHistoryByGameId(String gameId) async {
    await db.delete(
      DBProvider.tableMatchHistory,
      where: 'gameId = ?',
      whereArgs: [gameId],
    );
  }

  Future<void> clearAll() async {
    await db.delete(DBProvider.tableMatchHistory);
  }
}
