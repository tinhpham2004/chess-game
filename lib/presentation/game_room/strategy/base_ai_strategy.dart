import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/chain_of_responsibility/move_validator.dart';
import 'package:chess_game/presentation/game_room/strategy/ai_strategy_interface.dart';
import 'package:chess_game/presentation/game_room/strategy/move_evaluation.dart';

/// Base strategy with common functionality
abstract class BaseAIStrategy implements AIStrategy {
  late GameRoomMoveValidator _moveValidator;

  BaseAIStrategy() {
    _moveValidator = GameRoomMoveValidator();
  }

  void setMoveValidator(GameRoomMoveValidator validator) {
    _moveValidator = validator;
  }

  /// Get all valid moves for a color
  @override
  List<MoveEvaluation> getAllValidMoves(
      List<ChessPiece> pieces, PieceColor color) {
    final validMoves = <MoveEvaluation>[];
    final colorPieces = pieces.where((p) => p.color == color).toList();

    for (final piece in colorPieces) {
      final possibleMoves = piece.getPossibleMoves(pieces);

      for (final move in possibleMoves) {
        if (_moveValidator.validateMove(piece, piece.position, move, pieces)) {
          final capturedPiece =
              pieces.where((p) => p.position == move).firstOrNull;
          validMoves.add(MoveEvaluation(
            from: piece.position,
            to: move,
            score: 0.0, // Will be calculated by specific strategies
            piece: piece,
            capturedPiece: capturedPiece,
          ));
        }
      }
    }

    return validMoves;
  }

  /// Evaluate board position
  @override
  double evaluateBoard(List<ChessPiece> pieces, PieceColor aiColor) {
    double score = 0.0;

    // Material values
    const pieceValues = {
      PieceType.pawn: 1.0,
      PieceType.knight: 3.0,
      PieceType.bishop: 3.0,
      PieceType.rook: 5.0,
      PieceType.queen: 9.0,
      PieceType.king: 1000.0,
    };

    for (final piece in pieces) {
      final value = pieceValues[piece.type] ?? 0.0;
      if (piece.color == aiColor) {
        score += value;
      } else {
        score -= value;
      }
    }

    // Positional bonuses
    score += _evaluatePositionalFactors(pieces, aiColor);

    return score;
  }

  double _evaluatePositionalFactors(
      List<ChessPiece> pieces, PieceColor aiColor) {
    double score = 0.0;

    for (final piece in pieces) {
      final multiplier = piece.color == aiColor ? 1.0 : -1.0;

      // Center control bonus
      if (piece.position.col >= 2 &&
          piece.position.col <= 5 &&
          piece.position.row >= 2 &&
          piece.position.row <= 5) {
        score += 0.1 * multiplier;
      }

      // Piece development bonus (not on starting rank)
      final startingRank = piece.color == PieceColor.white ? 7 : 0;
      if (piece.position.row != startingRank && piece.type != PieceType.pawn) {
        score += 0.1 * multiplier;
      }
    }

    return score;
  }

  /// Simulate a move and return the new board state
  List<ChessPiece> simulateMove(
      List<ChessPiece> pieces, Position from, Position to) {
    final newPieces = pieces.map((p) => p.clone()).toList();

    // Find and move the piece
    final pieceIndex = newPieces.indexWhere((p) => p.position == from);
    if (pieceIndex != -1) {
      newPieces[pieceIndex].position = to;

      // Remove captured piece if any
      newPieces
          .removeWhere((p) => p.position == to && p != newPieces[pieceIndex]);
    }

    return newPieces;
  }
}
