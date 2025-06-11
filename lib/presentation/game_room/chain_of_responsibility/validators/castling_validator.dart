import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 5. Special handler for castling moves
class CastlingValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    if (piece.type != PieceType.king) return true;

    final deltaCol = to.col - from.col;
    final deltaRow = to.row - from.row;

    // Check if this is a castling attempt (king moves 2 squares horizontally)
    if (deltaRow != 0 || deltaCol.abs() != 2) return true;

    print(
        'CastlingValidator: Processing castling move ${from.toString()} -> ${to.toString()}');

    // Verify king hasn't moved
    if (piece is! King || piece.hasMoved) {
      print('CastlingValidator: King has already moved, castling not allowed');
      return false;
    }

    // Verify king is on starting position
    final expectedRow = piece.color == PieceColor.white ? 7 : 0;
    if (from.row != expectedRow || from.col != 4) {
      print('CastlingValidator: King not on starting position');
      return false;
    }

    // Determine castling side
    final isKingSide = deltaCol > 0;
    final rookCol = isKingSide ? 7 : 0;
    final expectedDestCol = isKingSide ? 6 : 2;

    print(
        'CastlingValidator: ${isKingSide ? "King-side" : "Queen-side"} castling attempt');

    // Verify correct destination
    if (to.col != expectedDestCol) {
      print('CastlingValidator: Incorrect destination column');
      return false;
    }

    // Find the rook
    final rook = allPieces
        .where((p) =>
            p.type == PieceType.rook &&
            p.color == piece.color &&
            p.position == Position(rookCol, from.row))
        .firstOrNull;

    if (rook == null) {
      print('CastlingValidator: Rook not found at expected position');
      return false;
    }

    if (rook is Rook && rook.hasMoved) {
      print('CastlingValidator: Rook has already moved');
      return false;
    } // Check if path between king and rook is clear
    final squaresToCheck = <int>[];
    if (isKingSide) {
      // King-side: check f1 (col 5) and g1 (col 6)
      squaresToCheck.addAll([5, 6]);
    } else {
      // Queen-side: check b1 (col 1), c1 (col 2), and d1 (col 3)
      squaresToCheck.addAll([1, 2, 3]);
    }

    print('CastlingValidator: Checking if squares $squaresToCheck are clear');
    for (final col in squaresToCheck) {
      final checkPos = Position(col, from.row);
      if (allPieces.any((p) => p.position == checkPos)) {
        print('CastlingValidator: Square ${checkPos.toString()} is occupied');
        return false;
      }
    } // Check if king passes through or lands on attacked square
    final kingPath = <Position>[
      from, // Starting position
      Position(from.col + (isKingSide ? 1 : -1), from.row), // Middle square
      to, // Destination
    ];

    print('CastlingValidator: Checking if king path $kingPath is safe');
    for (final pos in kingPath) {
      if (_isPositionUnderAttack(pos, piece.color, allPieces)) {
        print('CastlingValidator: Position ${pos.toString()} is under attack');
        return false;
      }
    }

    print('CastlingValidator: Castling is legal');
    return true;
  }

  bool _isPositionUnderAttack(
      Position position, PieceColor defendingColor, List<ChessPiece> pieces) {
    final opponentPieces = pieces.where((p) => p.color != defendingColor);

    for (final opponent in opponentPieces) {
      if (_canPieceAttackPosition(
          opponent, opponent.position, position, pieces)) {
        return true;
      }
    }

    return false;
  }

  bool _canPieceAttackPosition(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    // Check piece-specific attack patterns without creating new validators
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
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        if (from.row == to.row || from.col == to.col || deltaRow == deltaCol) {
          return _isPathClear(from, to, allPieces);
        }
        return false;

      case PieceType.king:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        return deltaRow <= 1 && deltaCol <= 1;
    }
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
