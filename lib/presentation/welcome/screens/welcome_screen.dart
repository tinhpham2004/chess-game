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
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});
  final _themeColor = getIt.get<AppTheme>().themeColor;

  void _onPlayWithAI() {
    AppRouter.push(AppRouter.difficultyScreen);
  }

  void _onPlayWithFriend() {
    AppRouter.push(AppRouter.gameSetupScreen, params: {'isAIOpponent': false});
  }

  void _onViewMatchHistory() {
    AppRouter.push(AppRouter.matchHistoryScreen);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(title: 'Chess Game'),
      backgroundColor: _themeColor.backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.rem300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                'Welcome to Chess Game',
                style: TextStyle(
                  fontSize: AppFontSize.xxxl,
                  fontWeight: AppFontWeight.bold,
                  color: _themeColor.textPrimaryColor,
                ),
                align: TextAlign.center,
              ),
              Column(
                spacing: AppSpacing.rem300.h,
                children: [
                  CommonButton(
                    text: 'Play with AI',
                    onPressed: _onPlayWithAI,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.rem200),
                  ),
                  CommonButton(
                    text: 'Play with Friend',
                    onPressed: _onPlayWithFriend,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.rem200),
                  ),
                  CommonButton(
                    text: 'View Match History',
                    onPressed: _onViewMatchHistory,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.rem200),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
