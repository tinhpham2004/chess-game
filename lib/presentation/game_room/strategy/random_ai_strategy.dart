import 'dart:math';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/command/move_command.dart';
import 'package:chess_game/presentation/game_room/strategy/base_ai_strategy.dart';
import 'package:chess_game/presentation/game_room/strategy/move_evaluation.dart';

/// Concrete strategy - Random moves
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
