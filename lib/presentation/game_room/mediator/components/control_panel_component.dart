import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';

/// ControlPanel Component theo UML
class ControlPanelComponent extends UIComponent {
  bool _undoEnabled = false;
  bool _gameOver = false;
  bool _hintEnabled = true;

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
    print(
        '🎯 ControlPanelComponent: Buttons updated - undo: $canUndo, gameOver: $isGameOver');

    // ✅ Notify UI về state change
    onStateChanged?.call();
  }

  void updateGameState({
    required bool canUndo,
    required bool gameEnded,
    required bool isWhitesTurn,
  }) {
    _undoEnabled = canUndo;
    _gameOver = gameEnded;
    _hintEnabled = !gameEnded;

    print(
        '🎯 ControlPanelComponent: Game state updated - canUndo: $canUndo, gameEnded: $gameEnded, turn: ${isWhitesTurn ? "White" : "Black"}');

    // Notify UI về state change
    onStateChanged?.call();
  }
}
