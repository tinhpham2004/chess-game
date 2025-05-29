import 'dart:convert';

import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/data/datasource/game_room_dao.dart';
import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class GameRoomRepository {
  final GameRoomDao _dao;

  GameRoomRepository(this._dao);

  Future<void> saveGameRoom(GameRoomEntity gameRoom) async {
    await _dao.insertGameRoom(gameRoom);
  }

  Future<GameRoomEntity?> fetchGameRoom(String id) async {
    return await _dao.getGameRoom(id);
  }

  Future<void> deleteGameRoom(String id) async {
    await _dao.deleteGameRoom(id);
  }

  Future<void> clearAllGameRooms() async {
    await _dao.clearAll();
  }

  Future<List<GameRoomEntity>> fetchAllGameRooms() async {
    return await _dao.getAllGameRooms();
  }

  Future<GameConfig?> fetchGameConfig(GameRoomEntity gameRoom) async {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(gameRoom.json);
      if (jsonData.containsKey('gameConfig')) {
        final gameConfigJson = jsonEncode(jsonData['gameConfig']);
        return GameConfig.fromJson(gameConfigJson);
      }
    } catch (e) {
      // Handle or log the error if necessary
    }
    return null;
  }
}
