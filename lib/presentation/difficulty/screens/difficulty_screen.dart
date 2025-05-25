import 'package:chess_game/core/common/button/common_button.dart';
import 'package:chess_game/core/common/scaffold/common_app_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/router/app_router.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

class DifficultyScreen extends StatelessWidget {
  DifficultyScreen({super.key});
  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(title: 'Select Difficulty'),
      backgroundColor: _themeColor.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.rem300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonText(
              'Select AI Difficulty Level',
              style: TextStyle(
                fontSize: AppFontSize.xxl,
                fontWeight: AppFontWeight.bold,
                color: _themeColor.textPrimaryColor,
              ),
              align: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.rem500),
            _buildDifficultyButton(context, 'Easy', 1),
            SizedBox(height: AppSpacing.rem200),
            _buildDifficultyButton(context, 'Medium', 5),
            SizedBox(height: AppSpacing.rem200),
            _buildDifficultyButton(context, 'Hard', 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, int level) {
    return CommonButton(
      text: label,
      onPressed: () {
        // Navigate to game setup with selected AI level
        AppRouter.push(AppRouter.gameSetupScreen, params: {
          'isAIOpponent': true,
          'aiDifficulty': level,
        });
      },
      padding: EdgeInsets.symmetric(vertical: AppSpacing.rem200),
    );
  }
}
