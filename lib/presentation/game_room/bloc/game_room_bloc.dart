import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:chess_game/data/entities/match_history_entity.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';
import 'package:chess_game/data/repository/match_history_repository.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/core/models/game_room.dart';
import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/presentation/game_room/command/game_room_command_manager.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';
import 'package:chess_game/presentation/game_room/mediator/chess_game_mediator.dart';
import 'package:chess_game/presentation/game_room/mediator/components/chess_board_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/move_history_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/control_panel_component.dart';
import 'package:chess_game/presentation/game_room/mediator/components/chat_panel_component.dart';
import 'package:chess_game/presentation/game_room/mediator/ui_mediator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'game_room_event.dart';
part 'game_room_state.dart';

@injectable
class GameRoomBloc extends Bloc<GameRoomEvent, GameRoomState> {
  final GameRoomRepository _gameRoomRepository;
  final MatchHistoryRepository _matchHistoryRepository;
  final GameRoomCommandManager _commandManager = GameRoomCommandManager();
  final ChessBoardManager _boardManager = ChessBoardManager();
  GameRoom? _currentGameRoom;

  // Mediator
  late final ChessGameMediator _gameMediator;

  // Getter để UI có thể access mediator
  ChessGameMediator get gameMediator => _gameMediator;

  GameRoomBloc(this._gameRoomRepository, this._matchHistoryRepository)
      : super(const GameRoomState()) {
    // Connect command manager with board manager
    _commandManager.setBoardManager(_boardManager);

    // Initialize mediator
    _initializeMediator();

    // Register event handlers
    on<GameRoomInitialized>(_onInitialized);
    on<LoadGameRoomEvent>(_onLoadGameRoom);
    on<SaveGameRoomEvent>(_onSaveGameRoom);
    on<DeleteGameRoomEvent>(_onDeleteGameRoom);
    on<LoadGameConfigEvent>(_onLoadGameConfig);
    on<SaveMatchHistoryEvent>(_onSaveMatchHistory);

    // Chess game events
    on<StartNewGameEvent>(_onStartNewGame);
    on<SelectPieceEvent>(_onSelectPiece);
    on<MovePieceEvent>(_onMovePiece);
    on<UndoMoveEvent>(_onUndoMove);
    on<RestartGameEvent>(_onRestartGame);
    on<MakeAIMoveEvent>(_onMakeAIMove);
    on<DeselectPieceEvent>(_onDeselectPiece);
    on<AnimationCompletedEvent>(_onAnimationCompleted);
  }

  /// Initialize mediator with all components
  void _initializeMediator() {
    try {
      final chessBoardComponent = ChessBoardComponent();
      final moveHistoryComponent = MoveHistoryComponent();
      final controlPanelComponent = ControlPanelComponent();
      final chatPanelComponent = ChatPanelComponent();

      _gameMediator = ChessGameMediator(
        chessBoard: chessBoardComponent,
        moveHistory: moveHistoryComponent,
        controlPanel: controlPanelComponent,
        chatPanel: chatPanelComponent,
      );

      print('🎯 GameRoomBloc: Mediator initialized successfully');
    } catch (e) {
      print('🎯 GameRoomBloc: Failed to initialize mediator: $e');
      rethrow;
    }
  }

  void _onInitialized(GameRoomInitialized event, Emitter<GameRoomState> emit) {
    emit(const GameRoomState());
  }

  Future<void> _onLoadGameRoom(
      LoadGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final gameRoom = await _gameRoomRepository.fetchGameRoom(event.id);
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
      await _gameRoomRepository.saveGameRoom(event.gameRoom);
      emit(state.copyWith(gameRoom: event.gameRoom, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteGameRoom(
      DeleteGameRoomEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      await _gameRoomRepository.deleteGameRoom(event.id);
      emit(const GameRoomState());
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadGameConfig(
      LoadGameConfigEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final gameRoom = await _gameRoomRepository.fetchGameRoom(event.gameId);
      if (gameRoom != null) {
        final gameConfig = await _gameRoomRepository.fetchGameConfig(gameRoom);

        if (gameConfig != null) {
          emit(state.copyWith(
              gameRoom: gameRoom, gameConfig: gameConfig, loading: false));
        } else {
          emit(state.copyWith(
              gameRoom: gameRoom,
              loading: false,
              errorMessage: 'Game config not found'));
        }
      } else {
        emit(state.copyWith(
            loading: false, errorMessage: 'Game room not found'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveMatchHistory(
      SaveMatchHistoryEvent event, Emitter<GameRoomState> emit) async {
    emit(state.copyWith(
        loading: true, errorMessage: null, winner: event.winner));
    try {
      if (state.gameConfig != null) {
        final whitePlayer =
            state.gameConfig!.isWhitePlayerAI ? 'Computer' : 'Player 1';
        final blackPlayer =
            state.gameConfig!.isBlackPlayerAI ? 'Computer' : 'Player 2';
        final isAiOpponent = state.gameConfig!.isWhitePlayerAI ||
            state.gameConfig!.isBlackPlayerAI;

        // Create a match history record
        final matchHistory = MatchHistoryEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          gameId: event.gameId,
          whitePlayer: whitePlayer,
          blackPlayer: blackPlayer,
          winner: event.winner.toLowerCase(), // 'white', 'black', or 'draw'
          moveHistory: state.moveHistory.join(','), // Join moves with comma
          date: DateTime.now(),
          isAiOpponent: isAiOpponent,
          aiDifficulty:
              isAiOpponent ? state.gameConfig?.aiDifficultyLevel : null,
        );

        // Save to database
        await _matchHistoryRepository.saveMatchHistory(matchHistory);
        emit(state.copyWith(loading: false, gameEnded: true));
      } else {
        emit(state.copyWith(
            loading: false, errorMessage: 'Game config not found'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  // Chess game event handlers
  Future<void> _onStartNewGame(
      StartNewGameEvent event, Emitter<GameRoomState> emit) async {
    try {
      // Create a new game room instance
      _currentGameRoom = GameRoom(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        config: event.gameConfig,
      );

      // Initialize board using ChessBoardManager
      _boardManager.initializeBoard();
      final emptyMoves = _createEmptyMovesMatrix();

      // Determine AI color if any
      PieceColor? aiColor;
      if (event.gameConfig.isWhitePlayerAI) {
        aiColor = PieceColor.white;
      } else if (event.gameConfig.isBlackPlayerAI) {
        aiColor = PieceColor.black;
      }

      emit(state.copyWith(
        gameConfig: event.gameConfig,
        board: _boardManager.board,
        possibleMoves: emptyMoves,
        isWhitesTurn: true,
        gameStarted: true,
        gameEnded: false,
        aiColor: aiColor,
        moveHistory: [],
        errorMessage: null,
      ));

      // Notify mediator about game start
      _gameMediator.notifyGameStarted();

      // If white is AI, make the first move
      if (aiColor == PieceColor.white) {
        add(MakeAIMoveEvent());
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      _gameMediator.broadcastSystemMessage("❌ Failed to start game: $e");
    }
  }

  void _onSelectPiece(SelectPieceEvent event, Emitter<GameRoomState> emit) {
    if (state.gameEnded || !state.gameStarted) return;

    final piece = _getPieceAt(event.position);
    if (piece == null) return;

    // Check if it's the correct player's turn
    final isWhitePiece = piece.color == PieceColor.white;
    if (isWhitePiece != state.isWhitesTurn) return;

    // Don't allow player to move AI pieces
    if (state.aiColor != null && piece.color == state.aiColor) return;

    // Notify mediator about square tap
    _gameMediator.chessBoard.onSquareTapped(event.position);

    // Calculate possible moves
    final possibleMoves = _getPossibleMoves(piece);

    emit(state.copyWith(
      selectedPosition: event.position,
      possibleMoves: possibleMoves,
    ));
  }

  void _onMovePiece(MovePieceEvent event, Emitter<GameRoomState> emit) {
    if (state.gameEnded || !state.gameStarted) return;

    final piece = _getPieceAt(event.from);
    if (piece == null) return;

    // Check if move is valid
    if (!_isValidMove(event.from, event.to)) return;

    // Notify mediator about piece drop
    _gameMediator.chessBoard.onPieceDropped(event.from, event.to);

    // First, check if this is a special move (castling or promotion)
    if (handleSpecialMove(event.from, event.to, emit)) {
      return; // Special move was handled
    }

    // Start the animation by setting the animating move
    final animationData = AnimationData(
      piece: piece,
      fromPosition: event.from,
      toPosition: event.to,
    );

    emit(state.copyWith(
      animatingMove: animationData,
      clearSelectedPosition: true,
      possibleMoves: _createEmptyMovesMatrix(),
    ));
  }

  void _onAnimationCompleted(
      AnimationCompletedEvent event, Emitter<GameRoomState> emit) {
    if (state.animatingMove == null) return;

    final piece = _getPieceAt(event.from);
    if (piece == null) return;

    try {
      // Check if there's a piece to capture
      final capturedPiece = _getPieceAt(event.to);

      // Execute the actual move after animation completes using command pattern
      _commandManager.executeMove(
        piece: piece,
        to: event.to,
        capturedPiece: capturedPiece,
      );

      // Execute the actual move after animation completes
      final newBoard = _executeMove(event.from, event.to);

      // Switch turn in board manager to keep it synchronized with UI state
      _boardManager.switchTurn();

      // Save the board state after the turn is switched
      _boardManager.saveCurrentState();
      final newMoveHistory = [
        ...state.moveHistory,
        '${event.from.toString()}-${event.to.toString()}'
      ];

      // Check for game end conditions
      final isGameOver = _checkGameEnd(newBoard, !state.isWhitesTurn);
      String? winner;
      if (isGameOver) {
        winner = _determineWinner(newBoard, !state.isWhitesTurn);
      }

      // Notify mediator about move
      final move = '${event.from.toString()}-${event.to.toString()}';
      _gameMediator.notifyMoveRecorded(move,
          player: state.isWhitesTurn ? "White" : "Black");

      emit(state.copyWith(
        board: newBoard,
        isWhitesTurn: !state.isWhitesTurn,
        possibleMoves: _createEmptyMovesMatrix(),
        clearSelectedPosition: true,
        moveHistory: newMoveHistory,
        gameEnded: isGameOver,
        winner: winner,
        clearAnimatingMove: true,
      ));

      // Handle game end
      if (isGameOver && winner != null) {
        _gameMediator.notifyGameOver(winner);
        add(SaveMatchHistoryEvent(
          gameId: _currentGameRoom?.id ?? '',
          winner: winner,
        ));
      } else if (!isGameOver) {
        // Check if it's AI's turn to move
        final nextPlayerColor =
            state.isWhitesTurn ? PieceColor.black : PieceColor.white;
        if (state.aiColor == nextPlayerColor) {
          add(MakeAIMoveEvent());
        }
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Move failed: ${e.toString()}'));
      _gameMediator.broadcastSystemMessage("❌ Move failed: $e");
    }
  }

  void _onUndoMove(UndoMoveEvent event, Emitter<GameRoomState> emit) {
    if (_boardManager.canUndo) {
      try {
        // Notify mediator first
        _gameMediator.controlPanel.onUndoPressed();

        // Undo using memento (board manager handles the state restoration)
        final success = _boardManager.undo();

        if (success) {
          // Get the restored board state from board manager
          emit(state.copyWith(
            board: _boardManager.board,
            possibleMoves: _createEmptyMovesMatrix(),
            clearSelectedPosition: true,
            isWhitesTurn: _boardManager.currentTurn == PieceColor.white,
            gameEnded: false,
            winner: null,
            clearAnimatingMove: true,
          ));

          // Notify mediator about board change
          _gameMediator.notifyBoardChanged();
        }
      } catch (e) {
        emit(state.copyWith(errorMessage: 'Undo failed: ${e.toString()}'));
        _gameMediator.broadcastSystemMessage("❌ Undo failed: $e");
      }
    }
  }

  void _onRestartGame(RestartGameEvent event, Emitter<GameRoomState> emit) {
    if (state.gameConfig != null) {
      // Notify mediator before restart
      _gameMediator.controlPanel.restartGame();

      // Start new game with current config
      add(StartNewGameEvent(gameConfig: state.gameConfig!));
    }
  }

  // lib/presentation/game_room/bloc/game_room_bloc.dart

// Thêm 2 methods bị thiếu sau method _onRestartGame:

  void _onDeselectPiece(DeselectPieceEvent event, Emitter<GameRoomState> emit) {
    // Clear selected position and possible moves
    emit(state.copyWith(
      clearSelectedPosition: true,
      possibleMoves: _createEmptyMovesMatrix(),
    ));

    // Notify mediator about deselection
    _gameMediator.chessBoard.onSquareSelected(
        Position(-1, -1)); // Invalid position to indicate deselection

    print('🎯 GameRoomBloc: Piece deselected');
  }

  void _onMakeAIMove(MakeAIMoveEvent event, Emitter<GameRoomState> emit) {
    if (state.gameEnded || !state.gameStarted) return;

    // Check if it's actually AI's turn
    final currentPlayerColor =
        state.isWhitesTurn ? PieceColor.white : PieceColor.black;
    if (state.aiColor != currentPlayerColor) return;

    try {
      // Notify mediator about AI move attempt
      _gameMediator.broadcastSystemMessage("🤖 AI is thinking...");

      // Simple AI: Find a random valid move
      final aiMove = _generateAIMove();

      if (aiMove != null) {
        // Notify mediator about AI move
        _gameMediator.broadcastSystemMessage(
            "🤖 AI makes move: ${aiMove['from']}-${aiMove['to']}");

        // Execute AI move
        add(MovePieceEvent(
          from: aiMove['from'] as Position,
          to: aiMove['to'] as Position,
        ));
      } else {
        // No valid moves found - AI passes or game might be over
        _gameMediator
            .broadcastSystemMessage("🤖 AI has no valid moves available");
        print('🎯 GameRoomBloc: AI has no valid moves');
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'AI move failed: ${e.toString()}'));
      _gameMediator.broadcastSystemMessage("❌ AI move failed: $e");
    }
  }

// Helper method để generate AI move
  Map<String, Position>? _generateAIMove() {
    final board = _boardManager.board;
    final aiColor = state.aiColor;

    if (aiColor == null) return null;

    // Find all AI pieces
    final aiPieces = <Map<String, dynamic>>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == aiColor) {
          aiPieces.add({
            'piece': piece,
            'position': Position(col, row),
          });
        }
      }
    }

    // Try to find a valid move for any AI piece
    for (final pieceData in aiPieces) {
      final piece = pieceData['piece'] as ChessPiece;
      final position = pieceData['position'] as Position;
      final possibleMoves = _getPossibleMoves(piece);

      // Find first valid move
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          if (possibleMoves[row][col]) {
            final targetPosition = Position(col, row);

            // Validate the move is actually legal
            if (_isValidMove(position, targetPosition)) {
              return {
                'from': position,
                'to': targetPosition,
              };
            }
          }
        }
      }
    }

    return null; // No valid moves found
  }

  /// Get the new rook position after castling
  Position _getNewRookPositionForCastle(Position kingFrom, Position kingTo) {
    final isKingsideCastle = kingTo.col > kingFrom.col;
    final newRookCol = isKingsideCastle ? 5 : 3;
    return Position(newRookCol, kingFrom.row); // Fixed: col first, then row
  }

  /// Get the rook piece for castling
  ChessPiece? _getRookForCastle(Position kingFrom, Position kingTo) {
    final isKingsideCastle = kingTo.col > kingFrom.col;
    final rookCol = isKingsideCastle ? 7 : 0;
    return _getPieceAt(
        Position(rookCol, kingFrom.row)); // Fixed: col first, then row
  }

  /// Get the rook's original position for castling
  Position _getRookPositionForCastle(Position kingFrom, Position kingTo) {
    final isKingsideCastle = kingTo.col > kingFrom.col;
    final rookCol = isKingsideCastle ? 7 : 0;
    return Position(rookCol, kingFrom.row); // Fixed: col first, then row
  }

  // Command pattern helper methods

  /// Execute a castle move using command pattern
  void executeCastleMove({
    required ChessPiece king,
    required ChessPiece rook,
    required Position newKingPosition,
    required Position newRookPosition,
  }) {
    _commandManager.executeCastle(
      rook: rook,
      king: king,
      newRookPosition: newRookPosition,
      newKingPosition: newKingPosition,
    );
  }

  /// Execute a pawn promotion using command pattern
  void executePromotionMove({
    required ChessPiece pawn,
    required ChessPiece newPiece,
    required Position promotionPosition,
  }) {
    _commandManager.executePromotion(
      newPiece: newPiece,
      oldPiece: pawn,
      newPosition: promotionPosition,
    );
  }

  /// Check if a move is a castle move
  bool isCastleMove(Position from, Position to) {
    final piece = _getPieceAt(from);
    if (piece?.type != PieceType.king) return false;

    // King moves two squares horizontally
    return (from.col - to.col).abs() == 2;
  }

  /// Check if a move is a pawn promotion
  bool isPromotionMove(Position from, Position to) {
    final piece = _getPieceAt(from);
    if (piece?.type != PieceType.pawn) return false;

    // Pawn reaches the opposite end
    return (piece?.color == PieceColor.white && to.row == 0) ||
        (piece?.color == PieceColor.black && to.row == 7);
  }

  /// Handle special moves (castling, promotion) using command pattern
  bool handleSpecialMove(
      Position from, Position to, Emitter<GameRoomState> emit) {
    final piece = _getPieceAt(from);
    if (piece == null) return false;

    // Check for castling
    if (isCastleMove(from, to)) {
      final rook = _getRookForCastle(from, to);
      if (rook != null) {
        final newRookPosition = _getNewRookPositionForCastle(from, to);
        executeCastleMove(
          king: piece,
          rook: rook,
          newKingPosition: to,
          newRookPosition: newRookPosition,
        ); // Update the board state after castling
        final newBoard = _executeCastleMoveOnBoard(
            from, to, _getRookPositionForCastle(from, to), newRookPosition);

        // Switch turn in board manager to keep it synchronized with UI state
        _boardManager.switchTurn();

        emit(state.copyWith(
          board: newBoard,
          isWhitesTurn: !state.isWhitesTurn,
          possibleMoves: _createEmptyMovesMatrix(),
          clearSelectedPosition: true,
        ));
        return true;
      }
    }

    // Check for pawn promotion
    if (isPromotionMove(from, to)) {
      // For now, always promote to queen (in a real game, this would show a dialog)
      final promotedPiece = Queen(
        color: piece.color,
        position: to,
      );

      executePromotionMove(
        pawn: piece,
        newPiece: promotedPiece,
        promotionPosition: to,
      ); // Update the board state after promotion
      final newBoard = _executePromotionOnBoard(from, to, promotedPiece);

      // Switch turn in board manager to keep it synchronized with UI state
      _boardManager.switchTurn();

      emit(state.copyWith(
        board: newBoard,
        isWhitesTurn: !state.isWhitesTurn,
        possibleMoves: _createEmptyMovesMatrix(),
        clearSelectedPosition: true,
      ));
      return true;
    }

    return false;
  }

  /// Execute castle move on the board
  List<List<ChessPiece?>> _executeCastleMoveOnBoard(
      Position kingFrom, Position kingTo, Position rookFrom, Position rookTo) {
    // The castle command will handle the actual piece movement through board manager
    // Just return the current board state from board manager
    return _boardManager.board;
  }

  /// Execute promotion on the board
  List<List<ChessPiece?>> _executePromotionOnBoard(
      Position from, Position to, ChessPiece promotedPiece) {
    // The promotion command will handle the actual piece movement through board manager
    // Just return the current board state from board manager
    return _boardManager.board;
  }

  /// Get command history for debugging or analysis
  List<String> getCommandHistory() {
    return _commandManager
        .getCommandHistory()
        .map((command) => command.runtimeType.toString())
        .toList();
  }

  /// Check if undo is available
  bool get canUndo => _commandManager.canUndo;

  /// Check if redo is available
  bool get canRedo => _commandManager.canRedo;

  // Helper methods
  List<List<bool>> _createEmptyMovesMatrix() {
    return List.generate(8, (_) => List.generate(8, (_) => false));
  }

  ChessPiece? _getPieceAt(Position position) {
    if (position.row < 0 ||
        position.row >= 8 ||
        position.col < 0 ||
        position.col >= 8) {
      return null;
    }
    // Use board manager to get piece at position
    return _boardManager.getPieceAt(position);
  }

  List<List<bool>> _getPossibleMoves(ChessPiece piece) {
    final moves = _createEmptyMovesMatrix();
    final pos = piece.position;
    final board = _boardManager.board;

    // Simplified move calculation - show moves around the piece
    for (int dRow = -2; dRow <= 2; dRow++) {
      for (int dCol = -2; dCol <= 2; dCol++) {
        if (dRow == 0 && dCol == 0) continue;

        int newRow = pos.row + dRow;
        int newCol = pos.col + dCol;

        if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
          final targetPiece = board[newRow][newCol];
          if (targetPiece == null || targetPiece.color != piece.color) {
            moves[newRow][newCol] = true;
          }
        }
      }
    }

    return moves;
  }

  bool _isValidMove(Position from, Position to) {
    if (to.row < 0 || to.row >= 8 || to.col < 0 || to.col >= 8) return false;
    return state.possibleMoves[to.row][to.col];
  }

  List<List<ChessPiece?>> _executeMove(Position from, Position to) {
    // Use board manager to move piece, which handles the move internally
    _boardManager.movePiece(from, to);

    // Return the current board state from board manager
    return _boardManager.board;
  }

  bool _checkGameEnd(List<List<ChessPiece?>> board, bool isWhitesTurn) {
    // Simplified game end check - find if king is captured
    bool whiteKingExists = false;
    bool blackKingExists = false;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece?.type == PieceType.king) {
          if (piece!.color == PieceColor.white) {
            whiteKingExists = true;
          } else {
            blackKingExists = true;
          }
        }
      }
    }

    return !whiteKingExists || !blackKingExists;
  }

  String? _determineWinner(List<List<ChessPiece?>> board, bool wasWhitesTurn) {
    bool whiteKingExists = false;
    bool blackKingExists = false;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece?.type == PieceType.king) {
          if (piece!.color == PieceColor.white) {
            whiteKingExists = true;
          } else {
            blackKingExists = true;
          }
        }
      }
    }
    if (!whiteKingExists) return 'black';
    if (!blackKingExists) return 'white';
    return 'draw';
  }

  // Test methods để debug mediator
  void testMediatorFlow() {
    print('\n🎯 === TESTING MEDIATOR FLOW IN GAMEROOM BLOC ===');

    // Test 1: Component initialization
    print('🎯 Step 1: Testing component initialization');
    print('✅ ChessBoard Component: ${_gameMediator.chessBoard != null}');
    print('✅ MoveHistory Component: ${_gameMediator.moveHistory != null}');
    print('✅ ControlPanel Component: ${_gameMediator.controlPanel != null}');
    print('✅ ChatPanel Component: ${_gameMediator.chatPanel != null}');

    // Test 2: Mediator registration
    print('\n🎯 Step 2: Testing mediator registration');
    print(
        '✅ ChessBoard has mediator: ${_gameMediator.chessBoard.mediator != null}');
    print(
        '✅ MoveHistory has mediator: ${_gameMediator.moveHistory.mediator != null}');
    print(
        '✅ ControlPanel has mediator: ${_gameMediator.controlPanel.mediator != null}');
    print(
        '✅ ChatPanel has mediator: ${_gameMediator.chatPanel.mediator != null}');

    // Test 3: Event flow
    print('\n🎯 Step 3: Testing event communication');
    _testMediatorEvents();
  }

  void _testMediatorEvents() {
    print('🎯 Testing BLoC → Mediator → Components flow:');

    print('\n🎯 1. Testing Game Start Notification:');
    _gameMediator.notifyGameStarted();

    print('\n🎯 2. Testing Move Recording:');
    _gameMediator.notifyMoveRecorded('e2-e4', player: 'TestPlayer');

    print('\n🎯 3. Testing Board Change:');
    _gameMediator.notifyBoardChanged();

    print('\n🎯 4. Testing Chat Message:');
    _gameMediator.sendChatMessage('Test message from BLoC!', 'BLoC');

    print('🎯 Mediator flow test completed!');
  }

  /// Get mediator status for debugging
  Map<String, dynamic> getMediatorStatus() {
    return {
      'mediator_initialized': _gameMediator != null,
      'chess_board_component': _gameMediator.chessBoard != null,
      'move_history_component': _gameMediator.moveHistory != null,
      'control_panel_component': _gameMediator.controlPanel != null,
      'chat_panel_component': _gameMediator.chatPanel != null,
      'chat_messages_count': _gameMediator.chatPanel.messages.length,
      'move_history_count': _gameMediator.moveHistory.moves.length,
      'game_over': _gameMediator.chessBoard.isGameOver(),
      'can_undo': _gameMediator.chessBoard.canUndo(),
    };
  }
}
