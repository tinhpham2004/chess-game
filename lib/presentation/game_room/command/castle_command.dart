import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';

class CastleCommand implements Command {
  final ChessPiece rook;
  final ChessPiece king;
  final Position newRookPosition;
  final Position newKingPosition;
  late final Position oldRookPosition;
  late final Position oldKingPosition;
  final ChessBoardManager? boardManager;

  CastleCommand({
    required this.rook,
    required this.king,
    required this.newRookPosition,
    required this.newKingPosition,
    this.boardManager,
  }) {
    // Store the original positions for undo/redo functionality
    oldRookPosition = rook.position.clone();
    oldKingPosition = king.position.clone();
  }

  @override
  void execute() {
    // Use board manager if available, otherwise fall back to direct piece manipulation
    if (boardManager != null) {
      // Move king first, then rook
      boardManager!.movePiece(oldKingPosition, newKingPosition);
      boardManager!.movePiece(oldRookPosition, newRookPosition);
    } else {
      // Fallback: direct piece manipulation
      rook.position = newRookPosition;
      king.position = newKingPosition;
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
      // Fallback: revert the rook and king to their original positions
      rook.position = oldRookPosition;
      king.position = oldKingPosition;
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
      // Fallback: reapply the castle move
      rook.position = newRookPosition;
      king.position = newKingPosition;
    }
  }
}
