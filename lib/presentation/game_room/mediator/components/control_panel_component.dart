import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';
import 'package:flutter/material.dart';

/// ControlPanel Component theo UML
class ControlPanelComponent extends UIComponent {
  bool _undoEnabled = false;
  bool _gameOver = false;
  bool _hintEnabled = true;
  
  // ✅ Callback để notify UI về state changes
  VoidCallback? onStateChanged;

  // Getters
  bool get undoEnabled => _undoEnabled;
  bool get gameOver => _gameOver;
  bool get hintEnabled => _hintEnabled;

  void restartGame() {
    print('🎯 ControlPanelComponent: Restart button pressed');
    mediator?.notify(this, GameEvents.restartRequested);
  }

  void onUndoPressed() {
    print('🎯 ControlPanelComponent: Undo button pressed');
    if (_undoEnabled) {
      mediator?.notify(this, GameEvents.undoRequested);
    }
  }

  void onHintPressed() {
    print('🎯 ControlPanelComponent: Hint button pressed');
    if (_hintEnabled) {
      mediator?.notify(this, GameEvents.hintRequested);
    }
  }

  void updateButtons(bool canUndo, bool isGameOver) {
    _undoEnabled = canUndo;
    _gameOver = isGameOver;
    _hintEnabled = !isGameOver;
    print('🎯 ControlPanelComponent: Buttons updated - undo: $canUndo, gameOver: $isGameOver');
    
    // ✅ Notify UI về state change
    onStateChanged?.call();
  }
}