part of 'game_mediator_bloc.dart';

/// Base class for all GameMediator states
abstract class GameMediatorState extends Equatable {
  const GameMediatorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class GameMediatorInitial extends GameMediatorState {
  const GameMediatorInitial();
}

/// Loading state
class GameMediatorLoading extends GameMediatorState {
  const GameMediatorLoading();
}

/// Board interaction states
class BoardInteractionState extends GameMediatorState {
  final Position position;

  const BoardInteractionState(this.position);

  @override
  List<Object?> get props => [position];
}

class PieceMovedState extends GameMediatorState {
  final Position from;
  final Position to;

  const PieceMovedState(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

class BoardChangedState extends GameMediatorState {
  const BoardChangedState();
}

/// Game action states
class UndoExecutedState extends GameMediatorState {
  const UndoExecutedState();
}

class GameRestartedState extends GameMediatorState {
  const GameRestartedState();
}

class HintShownState extends GameMediatorState {
  final Position? from;
  final Position? to;

  const HintShownState({this.from, this.to});

  @override
  List<Object?> get props => [from, to];
}

/// Move recording states
class MoveRecordedState extends GameMediatorState {
  final String move;
  final String player;

  const MoveRecordedState(this.move, {this.player = "Player"});

  @override
  List<Object?> get props => [move, player];
}

/// Game state synchronization
class GameStateSyncedState extends GameMediatorState {
  final GameRoomState gameRoomState;

  const GameStateSyncedState(this.gameRoomState);

  @override
  List<Object?> get props => [gameRoomState];
}

/// Game end states
class GameOverState extends GameMediatorState {
  final String reason;
  final String? winner;

  const GameOverState(this.reason, this.winner);

  @override
  List<Object?> get props => [reason, winner];
}

/// Chat states
class MessageSentState extends GameMediatorState {
  final String message;
  final String sender;

  const MessageSentState(this.message, this.sender);

  @override
  List<Object?> get props => [message, sender];
}

class MessageReceivedState extends GameMediatorState {
  final String message;
  final String sender;
  final DateTime timestamp;

  const MessageReceivedState(this.message, this.sender, this.timestamp);

  @override
  List<Object?> get props => [message, sender, timestamp];
}

class MessagesClearedState extends GameMediatorState {
  const MessagesClearedState();
}

/// Timer states
class TimerUpdatedState extends GameMediatorState {
  final int whiteTime;
  final int blackTime;
  final PieceColor? activeColor;

  const TimerUpdatedState(this.whiteTime, this.blackTime, {this.activeColor});

  @override
  List<Object?> get props => [whiteTime, blackTime, activeColor];
}

class TimerStartedState extends GameMediatorState {
  const TimerStartedState();
}

class TimerPausedState extends GameMediatorState {
  const TimerPausedState();
}

class TimerResumedState extends GameMediatorState {
  const TimerResumedState();
}

class TimerStoppedState extends GameMediatorState {
  const TimerStoppedState();
}

/// Component update states
class ChessBoardUpdatedState extends GameMediatorState {
  final List<List<ChessPiece?>> board;
  final Position? selectedPosition;
  final List<List<bool>> possibleMoves;

  const ChessBoardUpdatedState(
      this.board, this.selectedPosition, this.possibleMoves);

  @override
  List<Object?> get props => [board, selectedPosition, possibleMoves];
}

class MoveHistoryUpdatedState extends GameMediatorState {
  final List<String> moveHistory;

  const MoveHistoryUpdatedState(this.moveHistory);

  @override
  List<Object?> get props => [moveHistory];
}

class ControlPanelUpdatedState extends GameMediatorState {
  final bool canUndo;
  final bool gameEnded;
  final bool isWhitesTurn;

  const ControlPanelUpdatedState(
      this.canUndo, this.gameEnded, this.isWhitesTurn);

  @override
  List<Object?> get props => [canUndo, gameEnded, isWhitesTurn];
}

/// AI states
class AIHintRequestedState extends GameMediatorState {
  const AIHintRequestedState();
}

class AIHintShownState extends GameMediatorState {
  final Position from;
  final Position to;
  final String? notation;

  const AIHintShownState(this.from, this.to, {this.notation});

  @override
  List<Object?> get props => [from, to, notation];
}

class AIMoveExecutedState extends GameMediatorState {
  final Position from;
  final Position to;
  final String notation;

  const AIMoveExecutedState(this.from, this.to, this.notation);

  @override
  List<Object?> get props => [from, to, notation];
}

/// Error states
class GameMediatorErrorState extends GameMediatorState {
  final String message;
  final String? details;

  const GameMediatorErrorState(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

/// Success states
class GameMediatorSuccessState extends GameMediatorState {
  final String message;
  final Map<String, dynamic>? data;

  const GameMediatorSuccessState(this.message, {this.data});

  @override
  List<Object?> get props => [message, data];
}
