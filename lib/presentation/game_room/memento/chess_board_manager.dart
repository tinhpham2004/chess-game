import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/memento/game_memento.dart';

/// Class quản lý board state và memento pattern
/// Đây là Originator trong memento pattern
class ChessBoardManager {
  // Current board state
  List<List<ChessPiece?>> _board = [];
  PieceColor _currentTurn = PieceColor.white;
  bool _isWhiteKingInCheck = false;
  bool _isBlackKingInCheck = false;

  // Memento management
  final GameHistory _gameHistory = GameHistory();

  // Getters
  List<List<ChessPiece?>> get board =>
      List.generate(8, (row) => List.generate(8, (col) => _board[row][col]));

  PieceColor get currentTurn => _currentTurn;
  bool get isWhiteKingInCheck => _isWhiteKingInCheck;
  bool get isBlackKingInCheck => _isBlackKingInCheck;
  bool get canUndo => _gameHistory.canUndo();
  bool get canRedo => _gameHistory.canRedo();

  /// Initialize board with standard chess setup
  void initializeBoard() {
    _board = _setupInitialBoard();
    _currentTurn = PieceColor.white;
    _isWhiteKingInCheck = false;
    _isBlackKingInCheck = false;

    // Save initial state
    _saveCurrentState();
  }

  /// Setup initial board with standard chess pieces
  List<List<ChessPiece?>> _setupInitialBoard() {
    final board =
        List.generate(8, (_) => List.generate(8, (_) => null as ChessPiece?));

    // Set up pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = Pawn(color: PieceColor.black, position: Position(i, 1));
      board[6][i] = Pawn(color: PieceColor.white, position: Position(i, 6));
    }

    // Set up rooks
    board[0][0] = Rook(color: PieceColor.black, position: Position(0, 0));
    board[0][7] = Rook(color: PieceColor.black, position: Position(7, 0));
    board[7][0] = Rook(color: PieceColor.white, position: Position(0, 7));
    board[7][7] = Rook(color: PieceColor.white, position: Position(7, 7));

    // Set up knights
    board[0][1] = Knight(color: PieceColor.black, position: Position(1, 0));
    board[0][6] = Knight(color: PieceColor.black, position: Position(6, 0));
    board[7][1] = Knight(color: PieceColor.white, position: Position(1, 7));
    board[7][6] = Knight(color: PieceColor.white, position: Position(6, 7));

    // Set up bishops
    board[0][2] = Bishop(color: PieceColor.black, position: Position(2, 0));
    board[0][5] = Bishop(color: PieceColor.black, position: Position(5, 0));
    board[7][2] = Bishop(color: PieceColor.white, position: Position(2, 7));
    board[7][5] = Bishop(color: PieceColor.white, position: Position(5, 7));

    // Set up queens
    board[0][3] = Queen(color: PieceColor.black, position: Position(3, 0));
    board[7][3] = Queen(color: PieceColor.white, position: Position(3, 7));

    // Set up kings
    board[0][4] = King(color: PieceColor.black, position: Position(4, 0));
    board[7][4] = King(color: PieceColor.white, position: Position(4, 7));

    return board;
  }

  /// Get piece at specific position
  ChessPiece? getPieceAt(Position position) {
    if (position.row < 0 ||
        position.row >= 8 ||
        position.col < 0 ||
        position.col >= 8) {
      return null;
    }
    return _board[position.row][position.col];
  }

  /// Set piece at specific position
  void setPieceAt(Position position, ChessPiece? piece) {
    if (position.row >= 0 &&
        position.row < 8 &&
        position.col >= 0 &&
        position.col < 8) {
      _board[position.row][position.col] = piece;
      if (piece != null) {
        piece.position = position;
      }
    }
  }

  /// Move piece from one position to another
  /// Returns the captured piece if any
  ChessPiece? movePiece(Position from, Position to) {
    final piece = getPieceAt(from);
    if (piece == null) return null;

    final capturedPiece = getPieceAt(to);

    // Update piece position
    piece.position = to;

    // Move piece on board
    setPieceAt(to, piece);
    setPieceAt(from, null);

    return capturedPiece;
  }

  /// Switch turns
  void switchTurn() {
    _currentTurn =
        _currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  /// Update check status
  void updateCheckStatus(bool whiteInCheck, bool blackInCheck) {
    _isWhiteKingInCheck = whiteInCheck;
    _isBlackKingInCheck = blackInCheck;
  }

  /// Save current board state to memento
  void saveCurrentState() {
    _saveCurrentState();
  }

  void _saveCurrentState() {
    final memento = _createMemento();
    _gameHistory.addMemento(memento);
  }

  /// Create memento from current state
  GameMemento _createMemento() {
    final pieceStates = <Map<String, dynamic>>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece != null) {
          pieceStates.add({
            'type': piece.type.toString(),
            'color': piece.color.toString(),
            'position': {
              'row': piece.position.row,
              'col': piece.position.col,
            },
            // Add piece-specific properties
            if (piece is Pawn) 'hasMoved': piece.hasMoved,
            if (piece is King) 'hasMoved': piece.hasMoved,
            if (piece is Rook) 'hasMoved': piece.hasMoved,
          });
        }
      }
    }

    return GameMemento(
      pieceStates,
      _currentTurn,
      _isWhiteKingInCheck,
      _isBlackKingInCheck,
    );
  }

  /// Restore state from memento
  void _restoreFromMemento(GameMemento memento) {
    // Clear current board
    _board =
        List.generate(8, (_) => List.generate(8, (_) => null as ChessPiece?));

    // Recreate pieces from memento
    for (var pieceData in memento.pieceStates) {
      final position = Position(
        pieceData['position']['col'] as int,
        pieceData['position']['row'] as int,
      );

      final color = pieceData['color'] == 'PieceColor.white'
          ? PieceColor.white
          : PieceColor.black;

      ChessPiece? piece;

      switch (pieceData['type']) {
        case 'PieceType.pawn':
          piece = Pawn(color: color, position: position);
          if (pieceData.containsKey('hasMoved')) {
            (piece as Pawn).hasMoved = pieceData['hasMoved'] as bool;
          }
          break;
        case 'PieceType.rook':
          piece = Rook(color: color, position: position);
          if (pieceData.containsKey('hasMoved')) {
            (piece as Rook).hasMoved = pieceData['hasMoved'] as bool;
          }
          break;
        case 'PieceType.knight':
          piece = Knight(color: color, position: position);
          break;
        case 'PieceType.bishop':
          piece = Bishop(color: color, position: position);
          break;
        case 'PieceType.queen':
          piece = Queen(color: color, position: position);
          break;
        case 'PieceType.king':
          piece = King(color: color, position: position);
          if (pieceData.containsKey('hasMoved')) {
            (piece as King).hasMoved = pieceData['hasMoved'] as bool;
          }
          break;
      }

      if (piece != null) {
        _board[position.row][position.col] = piece;
      }
    }

    _currentTurn = memento.currentTurn;
    _isWhiteKingInCheck = memento.isWhiteKingInCheck;
    _isBlackKingInCheck = memento.isBlackKingInCheck;
  }

  /// Undo to previous state
  bool undo() {
    final previousMemento = _gameHistory.getPreviousMemento();
    if (previousMemento != null) {
      _restoreFromMemento(previousMemento);
      return true;
    }
    return false;
  }

  /// Redo to next state
  bool redo() {
    final nextMemento = _gameHistory.getNextMemento();
    if (nextMemento != null) {
      _restoreFromMemento(nextMemento);
      return true;
    }
    return false;
  }

  /// Clear history
  void clearHistory() {
    _gameHistory.clearHistory();
  }

  /// Reset board to initial state
  void reset() {
    _board = _setupInitialBoard();
    _currentTurn = PieceColor.white;
    _isWhiteKingInCheck = false;
    _isBlackKingInCheck = false;
    clearHistory();
    _saveCurrentState();
  }
}
