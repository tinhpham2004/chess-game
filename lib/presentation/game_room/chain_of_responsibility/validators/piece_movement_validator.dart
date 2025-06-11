import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 4. Validates if the move is according to piece movement rules
class PieceMovementValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    switch (piece.type) {
      case PieceType.pawn:
        return _validatePawnMove(piece, from, to, allPieces);
      case PieceType.rook:
        return _validateRookMove(from, to, allPieces);
      case PieceType.knight:
        return _validateKnightMove(from, to);
      case PieceType.bishop:
        return _validateBishopMove(from, to, allPieces);
      case PieceType.queen:
        return _validateQueenMove(from, to, allPieces);
      case PieceType.king:
        return _validateKingMove(from, to);
    }
  }

  bool _validatePawnMove(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;
    final deltaRow = to.row - from.row;
    final deltaCol = (to.col - from.col).abs();

    final pieceAtDestination =
        allPieces.where((p) => p.position == to).firstOrNull;

    // Forward move
    if (deltaCol == 0 && pieceAtDestination == null) {
      // Single move forward
      if (deltaRow == direction) return true;

      // Double move from start position
      if (from.row == startRow && deltaRow == 2 * direction) {
        final middlePos = Position(from.col, from.row + direction);
        final pieceInMiddle =
            allPieces.where((p) => p.position == middlePos).firstOrNull;
        return pieceInMiddle == null;
      }
    }
    // Diagonal capture OR en passant
    else if (deltaCol == 1 && deltaRow == direction) {
      // Regular diagonal capture
      if (pieceAtDestination != null) {
        return pieceAtDestination.color != piece.color;
      }

      // Potential en passant capture (no piece at destination)
      // This will be validated more strictly by EnPassantValidator
      final captureRow = piece.color == PieceColor.white ? 3 : 4;
      if (from.row == captureRow) {
        return true; // Allow for further validation by EnPassantValidator
      }
    }

    return false;
  }

  bool _validateRookMove(
      Position from, Position to, List<ChessPiece> allPieces) {
    if (from.row != to.row && from.col != to.col) return false;
    return _isPathClear(from, to, allPieces);
  }

  bool _validateKnightMove(Position from, Position to) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();
    return (deltaRow == 2 && deltaCol == 1) || (deltaRow == 1 && deltaCol == 2);
  }

  bool _validateBishopMove(
      Position from, Position to, List<ChessPiece> allPieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();
    if (deltaRow != deltaCol) return false;
    return _isPathClear(from, to, allPieces);
  }

  bool _validateQueenMove(
      Position from, Position to, List<ChessPiece> allPieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();

    // Queen moves like rook or bishop
    if (from.row == to.row || from.col == to.col || deltaRow == deltaCol) {
      return _isPathClear(from, to, allPieces);
    }
    return false;
  }

  bool _validateKingMove(Position from, Position to) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();

    // Standard king move: one square in any direction
    if (deltaRow <= 1 && deltaCol <= 1) return true;

    // Potential castling move: king moves 2 squares horizontally
    if (deltaRow == 0 && deltaCol == 2) {
      // Allow castling moves here, detailed validation happens in CastlingValidator
      print(
          'PieceMovementValidator: Allowing potential castling move ${from.toString()} -> ${to.toString()}');
      return true;
    }

    return false;
  }

  bool _isPathClear(Position from, Position to, List<ChessPiece> allPieces) {
    final deltaRow = to.row - from.row;
    final deltaCol = to.col - from.col;
    final steps =
        deltaRow.abs() > deltaCol.abs() ? deltaRow.abs() : deltaCol.abs();

    if (steps <= 1) return true; // Adjacent squares

    final rowStep = deltaRow != 0 ? deltaRow ~/ deltaRow.abs() : 0;
    final colStep = deltaCol != 0 ? deltaCol ~/ deltaCol.abs() : 0;

    // Check each square along the path (excluding start and end)
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
