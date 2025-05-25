import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';

// Context class that maintains a reference to current state
class GameStateContext {
  late GameState _state;

  GameStateContext() {
    // Default initial state
    _state = WaitingState(this);
  }

  void changeState(GameState state) {
    _state = state;
  }

  bool canMove() => _state.canMove();
  bool canUndo() => _state.canUndo();
  bool isPaused() => _state.isPaused();
  bool isFinished() => _state.isFinished();

  // Move a piece based on current state
  bool movePiece(ChessPiece piece, Position destination) {
    return _state.movePiece(piece, destination);
  }
}

// Abstract state class
abstract class GameState {
  final GameStateContext context;

  GameState(this.context);

  bool canMove();
  bool canUndo();
  bool isPaused();
  bool isFinished();
  bool movePiece(ChessPiece piece, Position destination);
}

// Concrete state - Waiting (before game starts)
class WaitingState extends GameState {
  WaitingState(GameStateContext context) : super(context);

  @override
  bool canMove() => false;

  @override
  bool canUndo() => false;

  @override
  bool isPaused() => false;

  @override
  bool isFinished() => false;

  @override
  bool movePiece(ChessPiece piece, Position destination) {
    // Cannot move in waiting state
    return false;
  }
}

// Concrete state - Playing
class PlayingState extends GameState {
  PlayingState(GameStateContext context) : super(context);

  @override
  bool canMove() => true;

  @override
  bool canUndo() => true;

  @override
  bool isPaused() => false;

  @override
  bool isFinished() => false;

  @override
  bool movePiece(ChessPiece piece, Position destination) {
    // Implementation for moving a piece while in playing state
    // This would check if the move is valid and execute it
    return true;
  }
}

// Concrete state - Paused
class PausedState extends GameState {
  PausedState(GameStateContext context) : super(context);

  @override
  bool canMove() => false;

  @override
  bool canUndo() => false;

  @override
  bool isPaused() => true;

  @override
  bool isFinished() => false;

  @override
  bool movePiece(ChessPiece piece, Position destination) {
    // Cannot move in paused state
    return false;
  }
}

// Concrete state - Finished (checkmate or stalemate)
class FinishedState extends GameState {
  FinishedState(GameStateContext context) : super(context);

  @override
  bool canMove() => false;

  @override
  bool canUndo() => true; // Allow undoing to review game

  @override
  bool isPaused() => false;

  @override
  bool isFinished() => true;

  @override
  bool movePiece(ChessPiece piece, Position destination) {
    // Cannot move in finished state
    return false;
  }
}
