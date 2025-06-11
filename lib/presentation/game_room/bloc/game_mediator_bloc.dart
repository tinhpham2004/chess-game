import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/mediator/chess_game_mediator.dart';
import 'package:chess_game/presentation/game_room/mediator/components/chess_board_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/move_history_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/control_panel_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/chat_panel_component.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';

part 'game_mediator_event.dart';
part 'game_mediator_state.dart';

/// GameMediatorBloc quản lý tất cả tương tác giữa UI components thông qua Mediator Pattern
class GameMediatorBloc extends Bloc<GameMediatorEvent, GameMediatorState> {
  late final ChessGameMediator _mediator;
  late final ChessBoardComponent _chessBoardComponent;
  late final MoveHistoryComponent _moveHistoryComponent;
  late final ControlPanelComponent _controlPanelComponent;
  late final ChatPanelComponent _chatPanelComponent;

  final GameRoomBloc _gameRoomBloc;

  GameMediatorBloc(this._gameRoomBloc) : super(GameMediatorInitial()) {
    _initializeComponents();
    _setupEventHandlers();
    _subscribeToCoreBloc();
  }

  void _initializeComponents() {
    // Khởi tạo tất cả components
    _chessBoardComponent = ChessBoardComponent();
    _moveHistoryComponent = MoveHistoryComponent();
    _controlPanelComponent = ControlPanelComponent();
    _chatPanelComponent = ChatPanelComponent();

    // Tạo mediator và kết nối các components
    _mediator = ChessGameMediator(
      chessBoard: _chessBoardComponent,
      moveHistory: _moveHistoryComponent,
      controlPanel: _controlPanelComponent,
      chatPanel: _chatPanelComponent,
    );

    print('🎯 GameMediatorBloc: All components initialized and connected');
  }

  void _setupEventHandlers() {
    // UI interaction events
    on<BoardSquareTappedEvent>(_onBoardSquareTapped);
    on<PieceDroppedEvent>(_onPieceDropped);
    on<UndoRequestedEvent>(_onUndoRequested);
    on<RestartRequestedEvent>(_onRestartRequested);
    on<HintRequestedEvent>(_onHintRequested);

    // Chat events
    on<SendMessageEvent>(_onSendMessage);
    on<ClearMessagesEvent>(_onClearMessages);

    // Game state synchronization events
    on<SyncGameStateEvent>(_onSyncGameState);
    on<BoardChangedEvent>(_onBoardChanged);
    on<MoveRecordedEvent>(_onMoveRecorded);
    on<GameOverEvent>(_onGameOver);

    // Timer events
    on<MediatorTimerTickEvent>(_onMediatorTimerTick);
    on<TimerStartedEvent>(_onTimerStarted);
    on<TimerPausedEvent>(_onTimerPaused);
  }

  void _subscribeToCoreBloc() {
    // Lắng nghe thay đổi từ GameRoomBloc và đồng bộ với mediator
    _gameRoomBloc.stream.listen((gameRoomState) {
      add(SyncGameStateEvent(gameRoomState));
    });
  }

  // Event Handlers
  void _onBoardSquareTapped(
      BoardSquareTappedEvent event, Emitter<GameMediatorState> emit) {
    print('🎯 GameMediatorBloc: Board square tapped at ${event.position}');

    // Thông qua mediator để xử lý logic
    _mediator.notify(
        _chessBoardComponent, 'square_tapped', {'position': event.position});

    // Chuyển tiếp đến GameRoomBloc để xử lý game logic
    if (_chessBoardComponent.selectedPosition == null) {
      _gameRoomBloc.add(SelectPieceEvent(position: event.position));
    } else {
      _gameRoomBloc.add(MovePieceEvent(
        from: _chessBoardComponent.selectedPosition!,
        to: event.position,
      ));
    }

    emit(BoardInteractionState(event.position));
  }

  void _onPieceDropped(
      PieceDroppedEvent event, Emitter<GameMediatorState> emit) {
    print(
        '🎯 GameMediatorBloc: Piece dropped from ${event.from} to ${event.to}');

    _mediator.notify(_chessBoardComponent, 'piece_dropped',
        {'from': event.from, 'to': event.to});

    // Chuyển tiếp đến GameRoomBloc
    _gameRoomBloc.add(MovePieceEvent(from: event.from, to: event.to));

    emit(PieceMovedState(event.from, event.to));
  }

  void _onUndoRequested(
      UndoRequestedEvent event, Emitter<GameMediatorState> emit) {
    print('🎯 GameMediatorBloc: Undo requested');

    _mediator.notify(_controlPanelComponent, 'undo_requested', {});
    _gameRoomBloc.add(UndoMoveEvent());

    emit(UndoExecutedState());
  }

  void _onRestartRequested(
      RestartRequestedEvent event, Emitter<GameMediatorState> emit) {
    print('🎯 GameMediatorBloc: Restart requested');

    _mediator.notify(_controlPanelComponent, 'restart_requested', {});
    _gameRoomBloc.add(RestartGameEvent());

    emit(GameRestartedState());
  }

  void _onHintRequested(
      HintRequestedEvent event, Emitter<GameMediatorState> emit) {
    print('🎯 GameMediatorBloc: Hint requested');

    _mediator.notify(_controlPanelComponent, 'hint_requested', {});
    _gameRoomBloc.add(RequestHintEvent());

    emit(HintShownState());
  }

  void _onSendMessage(SendMessageEvent event, Emitter<GameMediatorState> emit) {
    print('🎯 GameMediatorBloc: Message sent: ${event.message}');

    _mediator.notify(_chatPanelComponent, 'message_sent', {
      'message': event.message,
      'sender': event.sender,
      'timestamp': DateTime.now().toIso8601String(),
    });

    emit(MessageSentState(event.message, event.sender));
  }

  void _onClearMessages(
      ClearMessagesEvent event, Emitter<GameMediatorState> emit) {
    print('🎯 GameMediatorBloc: Messages cleared');

    _mediator.notify(_chatPanelComponent, 'messages_cleared', {});

    emit(MessagesClearedState());
  }

  void _onSyncGameState(
      SyncGameStateEvent event, Emitter<GameMediatorState> emit) {
    // Đồng bộ state từ GameRoomBloc với các components
    final gameState = event.gameRoomState;

    // Cập nhật board component
    _chessBoardComponent.updateGameState(
      board: gameState.board,
      selectedPosition: gameState.selectedPosition,
      possibleMoves: gameState.possibleMoves,
      isWhitesTurn: gameState.isWhitesTurn,
      gameEnded: gameState.gameEnded,
      hintFromPosition: gameState.hintFromPosition,
      hintToPosition: gameState.hintToPosition,
    );

    // Cập nhật control panel
    _controlPanelComponent.updateGameState(
      canUndo: gameState.moveHistory.isNotEmpty,
      gameEnded: gameState.gameEnded,
      isWhitesTurn: gameState.isWhitesTurn,
    );

    // Cập nhật move history
    _moveHistoryComponent.updateMoveHistory(gameState.moveHistory);

    emit(GameStateSyncedState(gameState));
  }

  void _onBoardChanged(
      BoardChangedEvent event, Emitter<GameMediatorState> emit) {
    _mediator.notifyBoardChanged();
    emit(BoardChangedState());
  }

  void _onMoveRecorded(
      MoveRecordedEvent event, Emitter<GameMediatorState> emit) {
    _mediator.notifyMoveRecorded(event.move, player: event.player);
    emit(MoveRecordedState(event.move));
  }

  void _onGameOver(GameOverEvent event, Emitter<GameMediatorState> emit) {
    _mediator.notify(_chessBoardComponent, 'game_over',
        {'reason': event.reason, 'winner': event.winner});
    emit(GameOverState(event.reason, event.winner));
  }

  void _onMediatorTimerTick(
      MediatorTimerTickEvent event, Emitter<GameMediatorState> emit) {
    // Cập nhật timer qua mediator
    _mediator.notify(_controlPanelComponent, 'timer_tick', {
      'whiteTime': event.whiteTime,
      'blackTime': event.blackTime,
      'activeColor': event.activeColor,
    });
    emit(TimerUpdatedState(event.whiteTime, event.blackTime));
  }

  void _onTimerStarted(
      TimerStartedEvent event, Emitter<GameMediatorState> emit) {
    _mediator.notify(_controlPanelComponent, 'timer_started', {});
    emit(TimerStartedState());
  }

  void _onTimerPaused(TimerPausedEvent event, Emitter<GameMediatorState> emit) {
    _mediator.notify(_controlPanelComponent, 'timer_paused', {});
    emit(TimerPausedState());
  }

  // Public getters để access components
  ChessGameMediator get mediator => _mediator;
  ChessBoardComponent get chessBoardComponent => _chessBoardComponent;
  MoveHistoryComponent get moveHistoryComponent => _moveHistoryComponent;
  ControlPanelComponent get controlPanelComponent => _controlPanelComponent;
  ChatPanelComponent get chatPanelComponent => _chatPanelComponent;

  @override
  Future<void> close() {
    print('🎯 GameMediatorBloc: Disposing mediator and components');
    return super.close();
  }
}
