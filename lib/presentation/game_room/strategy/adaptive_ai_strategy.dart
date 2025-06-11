import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/strategy/base_ai_strategy.dart';
import 'package:chess_game/presentation/game_room/strategy/ai_strategy_interface.dart';
import 'package:chess_game/presentation/game_room/strategy/move_evaluation.dart';
import 'package:chess_game/presentation/game_room/strategy/minimax_ai_strategy.dart';
import 'package:chess_game/presentation/game_room/strategy/advanced_minimax_ai_strategy.dart';

/// Concrete strategy - Adaptive AI that learns from player moves
class AdaptiveAIStrategy extends BaseAIStrategy {
  final List<MoveEvaluation> _playerMoveHistory = [];
  late AIStrategy _baseStrategy;

  AdaptiveAIStrategy() {
    _baseStrategy = MinimaxAIStrategy(2);
  }

  void recordPlayerMove(MoveEvaluation move) {
    _playerMoveHistory.add(move);

    // Adapt strategy based on player patterns
    if (_playerMoveHistory.length > 10) {
      _analyzePlayerPatterns();
    }
  }

  void _analyzePlayerPatterns() {
    // Analyze player's move patterns and adjust strategy
    final recentMoves = _playerMoveHistory.length > 10
        ? _playerMoveHistory.sublist(_playerMoveHistory.length - 10)
        : _playerMoveHistory;

    // Count aggressive vs defensive moves
    int aggressiveMoves = 0;
    for (final move in recentMoves) {
      if (move.capturedPiece != null) {
        aggressiveMoves++;
      }
    }

    // Adjust strategy based on player style
    if (aggressiveMoves > 5) {
      // Player is aggressive, use defensive strategy
      _baseStrategy = AdvancedMinimaxAIStrategy(3);
    } else {
      // Player is defensive, use more aggressive strategy
      _baseStrategy = MinimaxAIStrategy(2);
    }
  }

  @override
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor) {
    return _baseStrategy.chooseMove(pieces, aiColor);
  }

  @override
  MoveEvaluation? getBestMoveEvaluation(
      List<ChessPiece> pieces, PieceColor aiColor) {
    return _baseStrategy.getBestMoveEvaluation(pieces, aiColor);
  }
}
