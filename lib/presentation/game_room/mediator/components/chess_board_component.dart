import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';

/// ChessBoard Component theo UML với Mediator Pattern
class ChessBoardComponent extends UIComponent {
  bool _isGameOver = false;
  String _gameOverReason = "";
  Position? _selectedPosition;
  String? _hintMove;
  List<List<ChessPiece?>> _board = [];
  List<List<bool>> _possibleMoves = [];
  bool _isWhitesTurn = true;
  bool _gameEnded = false;
  Position? _hintFromPosition;
  Position? _hintToPosition;

  // Getters for hint positions
  Position? get hintFromPosition => _hintFromPosition;
  Position? get hintToPosition => _hintToPosition;

  // Getters
  bool isGameOver() => _isGameOver;
  String get gameOverReason => _gameOverReason;
  Position? get selectedPosition => _selectedPosition;
  String? get hintMove => _hintMove;
  List<List<ChessPiece?>> get board => _board;
  List<List<bool>> get possibleMoves => _possibleMoves;
  bool get isWhitesTurn => _isWhitesTurn;
  bool get gameEnded => _gameEnded;

  void updateBoard() {
    print('🎯 ChessBoardComponent: Board updated');
    mediator?.notify(this, GameEvents.boardChanged);
  }

  void updateGameState({
    required List<List<ChessPiece?>> board,
    required Position? selectedPosition,
    required List<List<bool>> possibleMoves,
    required bool isWhitesTurn,
    required bool gameEnded,
    Position? hintFromPosition,
    Position? hintToPosition,
  }) {
    _board = board;
    _selectedPosition = selectedPosition;
    _possibleMoves = possibleMoves;
    _isWhitesTurn = isWhitesTurn;
    _gameEnded = gameEnded;
    _hintFromPosition = hintFromPosition;
    _hintToPosition = hintToPosition;

    notifyStateChanged();
    print('🎯 ChessBoardComponent: Game state updated');

    print(
        '🎯 ChessBoardComponent: Game state updated - Turn: ${isWhitesTurn ? "White" : "Black"}, GameEnded: $gameEnded');
  }

  void restartGame() {
    _isGameOver = false;
    _gameOverReason = "";
    _selectedPosition = null;
    _hintMove = null;
    _board = [];
    _possibleMoves = [];
    _isWhitesTurn = true;
    _gameEnded = false;
    _hintFromPosition = null;
    _hintToPosition = null;

    print('🎯 ChessBoardComponent: Game restarted');
    mediator?.notify(this, GameEvents.gameStarted);
  }

  void setGameOver(String reason) {
    _isGameOver = true;
    _gameOverReason = reason;
    _gameEnded = true;
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

  bool makeMove(Position from, Position to) {
    // Validate and execute move
    print('🎯 ChessBoardComponent: Attempting move from $from to $to');

    // Simplified move validation - in real implementation this would use move validator
    if (_possibleMoves.isNotEmpty &&
        to.row < _possibleMoves.length &&
        to.col < _possibleMoves[to.row].length &&
        _possibleMoves[to.row][to.col]) {
      // Execute move
      if (_board.isNotEmpty &&
          from.row < _board.length &&
          from.col < _board[from.row].length) {
        final piece = _board[from.row][from.col];
        if (piece != null) {
          _board[to.row][to.col] = piece;
          _board[from.row][from.col] = null;
          piece.position = to;

          _selectedPosition = null;
          _isWhitesTurn = !_isWhitesTurn;

          print('🎯 ChessBoardComponent: Move executed successfully');
          mediator?.notify(this, GameEvents.moveRecorded, {
            'move': '${from.toString()}-${to.toString()}',
            'player': _isWhitesTurn ? 'Black' : 'White',
          });

          return true;
        }
      }
    }

    print('🎯 ChessBoardComponent: Move failed - invalid move');
    return false;
  }

  void showHint() {
    _hintMove = "e2-e4"; // Placeholder hint
    print('🎯 ChessBoardComponent: Showing hint: $_hintMove');
  }

  bool canUndo() {
    // Simplified - in real implementation this would check move history
    return true;
  }

  void performUndo() {
    print('🎯 ChessBoardComponent: Undo performed');
    // Implement undo logic
    mediator?.notify(this, GameEvents.boardChanged);
  }
}
