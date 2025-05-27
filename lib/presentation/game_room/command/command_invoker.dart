import 'package:chess_game/presentation/game_room/command/command.dart';

// Command invoker that stores history
class CommandInvoker {
  final List<Command> _commandHistory = [];
  int _currentIndex = -1;

  bool get canUndo => _currentIndex >= 0;
  bool get canRedo => _currentIndex < _commandHistory.length - 1;

  void executeCommand(Command command) {
    // Remove any commands after current index if we're in middle of history
    if (_currentIndex < _commandHistory.length - 1) {
      _commandHistory.removeRange(_currentIndex + 1, _commandHistory.length);
    }

    command.execute();
    _commandHistory.add(command);
    _currentIndex = _commandHistory.length - 1;
  }

  void undo() {
    if (canUndo) {
      _commandHistory[_currentIndex].undo();
      _currentIndex--;
    }
  }

  void redo() {
    if (canRedo) {
      _currentIndex++;
      _commandHistory[_currentIndex].execute();
    }
  }

  void reset() {
    _commandHistory.clear();
    _currentIndex = -1;
  }
}
