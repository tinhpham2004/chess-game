import 'package:chess_game/core/models/chess_piece.dart';

/// BoardMemento - part of the Memento pattern
/// Used to save and restore the state of the chessboard
class BoardMemento {
  final List<List<ChessPiece?>> _state;

  BoardMemento(this._state);

  List<List<ChessPiece?>> getState() => _state;
}
