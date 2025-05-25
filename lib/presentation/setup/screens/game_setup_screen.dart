import 'package:chess_game/core/common/button/common_button.dart';
import 'package:chess_game/core/common/scaffold/common_app_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/core/patterns/builder/game_config_builder.dart';
import 'package:chess_game/router/app_router.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class GameSetupScreen extends StatefulWidget {
  final bool isAIOpponent;
  final int? aiDifficulty;

  const GameSetupScreen({
    required this.isAIOpponent,
    this.aiDifficulty,
    super.key,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final _gameRoomRepository = getIt.get<GameRoomRepository>();
  final _configDirector = getIt.get<GameConfigDirector>();
  final _themeColor = getIt.get<AppTheme>().themeColor;

  // Game configuration settings
  bool _playAsWhite = true;
  int _timeControlMinutes = 10;
  int _incrementSeconds = 5;

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Intermediate';
    }
  }

  Widget _buildColorOption(String label, bool isWhite) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _playAsWhite = isWhite;
        });
      },
      child: Container(
        width: 120,
        padding: EdgeInsets.all(AppSpacing.rem200),
        decoration: BoxDecoration(
          color: _playAsWhite == isWhite ? _themeColor.primaryColor.withOpacity(0.3) : _themeColor.backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _playAsWhite == isWhite ? _themeColor.primaryColor : _themeColor.borderColor,
            width: 2,
          ),
          boxShadow: _playAsWhite == isWhite
              ? [
                  BoxShadow(
                    color: _themeColor.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isWhite ? Colors.white : Colors.black,
                border: Border.all(
                  color: _themeColor.borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.rem100),
            CommonText(
              label,
              style: TextStyle(
                fontWeight: _playAsWhite == isWhite ? AppFontWeight.bold : AppFontWeight.regular,
                color: _themeColor.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGameAndNavigate() async {
    // Create game configuration
    final gameConfig = _configDirector.createCustomConfig(
      minutes: _timeControlMinutes,
      increment: _incrementSeconds,
      isWhiteAI: widget.isAIOpponent && !_playAsWhite,
      isBlackAI: widget.isAIOpponent && _playAsWhite,
      aiLevel: widget.aiDifficulty ?? 3,
      boardTheme: 'classic',
      pieceSet: 'standard',
      soundEnabled: true,
    );

    // Generate unique game id
    final gameId = DateTime.now().millisecondsSinceEpoch.toString(); // Create game room model
    final gameRoom = GameRoomEntity(
      id: gameId,
      json: jsonEncode({
        'gameConfig': jsonDecode(gameConfig.toJson()), // Parse the JSON string to a Map
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );

    // Save to repository
    await _gameRoomRepository.saveGameRoom(gameRoom);

    // Navigate to game room
    if (mounted) {
      AppRouter.push(AppRouter.gameRoomScreen, params: gameId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String opponentType = widget.isAIOpponent ? 'AI' : 'Friend';

    return CommonScaffold(
      appBar: CommonAppBar(
        title: 'Game Setup - vs $opponentType',
      ),
      backgroundColor: _themeColor.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _themeColor.surfaceColor,
              _themeColor.backgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.rem300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Center(
                child: CommonText(
                  'Configure Your Game',
                  style: TextStyle(
                    fontSize: AppFontSize.xxl,
                    fontWeight: AppFontWeight.bold,
                    color: _themeColor.textPrimaryColor,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.rem300),

              // Piece color selection
              Card(
                elevation: 4,
                color: _themeColor.surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _themeColor.primaryColor.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.rem200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        'Select your piece color:',
                        style: TextStyle(
                          fontSize: AppFontSize.md,
                          fontWeight: AppFontWeight.bold,
                          color: _themeColor.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: AppSpacing.rem200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildColorOption('White', true),
                          _buildColorOption('Black', false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.rem300),

              // Time control settings
              Card(
                elevation: 4,
                color: _themeColor.surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _themeColor.primaryColor.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.rem200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        'Time Control:',
                        style: TextStyle(
                          fontSize: AppFontSize.md,
                          fontWeight: AppFontWeight.bold,
                          color: _themeColor.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: AppSpacing.rem200),

                      // Time per move slider
                      Row(
                        children: [
                          CommonText(
                            'Minutes per side: ',
                            style: TextStyle(
                              color: _themeColor.textPrimaryColor,
                              fontWeight: AppFontWeight.medium,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: _themeColor.primaryColor,
                                inactiveTrackColor: _themeColor.primaryColor.withOpacity(0.3),
                                thumbColor: _themeColor.primaryColor,
                                overlayColor: _themeColor.primaryColor.withOpacity(0.2),
                                valueIndicatorColor: _themeColor.primaryVariant,
                                valueIndicatorTextStyle: TextStyle(
                                  color: _themeColor.onPrimaryColor,
                                ),
                              ),
                              child: Slider(
                                value: _timeControlMinutes.toDouble(),
                                min: 1,
                                max: 30,
                                divisions: 29,
                                label: '$_timeControlMinutes min',
                                onChanged: (value) {
                                  setState(() {
                                    _timeControlMinutes = value.round();
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _themeColor.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CommonText(
                              '$_timeControlMinutes',
                              style: TextStyle(
                                color: _themeColor.onPrimaryColor,
                                fontWeight: AppFontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Increment slider
                      Row(
                        children: [
                          CommonText(
                            'Increment (sec): ',
                            style: TextStyle(
                              color: _themeColor.textPrimaryColor,
                              fontWeight: AppFontWeight.medium,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: _themeColor.secondaryColor,
                                inactiveTrackColor: _themeColor.secondaryColor.withOpacity(0.3),
                                thumbColor: _themeColor.secondaryColor,
                                overlayColor: _themeColor.secondaryColor.withOpacity(0.2),
                                valueIndicatorColor: _themeColor.secondaryColor,
                                valueIndicatorTextStyle: TextStyle(
                                  color: _themeColor.onSecondaryColor,
                                ),
                              ),
                              child: Slider(
                                value: _incrementSeconds.toDouble(),
                                min: 0,
                                max: 30,
                                divisions: 30,
                                label: '$_incrementSeconds sec',
                                onChanged: (value) {
                                  setState(() {
                                    _incrementSeconds = value.round();
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _themeColor.secondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CommonText(
                              '$_incrementSeconds',
                              style: TextStyle(
                                color: _themeColor.onSecondaryColor,
                                fontWeight: AppFontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // AI difficulty (only show if opponent is AI)
              if (widget.isAIOpponent) ...[
                SizedBox(height: AppSpacing.rem300),
                Card(
                  elevation: 4,
                  color: _themeColor.surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _themeColor.primaryColor.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.rem200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'AI Difficulty Level:',
                          style: TextStyle(
                            fontSize: AppFontSize.md,
                            fontWeight: AppFontWeight.bold,
                            color: _themeColor.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: AppSpacing.rem200),
                        Center(
                          child: CommonText(
                            _getDifficultyText(widget.aiDifficulty ?? 3),
                            style: TextStyle(
                              color: _themeColor.primaryColor,
                              fontSize: AppFontSize.lg,
                              fontWeight: AppFontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),

              // Start game button
              CommonButton(
                text: 'Start Game',
                onPressed: _createGameAndNavigate,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.rem200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
