import 'package:chess_game/core/patterns/builder/game_config_builder.dart';
import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:chess_game/data/entities/match_history_entity.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';
import 'package:chess_game/data/repository/match_history_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'game_room_event.dart';
part 'game_room_state.dart';

@injectable
class GameRoomBloc extends Bloc<GameRoomEvent, GameRoomState> {
  final GameRoomRepository _gameRoomRepository;
  final MatchHistoryRepository _matchHistoryRepository;

  GameRoomBloc(this._gameRoomRepository, this._matchHistoryRepository) : super(const GameRoomState()) {
    on<GameRoomInitialized>(_onInitialized);
    on<LoadGameRoomEvent>(_onLoadGameRoom);
    on<SaveGameRoomEvent>(_onSaveGameRoom);
    on<DeleteGameRoomEvent>(_onDeleteGameRoom);
    on<LoadGameConfigEvent>(_onLoadGameConfig);
    on<SaveMatchHistoryEvent>(_onSaveMatchHistory);
  }

  void _onInitialized(GameRoomInitialized event, Emitter<GameRoomState> emit) {
    emit(const GameRoomState());
  }

  Future<void> _onLoadGameRoom(LoadGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final gameRoom = await _gameRoomRepository.fetchGameRoom(event.id);
      if (gameRoom != null) {
        emit(state.copyWith(gameRoom: gameRoom, loading: false));
      } else {
        emit(state.copyWith(loading: false, errorMessage: 'Game room not found'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveGameRoom(SaveGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      await _gameRoomRepository.saveGameRoom(event.gameRoom);
      emit(state.copyWith(gameRoom: event.gameRoom, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteGameRoom(DeleteGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      await _gameRoomRepository.deleteGameRoom(event.id);
      emit(const GameRoomState());
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadGameConfig(LoadGameConfigEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final gameRoom = await _gameRoomRepository.fetchGameRoom(event.gameId);
      if (gameRoom != null) {
        final gameConfig = await _gameRoomRepository.fetchGameConfig(gameRoom);

        if (gameConfig != null) {
          emit(state.copyWith(gameRoom: gameRoom, gameConfig: gameConfig, loading: false));
        } else {
          emit(state.copyWith(gameRoom: gameRoom, loading: false, errorMessage: 'Game config not found'));
        }
      } else {
        emit(state.copyWith(loading: false, errorMessage: 'Game room not found'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveMatchHistory(SaveMatchHistoryEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null, winner: event.winner));
    try {
      if (state.gameConfig != null) {
        final whitePlayer = state.gameConfig!.isWhitePlayerAI ? 'Computer' : 'Player 1';
        final blackPlayer = state.gameConfig!.isBlackPlayerAI ? 'Computer' : 'Player 2';
        final isAiOpponent = state.gameConfig!.isWhitePlayerAI || state.gameConfig!.isBlackPlayerAI;

        // Create a match history record
        final matchHistory = MatchHistoryEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          gameId: event.gameId,
          whitePlayer: whitePlayer,
          blackPlayer: blackPlayer,
          winner: event.winner.toLowerCase(), // 'white', 'black', or 'draw'
          moveHistory: '[]', // In a real app, you'd have actual moves stored
          date: DateTime.now(),
          isAiOpponent: isAiOpponent,
          aiDifficulty: isAiOpponent ? state.gameConfig?.aiDifficultyLevel : null,
        );

        // Save to database
        await _matchHistoryRepository.saveMatchHistory(matchHistory);
        emit(state.copyWith(loading: false));
      } else {
        emit(state.copyWith(loading: false, errorMessage: 'Game config not found'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }
}
