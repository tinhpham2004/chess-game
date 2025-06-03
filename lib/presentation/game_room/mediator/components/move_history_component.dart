import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';

/// MoveHistory Component theo UML (equivalent to MoveListPanel)
class MoveHistoryComponent extends UIComponent {
  final List<String> _moves = [];

  List<String> get moves => List.unmodifiable(_moves);

  void addMove(String move) {
    _moves.add(move);
    print('🎯 MoveHistoryComponent: Added move - $move');
  }

  void removeLastMove() {
    if (_moves.isNotEmpty) {
      final removedMove = _moves.removeLast();
      print('🎯 MoveHistoryComponent: Removed last move - $removedMove');
    }
  }

  void clear() {
    _moves.clear();
    print('🎯 MoveHistoryComponent: Cleared all moves');
  }

  void updateFromBoard() {
    print('🎯 MoveHistoryComponent: Updated from board changes');
  }

  void selectMove(int index) {
    if (index >= 0 && index < _moves.length) {
      print('🎯 MoveHistoryComponent: Selected move $index: ${_moves[index]}');
      mediator?.notify(this, 'move_selected', {'index': index, 'move': _moves[index]});
    }
  }
}