import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';

class PromoteCommand implements Command {
  final ChessPiece
      newPiece; // The new piece type to promote to (e.g., Queen, Rook, Bishop, Knight)
  final ChessPiece oldPiece; // The original pawn piece being promoted
  final Position newPosition; // Position where the promotion occurs
  late final Position oldPosition; // Original position of the pawn
  final ChessBoardManager? boardManager;

  PromoteCommand({
    required this.newPiece,
    required this.oldPiece,
    required this.newPosition,
    this.boardManager,
  }) {
    oldPosition = oldPiece.position.clone();
  }

  @override
  void execute() {
    // Use board manager if available, otherwise fall back to direct piece manipulation
    if (boardManager != null) {
      // Remove the pawn and place the promoted piece
      boardManager!.setPieceAt(oldPosition, null);
      boardManager!.setPieceAt(newPosition, newPiece);
    } else {
      // Fallback: direct piece manipulation
      oldPiece.position = newPosition;
      oldPiece.type = newPiece.type;
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
      // Fallback: revert the promotion back to a pawn
      oldPiece.position = oldPosition;
      oldPiece.type =
          oldPiece.type; // Change the type back to the original pawn type
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
      // Fallback: reapply the promotion
      oldPiece.position = newPosition;
      oldPiece.type = newPiece.type;
    }
  }
}
