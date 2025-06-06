import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';

/// Abstract handler for the Chain of Responsibility pattern
abstract class MoveValidator {
  MoveValidator? _nextValidator;

  MoveValidator setNext(MoveValidator validator) {
    _nextValidator = validator;
    return validator;
  }

  bool validate(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    final result = handleValidation(piece, from, to, allPieces);

    if (!result) return false;
    if (_nextValidator == null) return true;

    return _nextValidator!.validate(piece, from, to, allPieces);
  }

  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces);
}

/// 1. Validates the piece is actually moving (from != to)
class ActualMoveValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    return from != to;
  }
}

/// 2. Validates if the position is inside the board
class BoundsValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    return to.row >= 0 && to.row < 8 && to.col >= 0 && to.col < 8;
  }
}

/// 3. Validates if the position is occupied by a piece of the same color
class OccupancyValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    final pieceAtDestination =
        allPieces.where((p) => p.position == to).firstOrNull;

    if (pieceAtDestination == null) return true;
    return pieceAtDestination.color != piece.color;
  }
}

/// 4. Validates if the move is according to piece movement rules
class PieceMovementValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
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
    // Diagonal capture
    else if (deltaCol == 1 &&
        deltaRow == direction &&
        pieceAtDestination != null) {
      return pieceAtDestination.color != piece.color;
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
    return deltaRow <= 1 && deltaCol <= 1;
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

/// 5. Special handler for castling moves
class CastlingValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    if (piece.type != PieceType.king) return true;

    final deltaCol = to.col - from.col;
    final deltaRow = to.row - from.row;

    // Check if this is a castling attempt (king moves 2 squares horizontally)
    if (deltaRow != 0 || deltaCol.abs() != 2) return true;

    // Verify king hasn't moved
    if (piece is! King || piece.hasMoved) return false;

    // Verify king is on starting position
    final expectedRow = piece.color == PieceColor.white ? 7 : 0;
    if (from.row != expectedRow || from.col != 4) return false;

    // Determine castling side
    final isKingSide = deltaCol > 0;
    final rookCol = isKingSide ? 7 : 0;
    final expectedDestCol = isKingSide ? 6 : 2;

    // Verify correct destination
    if (to.col != expectedDestCol) return false;

    // Find the rook
    final rook = allPieces
        .where((p) =>
            p.type == PieceType.rook &&
            p.color == piece.color &&
            p.position == Position(rookCol, from.row))
        .firstOrNull;

    if (rook == null || (rook is Rook && rook.hasMoved)) return false;

    // Check if path between king and rook is clear
    final startCol = from.col.clamp(0, rookCol);
    final endCol = from.col.clamp(rookCol, 7);

    for (int col = startCol + 1; col < endCol; col++) {
      if (col == from.col) continue; // Skip king's position
      final checkPos = Position(col, from.row);
      if (allPieces.any((p) => p.position == checkPos)) {
        return false;
      }
    }

    // Check if king passes through or lands on attacked square
    final kingPath = <Position>[
      from,
      Position(from.col + (isKingSide ? 1 : -1), from.row),
      to,
    ];

    for (final pos in kingPath) {
      if (_isPositionUnderAttack(pos, piece.color, allPieces)) {
        return false;
      }
    }

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

/// 6. Validates en passant capture (limited without game history)
class EnPassantValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    if (piece.type != PieceType.pawn) return true;

    final direction = piece.color == PieceColor.white ? -1 : 1;
    final deltaRow = to.row - from.row;
    final deltaCol = (to.col - from.col).abs();

    // Check if this is a diagonal pawn move
    if (deltaCol != 1 || deltaRow != direction) return true;

    // Check if there's a piece at destination
    final pieceAtDestination =
        allPieces.where((p) => p.position == to).firstOrNull;

    // If there's a piece at destination, it's a regular capture
    if (pieceAtDestination != null) return true;

    // En passant specific validation
    final captureRow = piece.color == PieceColor.white ? 3 : 4;
    if (from.row != captureRow) return false;

    // Check if there's an opponent pawn adjacent that could be captured
    final adjacentPawnPos = Position(to.col, from.row);
    final pawnToCapture = allPieces
        .where((p) =>
            p.type == PieceType.pawn &&
            p.color != piece.color &&
            p.position == adjacentPawnPos)
        .firstOrNull;

    // Without game history, we can only validate the board position
    // In a complete implementation, we'd need to verify the pawn just moved two squares
    return pawnToCapture != null;
  }
}

/// 7. Validates pawn promotion
class PawnPromotionValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    if (piece.type != PieceType.pawn) return true;

    // Allow move to promotion rank
    // In actual game, UI would handle promotion choice
    return true;
  }
}

/// 8. Validates move doesn't leave own king in check
class KingSafetyValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
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
    return !_isKingInCheck(piece.color, simulatedPieces);
  }

  bool _isKingInCheck(PieceColor kingColor, List<ChessPiece> pieces) {
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

/// 9. Validates absolute pin situations
class AbsolutePinValidator extends MoveValidator {
  @override
  bool handleValidation(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
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

/// Factory to create chains of validators
class MoveValidatorChain {
  /// Create the complete chain with all validators
  static MoveValidator createCompleteChain() {
    final actualMoveValidator = ActualMoveValidator();
    final boundsValidator = BoundsValidator();
    final occupancyValidator = OccupancyValidator();
    final pieceMovementValidator = PieceMovementValidator();
    final castlingValidator = CastlingValidator();
    final enPassantValidator = EnPassantValidator();
    final pawnPromotionValidator = PawnPromotionValidator();
    final absolutePinValidator = AbsolutePinValidator();
    final kingSafetyValidator = KingSafetyValidator();

    // Chain them in optimal order (fail fast on simple checks)
    actualMoveValidator
        .setNext(boundsValidator)
        .setNext(occupancyValidator)
        .setNext(pieceMovementValidator)
        .setNext(castlingValidator)
        .setNext(enPassantValidator)
        .setNext(pawnPromotionValidator)
        .setNext(absolutePinValidator)
        .setNext(kingSafetyValidator);

    return actualMoveValidator;
  }

  /// Create a lightweight chain for quick validation
  static MoveValidator createBasicChain() {
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

    return actualMoveValidator;
  }

  /// Create chain for AI move generation (skips some checks)
  static MoveValidator createAIChain() {
    final boundsValidator = BoundsValidator();
    final occupancyValidator = OccupancyValidator();
    final pieceMovementValidator = PieceMovementValidator();
    final castlingValidator = CastlingValidator();
    final enPassantValidator = EnPassantValidator();
    final absolutePinValidator = AbsolutePinValidator();
    final kingSafetyValidator = KingSafetyValidator();

    boundsValidator
        .setNext(occupancyValidator)
        .setNext(pieceMovementValidator)
        .setNext(castlingValidator)
        .setNext(enPassantValidator)
        .setNext(absolutePinValidator)
        .setNext(kingSafetyValidator);

    return boundsValidator;
  }
}

/// Wrapper class for GameRoom usage
class GameRoomMoveValidator {
  final MoveValidator _validatorChain;
  final MoveValidator _aiValidatorChain;

  GameRoomMoveValidator()
      : _validatorChain = MoveValidatorChain.createCompleteChain(),
        _aiValidatorChain = MoveValidatorChain.createAIChain();

  bool validateMove(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      {bool isAI = false}) {
    final chain = isAI ? _aiValidatorChain : _validatorChain;
    return chain.validate(piece, from, to, allPieces);
  }

  /// Get all valid moves for a piece
  List<Position> getValidMovesForPiece(
      ChessPiece piece, List<ChessPiece> allPieces) {
    final validMoves = <Position>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final to = Position(col, row);
        if (validateMove(piece, piece.position, to, allPieces)) {
          validMoves.add(to);
        }
      }
    }

    return validMoves;
  }
}
