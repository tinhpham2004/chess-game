part of 'game_room_bloc.dart';

class AnimationData {
  final ChessPiece piece;
  final Position fromPosition;
  final Position toPosition;

  const AnimationData({
    required this.piece,
    required this.fromPosition,
    required this.toPosition,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimationData &&
          runtimeType == other.runtimeType &&
          piece == other.piece &&
          fromPosition == other.fromPosition &&
          toPosition == other.toPosition;

  @override
  int get hashCode =>
      piece.hashCode ^ fromPosition.hashCode ^ toPosition.hashCode;
}

class GameRoomState extends Equatable {
  final GameRoomEntity? gameRoom;
  final GameConfig? gameConfig;
  final bool loading;
  final String? errorMessage;
  final String? winner;
  // Chess game state
  final List<List<ChessPiece?>> board;
  final Position? selectedPosition;
  final List<List<bool>> possibleMoves;
  final bool isWhitesTurn;
  final bool gameStarted;
  final bool gameEnded;
  final PieceColor? aiColor;
  final List<String> moveHistory;
  final AnimationData? animatingMove;
  // New hint functionality
  final Position? hintFromPosition;
  final Position? hintToPosition;
  final bool showingHint;

  const GameRoomState({
    this.gameRoom,
    this.gameConfig,
    this.loading = false,
    this.errorMessage,
    this.winner,
    this.board = const [],
    this.selectedPosition,
    this.possibleMoves = const [],
    this.isWhitesTurn = true,
    this.gameStarted = false,
    this.gameEnded = false,
    this.aiColor,
    this.moveHistory = const [],
    this.animatingMove,
    this.hintFromPosition,
    this.hintToPosition,
    this.showingHint = false,
  });

  GameRoomState copyWith({
    GameRoomEntity? gameRoom,
    GameConfig? gameConfig,
    bool? loading,
    String? errorMessage,
    String? winner,
    List<List<ChessPiece?>>? board,
    Position? selectedPosition,
    List<List<bool>>? possibleMoves,
    bool? isWhitesTurn,
    bool? gameStarted,
    bool? gameEnded,
    PieceColor? aiColor,
    List<String>? moveHistory,
    AnimationData? animatingMove,
    Position? hintFromPosition,
    Position? hintToPosition,
    bool? showingHint,
    bool clearSelectedPosition = false,
    bool clearAnimatingMove = false,
    bool clearHint = false,
  }) {
    return GameRoomState(
      gameRoom: gameRoom ?? this.gameRoom,
      gameConfig: gameConfig ?? this.gameConfig,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      winner: winner ?? this.winner,
      board: board ?? this.board,
      selectedPosition: clearSelectedPosition
          ? null
          : (selectedPosition ?? this.selectedPosition),
      possibleMoves: possibleMoves ?? this.possibleMoves,
      isWhitesTurn: isWhitesTurn ?? this.isWhitesTurn,
      gameStarted: gameStarted ?? this.gameStarted,
      gameEnded: gameEnded ?? this.gameEnded,
      aiColor: aiColor ?? this.aiColor,
      moveHistory: moveHistory ?? this.moveHistory,
      animatingMove:
          clearAnimatingMove ? null : (animatingMove ?? this.animatingMove),
      hintFromPosition:
          clearHint ? null : (hintFromPosition ?? this.hintFromPosition),
      hintToPosition:
          clearHint ? null : (hintToPosition ?? this.hintToPosition),
      showingHint: clearHint ? false : (showingHint ?? this.showingHint),
    );
  }

  @override
  List<Object?> get props => [
        gameRoom,
        gameConfig,
        loading,
        errorMessage,
        winner,
        board,
        selectedPosition,
        possibleMoves,
        isWhitesTurn,
        gameStarted,
        gameEnded,
        aiColor,
        moveHistory,
        animatingMove,
        hintFromPosition,
        hintToPosition,
        showingHint,
      ];
}
