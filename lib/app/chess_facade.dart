import 'package:chess_game/data/models/game_room_model.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';

class ChessFacade {
  final GameRoomRepository _gameRoomRepository;

  ChessFacade(this._gameRoomRepository);

  Future<void> saveGameRoom(GameRoomModel gameRoom) {
    return _gameRoomRepository.saveGameRoom(gameRoom);
  }

  Future<GameRoomModel?> loadGameRoom(String id) {
    return _gameRoomRepository.fetchGameRoom(id);
  }

  Future<void> deleteGameRoom(String id) {
    return _gameRoomRepository.deleteGameRoom(id);
  }

  Future<void> clearAll() {
    return _gameRoomRepository.clearAllGameRooms();
  }

  Future<List<GameRoomModel>> getAllGameRooms() {
    return _gameRoomRepository.fetchAllGameRooms();
  }
}
