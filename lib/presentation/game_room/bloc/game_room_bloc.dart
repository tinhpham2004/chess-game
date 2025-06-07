import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:chess_game/data/entities/match_history_entity.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';
import 'package:chess_game/data/repository/match_history_repository.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/core/models/game_room.dart';
import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/core/patterns/strategy/ai_strategy.dart';
import 'package:chess_game/core/patterns/chain_of_responsibility/move_validator.dart';
import 'package:chess_game/presentation/game_room/command/move_command.dart';
import 'package:chess_game/presentation/game_room/command/game_room_command_manager.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';
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
  ChessAIPlayer? _aiPlayer;

  GameRoomBloc(this._gameRoomRepository, this._matchHistoryRepository)
      : super(const GameRoomState()) {
    // Connect command manager with board manager
    _commandManager.setBoardManager(_boardManager);

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
    // New hint functionality events
    on<RequestHintEvent>(_onRequestHint);
    on<DismissHintEvent>(_onDismissHint);
    on<ChangeAIDifficultyEvent>(_onChangeAIDifficulty);
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

      // Initialize AI player if needed
      if (event.gameConfig.isWhitePlayerAI ||
          event.gameConfig.isBlackPlayerAI) {
        _initializeAIPlayer(event.gameConfig.aiDifficultyLevel);
      }

      // Initialize board using ChessBoardManager
      _boardManager.reset();

      // Reset command manager
      _commandManager.reset();

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
        clearHint: true,
        isWhiteKingInCheck: false,
        isBlackKingInCheck: false,
      ));

      // If white is AI, make the first move
      if (aiColor == PieceColor.white) {
        add(MakeAIMoveEvent());
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
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

    // Check if user is selecting the same piece that's hinted
    final isSelectingHintedPiece = state.showingHint &&
        state.hintFromPosition != null &&
        state.hintFromPosition == event.position;

    // Calculate possible moves for the selected piece using move validator
    // This ensures only truly legal moves are shown based on current game state
    final possibleMoves = _getPossibleMoves(piece);

    // If selecting the hinted piece, keep the hint visualization but show the piece's actual moves
    // If selecting a different piece, clear the hint completely
    if (isSelectingHintedPiece) {
      // User selected the hinted piece - show both hint and possible moves
      emit(state.copyWith(
        selectedPosition: event.position,
        possibleMoves: possibleMoves,
        // Keep the hint visible since user selected the hinted piece
      ));
    } else {
      // User selected a different piece - clear hint and show new piece's moves
      emit(state.copyWith(
        selectedPosition: event.position,
        possibleMoves: possibleMoves,
        clearHint: true, // Clear hint when selecting a different piece
      ));
    }
  }

  void _onMovePiece(MovePieceEvent event, Emitter<GameRoomState> emit) {
    if (state.gameEnded || !state.gameStarted) return;

    final piece = _getPieceAt(event.from);
    if (piece == null) return;

    // Check if move is valid
    if (!_isValidMove(piece, event.from, event.to)) return;

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

    // Check if there's a piece to capture
    final capturedPiece = _getPieceAt(event
        .to); // Execute the actual move after animation completes using command pattern
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

    // Check if either king is in check after the move
    final checkStatus = _getCheckStatus();

    emit(state.copyWith(
      board: newBoard,
      isWhitesTurn: !state.isWhitesTurn,
      possibleMoves: _createEmptyMovesMatrix(),
      clearSelectedPosition: true,
      moveHistory: newMoveHistory,
      gameEnded: isGameOver,
      winner: winner,
      clearAnimatingMove: true,
      clearHint: true, // Clear hint after any move
      isWhiteKingInCheck: checkStatus.$1,
      isBlackKingInCheck: checkStatus.$2,
      whiteAttackingPieces: checkStatus.$3,
      blackAttackingPieces: checkStatus.$4,
    ));

    // If game ended, save match history
    if (isGameOver && winner != null) {
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
  }

  void _onUndoMove(UndoMoveEvent event, Emitter<GameRoomState> emit) {
    // Use memento pattern to undo to previous board state
    if (_boardManager.canUndo) {
      try {
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
        }
      } catch (e) {
        emit(state.copyWith(errorMessage: 'Undo failed: ${e.toString()}'));
      }
    }
  }

  void _onRestartGame(RestartGameEvent event, Emitter<GameRoomState> emit) {
    if (state.gameConfig != null) {
      // Clear any intermediate state from undo operations
      _boardManager.clearHistory();
      _commandManager.reset();

      // Start a completely new game
      add(StartNewGameEvent(gameConfig: state.gameConfig!));
    }
  }

  void _onMakeAIMove(MakeAIMoveEvent event, Emitter<GameRoomState> emit) {
    if (state.gameEnded || !state.gameStarted) return;
    if (state.aiColor == null || _aiPlayer == null) return;

    final currentPlayerColor =
        state.isWhitesTurn ? PieceColor.white : PieceColor.black;
    if (state.aiColor != currentPlayerColor) return;

    try {
      // Get all pieces from board manager
      final allPieces = _boardManager.getAllPieces();

      // Use enhanced AI strategy to get the best move
      final command = _aiPlayer!.makeMove(allPieces, currentPlayerColor);

      // Execute the AI command
      _commandManager.executeCommand(command);

      // Get the move details for updating the UI
      if (command is MoveCommand) {
        final from = command.oldPosition;
        final to = command.newPosition;

        // Check if this is a special move first
        if (handleSpecialMove(from, to, emit)) {
          return; // Special move was handled
        }

        // Execute regular move on board manager
        final newBoard = _executeMove(from, to);

        // Switch turn in board manager to keep it synchronized with UI state
        _boardManager.switchTurn();

        // Save the board state after the turn is switched
        _boardManager.saveCurrentState();
        final newMoveHistory = [
          ...state.moveHistory,
          'AI: ${from.toString()}-${to.toString()}'
        ];

        // Check for game end conditions
        final isGameOver = _checkGameEnd(newBoard, !state.isWhitesTurn);
        String? winner;
        if (isGameOver) {
          winner = _determineWinner(newBoard, !state.isWhitesTurn);
        }

        // Check if either king is in check after the AI move
        final checkStatus = _getCheckStatus();

        emit(state.copyWith(
          board: newBoard,
          isWhitesTurn: !state.isWhitesTurn,
          possibleMoves: _createEmptyMovesMatrix(),
          clearSelectedPosition: true,
          moveHistory: newMoveHistory,
          gameEnded: isGameOver,
          winner: winner,
          clearHint: true, // Clear any active hints when AI moves
          isWhiteKingInCheck: checkStatus.$1,
          isBlackKingInCheck: checkStatus.$2,
          whiteAttackingPieces: checkStatus.$3,
          blackAttackingPieces: checkStatus.$4,
        ));

        // If game ended, save match history
        if (isGameOver && winner != null) {
          add(SaveMatchHistoryEvent(
            gameId: _currentGameRoom?.id ?? '',
            winner: winner,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'AI move failed: ${e.toString()}'));
    }
  }

  void _onDeselectPiece(DeselectPieceEvent event, Emitter<GameRoomState> emit) {
    emit(state.copyWith(
      clearSelectedPosition: true,
      possibleMoves: _createEmptyMovesMatrix(),
      clearHint: true, // Clear any active hint when deselecting a piece
    ));
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
          clearHint: true, // Clear hint after castling move
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
        clearHint: true, // Clear hint after promotion move
      ));
      return true;
    }

    return false;
  }

  /// Get the rook piece for castling
  ChessPiece? _getRookForCastle(Position kingFrom, Position kingTo) {
    final isKingsideCastle = kingTo.col > kingFrom.col;
    final rookCol = isKingsideCastle ? 7 : 0;
    return _getPieceAt(Position(kingFrom.row, rookCol));
  }

  /// Get the rook's original position for castling
  Position _getRookPositionForCastle(Position kingFrom, Position kingTo) {
    final isKingsideCastle = kingTo.col > kingFrom.col;
    final rookCol = isKingsideCastle ? 7 : 0;
    return Position(kingFrom.row, rookCol);
  }

  /// Get the new rook position after castling
  Position _getNewRookPositionForCastle(Position kingFrom, Position kingTo) {
    final isKingsideCastle = kingTo.col > kingFrom.col;
    final newRookCol = isKingsideCastle ? 5 : 3;
    return Position(kingFrom.row, newRookCol);
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

  /// Initialize AI player with the specified difficulty level
  void _initializeAIPlayer(int difficultyLevel) {
    AIStrategy strategy;

    switch (difficultyLevel) {
      case 1:
        strategy = RandomAIStrategy();
        break;
      case 2:
        strategy = MinimaxAIStrategy(1);
        break;
      case 3:
        strategy = MinimaxAIStrategy(2);
        break;
      case 4:
        strategy = AdvancedMinimaxAIStrategy(3);
        break;
      case 5:
        strategy = AdaptiveAIStrategy();
        break;
      default:
        strategy = RandomAIStrategy();
    }

    _aiPlayer = ChessAIPlayer(strategy);
  }

  // Event handlers for hint functionality
  void _onRequestHint(RequestHintEvent event, Emitter<GameRoomState> emit) {
    if (state.gameEnded || !state.gameStarted) return;
    if (state.aiColor != null &&
        state.isWhitesTurn == (state.aiColor == PieceColor.white)) {
      // Don't give hints to AI player
      return;
    }

    try {
      // Get all pieces from board manager
      final allPieces = _boardManager.getAllPieces();
      final currentPlayerColor =
          state.isWhitesTurn ? PieceColor.white : PieceColor.black;

      // Check if the current player's king is in check
      final isPlayerInCheck = (currentPlayerColor == PieceColor.white &&
              state.isWhiteKingInCheck) ||
          (currentPlayerColor == PieceColor.black && state.isBlackKingInCheck);

      // Step 1: Use AI strategy to get suggested moves
      AIStrategy hintStrategy;
      if (isPlayerInCheck) {
        // Use deeper search when in check to find defensive moves
        hintStrategy = AdvancedMinimaxAIStrategy(3);
      } else {
        // Use standard depth for normal play
        hintStrategy = AdvancedMinimaxAIStrategy(2);
      }

      final hintProvider = ChessAIPlayer(hintStrategy);

      // Get top AI suggested moves (not just one)
      final aiSuggestedMoves =
          hintProvider.getTopMoves(allPieces, currentPlayerColor, 5);

      // Step 2: Use move validator to ensure all suggested moves are truly legal
      final validator = _currentGameRoom?.moveValidator ??
          MoveValidatorChain.createCompleteChain();

      final validAIMoves = <Map<String, dynamic>>[];

      for (final aiMove in aiSuggestedMoves) {
        final piece = _getPieceAt(aiMove.from);
        if (piece != null &&
            validator.validate(piece, aiMove.from, aiMove.to, allPieces)) {
          validAIMoves.add({
            'piece': piece,
            'from': aiMove.from,
            'to': aiMove.to,
            'aiScore': aiMove.score.round(), // AI evaluation score
            'priority': _calculateMovePriority(
                piece, aiMove.from, aiMove.to, allPieces),
          });
        }
      }

      // Step 3: If AI didn't provide enough moves, find additional valid moves
      if (validAIMoves.length < 3) {
        final playerPieces = allPieces
            .where((piece) => piece.color == currentPlayerColor)
            .toList();

        for (final piece in playerPieces) {
          for (int row = 0; row < 8; row++) {
            for (int col = 0; col < 8; col++) {
              final targetPosition = Position(col, row);

              // Skip if it's the same position as the piece
              if (targetPosition == piece.position) continue;

              // Skip if this move is already in AI suggestions
              if (validAIMoves.any((m) =>
                  m['from'] == piece.position && m['to'] == targetPosition)) {
                continue;
              }

              // Use validator to check if move is truly legal
              if (validator.validate(
                  piece, piece.position, targetPosition, allPieces)) {
                validAIMoves.add({
                  'piece': piece,
                  'from': piece.position,
                  'to': targetPosition,
                  'aiScore': 0, // No AI evaluation for these moves
                  'priority': _calculateMovePriority(
                      piece, piece.position, targetPosition, allPieces),
                });
              }
            }
          }
        }
      }

      if (validAIMoves.isNotEmpty) {
        // Step 4: Combine AI score and priority for final ranking
        for (final move in validAIMoves) {
          final aiScore = move['aiScore'] as int;
          final priority = move['priority'] as int;

          // Weighted combination: AI score has higher weight, but priority is also important
          move['finalScore'] = (aiScore * 0.7 + priority * 0.3).round();
        }

        // Sort moves by final score (higher is better)
        validAIMoves.sort((a, b) =>
            (b['finalScore'] as int).compareTo(a['finalScore'] as int));

        // Select the best move as hint
        final bestMove = validAIMoves.first;
        final from = bestMove['from'] as Position;
        final to = bestMove['to'] as Position;

        // Clear any current selection and show hint
        emit(state.copyWith(
          hintFromPosition: from,
          hintToPosition: to,
          showingHint: true,
          clearSelectedPosition: true, // Clear any current piece selection
          possibleMoves:
              _createEmptyMovesMatrix(), // Clear current possible moves
        ));
      } else {
        // No valid moves found (shouldn't happen in normal play)
        emit(state.copyWith(errorMessage: 'No valid moves available for hint'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to get hint: ${e.toString()}'));
    }
  }

  /// Calculate move priority for hint suggestions
  /// Higher values indicate better moves
  int _calculateMovePriority(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    int priority = 0;

    // Check if move captures an opponent piece
    final capturedPiece = allPieces.where((p) => p.position == to).firstOrNull;
    if (capturedPiece != null && capturedPiece.color != piece.color) {
      // Prioritize captures based on piece value
      switch (capturedPiece.type) {
        case PieceType.queen:
          priority += 900;
          break;
        case PieceType.rook:
          priority += 500;
          break;
        case PieceType.bishop:
        case PieceType.knight:
          priority += 300;
          break;
        case PieceType.pawn:
          priority += 100;
          break;
        case PieceType.king:
          priority += 10000; // Should never happen, but highest priority
          break;
      }
    }

    // Prioritize moves that get pieces out of danger
    // Check if the piece is currently under attack
    final isCurrentlyUnderAttack =
        _isPositionUnderAttack(from, piece.color, allPieces);
    if (isCurrentlyUnderAttack) {
      priority += 200; // Bonus for moving a piece that's under attack
    }

    // Prioritize central positions
    final centerDistance = (3.5 - to.col).abs() + (3.5 - to.row).abs();
    priority += (14 - centerDistance * 2)
        .round(); // Closer to center gets higher priority

    // Small bonus for developing pieces (moving from starting positions)
    if (_isPieceInStartingPosition(piece, from)) {
      priority += 50;
    }

    return priority;
  }

  /// Check if a position is under attack by opponent pieces
  bool _isPositionUnderAttack(Position position, PieceColor defendingColor,
      List<ChessPiece> allPieces) {
    final opponentPieces = allPieces.where((p) => p.color != defendingColor);

    for (final opponent in opponentPieces) {
      // Use simple attack pattern check (without full validation to avoid recursion)
      if (_canPieceAttackPosition(
          opponent, opponent.position, position, allPieces)) {
        return true;
      }
    }
    return false;
  }

  /// Simple check if a piece can attack a position (used for hint calculation)
  bool _canPieceAttackPosition(ChessPiece piece, Position from, Position to,
      List<ChessPiece> allPieces) {
    switch (piece.type) {
      case PieceType.pawn:
        final direction = piece.color == PieceColor.white ? -1 : 1;
        final deltaRow = to.row - from.row;
        final deltaCol = (to.col - from.col).abs();
        return deltaRow == direction && deltaCol == 1;
      case PieceType.rook:
        if (from.row != to.row && from.col != to.col) return false;
        return _isPathClearForHint(from, to, allPieces);
      case PieceType.knight:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        return (deltaRow == 2 && deltaCol == 1) ||
            (deltaRow == 1 && deltaCol == 2);
      case PieceType.bishop:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        if (deltaRow != deltaCol) return false;
        return _isPathClearForHint(from, to, allPieces);
      case PieceType.queen:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        if (from.row == to.row || from.col == to.col || deltaRow == deltaCol) {
          return _isPathClearForHint(from, to, allPieces);
        }
        return false;
      case PieceType.king:
        final deltaRow = (to.row - from.row).abs();
        final deltaCol = (to.col - from.col).abs();
        return deltaRow <= 1 && deltaCol <= 1;
    }
  }

  /// Simple path clear check for hint calculation
  bool _isPathClearForHint(
      Position from, Position to, List<ChessPiece> allPieces) {
    final deltaRow = to.row - from.row;
    final deltaCol = to.col - from.col;
    final steps =
        deltaRow.abs() > deltaCol.abs() ? deltaRow.abs() : deltaCol.abs();

    if (steps <= 1) return true;

    final rowStep = deltaRow != 0 ? deltaRow ~/ deltaRow.abs() : 0;
    final colStep = deltaCol != 0 ? deltaCol ~/ deltaCol.abs() : 0;

    for (int i = 1; i < steps; i++) {
      final checkPos =
          Position(from.col + (colStep * i), from.row + (rowStep * i));
      if (allPieces.any((p) => p.position == checkPos)) {
        return false;
      }
    }
    return true;
  }

  /// Check if a piece is in its starting position
  bool _isPieceInStartingPosition(ChessPiece piece, Position position) {
    switch (piece.type) {
      case PieceType.pawn:
        return (piece.color == PieceColor.white && position.row == 6) ||
            (piece.color == PieceColor.black && position.row == 1);
      case PieceType.rook:
        return (piece.color == PieceColor.white &&
                position.row == 7 &&
                (position.col == 0 || position.col == 7)) ||
            (piece.color == PieceColor.black &&
                position.row == 0 &&
                (position.col == 0 || position.col == 7));
      case PieceType.knight:
        return (piece.color == PieceColor.white &&
                position.row == 7 &&
                (position.col == 1 || position.col == 6)) ||
            (piece.color == PieceColor.black &&
                position.row == 0 &&
                (position.col == 1 || position.col == 6));
      case PieceType.bishop:
        return (piece.color == PieceColor.white &&
                position.row == 7 &&
                (position.col == 2 || position.col == 5)) ||
            (piece.color == PieceColor.black &&
                position.row == 0 &&
                (position.col == 2 || position.col == 5));
      case PieceType.queen:
        return (piece.color == PieceColor.white &&
                position.row == 7 &&
                position.col == 3) ||
            (piece.color == PieceColor.black &&
                position.row == 0 &&
                position.col == 3);
      case PieceType.king:
        return (piece.color == PieceColor.white &&
                position.row == 7 &&
                position.col == 4) ||
            (piece.color == PieceColor.black &&
                position.row == 0 &&
                position.col == 4);
    }
  }

  void _onDismissHint(DismissHintEvent event, Emitter<GameRoomState> emit) {
    emit(state.copyWith(
      clearHint: true,
      clearSelectedPosition: true, // Also clear any piece selection
      possibleMoves: _createEmptyMovesMatrix(), // Clear possible moves
    ));
  }

  void _onChangeAIDifficulty(
      ChangeAIDifficultyEvent event, Emitter<GameRoomState> emit) {
    _initializeAIPlayer(event.difficultyLevel);

    // Update game config if available
    if (state.gameConfig != null) {
      final updatedConfig = state.gameConfig!.clone(
        aiDifficultyLevel: event.difficultyLevel,
      );
      emit(state.copyWith(gameConfig: updatedConfig));
    }
  }

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

    // Get all pieces from the board manager
    final allPieces = _boardManager.getAllPieces();

    // Always use the move validator to get valid moves that consider the current chess match state
    // This includes checks, pins, castling restrictions, and other chess rules
    if (_currentGameRoom?.moveValidator != null) {
      final validator = _currentGameRoom!.moveValidator;

      // Check all possible positions on the board using the complete validation chain
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final targetPosition = Position(col, row);

          // Skip if it's the same position as the piece
          if (targetPosition == piece.position) continue;

          // Validate the move using the complete validation chain
          // This ensures we only show moves that are truly legal in the current game state
          if (validator.validate(
              piece, piece.position, targetPosition, allPieces)) {
            moves[row][col] = true;
          }
        }
      }
    } else {
      // Create a fallback validator if gameRoom validator is not available
      // This ensures we always validate moves properly even in edge cases
      final fallbackValidator = MoveValidatorChain.createCompleteChain();

      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final targetPosition = Position(col, row);

          // Skip if it's the same position as the piece
          if (targetPosition == piece.position) continue;

          // Use fallback validator with complete validation chain
          if (fallbackValidator.validate(
              piece, piece.position, targetPosition, allPieces)) {
            moves[row][col] = true;
          }
        }
      }
    }

    return moves;
  }

  bool _isValidMove(ChessPiece piece, Position from, Position to) {
    // Get all pieces from the board manager
    final allPieces = _boardManager.getAllPieces();

    // Use the move validator for proper validation that considers all chess rules
    if (_currentGameRoom?.moveValidator != null) {
      return _currentGameRoom!.moveValidator
          .validate(piece, from, to, allPieces);
    } else {
      // Create a fallback validator if gameRoom validator is not available
      final fallbackValidator = MoveValidatorChain.createCompleteChain();
      return fallbackValidator.validate(piece, from, to, allPieces);
    }
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

  /// Update check status for both kings and get attacking pieces
  (
    bool whiteInCheck,
    bool blackInCheck,
    List<Position> whiteAttackers,
    List<Position> blackAttackers
  ) _getCheckStatus() {
    final allPieces = _boardManager.getAllPieces();
    final kingSafetyValidator = KingSafetyValidator();

    final whiteInCheck =
        kingSafetyValidator.isKingInCheck(PieceColor.white, allPieces);
    final blackInCheck =
        kingSafetyValidator.isKingInCheck(PieceColor.black, allPieces);

    final whiteAttackers = whiteInCheck
        ? kingSafetyValidator.getAttackingPiecesPositions(
            PieceColor.white, allPieces)
        : <Position>[];
    final blackAttackers = blackInCheck
        ? kingSafetyValidator.getAttackingPiecesPositions(
            PieceColor.black, allPieces)
        : <Position>[];

    return (whiteInCheck, blackInCheck, whiteAttackers, blackAttackers);
  }
}
