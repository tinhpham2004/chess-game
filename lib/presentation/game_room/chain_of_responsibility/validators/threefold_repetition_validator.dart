import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 11. Validates threefold repetition rule
class ThreefoldRepetitionValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    // This validator doesn't block moves, it's used to check draw conditions
    return true;
  }

  /// Check if threefold repetition draw can be claimed
  bool canClaimThreefoldRepetition(
      FIDERuleContext context, List<ChessPiece> pieces) {
    if (context.positionHistory.isEmpty) return false;

    // Get the current position (would be the position after the proposed move)
    final currentPosition = _getCurrentPositionKey(pieces);

    // Count occurrences of this position
    int count = 0;
    for (final position in context.positionHistory) {
      if (position == currentPosition) {
        count++;
      }
    }

    return count >= 3;
  }

  String _getCurrentPositionKey(List<ChessPiece> pieces) {
    // Create a simplified position string for comparison
    // This should include piece positions and castling rights
    final sortedPieces = pieces.toList()
      ..sort((a, b) {
        final rowComparison = a.position.row.compareTo(b.position.row);
        if (rowComparison != 0) return rowComparison;
        return a.position.col.compareTo(b.position.col);
      });

    return sortedPieces
        .map((p) =>
            '${p.color.name[0]}${p.type.name[0]}${p.position.col}${p.position.row}')
        .join('-');
  }
}
