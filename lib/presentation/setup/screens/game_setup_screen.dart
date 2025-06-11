import 'package:chess_game/core/common/scaffold/common_app_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/data/entities/game_room_entity.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/presentation/setup/builder/interface/game_config_builder_interface.dart';
import 'package:chess_game/presentation/setup/builder/interface/game_config_director_interface.dart';
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
  // Game configuration settings
  final _gameConfigBuilder = getIt.get<IGameConfigBuilder>();
  final _configDirector = getIt.get<IGameConfigDirector>();

  final _gameRoomRepository = getIt.get<GameRoomRepository>();
  final _themeColor = getIt.get<AppTheme>().themeColor;

  // UI state variables
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

  void _updatePlayerTypes() {
    print(
        '_updatePlayerTypes called: isAIOpponent=${widget.isAIOpponent}, playAsWhite=$_playAsWhite');
    if (widget.isAIOpponent) {
      // If playing against AI, set AI to opposite color of player's choice
      if (_playAsWhite) {
        // Player is White, AI is Black
        print('Setting: Player=White, AI=Black');
        _gameConfigBuilder.setPlayerTypes(false, true);
      } else {
        // Player is Black, AI is White
        print('Setting: Player=Black, AI=White');
        _gameConfigBuilder.setPlayerTypes(true, false);
      }
    } else {
      // If playing against friend, both are human players
      print('Setting: Both players are human');
      _gameConfigBuilder.setPlayerTypes(false, false);
    }

    // Debug: Build config immediately to verify settings
    final testConfig = _gameConfigBuilder.build();
    print('Test config after setPlayerTypes: ${testConfig.toJson()}');
  }

  Widget _buildColorOption(String label, bool isWhite) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _playAsWhite = isWhite;
          _updatePlayerTypes();
        });
      },
      child: Container(
        width: 120,
        padding: EdgeInsets.all(AppSpacing.rem200),
        decoration: BoxDecoration(
          color: _playAsWhite == isWhite
              ? _themeColor.primaryColor.withOpacity(0.3)
              : _themeColor.backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _playAsWhite == isWhite
                ? _themeColor.primaryColor
                : _themeColor.borderColor,
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
                fontWeight: _playAsWhite == isWhite
                    ? AppFontWeight.bold
                    : AppFontWeight.regular,
                color: _themeColor.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGameAndNavigate() async {
    // Set the builder in director to ensure they use the same instance
    _configDirector.setBuilder(_gameConfigBuilder);

    // Create game configuration
    final gameConfig = _configDirector.buildGameConfig();
    print('Game Config: ${gameConfig.toJson()}');
    // Generate unique game id
    final gameId = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Create game room model
    final gameRoom = GameRoomEntity(
      id: gameId,
      json: jsonEncode({
        'gameConfig':
            jsonDecode(gameConfig.toJson()), // Parse the JSON string to a Map
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
  void initState() {
    super.initState();
    _gameConfigBuilder.reset();
    _gameConfigBuilder.setDifficultyLevel(widget.aiDifficulty ?? 3);

    // Set initial player types based on isAIOpponent and default color choice
    _updatePlayerTypes();
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
              _themeColor.surfaceColor.withOpacity(0.3),
              _themeColor.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.rem300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with icon
                      _buildHeaderSection(),
                      SizedBox(height: AppSpacing.rem400),

                      // Piece color selection
                      _buildColorSelectionCard(),
                      SizedBox(height: AppSpacing.rem300),

                      // Time control settings
                      _buildTimeControlCard(),

                      // AI difficulty (only show if opponent is AI)
                      if (widget.isAIOpponent) ...[
                        SizedBox(height: AppSpacing.rem300),
                        _buildAIDifficultyCard(),
                      ],

                      SizedBox(height: AppSpacing.rem400),
                    ],
                  ),
                ),
              ),

              // Start game button - fixed at bottom
              Container(
                padding: EdgeInsets.all(AppSpacing.rem300),
                decoration: BoxDecoration(
                  color: _themeColor.surfaceColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: _buildStartGameButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.rem300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _themeColor.primaryColor.withOpacity(0.1),
            _themeColor.surfaceColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _themeColor.primaryColor,
                  _themeColor.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Icon(
              widget.isAIOpponent ? Icons.smart_toy : Icons.people,
              size: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.rem200),
          CommonText(
            'Configure Your Game',
            style: TextStyle(
              fontSize: AppFontSize.xxl,
              fontWeight: AppFontWeight.bold,
              color: _themeColor.textPrimaryColor,
            ),
            align: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.rem100),
          CommonText(
            'vs ${widget.isAIOpponent ? 'AI Player' : 'Friend'}',
            style: TextStyle(
              fontSize: AppFontSize.md,
              color: _themeColor.textSecondaryColor,
            ),
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: _themeColor.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _themeColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.rem250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: _themeColor.primaryColor,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.rem150),
                CommonText(
                  'Choose Your Color',
                  style: TextStyle(
                    fontSize: AppFontSize.xxl,
                    fontWeight: AppFontWeight.bold,
                    color: _themeColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.rem250),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorOption('White', true),
                _buildColorOption('Black', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeControlCard() {
    return Container(
      decoration: BoxDecoration(
        color: _themeColor.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _themeColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.rem250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: _themeColor.primaryColor,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.rem150),
                CommonText(
                  'Time Control',
                  style: TextStyle(
                    fontSize: AppFontSize.xxl,
                    fontWeight: AppFontWeight.bold,
                    color: _themeColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.rem250),

            // Time per move slider
            _buildTimeSlider(
              'Minutes per side',
              _timeControlMinutes.toDouble(),
              1,
              30,
              29,
              '$_timeControlMinutes min',
              _themeColor.primaryColor,
              (value) {
                setState(() {
                  _timeControlMinutes = value.round();
                  _gameConfigBuilder.setTimeControl(
                      _timeControlMinutes, _incrementSeconds);
                });
              },
            ),

            SizedBox(height: AppSpacing.rem200),

            // Increment slider
            _buildTimeSlider(
              'Increment per move',
              _incrementSeconds.toDouble(),
              0,
              30,
              30,
              '$_incrementSeconds sec',
              _themeColor.secondaryColor,
              (value) {
                setState(() {
                  _incrementSeconds = value.round();
                  _gameConfigBuilder.setTimeControl(
                      _timeControlMinutes, _incrementSeconds);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlider(String title, double value, double min, double max,
      int divisions, String label, Color color, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              title,
              style: TextStyle(
                fontSize: AppFontSize.md,
                fontWeight: AppFontWeight.medium,
                color: _themeColor.textPrimaryColor,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.rem150,
                vertical: AppSpacing.rem050,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: CommonText(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: AppFontWeight.bold,
                  fontSize: AppFontSize.sm,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.rem100),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            valueIndicatorColor: color,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: AppFontWeight.bold,
            ),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildAIDifficultyCard() {
    final difficultyLevel = widget.aiDifficulty ?? 3;
    final difficultyText = _getDifficultyText(difficultyLevel);

    Color getDifficultyColor() {
      if (difficultyLevel <= 3) return Colors.green;
      if (difficultyLevel <= 7) return Colors.orange;
      return Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: _themeColor.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getDifficultyColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: getDifficultyColor().withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.rem250),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: getDifficultyColor(),
                  size: 24,
                ),
                SizedBox(width: AppSpacing.rem150),
                Expanded(
                  child: CommonText(
                    'AI Difficulty Level',
                    style: TextStyle(
                      fontSize: AppFontSize.xxl,
                      fontWeight: AppFontWeight.bold,
                      color: _themeColor.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.rem200),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.rem200),
              decoration: BoxDecoration(
                color: getDifficultyColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: getDifficultyColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    difficultyText,
                    style: TextStyle(
                      fontSize: AppFontSize.xl,
                      fontWeight: AppFontWeight.bold,
                      color: getDifficultyColor(),
                    ),
                    align: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.rem050),
                  CommonText(
                    'Level $difficultyLevel',
                    style: TextStyle(
                      fontSize: AppFontSize.sm,
                      color: _themeColor.textSecondaryColor,
                    ),
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartGameButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _themeColor.primaryColor,
            _themeColor.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _themeColor.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _createGameAndNavigate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.rem300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: AppSpacing.rem150),
                CommonText(
                  'Start Game',
                  style: TextStyle(
                    fontSize: AppFontSize.xxl,
                    fontWeight: AppFontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
