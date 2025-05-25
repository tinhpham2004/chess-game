import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'db_provider.dart';

@injectable
class GameRoomDao {
  final Database db;

  GameRoomDao(this.db);

  Future<void> insertGameRoom(GameRoomEntity gameRoom) async {
    await db.insert(
      DBProvider.tableGameRoom,
      gameRoom.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<GameRoomEntity?> getGameRoom(String id) async {
    final result = await db.query(
      DBProvider.tableGameRoom,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return GameRoomEntity.fromMap(result.first);
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

  Future<List<GameRoomEntity>> getAllGameRooms() async {
    final result = await db.query(DBProvider.tableGameRoom);
    return result.map((map) => GameRoomEntity.fromMap(map)).toList();
  }
}
