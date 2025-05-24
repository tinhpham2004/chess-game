import 'package:chess_game/app/chess_facade.dart';
import 'package:chess_game/data/models/game_room_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'game_room_event.dart';
part 'game_room_state.dart';

class GameRoomBloc extends Bloc<GameRoomEvent, GameRoomState> {
  final ChessFacade _facade;

  GameRoomBloc(this._facade) : super(const GameRoomState()) {
    on<GameRoomInitialized>(_onInitialized);
    on<LoadGameRoomEvent>(_onLoadGameRoom);
    on<SaveGameRoomEvent>(_onSaveGameRoom);
    on<DeleteGameRoomEvent>(_onDeleteGameRoom);
  }

  void _onInitialized(GameRoomInitialized event, Emitter<GameRoomState> emit) {
    emit(const GameRoomState());
  }

  Future<void> _onLoadGameRoom(
      LoadGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final gameRoom = await _facade.loadGameRoom(event.id);
      if (gameRoom != null) {
        emit(state.copyWith(gameRoom: gameRoom, loading: false));
      } else {
        emit(state.copyWith(
            loading: false, errorMessage: 'Game room not found'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveGameRoom(
      SaveGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      await _facade.saveGameRoom(event.gameRoom);
      emit(state.copyWith(gameRoom: event.gameRoom, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteGameRoom(
      DeleteGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      await _facade.deleteGameRoom(event.id);
      emit(const GameRoomState());
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }
}
