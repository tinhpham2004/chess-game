import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';

/// FIDE rule validation context for move validation
class FIDERuleContext {
  final List<String> moveHistory;
  final String? lastDoubleMovePawn; // For en passant
  final int fiftyMoveCounter;
  final List<String> positionHistory; // For threefold repetition
  final int moveNumber;
  final bool isWhitesTurn;

  const FIDERuleContext({
    required this.moveHistory,
    this.lastDoubleMovePawn,
    required this.fiftyMoveCounter,
    required this.positionHistory,
    required this.moveNumber,
    required this.isWhitesTurn,
  });
}

/// Abstract handler for the Chain of Responsibility pattern
abstract class MoveValidator {
  MoveValidator? _nextValidator;

  MoveValidator setNext(MoveValidator validator) {
    _nextValidator = validator;
    return validator;
  }

  bool validate(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    final result = handleValidation(piece, from, to, allPieces, context);

    if (!result) return false;
    if (_nextValidator == null) return true;

    return _nextValidator!.validate(piece, from, to, allPieces, context);
  }

  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]);
}

/// 1. Validates the piece is actually moving (from != to)
class ActualMoveValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    return from != to;
  }
}

/// 2. Validates if the position is inside the board
class BoundsValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    return to.row >= 0 && to.row < 8 && to.col >= 0 && to.col < 8;
  }
}

/// 3. Validates if the position is occupied by a piece of the same color
class OccupancyValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    final pieceAtDestination =
        allPieces.where((p) => p.position == to).firstOrNull;

    if (pieceAtDestination == null) return true;
    return pieceAtDestination.color != piece.color;
  }
}

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

/// 6. Validates en passant capture with proper game state validation
class EnPassantValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
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
    if (pawnToCapture == null) {
      return false; // FIDE rule: En passant is only valid if the opponent pawn just moved two squares
    }
    if (context?.lastDoubleMovePawn != null) {
      // The lastDoubleMovePawn should match the position of the pawn we're trying to capture
      return context!.lastDoubleMovePawn == adjacentPawnPos.toString();
    }

    // Without game context, we can only validate the board position
    return true;
  }
}

/// 7. Validates pawn promotion
class PawnPromotionValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    if (piece.type != PieceType.pawn) return true;

    // Allow move to promotion rank
    // In actual game, UI would handle promotion choice
    return true;
  }
}

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
    final validator = MoveValidatorChain.createCompleteChain();

    for (final piece in playerPieces) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final to = Position(col, row);
          if (validator.validate(piece, piece.position, to, pieces)) {
            return true;
          }
        }
      }
    }

    return false;
  }
}

/// 14. Validates checkmate conditions
class CheckmateValidator extends MoveValidator {
  @override
  bool handleValidation(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    // This validator doesn't block moves, it's used to check game end conditions
    return true;
  }

  /// Check if the current position is checkmate
  bool isCheckmate(PieceColor colorToMove, List<ChessPiece> pieces) {
    // King must be in check
    final kingSafetyValidator = KingSafetyValidator();
    if (!kingSafetyValidator.isKingInCheck(colorToMove, pieces)) {
      return false;
    }

    // No legal moves available to escape check
    return !_hasLegalMoves(colorToMove, pieces);
  }

  bool _hasLegalMoves(PieceColor color, List<ChessPiece> pieces) {
    final playerPieces = pieces.where((p) => p.color == color);
    final validator = MoveValidatorChain.createCompleteChain();

    for (final piece in playerPieces) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final to = Position(col, row);
          if (validator.validate(piece, piece.position, to, pieces)) {
            return true;
          }
        }
      }
    }

    return false;
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
    final fiftyMoveRuleValidator = FiftyMoveRuleValidator();
    final threefoldRepetitionValidator = ThreefoldRepetitionValidator();
    final insufficientMaterialValidator = InsufficientMaterialValidator();
    final stalemateValidator = StalemateValidator();
    final checkmateValidator = CheckmateValidator();

    // Chain them in optimal order (fail fast on simple checks)
    actualMoveValidator
        .setNext(boundsValidator)
        .setNext(occupancyValidator)
        .setNext(pieceMovementValidator)
        .setNext(castlingValidator)
        .setNext(enPassantValidator)
        .setNext(pawnPromotionValidator)
        .setNext(absolutePinValidator)
        .setNext(kingSafetyValidator)
        .setNext(fiftyMoveRuleValidator)
        .setNext(threefoldRepetitionValidator)
        .setNext(insufficientMaterialValidator)
        .setNext(stalemateValidator)
        .setNext(checkmateValidator);

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

  /// Create FIDE rule validators (for game end condition checking)
  static Map<String, MoveValidator> createFideRuleValidators() {
    return {
      'fiftyMoveRule': FiftyMoveRuleValidator(),
      'threefoldRepetition': ThreefoldRepetitionValidator(),
      'insufficientMaterial': InsufficientMaterialValidator(),
      'stalemate': StalemateValidator(),
      'checkmate': CheckmateValidator(),
    };
  }
}

/// Wrapper class for GameRoom usage
class GameRoomMoveValidator {
  final MoveValidator _validatorChain;
  final MoveValidator _aiValidatorChain;
  final Map<String, MoveValidator> _fideValidators;

  GameRoomMoveValidator()
      : _validatorChain = MoveValidatorChain.createCompleteChain(),
        _aiValidatorChain = MoveValidatorChain.createAIChain(),
        _fideValidators = MoveValidatorChain.createFideRuleValidators();

  bool validateMove(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      {bool isAI = false, FIDERuleContext? context}) {
    final chain = isAI ? _aiValidatorChain : _validatorChain;
    return chain.validate(piece, from, to, allPieces, context);
  }

  /// Get all valid moves for a piece
  List<Position> getValidMovesForPiece(
      ChessPiece piece, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    final validMoves = <Position>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final to = Position(col, row);
        if (validateMove(piece, piece.position, to, allPieces,
            context: context)) {
          validMoves.add(to);
        }
      }
    }

    return validMoves;
  }

  /// Check if fifty-move rule draw can be claimed
  bool canClaimFiftyMoveRule(FIDERuleContext context) {
    final validator =
        _fideValidators['fiftyMoveRule'] as FiftyMoveRuleValidator;
    return validator.canClaimFiftyMoveRule(context);
  }

  /// Check if threefold repetition draw can be claimed
  bool canClaimThreefoldRepetition(
      FIDERuleContext context, List<ChessPiece> pieces) {
    final validator =
        _fideValidators['threefoldRepetition'] as ThreefoldRepetitionValidator;
    return validator.canClaimThreefoldRepetition(context, pieces);
  }

  /// Check if the position has insufficient material for checkmate
  bool hasInsufficientMaterial(List<ChessPiece> pieces) {
    final validator = _fideValidators['insufficientMaterial']
        as InsufficientMaterialValidator;
    return validator.hasInsufficientMaterial(pieces);
  }

  /// Check if the current position is stalemate
  bool isStalemate(PieceColor colorToMove, List<ChessPiece> pieces) {
    final validator = _fideValidators['stalemate'] as StalemateValidator;
    return validator.isStalemate(colorToMove, pieces);
  }

  /// Check if the current position is checkmate
  bool isCheckmate(PieceColor colorToMove, List<ChessPiece> pieces) {
    final validator = _fideValidators['checkmate'] as CheckmateValidator;
    return validator.isCheckmate(colorToMove, pieces);
  }

  /// Check if king is in check
  bool isKingInCheck(PieceColor kingColor, List<ChessPiece> pieces) {
    final kingSafetyValidator = KingSafetyValidator();
    return kingSafetyValidator.isKingInCheck(kingColor, pieces);
  }
}
