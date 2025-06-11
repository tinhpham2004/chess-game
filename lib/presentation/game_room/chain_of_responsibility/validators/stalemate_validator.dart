import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'move_validator_base.dart';
import 'king_safety_validator.dart';
import 'actual_move_validator.dart';
import 'bounds_validator.dart';
import 'occupancy_validator.dart';
import 'piece_movement_validator.dart';

/// 13. Validates stalemate conditions
class StalemateValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    // This validator doesn't block moves, it's used to check game end conditions
    return true;
  }

  /// Check if the current position is stalemate
  bool isStalemate(PieceColor colorToMove, List<ChessPiece> pieces) {
    // King must not be in check
    final kingSafetyValidator = KingSafetyValidator();
    if (kingSafetyValidator.isKingInCheck(colorToMove, pieces)) {
      return false;
    }

    // No legal moves available
    return !_hasLegalMoves(colorToMove, pieces);
  }

  bool _hasLegalMoves(PieceColor color, List<ChessPiece> pieces) {
    final playerPieces = pieces.where((p) => p.color == color);

    // Create a basic validator chain without circular dependency
    final actualMoveValidator = ActualMoveValidator();
    final boundsValidator = BoundsValidator();
    final occupancyValidator = OccupancyValidator();
    final pieceMovementValidator = PieceMovementValidator();
    final kingSafetyValidator = KingSafetyValidator();

    actualMoveValidator
        .setNext(boundsValidator)
        .setNext(occupancyValidator)
        .setNext(pieceMovementValidator)
        .setNext(kingSafetyValidator);

    for (final piece in playerPieces) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final to = Position(col, row);
          if (actualMoveValidator.validate(piece, piece.position, to, pieces)) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
