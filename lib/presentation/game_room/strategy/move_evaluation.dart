import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';

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
