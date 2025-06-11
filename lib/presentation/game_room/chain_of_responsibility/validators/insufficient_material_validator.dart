import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';

/// 12. Validates insufficient material for checkmate
class InsufficientMaterialValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    // This validator doesn't block moves, it's used to check draw conditions
    return true;
  }

  /// Check if the position has insufficient material for checkmate
  bool hasInsufficientMaterial(List<ChessPiece> pieces) {
    final whitePieces =
        pieces.where((p) => p.color == PieceColor.white).toList();
    final blackPieces =
        pieces.where((p) => p.color == PieceColor.black).toList();

    // Both sides must have insufficient material
    return _hasSideInsufficientMaterial(whitePieces) &&
        _hasSideInsufficientMaterial(blackPieces);
  }

  bool _hasSideInsufficientMaterial(List<ChessPiece> pieces) {
    // Remove kings for counting
    final nonKingPieces =
        pieces.where((p) => p.type != PieceType.king).toList();

    // King vs King
    if (nonKingPieces.isEmpty) return true;

    // King and Bishop vs King
    if (nonKingPieces.length == 1 &&
        nonKingPieces.first.type == PieceType.bishop) {
      return true;
    }

    // King and Knight vs King
    if (nonKingPieces.length == 1 &&
        nonKingPieces.first.type == PieceType.knight) {
      return true;
    }

    // King and two Knights vs King (very rare but insufficient)
    if (nonKingPieces.length == 2 &&
        nonKingPieces.every((p) => p.type == PieceType.knight)) {
      return true;
    }

    return false;
  }
}
