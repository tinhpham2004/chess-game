import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';
import 'package:flutter/material.dart';

/// MoveHistory Component theo UML (equivalent to MoveListPanel)
class MoveHistoryComponent extends UIComponent {
  final List<String> _moves = [];
  
  // ✅ Callback để notify UI về state changes
  VoidCallback? onStateChanged;

  List<String> get moves => List.unmodifiable(_moves);

  void addMove(String move) {
    _moves.add(move);
    print('🎯 MoveHistoryComponent: Added move - $move');
    
    // ✅ Notify UI về state change
    onStateChanged?.call();
  }

  void removeLastMove() {
    if (_moves.isNotEmpty) {
      final removedMove = _moves.removeLast();
      print('🎯 MoveHistoryComponent: Removed last move - $removedMove');
      
      // ✅ Notify UI về state change
      onStateChanged?.call();
    }
  }

  void clear() {
    _moves.clear();
    print('🎯 MoveHistoryComponent: Cleared all moves');
    
    // ✅ Notify UI về state change
    onStateChanged?.call();
  }

  void updateFromBoard() {
    print('🎯 MoveHistoryComponent: Updated from board changes');
    // ✅ Notify UI về state change
    onStateChanged?.call();
  }

  void selectMove(int index) {
    if (index >= 0 && index < _moves.length) {
      print('🎯 MoveHistoryComponent: Selected move $index: ${_moves[index]}');
      mediator?.notify(this, 'move_selected', {'index': index, 'move': _moves[index]});
    }
  }
}