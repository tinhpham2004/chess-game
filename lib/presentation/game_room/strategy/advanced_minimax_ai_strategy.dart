import 'dart:math';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/command/move_command.dart';
import 'package:chess_game/presentation/game_room/chain_of_responsibility/move_validator.dart';
import 'package:chess_game/presentation/game_room/strategy/base_ai_strategy.dart';
import 'package:chess_game/presentation/game_room/strategy/move_evaluation.dart';

/// Concrete strategy - Improved Minimax with better evaluation
class AdvancedMinimaxAIStrategy extends BaseAIStrategy {
  final int _depthLevel;

  AdvancedMinimaxAIStrategy(this._depthLevel);

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

    // Sort moves for better alpha-beta pruning
    validMoves
        .sort((a, b) => _getMoveOrderScore(b).compareTo(_getMoveOrderScore(a)));

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

  double _getMoveOrderScore(MoveEvaluation move) {
    double score = 0.0;

    // Prioritize captures
    if (move.capturedPiece != null) {
      const pieceValues = {
        PieceType.pawn: 1.0,
        PieceType.knight: 3.0,
        PieceType.bishop: 3.0,
        PieceType.rook: 5.0,
        PieceType.queen: 9.0,
        PieceType.king: 100.0,
      };
      score += pieceValues[move.capturedPiece!.type] ?? 0.0;
    }

    return score;
  }

  double _minimax(List<ChessPiece> pieces, int depth, bool isMaximizing,
      PieceColor aiColor, double alpha, double beta) {
    if (depth == 0) {
      return _evaluateBoardAdvanced(pieces, aiColor);
    }

    final currentColor = isMaximizing
        ? aiColor
        : (aiColor == PieceColor.white ? PieceColor.black : PieceColor.white);
    final validMoves = getAllValidMoves(pieces, currentColor);

    if (validMoves.isEmpty) {
      return isMaximizing ? double.negativeInfinity : double.infinity;
    }

    // Sort moves for better pruning
    validMoves
        .sort((a, b) => _getMoveOrderScore(b).compareTo(_getMoveOrderScore(a)));

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      for (final move in validMoves) {
        final newBoard = simulateMove(pieces, move.from, move.to);
        final eval = _minimax(newBoard, depth - 1, false, aiColor, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in validMoves) {
        final newBoard = simulateMove(pieces, move.from, move.to);
        final eval = _minimax(newBoard, depth - 1, true, aiColor, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  double _evaluateBoardAdvanced(List<ChessPiece> pieces, PieceColor aiColor) {
    double score = evaluateBoard(pieces, aiColor); // Base evaluation

    // Add advanced evaluation factors
    score += _evaluateKingSafety(pieces, aiColor);
    score += _evaluatePawnStructure(pieces, aiColor);
    score += _evaluatePieceActivity(pieces, aiColor);

    return score;
  }

  double _evaluateKingSafety(List<ChessPiece> pieces, PieceColor aiColor) {
    double score = 0.0;
    final kingSafetyValidator = KingSafetyValidator();

    // Check if our king is in check (major penalty)
    if (kingSafetyValidator.isKingInCheck(aiColor, pieces)) {
      score -= 50.0; // Huge penalty for being in check
    }

    // Check if opponent's king is in check (major bonus)
    final opponentColor =
        aiColor == PieceColor.white ? PieceColor.black : PieceColor.white;
    if (kingSafetyValidator.isKingInCheck(opponentColor, pieces)) {
      score += 50.0; // Big bonus for putting opponent in check
    }

    final aiKing = pieces
        .where((p) => p.type == PieceType.king && p.color == aiColor)
        .firstOrNull;

    if (aiKing != null) {
      // Penalty for king in center during opening/middle game
      if (aiKing.position.col >= 2 &&
          aiKing.position.col <= 5 &&
          aiKing.position.row >= 2 &&
          aiKing.position.row <= 5) {
        score -= 2.0;
      }

      // Count how many enemy pieces can attack the king's vicinity
      final enemyPieces = pieces.where((p) => p.color != aiColor);
      int threatsNearKing = 0;

      for (final enemy in enemyPieces) {
        final attackMoves = enemy.getPossibleMoves(pieces);
        for (final move in attackMoves) {
          final distance = (move.row - aiKing.position.row).abs() +
              (move.col - aiKing.position.col).abs();
          if (distance <= 2) {
            threatsNearKing++;
          }
        }
      }

      score -= threatsNearKing * 0.3; // Penalty for threats near king
    }

    return score;
  }

  double _evaluatePawnStructure(List<ChessPiece> pieces, PieceColor aiColor) {
    double score = 0.0;

    final aiPawns = pieces
        .where((p) => p.type == PieceType.pawn && p.color == aiColor)
        .toList();

    // Bonus for advanced pawns
    for (final pawn in aiPawns) {
      final advancement = aiColor == PieceColor.white
          ? (7 - pawn.position.row)
          : pawn.position.row;
      score += advancement * 0.1;
    }

    return score;
  }

  double _evaluatePieceActivity(List<ChessPiece> pieces, PieceColor aiColor) {
    double score = 0.0;

    for (final piece in pieces.where((p) => p.color == aiColor)) {
      final moves = piece.getPossibleMoves(pieces);
      score += moves.length * 0.05; // Mobility bonus
    }

    return score;
  }
}
