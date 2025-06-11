import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';
import 'package:chess_game/presentation/game_room/bloc/game_mediator_bloc.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/core/models/chess_piece.dart';

/// Enhanced GameRoomBloc với Mediator Pattern integration
class EnhancedGameRoomBloc extends GameRoomBloc {
  late final GameMediatorBloc _mediatorBloc;

  EnhancedGameRoomBloc(super.gameRoomRepository, super.matchHistoryRepository) {
    _mediatorBloc = GameMediatorBloc(this);
    _setupMediatorIntegration();
  }

  GameMediatorBloc get mediatorBloc => _mediatorBloc;

  void _setupMediatorIntegration() {
    // Lắng nghe các thay đổi từ stream và notify mediator
    stream.listen((gameRoomState) {
      _syncStateWithMediator(gameRoomState);
    });
  }

  void _syncStateWithMediator(GameRoomState gameState) {
    // Đồng bộ state với mediator
    _mediatorBloc.add(SyncGameStateEvent(gameState));

    // Notify các events đặc biệt
    if (gameState.gameEnded) {
      _mediatorBloc.add(GameOverEvent(
        gameState.gameEnded ? "Game Ended" : "Unknown",
        winner: gameState.isWhitesTurn ? "Black" : "White",
      ));
    }
  }

  // Override các method để tích hợp với mediator
  @override
  void add(GameRoomEvent event) {
    super.add(event);

    // Notify mediator về các events quan trọng
    _notifyMediatorAboutEvent(event);
  }

  void _notifyMediatorAboutEvent(GameRoomEvent event) {
    switch (event.runtimeType) {
      case MovePieceEvent _:
        final moveEvent = event as MovePieceEvent;
        _mediatorBloc.add(MoveRecordedEvent(
          '${moveEvent.from.toString()}-${moveEvent.to.toString()}',
          player: state.isWhitesTurn ? "White" : "Black",
        ));
        break;

      case UndoMoveEvent _:
        _mediatorBloc.add(UndoRequestedEvent());
        break;

      case RestartGameEvent _:
        _mediatorBloc.add(RestartRequestedEvent());
        break;

      case RequestHintEvent _:
        _mediatorBloc.add(HintRequestedEvent());
        break;
    }
  }

  // Mediator interface methods
  void onBoardSquareTapped(Position position) {
    _mediatorBloc.add(BoardSquareTappedEvent(position));
  }

  void onPieceDropped(Position from, Position to) {
    _mediatorBloc.add(PieceDroppedEvent(from, to));
  }

  void onUndoRequested() {
    _mediatorBloc.add(UndoRequestedEvent());
    add(UndoMoveEvent());
  }

  void onRestartRequested() {
    _mediatorBloc.add(RestartRequestedEvent());
    add(RestartGameEvent());
  }

  void onHintRequested() {
    _mediatorBloc.add(HintRequestedEvent());
    add(RequestHintEvent());
  }

  void onSendMessage(String message, String sender) {
    _mediatorBloc.add(SendMessageEvent(message, sender));
  }

  void onClearMessages() {
    _mediatorBloc.add(ClearMessagesEvent());
  }

  // Timer integration
  void onTimerTick(int whiteTime, int blackTime, PieceColor activeColor) {
    _mediatorBloc
        .add(MediatorTimerTickEvent(whiteTime, blackTime, activeColor));
  }

  void onTimerStarted() {
    _mediatorBloc.add(TimerStartedEvent());
  }

  void onTimerPaused() {
    _mediatorBloc.add(TimerPausedEvent());
  }

  @override
  Future<void> close() {
    _mediatorBloc.close();
    return super.close();
  }
}
