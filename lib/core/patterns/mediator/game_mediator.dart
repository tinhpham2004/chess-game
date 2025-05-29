import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/command/command_invoker.dart';
import 'package:chess_game/presentation/game_room/memento/board_memento.dart';

/// Mediator interface
abstract class GameMediator {
  void notifyBoardChanged();
  void notifyMoveRecorded(String move);
  void notifyTimerUpdated(int whiteTimeLeft, int blackTimeLeft);
  void performUndoMove();
  void performRestartGame();
  void performHint();
  void makeMove(Position from, Position to);
}

/// Component interface
abstract class GameComponent {
  void setMediator(GameMediator mediator);
}

/// Concrete Mediator
class ChessGameMediator implements GameMediator {
  late final ChessBoardComponent _chessBoard;
  late final MoveHistoryComponent _moveHistory;
  late final ControlPanelComponent _controlPanel;
  late final TimerPanelComponent _timerPanel;

  final CommandInvoker _commandInvoker = CommandInvoker();
  BoardMemento? _savedState;

  ChessGameMediator({
    required ChessBoardComponent chessBoard,
    required MoveHistoryComponent moveHistory,
    required ControlPanelComponent controlPanel,
    required TimerPanelComponent timerPanel,
  }) {
    _chessBoard = chessBoard;
    _moveHistory = moveHistory;
    _controlPanel = controlPanel;
    _timerPanel = timerPanel;

    // Register this mediator with all components
    _chessBoard.setMediator(this);
    _moveHistory.setMediator(this);
    _controlPanel.setMediator(this);
    _timerPanel.setMediator(this);
  }

  @override
  void notifyBoardChanged() {
    _moveHistory.updateFromBoard(_chessBoard);
    _controlPanel.updateButtons(_commandInvoker.canUndo, _chessBoard.isGameOver());
  }

  @override
  void notifyMoveRecorded(String move) {
    _moveHistory.addMove(move);
  }

  @override
  void notifyTimerUpdated(int whiteTimeLeft, int blackTimeLeft) {
    _timerPanel.updateTimers(whiteTimeLeft, blackTimeLeft);

    // Check for time-based game over conditions
    if (whiteTimeLeft <= 0 || blackTimeLeft <= 0) {
      _chessBoard.setGameOver(whiteTimeLeft <= 0 ? "Black wins on time" : "White wins on time");
    }
  }

  @override
  void performUndoMove() {
    if (_commandInvoker.canUndo) {
      _commandInvoker.undo();
      _chessBoard.updateUI();
      _moveHistory.removeLastMove();
    }
  }

  @override
  void performRestartGame() {
    if (_savedState != null) {
      _chessBoard.restoreInitialState(_savedState!);
      _commandInvoker.reset();
      _moveHistory.clear();
      _timerPanel.resetTimers();
    }
  }

  @override
  void performHint() {
    _chessBoard.showHint();
  }

  @override
  void makeMove(Position from, Position to) {
    final command = _chessBoard.createMoveCommand(from, to);
    if (command != null) {
      _commandInvoker.executeCommand(command);
      notifyBoardChanged();
    }
  }

  // Save the initial state of the board for restarts
  void saveInitialState(BoardMemento state) {
    _savedState = state;
  }
}

/// Concrete Component - ChessBoard
class ChessBoardComponent implements GameComponent {
  late final GameMediator _mediator;
  bool _isGameOver = false;
  String _gameOverReason = "";

  @override
  void setMediator(GameMediator mediator) {
    _mediator = mediator;
  }

  void updateUI() {
    // Update the chess board UI
    // This would be implemented in the actual UI component
  }

  Command? createMoveCommand(Position from, Position to) {
    // Logic to create a move command based on the positions
    // This would check if the move is valid and return a command
    return null; // Placeholder
  }

  void restoreInitialState(BoardMemento state) {
    // Reset the chess board to its initial state
    _isGameOver = false;
    _gameOverReason = "";
  }

  bool isGameOver() => _isGameOver;

  void setGameOver(String reason) {
    _isGameOver = true;
    _gameOverReason = reason;
    _mediator.notifyBoardChanged();
  }

  void showHint() {
    // Logic to show a hint for the current player
  }
}

/// Concrete Component - MoveHistory
class MoveHistoryComponent implements GameComponent {
  late final GameMediator _mediator;
  final List<String> _moves = [];

  @override
  void setMediator(GameMediator mediator) {
    _mediator = mediator;
  }

  void addMove(String move) {
    _moves.add(move);
    // Update the UI
  }

  void removeLastMove() {
    if (_moves.isNotEmpty) {
      _moves.removeLast();
      // Update the UI
    }
  }

  void clear() {
    _moves.clear();
    // Update the UI
  }

  void updateFromBoard(ChessBoardComponent board) {
    // The board has changed state, update move history if needed
  }
}

/// Concrete Component - ControlPanel
class ControlPanelComponent implements GameComponent {
  late final GameMediator _mediator;
  bool _undoEnabled = false;
  bool _gameOver = false;

  @override
  void setMediator(GameMediator mediator) {
    _mediator = mediator;
  }

  void onUndoPressed() {
    if (_undoEnabled) {
      _mediator.performUndoMove();
    }
  }

  void onRestartPressed() {
    _mediator.performRestartGame();
  }

  void onHintPressed() {
    _mediator.performHint();
  }

  void updateButtons(bool canUndo, bool isGameOver) {
    _undoEnabled = canUndo;
    _gameOver = isGameOver;
    // Update the UI to reflect the new states
  }
}

/// Concrete Component - TimerPanel
class TimerPanelComponent implements GameComponent {
  late final GameMediator _mediator;
  int _whiteTimeLeft = 0; // in seconds
  int _blackTimeLeft = 0; // in seconds

  @override
  void setMediator(GameMediator mediator) {
    _mediator = mediator;
  }

  void updateTimers(int whiteTimeLeft, int blackTimeLeft) {
    _whiteTimeLeft = whiteTimeLeft;
    _blackTimeLeft = blackTimeLeft;
    // Update the UI
  }

  void resetTimers() {
    // Reset timers to the initial values from game config
    // and update the UI
  }

  void startTimer(bool whitesTurn) {
    // Start the timer for the current player
    // This would be implemented with an actual Timer
  }

  void stopTimer() {
    // Stop the timer
  }
}
