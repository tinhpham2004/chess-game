import 'package:chess_game/data/datasource/game_room_dao.dart';
import 'package:chess_game/data/models/game_room_model.dart';

class GameRoomRepository {
  final GameRoomDao _dao;

  GameRoomRepository(this._dao);

  Future<void> saveGameRoom(GameRoomModel gameRoom) async {
    await _dao.insertGameRoom(gameRoom);
  }

  Future<GameRoomModel?> fetchGameRoom(String id) async {
    return await _dao.getGameRoom(id);
  }

  Future<void> deleteGameRoom(String id) async {
    await _dao.deleteGameRoom(id);
  }

  Future<void> clearAllGameRooms() async {
    await _dao.clearAll();
  }

  Future<List<GameRoomModel>> fetchAllGameRooms() async {
    return await _dao.getAllGameRooms();
  }
}
