import 'package:chess_game/core/common/button/common_button.dart';
import 'package:chess_game/core/common/scaffold/common_app_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';
import 'package:chess_game/presentation/game_room/widgets/chess_board.dart';
import 'package:chess_game/presentation/game_room/widgets/game_over_dialog.dart';

import 'package:chess_game/presentation/game_room/widgets/control_panel.dart';
import 'package:chess_game/presentation/game_room/widgets/move_history.dart';
import 'package:chess_game/presentation/game_room/widgets/chat_panel.dart';

import 'package:chess_game/presentation/game_room/services/piece_asset_service.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    debugPrint('🎯 Loading game room: ${widget.gameId}');
    _gameRoomBloc.add(LoadGameConfigEvent(gameId: widget.gameId));
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

  void _showGameInfo(BuildContext context, GameRoomState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Game ID: ${widget.gameId}'),
              SizedBox(height: 8),
              if (state.gameConfig != null) ...[
                Text('Time Control: ${state.gameConfig!.timeControlMinutes} min'),
                Text('Increment: ${state.gameConfig!.incrementSeconds} sec'),
                Text('White Player: ${state.gameConfig!.isWhitePlayerAI ? "AI" : "Human"}'),
                Text('Black Player: ${state.gameConfig!.isBlackPlayerAI ? "AI" : "Human"}'),
                if (state.gameConfig!.isWhitePlayerAI || state.gameConfig!.isBlackPlayerAI)
                  Text('AI Difficulty: ${state.gameConfig!.aiDifficultyLevel}'),
              ],
              SizedBox(height: 8),
              Text('Moves played: ${state.moveHistory.length}'),
              Text('Current turn: ${state.isWhitesTurn ? "White" : "Black"}'),
              if (state.gameEnded)
                Text('Winner: ${state.winner ?? "Draw"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameRoomBloc>(
      create: (context) => _gameRoomBloc,
      child: BlocListener<GameRoomBloc, GameRoomState>(
        listener: (context, state) {
          debugPrint('🎯 GameRoom State changed: loading=${state.loading}, started=${state.gameStarted}');
          
          // Auto-start a new game when config is loaded and game hasn't started yet
          if (state.gameConfig != null &&
              !state.gameStarted &&
              !state.loading &&
              state.errorMessage == null) {
            debugPrint('🎯 Auto-starting new game');
            context.read<GameRoomBloc>().add(StartNewGameEvent(gameConfig: state.gameConfig!));
          }

          // Handle game end
          if (state.gameEnded && state.winner != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showGameEndDialog(context, state.winner!);
            });
          }
        },
        child: BlocBuilder<GameRoomBloc, GameRoomState>(
          builder: (context, state) {
            debugPrint('🎯 Building GameRoom UI: loading=${state.loading}, error=${state.errorMessage}');
            
            if (state.loading) {
              return Scaffold(
                appBar: AppBar(title: Text('Loading Game...')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading game room...'),
                    ],
                  ),
                ),
              );
            }

            if (state.errorMessage != null) {
              return Scaffold(
                appBar: AppBar(title: Text('Error')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: ${state.errorMessage}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadGameRoom(),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text('Chess Game - ${widget.gameId}'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () => _showGameInfo(context, state),
                  ),
                ],
              ),
              body: _buildGameLayout(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameLayout(BuildContext context, GameRoomState state) {
    debugPrint('🎯 Building game layout with mediator: ${_gameRoomBloc.gameMediator != null}');
    
    // Thêm debug info
    if (_gameRoomBloc.gameMediator == null) {
      debugPrint('🚨 ERROR: Mediator is null!');
      return Center(child: Text('Mediator not initialized'));
    }
    
    debugPrint('🎯 Mediator components: '
      'moveHistory=${_gameRoomBloc.gameMediator.moveHistory != null}, '
      'chatPanel=${_gameRoomBloc.gameMediator.chatPanel != null}');
    
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint('🎯 Screen constraints: ${constraints.maxWidth}x${constraints.maxHeight}');
        
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(context, state);
        } else {
          return _buildMobileLayout(context, state);
        }
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, GameRoomState state) {
    return Row(
      children: [
        // Left panel: Move History & Chat
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.rem150),
            child: Column(
              children: [
                // Move History
                Expanded(
                  flex: 1,
                  child: _buildMoveHistorySection(),
                ),
                SizedBox(height: AppSpacing.rem150),
                // Chat Panel
                Expanded(
                  flex: 1,
                  child: _buildChatPanelSection(),
                ),
              ],
            ),
          ),
        ),

        // Center: Chess Board
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Game status
              _buildGameStatus(state),

              // Chess Board
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.rem150),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildChessBoard(state),
                    ),
                  ),
                ),
              ),

              // Control Panel
              Padding(
                padding: EdgeInsets.all(AppSpacing.rem150),
                child: _buildControlPanelSection(),
              ),
            ],
          ),
        ),

        // Right panel: Game info hoặc để trống
        Expanded(
          flex: 1,
          child: Container(
            color: _themeColor.surfaceColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.rem150),
                  child: Text(
                    'Game Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _themeColor.textPrimaryColor,
                    ),
                  ),
                ),
                // Có thể thêm thông tin game khác ở đây
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, GameRoomState state) {
    return Column(
      children: [
        // Game status
        _buildGameStatus(state),

        // Chess Board
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.rem150),
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildChessBoard(state),
            ),
          ),
        ),

        // Control Panel
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.rem150),
          child: _buildControlPanelSection(),
        ),

        // Move History & Chat in tabs
        Expanded(
          flex: 2,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: _themeColor.primaryColor,
                  unselectedLabelColor: _themeColor.textSecondaryColor,
                  tabs: [
                    Tab(text: 'Moves'),
                    Tab(text: 'Chat'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.rem100),
                        child: _buildMoveHistorySection(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.rem100),
                        child: _buildChatPanelSection(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Helper methods để build sections
  Widget _buildMoveHistorySection() {
    return BlocBuilder<GameRoomBloc, GameRoomState>(
      builder: (context, state) {
        try {
          return MoveHistoryWidget(
            component: _gameRoomBloc.gameMediator.moveHistory,
          );
        } catch (e) {
          debugPrint('🚨 Error building MoveHistory: $e');
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('Move History\n(Error: $e)', textAlign: TextAlign.center),
            ),
          );
        }
      },
    );
  }

  Widget _buildChatPanelSection() {
    return BlocBuilder<GameRoomBloc, GameRoomState>(
      builder: (context, state) {
        try {
          return ChatPanelWidget(
            component: _gameRoomBloc.gameMediator.chatPanel,
          );
        } catch (e) {
          debugPrint('🚨 Error building ChatPanel: $e');
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('Chat Panel\n(Error: $e)', textAlign: TextAlign.center),
            ),
          );
        }
      },
    );
  }

  Widget _buildControlPanelSection() {
    return BlocBuilder<GameRoomBloc, GameRoomState>(
      builder: (context, state) {
        try {
          return ControlPanelWidget(
            component: _gameRoomBloc.gameMediator.controlPanel,
          );
        } catch (e) {
          debugPrint('🚨 Error building ControlPanel: $e');
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Control Panel (Error: $e)', textAlign: TextAlign.center),
          );
        }
      },
    );
  }

  Widget _buildGameStatus(GameRoomState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.rem150),
      decoration: BoxDecoration(
        color: _themeColor.primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: _themeColor.borderColor),
        ),
      ),
      child: Column(
        children: [
          Text(
            state.gameEnded
                ? 'Game Over - ${state.winner ?? "Draw"}!'
                : '${state.isWhitesTurn ? "White" : "Black"}\'s Turn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _themeColor.textPrimaryColor,
            ),
          ),
          if (state.gameConfig != null) ...[
            SizedBox(height: AppSpacing.rem100),
            Text(
              'White: ${state.gameConfig!.isWhitePlayerAI ? "AI" : "Human"} | '
              'Black: ${state.gameConfig!.isBlackPlayerAI ? "AI" : "Human"}',
              style: TextStyle(
                color: _themeColor.textSecondaryColor,
              ),
            ),
          ],
          if (!state.gameStarted && state.gameConfig != null) ...[
            SizedBox(height: AppSpacing.rem100),
            Text(
              'Starting game...',
              style: TextStyle(
                color: _themeColor.secondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChessBoard(GameRoomState state) {
    try {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: _themeColor.borderColor, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.rem100),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.rem075),
          child: ChessBoard(),
        ),
      );
    } catch (e) {
      debugPrint('🚨 Error building ChessBoard: $e');
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('Chess Board\n(Error: $e)', textAlign: TextAlign.center),
        ),
      );
    }
  }
}
