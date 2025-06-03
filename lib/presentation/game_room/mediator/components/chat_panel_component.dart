import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
  });
}

/// ChatPanel Component theo UML
class ChatPanelComponent extends UIComponent {
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;

  // Callback để notify UI về state changes
  VoidCallback? onStateChanged;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;

  void sendMessage(String message, String sender) {
    print('🎯 ChatPanelComponent: Sending message from $sender: $message');
    
    final chatMessage = ChatMessage(
      sender: sender,
      message: message,
      timestamp: DateTime.now(),
    );
    
    _messages.add(chatMessage);
    
    // Notify mediator about message sent
    mediator?.notify(this, GameEvents.messageSent, {
      'message': message,
      'sender': sender,
      'timestamp': chatMessage.timestamp.toIso8601String(),
    });
    
    // Notify UI về state change
    onStateChanged?.call();
  }

  void receiveMessage(String message, String sender) {
    print('🎯 ChatPanelComponent: Receiving message from $sender: $message');
    
    final chatMessage = ChatMessage(
      sender: sender,
      message: message,
      timestamp: DateTime.now(),
    );
    
    _messages.add(chatMessage);
    
    // Notify mediator about message received
    mediator?.notify(this, GameEvents.messageReceived, {
      'message': message,
      'sender': sender,
      'timestamp': chatMessage.timestamp.toIso8601String(),
    });
    
    // Notify UI về state change
    onStateChanged?.call();
  }

  void broadcastSystemMessage(String message) {
    print('🎯 ChatPanelComponent: Broadcasting system message: $message');
    
    final chatMessage = ChatMessage(
      sender: 'System',
      message: message,
      timestamp: DateTime.now(),
    );
    
    _messages.add(chatMessage);
    
    // Notify UI về state change
    onStateChanged?.call();
  }

  void clearMessages() {
    print('🎯 ChatPanelComponent: Clearing all messages');
    _messages.clear();
    
    // Notify mediator about messages cleared
    mediator?.notify(this, GameEvents.messagesCleared);
    
    // Notify UI về state change
    onStateChanged?.call();
  }

  void setConnectionStatus(bool connected) {
    _isConnected = connected;
    print('🎯 ChatPanelComponent: Connection status changed to: $connected');
    
    // Notify UI về state change
    onStateChanged?.call();
  }

  void notifyGameEvent(String eventType, Map<String, dynamic>? data) {
    switch (eventType) {
      case 'game_started':
        broadcastSystemMessage("🎮 Game started! Good luck!");
        break;
      case 'move_made':
        final move = data?['move'] ?? 'unknown move';
        final player = data?['player'] ?? 'Player';
        broadcastSystemMessage("📝 $player made move: $move");
        break;
      case 'game_over':
        final winner = data?['winner'] ?? 'Unknown';
        broadcastSystemMessage("🏆 Game Over! Winner: $winner");
        break;
      case 'undo_requested':
        broadcastSystemMessage("↩️ Move was undone");
        break;
      case 'hint_requested':
        broadcastSystemMessage("💡 Hint was requested");
        break;
      case 'board_changed':
        // Có thể thêm logic để notify về board changes nếu cần
        break;
      default:
        print('🎯 ChatPanelComponent: Unknown game event: $eventType');
    }
  }
}