import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 9. Validates absolute pin situations
class AbsolutePinValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    // Skip if it's the king moving (handled by KingSafetyValidator)
    if (piece.type == PieceType.king) return true;

    // Find the king
    final king = allPieces
        .where((p) => p.type == PieceType.king && p.color == piece.color)
        .firstOrNull;

    if (king == null) return false;

    // Check if piece is pinned
    final isPinned = _isPiecePinned(piece, king.position, allPieces);
    if (!isPinned) return true;

    // If pinned, can only move along the pin line
    return _canMoveAlongPinLine(from, to, king.position, allPieces);
  }

  bool _isPiecePinned(
      ChessPiece piece, Position kingPos, List<ChessPiece> pieces) {
    // Check each opponent sliding piece
    final opponentSlidingPieces = pieces.where((p) =>
        p.color != piece.color &&
        (p.type == PieceType.queen ||
            p.type == PieceType.rook ||
            p.type == PieceType.bishop));

    for (final attacker in opponentSlidingPieces) {
      if (_isOnLineBetween(piece.position, attacker.position, kingPos)) {
        // Check if attacker can reach king through this piece
        final piecesWithoutCurrent = pieces.where((p) => p != piece).toList();

        // Verify attacker could reach king if piece wasn't there
        bool canAttackKing = false;
        switch (attacker.type) {
          case PieceType.queen:
            canAttackKing = _canQueenAttack(
                attacker.position, kingPos, piecesWithoutCurrent);
            break;
          case PieceType.rook:
            canAttackKing = _canRookAttack(
                attacker.position, kingPos, piecesWithoutCurrent);
            break;
          case PieceType.bishop:
            canAttackKing = _canBishopAttack(
                attacker.position, kingPos, piecesWithoutCurrent);
            break;
          default:
            break;
        }

        if (canAttackKing) return true;
      }
    }

    return false;
  }

  bool _isOnLineBetween(Position piece, Position attacker, Position king) {
    // Check horizontal line
    if (attacker.row == piece.row && piece.row == king.row) {
      return (piece.col > attacker.col && piece.col < king.col) ||
          (piece.col < attacker.col && piece.col > king.col);
    }

    // Check vertical line
    if (attacker.col == piece.col && piece.col == king.col) {
      return (piece.row > attacker.row && piece.row < king.row) ||
          (piece.row < attacker.row && piece.row > king.row);
    }

    // Check diagonal line
    final deltaRowAK = king.row - attacker.row;
    final deltaColAK = king.col - attacker.col;
    final deltaRowAP = piece.row - attacker.row;
    final deltaColAP = piece.col - attacker.col;

    if (deltaRowAK.abs() == deltaColAK.abs() &&
        deltaRowAP.abs() == deltaColAP.abs()) {
      // Same diagonal direction
      if (deltaRowAK.sign == deltaRowAP.sign &&
          deltaColAK.sign == deltaColAP.sign) {
        // Check if piece is between
        return deltaRowAP.abs() < deltaRowAK.abs();
      }
    }

    return false;
  }

  bool _canMoveAlongPinLine(
      Position from, Position to, Position kingPos, List<ChessPiece> pieces) {
    // Find the attacker causing the pin
    final attackers = pieces.where((p) =>
        p.color != pieces.firstWhere((pc) => pc.position == from).color &&
        (p.type == PieceType.queen ||
            p.type == PieceType.rook ||
            p.type == PieceType.bishop));

    for (final attacker in attackers) {
      if (_isOnLineBetween(from, attacker.position, kingPos)) {
        // Check if move keeps piece on the same line
        if (_isOnLineBetween(to, attacker.position, kingPos)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _canQueenAttack(Position from, Position to, List<ChessPiece> pieces) {
    return _canRookAttack(from, to, pieces) ||
        _canBishopAttack(from, to, pieces);
  }

  bool _canRookAttack(Position from, Position to, List<ChessPiece> pieces) {
    if (from.row != to.row && from.col != to.col) return false;
    return _isPathClear(from, to, pieces);
  }

  bool _canBishopAttack(Position from, Position to, List<ChessPiece> pieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();
    if (deltaRow != deltaCol) return false;
    return _isPathClear(from, to, pieces);
  }

  bool _isPathClear(Position from, Position to, List<ChessPiece> pieces) {
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
      if (pieces.any((p) => p.position == checkPos)) {
        return false;
      }
    }

    return true;
  }
}
