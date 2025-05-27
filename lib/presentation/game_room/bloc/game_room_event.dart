part of 'game_room_bloc.dart';

abstract class GameRoomEvent {}

class GameRoomInitialized extends GameRoomEvent {}

class LoadGameRoomEvent extends GameRoomEvent {
  final String id;
  LoadGameRoomEvent({required this.id});
}

class SaveGameRoomEvent extends GameRoomEvent {
  final GameRoomEntity gameRoom;
  SaveGameRoomEvent({required this.gameRoom});
}

class DeleteGameRoomEvent extends GameRoomEvent {
  final String id;
  DeleteGameRoomEvent({required this.id});
}

class LoadGameConfigEvent extends GameRoomEvent {
  final String gameId;
  LoadGameConfigEvent({required this.gameId});
}

class SaveMatchHistoryEvent extends GameRoomEvent {
  final String gameId;
  final String winner;

  SaveMatchHistoryEvent({
    required this.gameId,
    required this.winner,
  });
}

// Chess Game Events
class StartNewGameEvent extends GameRoomEvent {
  final GameConfig gameConfig;
  StartNewGameEvent({required this.gameConfig});
}

class SelectPieceEvent extends GameRoomEvent {
  final Position position;
  SelectPieceEvent({required this.position});
}

class MovePieceEvent extends GameRoomEvent {
  final Position from;
  final Position to;
  MovePieceEvent({required this.from, required this.to});
}

class AnimationCompletedEvent extends GameRoomEvent {
  final Position from;
  final Position to;
  AnimationCompletedEvent({required this.from, required this.to});
}

class UndoMoveEvent extends GameRoomEvent {}

class RestartGameEvent extends GameRoomEvent {}

class MakeAIMoveEvent extends GameRoomEvent {}

class DeselectPieceEvent extends GameRoomEvent {}
