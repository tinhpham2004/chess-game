import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 10. Validates fifty-move rule (no pawn move or capture in 50 moves)
class FiftyMoveRuleValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    // This validator doesn't block moves, it's used to check draw conditions
    return true;
  }

  /// Check if fifty-move rule draw can be claimed
  bool canClaimFiftyMoveRule(FIDERuleContext context) {
    return context.fiftyMoveCounter >=
        100; // 50 moves for each side = 100 half-moves
  }
}
