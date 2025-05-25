import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';

// Command interface
abstract class Command {
  void execute();
  void undo();
}

// Command for moving a chess piece
class MoveCommand implements Command {
  final ChessPiece piece;
  final Position newPosition;
  late final Position oldPosition;
  ChessPiece? capturedPiece;

  MoveCommand(this.piece, this.newPosition) {
    oldPosition = piece.position.clone();
  }

  @override
  void execute() {
    // Store old position for undo
    // Implementation would include:
    // 1. Check if there's a piece at the destination to capture
    // 2. Move the piece to the new position
    piece.position = newPosition;
  }

  @override
  void undo() {
    // Restore piece to previous position
    piece.position = oldPosition;
    // If a piece was captured, restore it
  }
}

// Command invoker that stores history
class CommandInvoker {
  final List<Command> _commandHistory = [];
  int _currentIndex = -1;

  void executeCommand(Command command) {
    // Remove any commands after current index if we're in middle of history
    if (_currentIndex < _commandHistory.length - 1) {
      _commandHistory.removeRange(_currentIndex + 1, _commandHistory.length);
    }

    command.execute();
    _commandHistory.add(command);
    _currentIndex = _commandHistory.length - 1;
  }

  bool canUndo() => _currentIndex >= 0;
  bool canRedo() => _currentIndex < _commandHistory.length - 1;

  void undo() {
    if (canUndo()) {
      _commandHistory[_currentIndex].undo();
      _currentIndex--;
    }
  }

  void redo() {
    if (canRedo()) {
      _currentIndex++;
      _commandHistory[_currentIndex].execute();
    }
  }

  void reset() {
    _commandHistory.clear();
    _currentIndex = -1;
  }
}
