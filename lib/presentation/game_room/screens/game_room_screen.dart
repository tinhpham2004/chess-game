import 'package:chess_game/core/common/button/common_button.dart';
import 'package:chess_game/core/common/scaffold/common_app_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/core/patterns/builder/game_config_builder.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';
import 'package:chess_game/presentation/game_room/widgets/chess_board.dart';
import 'package:chess_game/presentation/game_room/widgets/game_over_dialog.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameRoomScreen extends StatefulWidget {
  final String gameId;
  const GameRoomScreen({required this.gameId, super.key});

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  final _gameRoomBloc = getIt.get<GameRoomBloc>();
  final _themeColor = getIt.get<AppTheme>().themeColor;

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
            _resetGame();
          },
        );
      },
    );
  }

  void _resetGame() {
    _gameRoomBloc.add(LoadGameConfigEvent(gameId: widget.gameId));
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
              body: Column(
                children: [
                  // Game info bar
                  if (gameConfig != null) _buildGameInfoBar(gameConfig),
                  // Chess board
                  Expanded(
                    child: Center(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CommonText(
            'vs $opponentType$difficulty',
            style: TextStyle(
              color: _themeColor.textPrimaryColor,
              fontWeight: AppFontWeight.medium,
            ),
          ),
          CommonText(
            'Time: ${gameConfig.timeControlMinutes} min / ${gameConfig.incrementSeconds} sec',
            style: TextStyle(
              color: _themeColor.textPrimaryColor,
              fontWeight: AppFontWeight.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls(BuildContext context, GameRoomState state) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.rem200),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CommonButton(
                text: 'Undo',
                onPressed: state.gameStarted && !state.gameEnded
                    ? () => context.read<GameRoomBloc>().add(UndoMoveEvent())
                    : null,
              ),
              CommonButton(
                text: 'Restart',
                onPressed: state.gameStarted
                    ? () => context.read<GameRoomBloc>().add(RestartGameEvent())
                    : null,
              ),
              if (state.gameEnded)
                CommonButton(
                  text: 'New Game',
                  onPressed: () =>
                      context.read<GameRoomBloc>().add(RestartGameEvent()),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.rem100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 100,
                child: CommonButton(
                  text: 'End Game (White wins)',
                  onPressed: () {
                    // For demo purposes - normally this would be triggered by the actual game state
                    _simulateGameEnd('White');
                  },
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.rem150),
                ),
              ),
              SizedBox(height: AppSpacing.rem100),
              SizedBox(
                width: 100,
                child: CommonButton(
                  text: 'End Game (Black wins)',
                  onPressed: () {
                    // For demo purposes
                    _simulateGameEnd('Black');
                  },
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.rem150),
                ),
              ),
              SizedBox(height: AppSpacing.rem100),
              SizedBox(
                width: 100,
                child: CommonButton(
                  text: 'End Game (Draw)',
                  onPressed: () {
                    // For demo purposes
                    _simulateGameEnd('Draw');
                  },
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.rem150),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
