import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';
import 'package:chess_game/presentation/game_room/mediator/components/chess_board_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/move_history_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/control_panel_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/chat_panel_component.dart';

/// Concrete Mediator implementation with ChatPanel
class ChessGameMediator implements UIMediator {
  late final ChessBoardComponent _chessBoard;
  late final MoveHistoryComponent _moveHistory;
  late final ControlPanelComponent _controlPanel;
  late final ChatPanelComponent _chatPanel;

  // Getters để access components
  ChessBoardComponent get chessBoard => _chessBoard;
  MoveHistoryComponent get moveHistory => _moveHistory;
  ControlPanelComponent get controlPanel => _controlPanel;
  ChatPanelComponent get chatPanel => _chatPanel;

  ChessGameMediator({
    required ChessBoardComponent chessBoard,
    required MoveHistoryComponent moveHistory,
    required ControlPanelComponent controlPanel,
    required ChatPanelComponent chatPanel,
  }) {
    _chessBoard = chessBoard;
    _moveHistory = moveHistory;
    _controlPanel = controlPanel;
    _chatPanel = chatPanel;

    // Set mediator cho tất cả components
    _chessBoard.setMediator(this);
    _moveHistory.setMediator(this);
    _controlPanel.setMediator(this);
    _chatPanel.setMediator(this);
    
    print('🎯 ChessGameMediator: Initialized with ChatPanel successfully');
  }

  @override
  void notify(UIComponent sender, String event, [Map<String, dynamic>? data]) {
    print('🎯 MEDIATOR: Received "$event" from ${sender.runtimeType}');
    
    switch (event) {
      case GameEvents.boardChanged:
        _handleBoardChanged(sender, data);
        break;
      case GameEvents.moveRecorded:
        _handleMoveRecorded(sender, data);
        break;
      case GameEvents.undoRequested:
        _handleUndoRequested(sender, data);
        break;
      case GameEvents.restartRequested:
        _handleRestartRequested(sender, data);
        break;
      case GameEvents.hintRequested:
        _handleHintRequested(sender, data);
        break;
      case GameEvents.squareTapped:
        _handleSquareTapped(sender, data);
        break;
      case GameEvents.pieceDropped:
        _handlePieceDropped(sender, data);
        break;
      case GameEvents.messageReceived:
        _handleMessageReceived(sender, data);
        break;
      case GameEvents.messageSent:
        _handleMessageSent(sender, data);
        break;
      case GameEvents.messagesCleared:
        _handleMessagesCleared(sender, data);
        break;
      case GameEvents.gameOver:
        _handleGameOver(sender, data);
        break;
      default:
        print('🎯 MEDIATOR: Unknown event: $event');
    }
  }

  void _handleBoardChanged(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Handling board changed');
    _moveHistory.updateFromBoard();
    _controlPanel.updateButtons(_chessBoard.canUndo(), _chessBoard.isGameOver());
    
    // Notify chat about board state change
    _chatPanel.notifyGameEvent('board_changed', data);
  }

  void _handleMoveRecorded(UIComponent sender, Map<String, dynamic>? data) {
    if (data != null && data['move'] != null) {
      print('🎯 MEDIATOR: Recording move: ${data['move']}');
      
      // Only record in MoveHistory - ChessBoard handles its own internal history
      _moveHistory.addMove(data['move'] as String);
      
      // Update control panel buttons
      _controlPanel.updateButtons(_chessBoard.canUndo(), _chessBoard.isGameOver());
      
      // Notify chat about the move
      _chatPanel.notifyGameEvent('move_made', {
        'move': data['move'],
        'player': data['player'] ?? 'Player',
      });
    }
  }

  void _handleUndoRequested(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Processing undo request');
    if (_chessBoard.canUndo()) {
      _chessBoard.performUndo();
      _moveHistory.removeLastMove();
      _controlPanel.updateButtons(_chessBoard.canUndo(), _chessBoard.isGameOver());
      
      // Notify chat about undo
      _chatPanel.notifyGameEvent('undo_requested', data);
    }
  }

  void _handleRestartRequested(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Processing restart request');
    _chessBoard.restartGame();
    _moveHistory.clear();
    _chatPanel.clearMessages();
    _controlPanel.updateButtons(false, false);
    
    // Notify chat about game restart
    _chatPanel.broadcastSystemMessage("🔄 Game has been restarted! New game begins now.");
  }

  void _handleHintRequested(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Processing hint request');
    _chessBoard.showHint();
    
    // Notify chat about hint
    _chatPanel.notifyGameEvent('hint_requested', data);
  }

  void _handleSquareTapped(UIComponent sender, Map<String, dynamic>? data) {
    if (data != null && data['position'] != null) {
      final position = data['position'] as Position;
      print('🎯 MEDIATOR: Square tapped at $position');
      _chessBoard.onSquareSelected(position);
    }
  }

  void _handlePieceDropped(UIComponent sender, Map<String, dynamic>? data) {
    if (data != null && data['from'] != null && data['to'] != null) {
      final from = data['from'] as Position;
      final to = data['to'] as Position;
      print('🎯 MEDIATOR: Piece dropped from $from to $to');
      
      if (_chessBoard.makeMove(from, to)) {
        notify(_chessBoard, GameEvents.moveRecorded, {
          'move': '$from-$to',
          'player': 'Player',
        });
        notify(_chessBoard, GameEvents.boardChanged);
      }
    }
  }

  void _handleMessageReceived(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Message received in chat');
    // Could coordinate with other components if needed
  }

  void _handleMessageSent(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Message sent in chat');
    // Could coordinate with other components if needed
  }

  void _handleMessagesCleared(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Chat messages cleared');
  }

  void _handleGameOver(UIComponent sender, Map<String, dynamic>? data) {
    print('🎯 MEDIATOR: Game over event');
    final reason = data?['reason'] ?? 'Game ended';
    _chatPanel.notifyGameEvent('game_over', {
      'winner': reason,
      'reason': reason,
    });
  }

  // Public methods để BLoC có thể gọi
  void notifyBoardChanged() {
    notify(_chessBoard, GameEvents.boardChanged);
  }

  void notifyMoveRecorded(String move, {String player = "Player"}) {
    notify(_moveHistory, GameEvents.moveRecorded, {
      'move': move,
      'player': player,
    });
  }

  void notifyGameStarted() {
    _chatPanel.broadcastSystemMessage("🎮 Welcome to Chess Game! May the best player win!");
    _chatPanel.setConnectionStatus(true);
  }

  void notifyGameOver(String winner) {
    _chatPanel.notifyGameEvent('game_over', {'winner': winner});
  }

  void sendChatMessage(String message, String sender) {
    _chatPanel.sendMessage(message, sender);
  }

  void broadcastSystemMessage(String message) {
    _chatPanel.broadcastSystemMessage(message);
  }
}