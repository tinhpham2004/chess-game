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
    //Add validation for valid transitions
    if (_isValidTransition(state)) {
      _state = state;
    } else {
      throw Exception('Invalid state transition to ${state.runtimeType}');
    }
  }

  bool _isValidTransition(GameState newState) {
    if (_state is WaitingState && newState is! PlayingState) return false;
    if (_state is PlayingState && newState is! PausedState && newState is! FinishedState) return false;
    if (_state is PausedState && newState is! PlayingState) return false;
    if (_state is FinishedState) return false; // No transitions from FinishedState
    return true;
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
  WaitingState(super.context);

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
  PlayingState(super.context);

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
    // Check if the destination is within bounds
    if (destination.row < 0 || destination.row >= 8 || 
        destination.col < 0 || destination.col >= 8) {
      return false;
    }

    // Create a clone of the piece and its current position for validation
    final pieceClone = piece.clone();
    final startPosition = piece.position.clone();

    // Use the piece's isValidMove method to check if the move is valid
    // The empty list will be replaced with actual pieces in the game implementation
    if (!pieceClone.isValidMove(startPosition, destination, [])) {
      return false;
    }

    // Update the piece's position if the move is valid
    piece.position = destination;

    // The piece has moved - update its state if needed
    switch (piece.type) {
      case PieceType.pawn:
        (piece as Pawn).hasMoved = true;
        break;
      case PieceType.king:
        (piece as King).hasMoved = true;
        break;
      case PieceType.rook:
        (piece as Rook).hasMoved = true;
        break;
      default:
        break;
    }

    return true;
  }
}

// Concrete state - Paused
class PausedState extends GameState {
  PausedState(super.context);

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
  FinishedState(super.context);

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
