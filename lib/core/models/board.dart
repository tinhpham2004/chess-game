import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/memento/board_memento.dart';
import 'package:chess_game/presentation/game_room/observer/interface/board_publisher_interface.dart';
import 'package:chess_game/presentation/game_room/observer/interface/board_subscriber_interface.dart';

class Board implements IBoardPublisher {
  final List<List<ChessPiece?>> _board = List.generate(
    8,
    (_) => List.generate(8, (_) => null),
  );

  final List<IBoardSubscriber> _observers = [];

  // Observer pattern methods
  @override
  void subscribe(IBoardSubscriber observer) {
    _observers.add(observer);
  }

  @override
  void unsubscribe(IBoardSubscriber observer) {
    _observers.remove(observer);
  }

  @override
  void notifySubscribers() {
    for (final observer in _observers) {
      observer.update();
    }
  }

  // Game logic methods
  ChessPiece? getPieceAt(Position position) {
    if (!_isValidPosition(position)) return null;
    return _board[position.row][position.col];
  }

  bool movePiece(Position from, Position to) {
    if (!_isValidPosition(from) || !_isValidPosition(to)) return false;

    final piece = _board[from.row][from.col];
    if (piece == null) return false;

    _board[to.row][to.col] = piece;
    _board[from.row][from.col] = null;

    notifySubscribers();
    return true;
  }

  bool _isValidPosition(Position position) {
    return position.row >= 0 &&
        position.row < 8 &&
        position.col >= 0 &&
        position.col < 8;
  }

  // Memento pattern methods
  BoardMemento createMemento() {
    return BoardMemento(_deepCopyBoard());
  }

  void restoreFromMemento(BoardMemento memento) {
    _restoreBoard(memento.getState());
    notifySubscribers();
  }

  List<List<ChessPiece?>> _deepCopyBoard() {
    return List.generate(
      8,
      (row) => List.generate(
        8,
        (col) => _board[row][col]?.clone(),
      ),
    );
  }

  void _restoreBoard(List<List<ChessPiece?>> state) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        _board[row][col] = state[row][col]?.clone();
      }
    }
  }
}
