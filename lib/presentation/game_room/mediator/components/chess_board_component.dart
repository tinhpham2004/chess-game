import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';

/// ChessBoard Component theo UML
class ChessBoardComponent extends UIComponent {
  bool _isGameOver = false;
  String _gameOverReason = "";
  Position? _selectedPosition;
  String? _hintMove;

  // Getters
  bool isGameOver() => _isGameOver;
  String get gameOverReason => _gameOverReason;
  Position? get selectedPosition => _selectedPosition;
  String? get hintMove => _hintMove;

  void updateBoard() {
    print('🎯 ChessBoardComponent: Board updated');
  }

  void restartGame() {
    _isGameOver = false;
    _gameOverReason = "";
    _selectedPosition = null;
    _hintMove = null;
    print('🎯 ChessBoardComponent: Game restarted');
  }
  

  void setGameOver(String reason) {
    _isGameOver = true;
    _gameOverReason = reason;
    print('🎯 ChessBoardComponent: Game over - $reason');
    mediator?.notify(this, GameEvents.gameOver, {'reason': reason});
  }

  void onSquareSelected(Position position) {
    _selectedPosition = position;
    print('🎯 ChessBoardComponent: Square selected at $position');
  }

  void onSquareTapped(Position position) {
    print('🎯 ChessBoardComponent: Square tapped at $position');
    mediator?.notify(this, GameEvents.squareTapped, {'position': position});
  }

  void onPieceDropped(Position from, Position to) {
    print('🎯 ChessBoardComponent: Piece dropped from $from to $to');
    mediator?.notify(this, GameEvents.pieceDropped, {'from': from, 'to': to});
  }

  void showHint() {
    _hintMove = "e2-e4"; // Placeholder hint
    print('🎯 ChessBoardComponent: Showing hint: $_hintMove');
  }

  bool canUndo() {
    return true; // Placeholder - should check actual undo availability
  }

  void performUndo() {
    print('🎯 ChessBoardComponent: Performing undo');
    _selectedPosition = null;
  }

  bool makeMove(Position from, Position to) {
    print('🎯 ChessBoardComponent: Making move from $from to $to');
    return true; // Placeholder - should return actual move result
  }
}