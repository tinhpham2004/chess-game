import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/chain_of_responsibility/move_validator.dart';
import 'package:chess_game/presentation/game_room/strategy/ai_strategy_interface.dart';
import 'package:chess_game/presentation/game_room/strategy/move_evaluation.dart';
import 'package:chess_game/presentation/game_room/strategy/minimax_ai_strategy.dart';
import 'package:chess_game/presentation/game_room/strategy/advanced_minimax_ai_strategy.dart';

/// Context for the AI strategy
class ChessAIPlayer {
  AIStrategy _strategy;
  final GameRoomMoveValidator _moveValidator = GameRoomMoveValidator();

  ChessAIPlayer(this._strategy);

  void setStrategy(AIStrategy strategy) {
    _strategy = strategy;
  }

  Command makeMove(List<ChessPiece> pieces, PieceColor aiColor) {
    return _strategy.chooseMove(pieces, aiColor);
  }

  /// Get a hint move for the human player
  MoveEvaluation? getHintMove(List<ChessPiece> pieces, PieceColor playerColor) {
    // Use a smart strategy to suggest a good move for the player
    final hintStrategy = MinimaxAIStrategy(2); // Use depth 2 for hints
    hintStrategy.setMoveValidator(_moveValidator);

    try {
      final evaluation =
          hintStrategy.getBestMoveEvaluation(pieces, playerColor);
      return evaluation;
    } catch (e) {
      print('Failed to get hint: $e');
      return null;
    }
  }

  /// Get multiple top move suggestions for hint system
  List<MoveEvaluation> getTopMoves(
      List<ChessPiece> pieces, PieceColor playerColor, int count) {
    try {
      // Get all valid moves using the current strategy
      final allValidMoves = _strategy.getAllValidMoves(pieces, playerColor);

      if (allValidMoves.isEmpty) return [];

      // Evaluate each move using the strategy's evaluation method
      for (final move in allValidMoves) {
        // Use a temporary AI strategy to evaluate this specific move
        final evaluationStrategy = _strategy is AdvancedMinimaxAIStrategy
            ? AdvancedMinimaxAIStrategy(2)
            : MinimaxAIStrategy(2);
        evaluationStrategy.setMoveValidator(_moveValidator);

        // Simulate the move and evaluate the resulting board position
        final simulatedPieces = _simulateMove(pieces, move.from, move.to);
        final evaluation =
            evaluationStrategy.evaluateBoard(simulatedPieces, playerColor);
        move.score = evaluation;
      }

      // Sort moves by evaluation score (higher is better)
      allValidMoves.sort((a, b) => b.score.compareTo(a.score));

      // Return the top 'count' moves
      return allValidMoves.take(count).toList();
    } catch (e) {
      print('Failed to get top moves: $e');
      return [];
    }
  }

  /// Helper method to simulate a move for evaluation
  List<ChessPiece> _simulateMove(
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
