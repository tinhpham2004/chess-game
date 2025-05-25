import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';

/// Abstract handler for the Chain of Responsibility pattern
abstract class MoveValidator {
  MoveValidator? _nextValidator;

  MoveValidator setNext(MoveValidator validator) {
    _nextValidator = validator;
    return validator; // Return next validator to allow chaining
  }

  bool validate(ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces) {
    final result = handleValidation(piece, from, to, allPieces);

    // If the current validation fails, return false immediately
    if (!result) return false;

    // If there's no next validator or this validator is the last in chain, return the result
    if (_nextValidator == null) return true;

    // Otherwise, pass to the next validator
    return _nextValidator!.validate(piece, from, to, allPieces);
  }

  /// Each concrete validator must implement this method
  bool handleValidation(ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces);
}

/// Concrete handler - Validates if the position is inside the board
class InsideBoundsValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces) {
    // Check if the destination is within the board bounds
    return to.row >= 0 && to.row < 8 && to.col >= 0 && to.col < 8;
  }
}

/// Concrete handler - Validates if the position is occupied by a piece of the same color
class SameColorValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces) {
    // Check if there's a piece of the same color at the destination
    final pieceAtDestination = allPieces.where((p) => p.position.row == to.row && p.position.col == to.col).firstOrNull;

    if (pieceAtDestination == null) return true; // No piece at destination
    return pieceAtDestination.color != piece.color; // Different color is allowed (capture)
  }
}

/// Concrete handler - Validates if the move is according to piece rules
class PieceRulesValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces) {
    // Implementation depends on the specific piece type
    // This would check if the move is valid for the specific piece type
    // (e.g., rooks move horizontally/vertically, bishops diagonally, etc.)
    return piece.isValidMove(from, to, allPieces);
  }
}

/// Concrete handler - Validates if the move would put/leave own king in check
class CheckValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces) {
    // Implementation would simulate the move and check if it
    // leaves the player's king in check

    // This would require:
    // 1. Creating a deep copy of all pieces
    // 2. Executing the move on the copy
    // 3. Checking if the player's king is in check

    // A simplistic placeholder implementation:
    return true; // This would need a proper implementation
  }
}

/// Factory to create a chain of validators in the correct order
class MoveValidatorChain {
  static MoveValidator createChain() {
    final insideBoundsValidator = InsideBoundsValidator();
    final sameColorValidator = SameColorValidator();
    final pieceRulesValidator = PieceRulesValidator();
    final checkValidator = CheckValidator();

    insideBoundsValidator.setNext(sameColorValidator).setNext(pieceRulesValidator).setNext(checkValidator);

    return insideBoundsValidator;
  }
}
