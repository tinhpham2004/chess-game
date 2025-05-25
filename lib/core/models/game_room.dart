import 'dart:convert';

import 'package:chess_game/core/models/board.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/core/patterns/builder/game_config_builder.dart';
import 'package:chess_game/core/patterns/chain_of_responsibility/move_validator.dart';
import 'package:chess_game/core/patterns/command/command.dart';
import 'package:chess_game/core/patterns/memento/board_memento.dart';
import 'package:chess_game/core/patterns/observer/board_observer.dart';
import 'package:chess_game/core/patterns/state/game_state.dart';
import 'package:chess_game/core/patterns/strategy/ai_strategy.dart';

/// The main GameRoom class that coordinates all chess game operations
class GameRoom {
  final String id;
  final Board _board = Board();
  final GameStateContext _stateContext = GameStateContext();
  final CommandInvoker _commandInvoker = CommandInvoker();
  final MoveValidator _moveValidator = MoveValidatorChain.createChain();
  final GameConfig _config;
  BoardMemento? _initialState;
  bool _whitesTurn = true;
  ChessAIPlayer? _aiPlayer;

  GameRoom({
    required this.id,
    required GameConfig config,
  }) : _config = config {
    _setupGame();
  }

  /// Initialize the game with the config settings
  void _setupGame() {
    // Setup the initial board state based on standard chess rules
    // Initialize pieces in their starting positions
    _initialState = _board.createMemento();

    // Setup AI if needed
    if (_config.isWhitePlayerAI || _config.isBlackPlayerAI) {
      final strategy = _config.aiDifficultyLevel > 5 ? MinimaxAIStrategy(_config.aiDifficultyLevel - 5) : RandomAIStrategy();

      _aiPlayer = ChessAIPlayer(strategy);
    }

    // Change state to Playing
    _stateContext.changeState(PlayingState(_stateContext));
  }

  /// Add an observer to be notified of board changes
  void addObserver(BoardObserver observer) {
    _board.addObserver(observer);
  }

  /// Remove an observer
  void removeObserver(BoardObserver observer) {
    _board.removeObserver(observer);
  }

  /// Attempt to move a piece
  bool movePiece(Position from, Position to) {
    if (!_stateContext.canMove()) return false;

    final piece = _board.getPieceAt(from);
    if (piece == null) return false;

    // Check if it's the right player's turn
    if ((piece.color == PieceColor.white) != _whitesTurn) return false;

    // Validate the move using the Chain of Responsibility
    if (!_moveValidator.validate(piece, from, to, _getAllPieces())) {
      return false;
    }

    // Create and execute the move command
    final command = MoveCommand(piece, to);
    _commandInvoker.executeCommand(command);

    // Switch turns
    _whitesTurn = !_whitesTurn;

    // If it's the AI's turn, make an AI move
    _makeAIMoveIfNeeded();

    return true;
  }

  /// Make an AI move if it's AI's turn
  void _makeAIMoveIfNeeded() {
    if (_aiPlayer == null) return;

    final isAITurn = (_whitesTurn && _config.isWhitePlayerAI) || (!_whitesTurn && _config.isBlackPlayerAI);

    if (isAITurn) {
      final aiColor = _whitesTurn ? PieceColor.white : PieceColor.black;
      try {
        final command = _aiPlayer!.makeMove(_getAllPieces(), aiColor);
        _commandInvoker.executeCommand(command);
        _whitesTurn = !_whitesTurn;
      } catch (e) {
        print('AI failed to make a move: $e');
      }
    }
  }

  /// Get all pieces on the board
  List<ChessPiece> _getAllPieces() {
    // Implementation to get all pieces from the board
    return []; // Placeholder
  }

  /// Undo the last move
  bool undo() {
    if (!_stateContext.canUndo() || !_commandInvoker.canUndo()) return false;

    _commandInvoker.undo();
    _whitesTurn = !_whitesTurn;

    // If undoing from an AI move, undo the human move as well
    if (_aiPlayer != null) {
      final isUndoingAIMove = (_whitesTurn && _config.isBlackPlayerAI) || (!_whitesTurn && _config.isWhitePlayerAI);

      if (isUndoingAIMove && _commandInvoker.canUndo()) {
        _commandInvoker.undo();
        _whitesTurn = !_whitesTurn;
      }
    }

    return true;
  }

  /// Restart the game to the initial state
  void restart() {
    if (_initialState != null) {
      _board.restoreFromMemento(_initialState!);
      _commandInvoker.reset();
      _whitesTurn = true;

      // Change state back to Playing
      _stateContext.changeState(PlayingState(_stateContext));
    }
  }

  /// Get a hint for the current player
  Position? getHint() {
    // Implementation for providing a hint
    // This could use a simplified version of the AI to suggest a move
    return null; // Placeholder
  }

  /// Convert the game state to JSON for storage
  String toJson() {
    // This would serialize the entire game state including:
    // - Board state
    // - Current player turn
    // - Game configuration
    // - Move history
    return jsonEncode({
      'id': id,
      // Other properties would be serialized here
    });
  }

  /// Create a GameRoom from JSON
  factory GameRoom.fromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>; // Create a GameConfig first
    final configBuilder = ChessGameConfigBuilder();
    // Set config values from JSON

    // Then create the GameRoom
    final gameRoom = GameRoom(
      id: data['id'],
      config: configBuilder.build(),
    );

    // Restore the game state from JSON
    // This would restore the board, current turn, etc.

    return gameRoom;
  }
}
