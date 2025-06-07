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

// New events for hint functionality
class RequestHintEvent extends GameRoomEvent {}

class DismissHintEvent extends GameRoomEvent {}

class ChangeAIDifficultyEvent extends GameRoomEvent {
  final int difficultyLevel; // 1-4: Random, Minimax depth 1-3
  ChangeAIDifficultyEvent({required this.difficultyLevel});
}

// FIDE rules events
class CheckGameEndConditionsEvent extends GameRoomEvent {}

class ClaimDrawEvent extends GameRoomEvent {
  final String
      reason; // "threefold_repetition", "fifty_move_rule", "insufficient_material", "stalemate"
  ClaimDrawEvent({required this.reason});
}

// Timer and clock events
class StartTimerEvent extends GameRoomEvent {}

class PauseTimerEvent extends GameRoomEvent {}

class ResumeTimerEvent extends GameRoomEvent {}

class TimerTickEvent extends GameRoomEvent {
  final int whiteTimeLeft; // in seconds
  final int blackTimeLeft; // in seconds
  TimerTickEvent({required this.whiteTimeLeft, required this.blackTimeLeft});
}

class TimeoutEvent extends GameRoomEvent {
  final PieceColor timeoutColor; // which player ran out of time
  TimeoutEvent({required this.timeoutColor});
}
