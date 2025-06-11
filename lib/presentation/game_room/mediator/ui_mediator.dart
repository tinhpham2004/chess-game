/// Base UI Mediator interface
abstract class UIMediator {
  void notify(UIComponent sender, String event, [Map<String, dynamic>? data]);
}

/// Base UI Component
abstract class UIComponent {
  UIMediator? _mediator;
  void Function()? onStateChanged;

  void setMediator(UIMediator mediator) {
    _mediator = mediator;
  }

  UIMediator? get mediator => _mediator;

  /// Notify state change to UI
  void notifyStateChanged() {
    onStateChanged?.call();
  }
}

/// Game events constants - updated for ChatPanel
abstract class GameEvents {
  // Board events
  static const String boardChanged = 'board_changed';
  static const String squareTapped = 'square_tapped';
  static const String pieceDropped = 'piece_dropped';

  // Move events
  static const String moveRecorded = 'move_recorded';
  static const String undoRequested = 'undo_requested';
  static const String restartRequested = 'restart_requested';
  static const String hintRequested = 'hint_requested';

  // Game state events
  static const String gameOver = 'game_over';
  static const String gameStarted = 'game_started';
  static const String gamePaused = 'game_paused';
  static const String gameResumed = 'game_resumed';

  // Chat events
  static const String messageReceived = 'message_received';
  static const String messageSent = 'message_sent';
  static const String messagesCleared = 'messages_cleared';

  // Timer events - NEW
  static const String timerStarted = 'timer_started';
  static const String timerSwitched = 'timer_switched';
  static const String timerPaused = 'timer_paused';
  static const String timerResumed = 'timer_resumed';
  static const String timerReset = 'timer_reset';
  static const String timerStopped = 'timer_stopped';
  static const String timerTick = 'timer_tick';
  static const String timerExpired = 'timer_expired';
}
