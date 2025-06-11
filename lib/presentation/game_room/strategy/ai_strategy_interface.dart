import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/strategy/move_evaluation.dart';

/// Strategy interface for AI implementations
abstract class AIStrategy {
  Command chooseMove(List<ChessPiece> pieces, PieceColor aiColor);

  /// Get the best move evaluation without creating a command
  MoveEvaluation? getBestMoveEvaluation(
      List<ChessPiece> pieces, PieceColor aiColor);

  /// Get all valid moves for a color
  List<MoveEvaluation> getAllValidMoves(
      List<ChessPiece> pieces, PieceColor color);

  /// Evaluate board position
  double evaluateBoard(List<ChessPiece> pieces, PieceColor aiColor);
}
