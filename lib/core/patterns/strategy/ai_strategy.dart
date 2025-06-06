import 'dart:math';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/command/move_command.dart';
import 'package:chess_game/core/patterns/chain_of_responsibility/move_validator.dart';

/// Move evaluation result for AI strategies
class MoveEvaluation {
  final Position from;
  final Position to;
  double score;
  final ChessPiece piece;
  final ChessPiece? capturedPiece;

  MoveEvaluation({
    required this.from,
    required this.to,
    required this.score,
    required this.piece,
    this.capturedPiece,
  });
}

// Context for the AI strategy
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
}

// Strategy interface
abstract class AIStrategy {
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor);

  /// Get the best move evaluation without creating a command
  MoveEvaluation? getBestMoveEvaluation(
      List<ChessPiece> pieces, PieceColor aiColor);
}

// Base strategy with common functionality
abstract class BaseAIStrategy implements AIStrategy {
  late GameRoomMoveValidator _moveValidator;

  BaseAIStrategy() {
    _moveValidator = GameRoomMoveValidator();
  }

  void setMoveValidator(GameRoomMoveValidator validator) {
    _moveValidator = validator;
  }

  /// Get all valid moves for a color
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

// Concrete strategy - Random moves
class RandomAIStrategy extends BaseAIStrategy {
  final Random _random = Random();

  @override
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor) {
    final validMoves = getAllValidMoves(pieces, aiColor);

    if (validMoves.isEmpty) {
      throw Exception("No pieces available for AI to move");
    }

    // Choose a random move
    final selectedMove = validMoves[_random.nextInt(validMoves.length)];

    return MoveCommand(piece: selectedMove.piece, newPosition: selectedMove.to);
  }

  @override
  MoveEvaluation? getBestMoveEvaluation(
      List<ChessPiece> pieces, PieceColor aiColor) {
    final validMoves = getAllValidMoves(pieces, aiColor);
    if (validMoves.isEmpty) return null;

    return validMoves[_random.nextInt(validMoves.length)];
  }
}

// Concrete strategy - Minimax algorithm for better AI
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

// Concrete strategy - Improved Minimax with better evaluation
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

    final aiKing = pieces
        .where((p) => p.type == PieceType.king && p.color == aiColor)
        .firstOrNull;

    if (aiKing != null) {
      // Penalty for exposed king
      final attackers = pieces.where((p) => p.color != aiColor).length;
      if (attackers > 0) {
        score -= 0.5;
      }
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

// Concrete strategy - Adaptive AI that learns from player moves
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
