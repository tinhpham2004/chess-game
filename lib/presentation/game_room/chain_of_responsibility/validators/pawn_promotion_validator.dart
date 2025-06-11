import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 7. Validates pawn promotion
class PawnPromotionValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    if (piece.type != PieceType.pawn) return true;

    // Allow move to promotion rank
    // In actual game, UI would handle promotion choice
    return true;
  }
}
