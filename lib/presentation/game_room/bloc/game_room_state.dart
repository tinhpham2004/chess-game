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
  // Enhanced game state for FIDE rules
  final List<String> pgnMoveHistory; // Full PGN notation for move history
  final int fiftyMoveCounter; // Counter for 50-move rule
  final String?
      lastDoubleMovePawn; // Position of pawn that just moved two squares (for en passant)
  final int moveNumber; // Current move number
  final List<String> positionHistory; // FEN positions for threefold repetition
  // Check detection
  final bool isWhiteKingInCheck;
  final bool isBlackKingInCheck;
  // Attacking pieces positions
  final List<Position> whiteAttackingPieces;
  final List<Position> blackAttackingPieces;
  // Timer and clock state
  final int whiteTimeLeft; // in seconds
  final int blackTimeLeft; // in seconds
  final bool timerRunning;
  final bool timerPaused;
  final PieceColor?
      activeTimerColor; // which player's timer is currently running

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
    this.isWhiteKingInCheck = false,
    this.isBlackKingInCheck = false,
    this.whiteAttackingPieces = const [],
    this.blackAttackingPieces = const [],
    // Timer and clock state
    this.whiteTimeLeft = 0,
    this.blackTimeLeft = 0,
    this.timerRunning = false,
    this.timerPaused = false,
    this.activeTimerColor,
    // Enhanced game state for FIDE rules
    this.pgnMoveHistory = const [],
    this.fiftyMoveCounter = 0,
    this.lastDoubleMovePawn,
    this.moveNumber = 1,
    this.positionHistory = const [],
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
    bool? isWhiteKingInCheck,
    bool? isBlackKingInCheck,
    List<Position>? whiteAttackingPieces,
    List<Position>? blackAttackingPieces,
    // Timer and clock state
    int? whiteTimeLeft,
    int? blackTimeLeft,
    bool? timerRunning,
    bool? timerPaused,
    PieceColor? activeTimerColor,
    // Enhanced game state for FIDE rules
    List<String>? pgnMoveHistory,
    int? fiftyMoveCounter,
    String? lastDoubleMovePawn,
    int? moveNumber,
    List<String>? positionHistory,
    bool clearSelectedPosition = false,
    bool clearAnimatingMove = false,
    bool clearHint = false,
    bool clearLastDoubleMovePawn = false,
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
      isWhiteKingInCheck: isWhiteKingInCheck ?? this.isWhiteKingInCheck,
      isBlackKingInCheck: isBlackKingInCheck ?? this.isBlackKingInCheck,
      whiteAttackingPieces: whiteAttackingPieces ?? this.whiteAttackingPieces,
      blackAttackingPieces: blackAttackingPieces ?? this.blackAttackingPieces,
      // Timer and clock state
      whiteTimeLeft: whiteTimeLeft ?? this.whiteTimeLeft,
      blackTimeLeft: blackTimeLeft ?? this.blackTimeLeft,
      timerRunning: timerRunning ?? this.timerRunning,
      timerPaused: timerPaused ?? this.timerPaused,
      activeTimerColor: activeTimerColor ?? this.activeTimerColor,
      // Enhanced game state for FIDE rules
      pgnMoveHistory: pgnMoveHistory ?? this.pgnMoveHistory,
      fiftyMoveCounter: fiftyMoveCounter ?? this.fiftyMoveCounter,
      lastDoubleMovePawn: clearLastDoubleMovePawn
          ? null
          : (lastDoubleMovePawn ?? this.lastDoubleMovePawn),
      moveNumber: moveNumber ?? this.moveNumber,
      positionHistory: positionHistory ?? this.positionHistory,
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
        isWhiteKingInCheck,
        isBlackKingInCheck,
        whiteAttackingPieces,
        blackAttackingPieces,
        // Timer and clock state
        whiteTimeLeft,
        blackTimeLeft,
        timerRunning,
        timerPaused,
        activeTimerColor,
        // Enhanced game state for FIDE rules
        pgnMoveHistory,
        fiftyMoveCounter,
        lastDoubleMovePawn,
        moveNumber,
        positionHistory,
      ];
}
