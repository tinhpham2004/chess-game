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
