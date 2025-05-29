import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/command/move_command.dart';
import 'package:chess_game/presentation/game_room/command/ai_move_command.dart';
import 'package:chess_game/presentation/game_room/command/castle_command.dart';
import 'package:chess_game/presentation/game_room/command/promote_command.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';

/// Game Room Command Manager that integrates Command pattern with Memento pattern
/// This class handles all chess game commands and automatically saves board state
/// after each command that changes the game state
class GameRoomCommandManager {
  final List<Command> _commandHistory = [];
  int _currentIndex = -1;
  ChessBoardManager? _boardManager;

  bool get canUndo => _boardManager?.canUndo ?? false;
  bool get canRedo => _boardManager?.canRedo ?? false;

  /// Set the board manager for memento integration
  void setBoardManager(ChessBoardManager boardManager) {
    _boardManager = boardManager;
  }

  /// Get the current board manager
  ChessBoardManager? get boardManager => _boardManager;

  void executeCommand(Command command) {
    // Remove any commands after current index if we're in middle of history
    if (_currentIndex < _commandHistory.length - 1) {
      _commandHistory.removeRange(_currentIndex + 1, _commandHistory.length);
    }

    command.execute();
    _commandHistory.add(command);
    _currentIndex = _commandHistory.length - 1;

    // Save board state after commands that change game state
    if (_shouldSaveState(command)) {
      _boardManager?.saveCurrentState();
    }
  }

  /// Check if command changes game state and requires saving memento
  bool _shouldSaveState(Command command) {
    // Don't auto-save for MoveCommand and AIMoveCommand as they're handled manually in the bloc
    // to ensure proper turn synchronization
    return command is CastleCommand || command is PromoteCommand;
  }

  void undo() {
    if (_boardManager != null && _boardManager!.canUndo) {
      _boardManager!.undo();
      if (_currentIndex >= 0) {
        _currentIndex--;
      }
    }
  }

  void redo() {
    if (_boardManager != null && _boardManager!.canRedo) {
      _boardManager!.redo();
      if (_currentIndex < _commandHistory.length - 1) {
        _currentIndex++;
      }
    }
  }

  void reset() {
    _commandHistory.clear();
    _currentIndex = -1;
  }

  /// Execute a move piece command
  void executeMove({
    required ChessPiece piece,
    required Position to,
    ChessPiece? capturedPiece,
  }) {
    final command = MoveCommand(
      piece: piece,
      newPosition: to,
      boardManager: _boardManager,
    );
    if (capturedPiece != null) {
      command.capturedPiece = capturedPiece;
    }
    executeCommand(command);
  }

  /// Execute an AI move command
  void executeAIMove({
    required ChessPiece piece,
    required Position from,
    required Position to,
    ChessPiece? capturedPiece,
  }) {
    final command = AIMoveCommand(
      piece: piece,
      from: from,
      to: to,
      capturedPiece: capturedPiece,
      boardManager: _boardManager,
    );
    executeCommand(command);
  }

  /// Execute a castle command
  void executeCastle({
    required ChessPiece rook,
    required ChessPiece king,
    required Position newRookPosition,
    required Position newKingPosition,
  }) {
    final command = CastleCommand(
      rook: rook,
      king: king,
      newRookPosition: newRookPosition,
      newKingPosition: newKingPosition,
      boardManager: _boardManager,
    );
    executeCommand(command);
  }

  /// Execute a promotion command
  void executePromotion({
    required ChessPiece newPiece,
    required ChessPiece oldPiece,
    required Position newPosition,
  }) {
    final command = PromoteCommand(
      newPiece: newPiece,
      oldPiece: oldPiece,
      newPosition: newPosition,
      boardManager: _boardManager,
    );
    executeCommand(command);
  }

  /// Get the command history for debugging or analysis
  List<Command> getCommandHistory() {
    return List.unmodifiable(_commandHistory);
  }

  /// Check if there are any commands in history
  bool get hasHistory => _commandHistory.isNotEmpty;

  /// Get the current command index
  int get currentIndex => _currentIndex;

  /// Get the total number of commands in history
  int get historyLength => _commandHistory.length;
}
