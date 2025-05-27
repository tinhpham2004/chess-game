import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';

/// Command for AI making a move
class AIMoveCommand implements Command {
  final ChessPiece piece;
  final Position from;
  final Position to;
  late final Position oldPosition;
  ChessPiece? capturedPiece;
  final ChessBoardManager? boardManager;

  AIMoveCommand({
    required this.piece,
    required this.from,
    required this.to,
    this.capturedPiece,
    this.boardManager,
  }) {
    oldPosition = piece.position.clone();
  }

  @override
  void execute() {
    // Use board manager if available, otherwise fall back to direct piece manipulation
    if (boardManager != null) {
      capturedPiece = boardManager!.movePiece(from, to);
      boardManager!.switchTurn();
    } else {
      // Fallback: direct piece manipulation
      piece.position = to;
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
      // If a piece was captured, restore it
      // Switch turns back
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
      // Fallback: reapply the AI move
      piece.position = to;
    }
  }
}
