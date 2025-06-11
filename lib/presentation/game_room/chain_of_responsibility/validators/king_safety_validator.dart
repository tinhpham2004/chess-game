import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 8. Validates move doesn't leave own king in check
class KingSafetyValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    // Create a deep copy and simulate the move
    final simulatedPieces = allPieces.map((p) => p.clone()).toList();

    // Find and move the piece
    final pieceIndex = simulatedPieces.indexWhere((p) => p.position == from);
    if (pieceIndex == -1) return false;

    final pieceToMove = simulatedPieces[pieceIndex];

    // Handle special moves
    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      // Castling - also move the rook
      final isKingSide = to.col > from.col;
      final rookCol = isKingSide ? 7 : 0;
      final rookNewCol = isKingSide ? 5 : 3;
      final rookPos = Position(rookCol, from.row);

      final rookIndex = simulatedPieces.indexWhere((p) =>
          p.type == PieceType.rook &&
          p.color == piece.color &&
          p.position == rookPos);

      if (rookIndex != -1) {
        simulatedPieces[rookIndex].position = Position(rookNewCol, from.row);
      }
    }

    // Handle en passant
    if (piece.type == PieceType.pawn &&
        (to.col - from.col).abs() == 1 &&
        !simulatedPieces.any((p) => p.position == to)) {
      // Remove captured pawn in en passant
      final captureRow = piece.color == PieceColor.white ? 3 : 4;
      if (from.row == captureRow) {
        final capturedPawnPos = Position(to.col, from.row);
        simulatedPieces.removeWhere((p) => p.position == capturedPawnPos);
      }
    }

    // Remove any captured piece at destination
    simulatedPieces.removeWhere((p) => p.position == to);

    // Move the piece
    pieceToMove.position = to;

    // Check if king is safe
    return !isKingInCheck(piece.color, simulatedPieces);
  }

  /// Public method to check if a king is in check
  bool isKingInCheck(PieceColor kingColor, List<ChessPiece> pieces) {
    final king = pieces
        .where((p) => p.type == PieceType.king && p.color == kingColor)
        .firstOrNull;

    if (king == null) return true; // No king = invalid position

    final opponentPieces = pieces.where((p) => p.color != kingColor);

    for (final opponent in opponentPieces) {
      if (_canPieceAttackPosition(
          opponent, opponent.position, king.position, pieces)) {
        return true;
      }
    }

    return false;
  }

  /// Get all pieces that are attacking the king
  List<Position> getAttackingPiecesPositions(
      PieceColor kingColor, List<ChessPiece> pieces) {
    final king = pieces
        .where((p) => p.type == PieceType.king && p.color == kingColor)
        .firstOrNull;

    if (king == null) return []; // No king = no attackers

    final attackingPositions = <Position>[];
    final opponentPieces = pieces.where((p) => p.color != kingColor);

    for (final opponent in opponentPieces) {
      if (_canPieceAttackPosition(
          opponent, opponent.position, king.position, pieces)) {
        attackingPositions.add(opponent.position);
      }
    }

    return attackingPositions;
  }

  bool _canPieceAttackPosition(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    switch (piece.type) {
      case PieceType.pawn:
        final direction = piece.color == PieceColor.white ? -1 : 1;
        final deltaRow = to.row - from.row;
        final deltaCol = (to.col - from.col).abs();
        return deltaRow == direction && deltaCol == 1;

      case PieceType.rook:
        if (from.row != to.row && from.col != to.col) return false;
        return _isPathClear(from, to, allPieces);

      case PieceType.knight:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        return (deltaRow == 2 && deltaCol == 1) ||
            (deltaRow == 1 && deltaCol == 2);

      case PieceType.bishop:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        if (deltaRow != deltaCol) return false;
        return _isPathClear(from, to, allPieces);

      case PieceType.queen:
        return _canRookAttack(from, to, allPieces) ||
            _canBishopAttack(from, to, allPieces);

      case PieceType.king:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        return deltaRow <= 1 && deltaCol <= 1;
    }
  }

  bool _canRookAttack(Position from, Position to, List<ChessPiece> allPieces) {
    if (from.row != to.row && from.col != to.col) return false;
    return _isPathClear(from, to, allPieces);
  }

  bool _canBishopAttack(
      Position from, Position to, List<ChessPiece> allPieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();
    if (deltaRow != deltaCol) return false;
    return _isPathClear(from, to, allPieces);
  }

  bool _isPathClear(Position from, Position to, List<ChessPiece> allPieces) {
    final deltaRow = to.row - from.row;
    final deltaCol = to.col - from.col;
    final steps =
        deltaRow.abs() > deltaCol.abs() ? deltaRow.abs() : deltaCol.abs();

    if (steps <= 1) return true;

    final rowStep = deltaRow != 0 ? deltaRow ~/ deltaRow.abs() : 0;
    final colStep = deltaCol != 0 ? deltaCol ~/ deltaCol.abs() : 0;

    for (int i = 1; i < steps; i++) {
      final checkPos =
          Position(from.col + (colStep * i), from.row + (rowStep * i));
      if (allPieces.any((p) => p.position == checkPos)) {
        return false;
      }
    }

    return true;
  }
}
