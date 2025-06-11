import 'dart:math';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/command/move_command.dart';
import 'package:chess_game/presentation/game_room/strategy/base_ai_strategy.dart';
import 'package:chess_game/presentation/game_room/strategy/move_evaluation.dart';

/// Concrete strategy - Minimax algorithm for better AI
class MinimaxAIStrategy extends BaseAIStrategy {
  final int _depthLevel;

  MinimaxAIStrategy(this._depthLevel);

  @override
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor) {
    final bestMove = getBestMoveEvaluation(pieces, aiColor);

    if (bestMove == null) {
      throw Exception("No valid moves for AI");
    }

    return MoveCommand(piece: bestMove.piece, newPosition: bestMove.to);
  }

  @override
  MoveEvaluation? getBestMoveEvaluation(
      List<ChessPiece> pieces, PieceColor aiColor) {
    final validMoves = getAllValidMoves(pieces, aiColor);

    if (validMoves.isEmpty) return null;

    MoveEvaluation? bestMove;
    double bestScore = double.negativeInfinity;

    for (final move in validMoves) {
      final newBoard = simulateMove(pieces, move.from, move.to);
      final score = _minimax(newBoard, _depthLevel - 1, false, aiColor,
          double.negativeInfinity, double.infinity);

      move.score = score;
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  double _minimax(List<ChessPiece> pieces, int depth, bool isMaximizing,
      PieceColor aiColor, double alpha, double beta) {
    if (depth == 0) {
      return evaluateBoard(pieces, aiColor);
    }

    final currentColor = isMaximizing
        ? aiColor
        : (aiColor == PieceColor.white ? PieceColor.black : PieceColor.white);
    final validMoves = getAllValidMoves(pieces, currentColor);

    if (validMoves.isEmpty) {
      // No valid moves - could be checkmate or stalemate
      return isMaximizing ? double.negativeInfinity : double.infinity;
    }

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      for (final move in validMoves) {
        final newBoard = simulateMove(pieces, move.from, move.to);
        final eval = _minimax(newBoard, depth - 1, false, aiColor, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Alpha-beta pruning
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in validMoves) {
        final newBoard = simulateMove(pieces, move.from, move.to);
        final eval = _minimax(newBoard, depth - 1, true, aiColor, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Alpha-beta pruning
      }
      return minEval;
    }
  }
}
