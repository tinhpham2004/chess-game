part of 'game_room_bloc.dart';

class GameRoomState extends Equatable {
  final GameRoomEntity? gameRoom;
  final GameConfig? gameConfig;
  final bool loading;
  final String? errorMessage;
  final String? winner;

  const GameRoomState({
    this.gameRoom,
    this.gameConfig,
    this.loading = false,
    this.errorMessage,
    this.winner,
  });

  GameRoomState copyWith({
    GameRoomEntity? gameRoom,
    GameConfig? gameConfig,
    bool? loading,
    String? errorMessage,
    String? winner,
  }) {
    return GameRoomState(
      gameRoom: gameRoom ?? this.gameRoom,
      gameConfig: gameConfig ?? this.gameConfig,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      winner: winner ?? this.winner,
    );
  }

  @override
  List<Object?> get props => [gameRoom, gameConfig, loading, errorMessage, winner];
}
