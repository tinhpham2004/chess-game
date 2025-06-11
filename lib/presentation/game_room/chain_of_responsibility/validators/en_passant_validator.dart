import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 6. Validates en passant capture with proper game state validation
class EnPassantValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    if (piece.type != PieceType.pawn) return true;

    final direction = piece.color == PieceColor.white ? -1 : 1;
    final deltaRow = to.row - from.row;
    final deltaCol = (to.col - from.col).abs();

    // Check if this is a diagonal pawn move
    if (deltaCol != 1 || deltaRow != direction) return true;

    // Check if there's a piece at destination
    final pieceAtDestination =
        allPieces.where((p) => p.position == to).firstOrNull;

    // If there's a piece at destination, it's a regular capture
    if (pieceAtDestination != null) return true;

    // En passant specific validation
    final captureRow = piece.color == PieceColor.white ? 3 : 4;
    if (from.row != captureRow) return false;

    // Check if there's an opponent pawn adjacent that could be captured
    final adjacentPawnPos = Position(to.col, from.row);
    final pawnToCapture = allPieces
        .where((p) =>
            p.type == PieceType.pawn &&
            p.color != piece.color &&
            p.position == adjacentPawnPos)
        .firstOrNull;
    if (pawnToCapture == null) {
      return false; // FIDE rule: En passant is only valid if the opponent pawn just moved two squares
    }
    if (context?.lastDoubleMovePawn != null) {
      // The lastDoubleMovePawn should match the position of the pawn we're trying to capture
      return context!.lastDoubleMovePawn == adjacentPawnPos.toString();
    }

    // Without game context, we can only validate the board position
    return true;
  }
}
