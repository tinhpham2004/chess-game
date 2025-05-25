import 'dart:math';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/patterns/command/command.dart';

// Context for the AI strategy
class ChessAIPlayer {
  AIStrategy _strategy;

  ChessAIPlayer(this._strategy);

  void setStrategy(AIStrategy strategy) {
    _strategy = strategy;
  }

  Command makeMove(List<ChessPiece> pieces, PieceColor aiColor) {
    return _strategy.chooseMove(pieces, aiColor);
  }
}

// Strategy interface
abstract class AIStrategy {
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor);
}

// Concrete strategy - Random moves
class RandomAIStrategy implements AIStrategy {
  final Random _random = Random();

  @override
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor) {
    // Filter pieces of the AI's color
    final aiPieces = pieces.where((piece) => piece.color == aiColor).toList();

    if (aiPieces.isEmpty) {
      throw Exception("No pieces available for AI to move");
    }

    // Randomly select a piece to move
    final selectedPiece = aiPieces[_random.nextInt(aiPieces.length)];

    // Get all possible moves for the selected piece
    final possibleMoves = selectedPiece.getPossibleMoves(pieces);

    if (possibleMoves.isEmpty) {
      // If no moves possible for this piece, try another strategy or piece
      // For now, we'll throw an exception
      throw Exception("No valid moves for selected piece");
    }

    // Choose a random move from possible moves
    final targetPosition = possibleMoves[_random.nextInt(possibleMoves.length)];

    // Create and return a move command
    return MoveCommand(selectedPiece, targetPosition);
  }
}

// Concrete strategy - Minimax algorithm for better AI
class MinimaxAIStrategy implements AIStrategy {
  final int _depthLevel;

  MinimaxAIStrategy(this._depthLevel);

  @override
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor) {
    // A real minimax implementation would be more complex
    // This is just a placeholder showing the pattern
    // It would evaluate each possible move and choose the best one

    // For now, this is just a simple implementation
    // that chooses the first available move
    final aiPieces = pieces.where((piece) => piece.color == aiColor).toList();

    for (var piece in aiPieces) {
      final moves = piece.getPossibleMoves(pieces);
      if (moves.isNotEmpty) {
        return MoveCommand(piece, moves.first);
      }
    }

    throw Exception("No valid moves for AI");
  }
}

// Concrete strategy - Adaptive AI that learns from player moves
class AdaptiveAIStrategy implements AIStrategy {
  final List<Command> _playerMoveHistory = [];
  final Random _random = Random();

  void recordPlayerMove(Command move) {
    _playerMoveHistory.add(move);
  }

  @override
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor) {
    // A real adaptive AI would analyze player moves and adapt
    // This is just a placeholder

    // Fallback to random strategy for now
    return RandomAIStrategy().chooseMove(pieces, aiColor);
  }
}
