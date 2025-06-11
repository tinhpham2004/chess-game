part of 'game_mediator_bloc.dart';

/// Base class for all GameMediator events
abstract class GameMediatorEvent extends Equatable {
  const GameMediatorEvent();

  @override
  List<Object?> get props => [];
}

/// UI Interaction Events
class BoardSquareTappedEvent extends GameMediatorEvent {
  final Position position;

  const BoardSquareTappedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class PieceDroppedEvent extends GameMediatorEvent {
  final Position from;
  final Position to;

  const PieceDroppedEvent(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

class UndoRequestedEvent extends GameMediatorEvent {
  const UndoRequestedEvent();
}

class RestartRequestedEvent extends GameMediatorEvent {
  const RestartRequestedEvent();
}

class HintRequestedEvent extends GameMediatorEvent {
  const HintRequestedEvent();
}

/// Chat Events
class SendMessageEvent extends GameMediatorEvent {
  final String message;
  final String sender;

  const SendMessageEvent(this.message, this.sender);

  @override
  List<Object?> get props => [message, sender];
}

class ClearMessagesEvent extends GameMediatorEvent {
  const ClearMessagesEvent();
}

/// Game State Synchronization Events
class SyncGameStateEvent extends GameMediatorEvent {
  final GameRoomState gameRoomState;

  const SyncGameStateEvent(this.gameRoomState);

  @override
  List<Object?> get props => [gameRoomState];
}

class BoardChangedEvent extends GameMediatorEvent {
  const BoardChangedEvent();
}

class MoveRecordedEvent extends GameMediatorEvent {
  final String move;
  final String player;

  const MoveRecordedEvent(this.move, {this.player = "Player"});

  @override
  List<Object?> get props => [move, player];
}

class GameOverEvent extends GameMediatorEvent {
  final String reason;
  final String? winner;

  const GameOverEvent(this.reason, {this.winner});

  @override
  List<Object?> get props => [reason, winner];
}

/// Timer Events
class MediatorTimerTickEvent extends GameMediatorEvent {
  final int whiteTime;
  final int blackTime;
  final PieceColor activeColor;

  const MediatorTimerTickEvent(
      this.whiteTime, this.blackTime, this.activeColor);

  @override
  List<Object?> get props => [whiteTime, blackTime, activeColor];
}

class TimerStartedEvent extends GameMediatorEvent {
  const TimerStartedEvent();
}

class TimerPausedEvent extends GameMediatorEvent {
  const TimerPausedEvent();
}

class TimerResumedEvent extends GameMediatorEvent {
  const TimerResumedEvent();
}

class TimerStoppedEvent extends GameMediatorEvent {
  const TimerStoppedEvent();
}

/// Component Update Events
class UpdateChessBoardEvent extends GameMediatorEvent {
  final List<List<ChessPiece?>> board;
  final Position? selectedPosition;
  final List<List<bool>> possibleMoves;

  const UpdateChessBoardEvent(
      this.board, this.selectedPosition, this.possibleMoves);

  @override
  List<Object?> get props => [board, selectedPosition, possibleMoves];
}

class UpdateMoveHistoryEvent extends GameMediatorEvent {
  final List<String> moveHistory;

  const UpdateMoveHistoryEvent(this.moveHistory);

  @override
  List<Object?> get props => [moveHistory];
}

class UpdateControlPanelEvent extends GameMediatorEvent {
  final bool canUndo;
  final bool gameEnded;
  final bool isWhitesTurn;

  const UpdateControlPanelEvent(
      this.canUndo, this.gameEnded, this.isWhitesTurn);

  @override
  List<Object?> get props => [canUndo, gameEnded, isWhitesTurn];
}

/// AI Events
class AIRequestHintEvent extends GameMediatorEvent {
  const AIRequestHintEvent();
}

class AIShowHintEvent extends GameMediatorEvent {
  final Position from;
  final Position to;

  const AIShowHintEvent(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

class AIMakeMoveEvent extends GameMediatorEvent {
  final Position from;
  final Position to;
  final String notation;

  const AIMakeMoveEvent(this.from, this.to, this.notation);

  @override
  List<Object?> get props => [from, to, notation];
}
