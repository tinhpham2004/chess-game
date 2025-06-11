import 'package:chess_game/core/common/button/common_button.dart';
import 'package:chess_game/core/common/scaffold/common_app_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';
import 'package:chess_game/presentation/game_room/widgets/chess_board.dart';
import 'package:chess_game/presentation/game_room/widgets/chess_timer.dart';
import 'package:chess_game/presentation/game_room/widgets/game_over_dialog.dart';
import 'package:chess_game/presentation/game_room/widgets/promotion_dialog.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

class GameRoomScreen extends StatefulWidget {
  final String gameId;
  const GameRoomScreen({required this.gameId, super.key});

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  final _gameRoomBloc = getIt.get<GameRoomBloc>();
  final _gameRoomRepository = getIt.get<GameRoomRepository>();
  final _themeColor = getIt.get<AppTheme>().themeColor;
  bool _isPromotionDialogShowing = false;
  bool _isGameOverDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _loadGameRoom();
  }

  Future<void> _loadGameRoom() async {
    _gameRoomBloc.add(LoadGameConfigEvent(gameId: widget.gameId));
  }

  void _simulateGameEnd(String winner) async {
    _gameRoomBloc.add(SaveMatchHistoryEvent(
      gameId: widget.gameId,
      winner: winner,
    ));

    _showGameEndDialog(context, winner);
  }

  void _showGameEndDialog(BuildContext context, String winner) {
    final state = _gameRoomBloc.state;
    final gameConfig = state.gameConfig;
    final isAiOpponent = gameConfig != null &&
        (gameConfig.isWhitePlayerAI || gameConfig.isBlackPlayerAI);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameOverDialog(
          result: winner,
          isAiOpponent: isAiOpponent,
          aiDifficulty: isAiOpponent ? gameConfig.aiDifficultyLevel : null,
          onPlayAgain: () {
            Navigator.of(context).pop();
            _isGameOverDialogShowing = false;
            // Use Prototype pattern to create new game from current config
            _createNewGameFromPrototype();
          },
        );
      },
    ).then((_) {
      // Reset flag when dialog is dismissed
      _isGameOverDialogShowing = false;
    });
  }

  void _resetGame() {
    _gameRoomBloc.add(LoadGameConfigEvent(gameId: widget.gameId));
  }

  /// Create a new game using Prototype pattern to clone the current configuration
  ///
  /// This method demonstrates the Prototype design pattern by:
  /// 1. Using the existing GameConfig's clone() method to create a deep copy
  /// 2. Creating a new game room entity with a unique ID
  /// 3. Saving the new configuration to the repository
  /// 4. Starting a new game with the cloned configuration
  ///
  /// This is similar to how _buildDemoControls works for simulating game ends,
  /// but instead creates new games with cloned configurations.
  ///
  /// The Prototype pattern allows us to:
  /// - Create new objects by copying existing instances
  /// - Avoid the overhead of re-setting all configuration parameters
  /// - Maintain consistency with the previous game's settings
  /// - Enable easy variations (like color swapping) of existing configurations
  Future<void> _createNewGameFromPrototype() async {
    final state = _gameRoomBloc.state;
    final currentConfig = state.gameConfig;

    if (currentConfig == null) {
      print('No current config available for cloning');
      return;
    }

    try {
      // Use Prototype pattern to clone the current game configuration
      // This creates a deep copy of the existing configuration
      final clonedConfig = currentConfig.clone();

      print('Prototype Pattern: Cloned config from existing game');
      print('Original config: ${currentConfig.toJson()}');
      print('Cloned config: ${clonedConfig.toJson()}');

      // Generate a new unique game ID for the cloned game
      final newGameId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new game room entity with the cloned configuration
      final gameRoom = GameRoomEntity(
        id: newGameId,
        json: jsonEncode({
          'gameConfig': jsonDecode(clonedConfig.toJson()),
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      // Save the new game room to repository
      await _gameRoomRepository.saveGameRoom(gameRoom);

      print('Prototype Pattern: Created new game room with ID: $newGameId');

      // Start the new game with the cloned configuration
      _gameRoomBloc.add(StartNewGameEvent(gameConfig: clonedConfig));
    } catch (e) {
      print('Error creating new game from prototype: $e');
      // Fallback to the original reset method
      _resetGame();
    }
  }

  /// Alternative: Create a new game with swapped colors (for variety)
  ///
  /// This demonstrates another use of the Prototype pattern with modification:
  /// 1. Clone the existing configuration using the Prototype pattern
  /// 2. Apply a modification (swap player colors) using the withSwappedColors() method
  /// 3. Create and save a new game room with the modified configuration
  ///
  /// This shows how the Prototype pattern can be extended to create variations
  /// of existing objects, not just exact copies. The withSwappedColors() method
  /// is itself an implementation of the Prototype pattern that creates a modified clone.
  Future<void> _createNewGameWithSwappedColors() async {
    final state = _gameRoomBloc.state;
    final currentConfig = state.gameConfig;

    if (currentConfig == null) {
      print('No current config available for cloning');
      return;
    }

    try {
      // Use Prototype pattern with modification - swap the player colors
      final clonedConfigWithSwappedColors = currentConfig.withSwappedColors();

      print('Prototype Pattern: Created config with swapped colors');
      print('Original config: ${currentConfig.toJson()}');
      print('Modified config: ${clonedConfigWithSwappedColors.toJson()}');

      // Generate a new unique game ID
      final newGameId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new game room entity
      final gameRoom = GameRoomEntity(
        id: newGameId,
        json: jsonEncode({
          'gameConfig': jsonDecode(clonedConfigWithSwappedColors.toJson()),
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      // Save to repository
      await _gameRoomRepository.saveGameRoom(gameRoom);

      // Start the new game
      _gameRoomBloc
          .add(StartNewGameEvent(gameConfig: clonedConfigWithSwappedColors));
    } catch (e) {
      print('Error creating new game with swapped colors: $e');
      // Fallback to normal clone
      _createNewGameFromPrototype();
    }
  }

  void _showPromotionDialog(BuildContext context, GameRoomState state) {
    if (_isPromotionDialogShowing) return; // Prevent multiple dialogs

    _isPromotionDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PromotionDialog(
          pawnColor: state.promotionPawn!.color,
          onPieceSelected: (pieceType) {
            Navigator.of(context).pop();
            _isPromotionDialogShowing = false;
            _gameRoomBloc.add(SelectPromotionPieceEvent(pieceType: pieceType));
          },
        );
      },
    ).then((_) {
      // Reset flag when dialog is dismissed (shouldn't happen due to barrierDismissible: false, but good for safety)
      _isPromotionDialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameRoomBloc>(
      create: (context) => _gameRoomBloc,
      child: BlocListener<GameRoomBloc, GameRoomState>(
        listener: (context, state) {
          // Auto-start a new game when config is loaded and game hasn't started yet
          if (state.gameConfig != null &&
              !state.gameStarted &&
              !state.loading &&
              state.errorMessage == null) {
            context
                .read<GameRoomBloc>()
                .add(StartNewGameEvent(gameConfig: state.gameConfig!));
          }

          // Show promotion dialog when needed (only if not already showing)
          if (state.showingPromotionDialog &&
              state.promotionFromPosition != null &&
              state.promotionToPosition != null &&
              state.promotionPawn != null &&
              !_isPromotionDialogShowing) {
            _showPromotionDialog(context, state);
          } // Show game over dialog when game ends (only if not already showing)
          if (state.gameEnded &&
              state.winner != null &&
              !_isGameOverDialogShowing) {
            print(
                '🎯 GAME_OVER_DIALOG: Game ended detected! Winner: ${state.winner}');
            _isGameOverDialogShowing = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print(
                  '🎯 GAME_OVER_DIALOG: Showing game end dialog for winner: ${state.winner}');
              _showGameEndDialog(context, state.winner!);
            });
          }
        },
        child: BlocSelector<GameRoomBloc, GameRoomState, GameConfig?>(
          selector: (state) => state.gameConfig,
          builder: (context, gameConfig) {
            return CommonScaffold(
              appBar: CommonAppBar(
                title: 'Game: ${widget.gameId}',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Show game settings dialog
                    },
                  ),
                ],
              ),
              backgroundColor: _themeColor.backgroundColor,
              isLoading: gameConfig == null,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          AppBar().preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Game info bar
                        if (gameConfig != null) _buildGameInfoBar(gameConfig),

                        // Timer display
                        if (gameConfig != null &&
                            gameConfig.timeControlMinutes > 0)
                          const ChessTimer(),

                        // Chess board - responsive sizing
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 600, // Maximum width for larger screens
                            maxHeight: 600, // Maximum height
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.rem100),
                              child: const ChessBoard(),
                            ),
                          ),
                        ),

                        // Game controls
                        _buildGameControls(
                            context, context.read<GameRoomBloc>().state),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameInfoBar(GameConfig gameConfig) {
    final isAiGame = gameConfig.isWhitePlayerAI || gameConfig.isBlackPlayerAI;

    final opponentType = isAiGame ? 'AI' : 'Friend';
    final difficulty =
        isAiGame ? ' (Level: ${gameConfig.aiDifficultyLevel})' : '';

    return Container(
      padding: EdgeInsets.all(AppSpacing.rem100),
      color: _themeColor.secondaryColor.withOpacity(0.2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use column layout for smaller screens to prevent overflow
          if (constraints.maxWidth < 400) {
            return Column(
              children: [
                CommonText(
                  'vs $opponentType$difficulty',
                  style: TextStyle(
                    color: _themeColor.textPrimaryColor,
                    fontWeight: AppFontWeight.medium,
                  ),
                  align: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.rem050),
                CommonText(
                  'Time: ${gameConfig.timeControlMinutes} min / ${gameConfig.incrementSeconds} sec',
                  style: TextStyle(
                    color: _themeColor.textPrimaryColor,
                    fontWeight: AppFontWeight.medium,
                  ),
                  align: TextAlign.center,
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: CommonText(
                    'vs $opponentType$difficulty',
                    style: TextStyle(
                      color: _themeColor.textPrimaryColor,
                      fontWeight: AppFontWeight.medium,
                    ),
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: CommonText(
                    'Time: ${gameConfig.timeControlMinutes} min / ${gameConfig.incrementSeconds} sec',
                    style: TextStyle(
                      color: _themeColor.textPrimaryColor,
                      fontWeight: AppFontWeight.medium,
                    ),
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildGameControls(BuildContext context, GameRoomState state) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.rem200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main game controls - responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              // Use wrap for smaller screens, row for larger screens
              if (constraints.maxWidth < 600) {
                return Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: AppSpacing.rem100,
                  runSpacing: AppSpacing.rem100,
                  children: [
                    _buildControlButton(
                      'Undo',
                      state.gameStarted && !state.gameEnded
                          ? () =>
                              context.read<GameRoomBloc>().add(UndoMoveEvent())
                          : null,
                    ),
                    _buildControlButton(
                      state.showingHint ? 'Hide Hint' : 'Hint',
                      state.gameStarted &&
                              !state.gameEnded &&
                              !state.showingHint
                          ? () => context
                              .read<GameRoomBloc>()
                              .add(RequestHintEvent())
                          : state.showingHint
                              ? () => context
                                  .read<GameRoomBloc>()
                                  .add(DismissHintEvent())
                              : null,
                    ),
                    _buildControlButton(
                      'Restart',
                      state.gameStarted
                          ? () => context
                              .read<GameRoomBloc>()
                              .add(RestartGameEvent())
                          : null,
                    ),
                    if (state.gameEnded)
                      _buildControlButton(
                        'New Game',
                        () => context
                            .read<GameRoomBloc>()
                            .add(RestartGameEvent()),
                      ),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: _buildControlButton(
                        'Undo',
                        state.gameStarted && !state.gameEnded
                            ? () => context
                                .read<GameRoomBloc>()
                                .add(UndoMoveEvent())
                            : null,
                      ),
                    ),
                    SizedBox(width: AppSpacing.rem100),
                    Flexible(
                      child: _buildControlButton(
                        state.showingHint ? 'Hide Hint' : 'Hint',
                        state.gameStarted &&
                                !state.gameEnded &&
                                !state.showingHint
                            ? () => context
                                .read<GameRoomBloc>()
                                .add(RequestHintEvent())
                            : state.showingHint
                                ? () => context
                                    .read<GameRoomBloc>()
                                    .add(DismissHintEvent())
                                : null,
                      ),
                    ),
                    SizedBox(width: AppSpacing.rem100),
                    Flexible(
                      child: _buildControlButton(
                        'Restart',
                        state.gameStarted
                            ? () => context
                                .read<GameRoomBloc>()
                                .add(RestartGameEvent())
                            : null,
                      ),
                    ),
                    if (state.gameEnded) ...[
                      SizedBox(width: AppSpacing.rem100),
                      Flexible(
                        child: _buildControlButton(
                          'New Game',
                          () => context
                              .read<GameRoomBloc>()
                              .add(RestartGameEvent()),
                        ),
                      ),
                    ],
                  ],
                );
              }
            },
          ),

          // Demo controls - only show in debug mode
          // if (kDebugMode) ..._buildDemoControls(),
        ],
      ),
    );
  }

  Widget _buildControlButton(String text, VoidCallback? onPressed) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 150,
      ),
      child: CommonButton(
        text: text,
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.rem150,
          horizontal: AppSpacing.rem100,
        ),
      ),
    );
  }

  List<Widget> _buildDemoControls() {
    return [
      SizedBox(height: AppSpacing.rem200),
      CommonText(
        'Demo Controls (Debug Mode)',
        style: TextStyle(
          fontSize: 12,
          color: _themeColor.textSecondaryColor,
        ),
      ),
      SizedBox(height: AppSpacing.rem100),
      Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: AppSpacing.rem100,
        runSpacing: AppSpacing.rem100,
        children: [
          SizedBox(
            width: 120,
            child: CommonButton(
              text: 'White Wins',
              onPressed: () => _simulateGameEnd('White'),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.rem100),
            ),
          ),
          SizedBox(
            width: 120,
            child: CommonButton(
              text: 'Black Wins',
              onPressed: () => _simulateGameEnd('Black'),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.rem100),
            ),
          ),
          SizedBox(
            width: 120,
            child: CommonButton(
              text: 'Draw',
              onPressed: () => _simulateGameEnd('Draw'),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.rem100),
            ),
          ),
          SizedBox(
            width: 120,
            child: CommonButton(
              text: 'Clone Game',
              onPressed: () => _createNewGameFromPrototype(),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.rem100),
            ),
          ),
          SizedBox(
            width: 120,
            child: CommonButton(
              text: 'Swap Colors',
              onPressed: () => _createNewGameWithSwappedColors(),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.rem100),
            ),
          ),
        ],
      ),
    ];
  }
}
