import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 3. Validates if the position is occupied by a piece of the same color
class OccupancyValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    final pieceAtDestination =
        allPieces.where((p) => p.position == to).firstOrNull;

    if (pieceAtDestination == null) return true;
    return pieceAtDestination.color != piece.color;
  }
}
