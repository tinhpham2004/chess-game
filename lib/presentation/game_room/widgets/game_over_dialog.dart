import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/router/app_router.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// A dialog that shows the game result and provides options for next actions.
class GameOverDialog extends StatelessWidget {
  /// The winner of the game ('White', 'Black', or 'Draw')
  final String result;

  /// AI difficulty level if this was an AI game
  final int? aiDifficulty;

  /// Whether the game was against AI
  final bool isAiOpponent;

  /// Callback for when the user wants to play again with same settings
  final VoidCallback onPlayAgain;

  GameOverDialog({
    required this.result,
    required this.onPlayAgain,
    required this.isAiOpponent,
    this.aiDifficulty,
    super.key,
  });

  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  Widget build(BuildContext context) {
    final resultMessage = result == 'Draw' ? 'Game ended in a draw!' : '$result wins!';

    return AlertDialog(
      backgroundColor: _themeColor.backgroundColor,
      title: CommonText(
        'Game Over',
        style: TextStyle(
          fontSize: AppFontSize.lg,
          fontWeight: AppFontWeight.bold,
          color: _themeColor.textPrimaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText(
            resultMessage,
            style: TextStyle(
              fontSize: AppFontSize.md,
              fontWeight: AppFontWeight.bold,
              color: _themeColor.textPrimaryColor,
            ),
          ),
          SizedBox(height: AppSpacing.rem300),
          if (result != 'Draw') _buildWinnerImage(result),
          SizedBox(height: AppSpacing.rem300),
          CommonText(
            'What would you like to do next?',
            style: TextStyle(color: _themeColor.textPrimaryColor),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onPlayAgain,
          child: CommonText(
            'Play Again',
            style: TextStyle(color: _themeColor.primaryColor),
          ),
        ),
        TextButton(
          onPressed: () {
            // Go back to setup screen with same opponent type
            Navigator.of(context).pop();
            AppRouter.go(
              AppRouter.gameSetupScreen,
              params: {
                'isAIOpponent': isAiOpponent,
                'aiDifficulty': aiDifficulty,
              },
            );
          },
          child: CommonText(
            'New Match',
            style: TextStyle(color: _themeColor.primaryColor),
          ),
        ),
        TextButton(
          onPressed: () {
            // Go to match history screen
            Navigator.of(context).pop();
            AppRouter.go(AppRouter.matchHistoryScreen);
          },
          child: CommonText(
            'View History',
            style: TextStyle(color: _themeColor.primaryColor),
          ),
        ),
        TextButton(
          onPressed: () {
            // Go back to welcome screen
            Navigator.of(context).pop();
            AppRouter.go(AppRouter.welcomeScreen);
          },
          child: CommonText(
            'Main Menu',
            style: TextStyle(color: _themeColor.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerImage(String winner) {
    final isWhiteWinner = winner == 'White';

    return Container(
      padding: EdgeInsets.all(AppSpacing.rem150),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWhiteWinner ? Colors.white : Colors.black,
        border: Border.all(
          color: isWhiteWinner ? Colors.black : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events,
        size: 40,
        color: Colors.amber,
      ),
    );
  }
}
