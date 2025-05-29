import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';

// Command for moving a chess piece
class MoveCommand implements Command {
  final ChessPiece piece;
  final Position newPosition;
  late final Position oldPosition;
  ChessPiece? capturedPiece;
  final ChessBoardManager? boardManager;

  MoveCommand({
    required this.piece,
    required this.newPosition,
    this.boardManager,
  }) {
    oldPosition = piece.position.clone();
  }

  @override
  void execute() {
    // Use board manager if available, otherwise fall back to direct piece manipulation
    if (boardManager != null) {
      capturedPiece = boardManager!.movePiece(oldPosition, newPosition);
    } else {
      // Fallback: direct piece manipulation
      piece.position = newPosition;
    }
  }

  @override
  void undo() {
    // Note: When using ChessBoardManager with memento pattern,
    // undo is handled by the memento pattern, not by command undo
    if (boardManager != null) {
      // Board manager handles undo through memento pattern
      // This method is kept for compatibility but not used
      return;
    } else {
      // Fallback: restore piece to previous position
      piece.position = oldPosition;
      // If a piece was captured, restore it (would need board reference)
    }
  }

  @override
  void redo() {
    // Note: When using ChessBoardManager with memento pattern,
    // redo is handled by the memento pattern, not by command redo
    if (boardManager != null) {
      // Board manager handles redo through memento pattern
      // This method is kept for compatibility but not used
      return;
    } else {
      // Fallback: reapply the move
      piece.position = newPosition;
      // If a piece was captured, it should be removed from the board
    }
  }
}
