import 'package:chess_game/data/models/game_room_model.dart';
import 'package:sqflite/sqflite.dart';
import 'db_provider.dart';

class GameRoomDao {
  final Database db;

  GameRoomDao(this.db);

  Future<void> insertGameRoom(GameRoomModel gameRoom) async {
    await db.insert(
      DBProvider.tableGameRoom,
      gameRoom.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<GameRoomModel?> getGameRoom(String id) async {
    final result = await db.query(
      DBProvider.tableGameRoom,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return GameRoomModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteGameRoom(String id) async {
    await db.delete(
      DBProvider.tableGameRoom,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    await db.delete(DBProvider.tableGameRoom);
  }

  Future<List<GameRoomModel>> getAllGameRooms() async {
    final result = await db.query(DBProvider.tableGameRoom);
    return result.map((map) => GameRoomModel.fromMap(map)).toList();
  }
}
