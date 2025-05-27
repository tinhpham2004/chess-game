import 'dart:convert';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/command/command_invoker.dart';

// Memento class that stores the game state
class GameMemento {
  final List<Map<String, dynamic>> _pieceStates;
  final PieceColor _currentTurn;
  final bool _isWhiteKingInCheck;
  final bool _isBlackKingInCheck;

  GameMemento(
    this._pieceStates,
    this._currentTurn,
    this._isWhiteKingInCheck,
    this._isBlackKingInCheck,
  );

  // Constructor with serialized state
  factory GameMemento.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return GameMemento(
      (data['pieceStates'] as List).cast<Map<String, dynamic>>(),
      data['currentTurn'] == 'white' ? PieceColor.white : PieceColor.black,
      data['isWhiteKingInCheck'] as bool,
      data['isBlackKingInCheck'] as bool,
    );
  }

  // Serialize the memento to JSON
  String toJson() => jsonEncode({
        'pieceStates': _pieceStates,
        'currentTurn': _currentTurn == PieceColor.white ? 'white' : 'black',
        'isWhiteKingInCheck': _isWhiteKingInCheck,
        'isBlackKingInCheck': _isBlackKingInCheck,
      });

  // Getters for the encapsulated state (used by originator)
  List<Map<String, dynamic>> get pieceStates => _pieceStates;
  PieceColor get currentTurn => _currentTurn;
  bool get isWhiteKingInCheck => _isWhiteKingInCheck;
  bool get isBlackKingInCheck => _isBlackKingInCheck;
}

// Caretaker class that manages mementos
class GameHistory {
  final List<GameMemento> _mementos = [];
  int _currentIndex = -1;

  void addMemento(GameMemento memento) {
    // Remove any future history if we're in the middle of history
    if (_currentIndex < _mementos.length - 1) {
      _mementos.removeRange(_currentIndex + 1, _mementos.length);
    }

    _mementos.add(memento);
    _currentIndex = _mementos.length - 1;
  }

  GameMemento? getPreviousMemento() {
    if (_currentIndex <= 0) return null;

    _currentIndex--;
    return _mementos[_currentIndex];
  }

  GameMemento? getNextMemento() {
    if (_currentIndex >= _mementos.length - 1) return null;

    _currentIndex++;
    return _mementos[_currentIndex];
  }

  bool canUndo() => _currentIndex > 0;
  bool canRedo() => _currentIndex < _mementos.length - 1 && _mementos.isNotEmpty;

  void clearHistory() {
    _mementos.clear();
    _currentIndex = -1;
  }
}

// Originator class that creates mementos
class ChessBoard {
  List<ChessPiece> pieces = [];
  PieceColor currentTurn = PieceColor.white;
  bool isWhiteKingInCheck = false;
  bool isBlackKingInCheck = false;
  final GameHistory _history = GameHistory();
  final CommandInvoker _commandInvoker = CommandInvoker();

  // Create a memento containing a snapshot of the current state
  GameMemento createMemento() {
    final pieceStates = pieces.map((piece) {
      // Convert each piece to a map with its state
      return {
        'type': piece.type.toString(),
        'color': piece.color.toString(),
        'position': {
          'x': piece.position.x,
          'y': piece.position.y,
        },
        // Additional piece-specific properties
        if (piece is Pawn) 'hasMoved': (piece).hasMoved,
      };
    }).toList();

    return GameMemento(
      pieceStates,
      currentTurn,
      isWhiteKingInCheck,
      isBlackKingInCheck,
    );
  }

  // Restore state from a memento
  void restoreFromMemento(GameMemento memento) {
    pieces.clear();

    // Recreate pieces from the stored state
    for (var pieceData in memento.pieceStates) {
      // Implementation would recreate each piece based on type
      // This is simplified for demonstration
      final position = Position(
        pieceData['position']['x'] as int,
        pieceData['position']['y'] as int,
      );

      final color = pieceData['color'] == 'PieceColor.white' ? PieceColor.white : PieceColor.black;

      if (pieceData['type'] == 'PieceType.pawn') {
        final pawn = Pawn(color: color, position: position);
        if (pieceData.containsKey('hasMoved')) {
          pawn.hasMoved = pieceData['hasMoved'] as bool;
        }
        pieces.add(pawn);
      }
      // Add more piece types here...
    }

    currentTurn = memento.currentTurn;
    isWhiteKingInCheck = memento.isWhiteKingInCheck;
    isBlackKingInCheck = memento.isBlackKingInCheck;
  }

  // Save current state
  void saveState() {
    final memento = createMemento();
    _history.addMemento(memento);
  }

  // Undo to previous state
  bool undo() {
    final previousMemento = _history.getPreviousMemento();
    if (previousMemento != null) {
      restoreFromMemento(previousMemento);
      return true;
    }
    return false;
  }

  // Redo to next state
  bool redo() {
    final nextMemento = _history.getNextMemento();
    if (nextMemento != null) {
      restoreFromMemento(nextMemento);
      return true;
    }
    return false;
  }

  // Execute a command and save state
  void executeCommand(Command command) {
    saveState(); // Save state before executing the command
    _commandInvoker.executeCommand(command);
  }
}
