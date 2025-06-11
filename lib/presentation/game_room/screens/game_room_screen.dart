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
import 'package:chess_game/theme/font/app_font_size.dart';
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
                title: 'Chess Game',
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: AppSpacing.rem150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _themeColor.primaryColor.withOpacity(0.1),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: _themeColor.primaryColor,
                      ),
                      onPressed: () {
                        // Show game settings dialog
                      },
                      tooltip: 'Game Settings',
                    ),
                  ),
                ],
              ),
              backgroundColor: _themeColor.backgroundColor,
              isLoading: gameConfig == null,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _themeColor.surfaceColor.withOpacity(0.3),
                      _themeColor.backgroundColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Timer display - fixed at top
                      if (gameConfig != null &&
                          gameConfig.timeControlMinutes > 0)
                        _buildTimerSection(),

                      // Chess board - maximized
                      Expanded(
                        child: _buildChessBoard(),
                      ),

                      // Game controls - simple horizontal layout
                      _buildGameControls(
                          context, context.read<GameRoomBloc>().state),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return const ChessTimer();
  }

  Widget _buildChessBoard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.rem150),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: const ChessBoard(),
      ),
    );
  }

  Widget _buildGameControls(BuildContext context, GameRoomState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main game controls - horizontal row
        Padding(
          padding: EdgeInsets.all(AppSpacing.rem200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildControlButtons(context, state),
          ),
        ),

        // Debug controls - show in debug mode
        // if (kDebugMode) ...[
        //   SizedBox(height: AppSpacing.rem200),
        //   _buildDebugControls(),
        // ],
      ],
    );
  }

  List<Widget> _buildControlButtons(BuildContext context, GameRoomState state) {
    return [
      Expanded(
        child: _buildModernControlButton(
          'Undo',
          Icons.undo,
          state.gameStarted && !state.gameEnded
              ? () => context.read<GameRoomBloc>().add(UndoMoveEvent())
              : null,
          color: Colors.orange,
        ),
      ),
      SizedBox(width: AppSpacing.rem100),
      Expanded(
        child: _buildModernControlButton(
          state.showingHint ? 'Hide Hint' : 'Hint',
          state.showingHint ? Icons.visibility_off : Icons.lightbulb,
          state.gameStarted && !state.gameEnded && !state.showingHint
              ? () => context.read<GameRoomBloc>().add(RequestHintEvent())
              : state.showingHint
                  ? () => context.read<GameRoomBloc>().add(DismissHintEvent())
                  : null,
          color: Colors.blue,
        ),
      ),
      SizedBox(width: AppSpacing.rem100),
      Expanded(
        child: _buildModernControlButton(
          'Restart',
          Icons.refresh,
          state.gameStarted
              ? () => context.read<GameRoomBloc>().add(RestartGameEvent())
              : null,
          color: Colors.green,
        ),
      ),
      if (state.gameEnded) ...[
        SizedBox(width: AppSpacing.rem100),
        Expanded(
          child: _buildModernControlButton(
            'New Game',
            Icons.add,
            () => context.read<GameRoomBloc>().add(RestartGameEvent()),
            color: _themeColor.primaryColor,
          ),
        ),
      ],
    ];
  }

  Widget _buildModernControlButton(
      String text, IconData icon, VoidCallback? onPressed,
      {required Color color}) {
    final isEnabled = onPressed != null;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isEnabled
            ? color.withOpacity(0.1)
            : _themeColor.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? color.withOpacity(0.3)
              : _themeColor.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.rem100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? color : _themeColor.textSecondaryColor,
                  size: 20,
                ),
                SizedBox(height: AppSpacing.rem050),
                CommonText(
                  text,
                  style: TextStyle(
                    fontSize: AppFontSize.sm,
                    fontWeight: AppFontWeight.medium,
                    color: isEnabled ? color : _themeColor.textSecondaryColor,
                  ),
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebugControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.rem200),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report,
                color: Colors.red,
                size: 20,
              ),
              SizedBox(width: AppSpacing.rem100),
              CommonText(
                'Debug Controls',
                style: TextStyle(
                  fontSize: AppFontSize.md,
                  fontWeight: AppFontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.rem150),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: _buildDebugButton(
                      'White Wins', () => _simulateGameEnd('White'))),
              SizedBox(width: AppSpacing.rem100),
              Expanded(
                  child: _buildDebugButton(
                      'Black Wins', () => _simulateGameEnd('Black'))),
              SizedBox(width: AppSpacing.rem100),
              Expanded(
                  child: _buildDebugButton(
                      'Draw', () => _simulateGameEnd('Draw'))),
            ],
          ),
          SizedBox(height: AppSpacing.rem100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: _buildDebugButton(
                      'Clone Game', () => _createNewGameFromPrototype())),
              SizedBox(width: AppSpacing.rem100),
              Expanded(
                  child: _buildDebugButton(
                      'Swap Colors', () => _createNewGameWithSwappedColors())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton(String text, VoidCallback onPressed) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: CommonText(
              text,
              style: TextStyle(
                fontSize: AppFontSize.xs,
                fontWeight: AppFontWeight.medium,
                color: Colors.red,
              ),
              align: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
