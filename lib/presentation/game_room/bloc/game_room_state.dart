part of 'game_room_bloc.dart';

class GameRoomState extends Equatable {
  final GameRoomModel? gameRoom;
  final bool loading;
  final String? errorMessage;

  const GameRoomState({
    this.gameRoom,
    this.loading = false,
    this.errorMessage,
  });

  GameRoomState copyWith({
    GameRoomModel? gameRoom,
    bool? loading,
    String? errorMessage,
  }) {
    return GameRoomState(
      gameRoom: gameRoom ?? this.gameRoom,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [gameRoom, loading, errorMessage];
}
