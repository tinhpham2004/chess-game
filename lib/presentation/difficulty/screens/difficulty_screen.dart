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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.rem300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.rem400),
                
                // Header section
                Container(
                  padding: EdgeInsets.all(AppSpacing.rem300),
                  decoration: BoxDecoration(
                    color: _themeColor.surfaceColor.withOpacity(0.8),
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
                          Icons.psychology,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: AppSpacing.rem200),
                      CommonText(
                        'Choose AI Difficulty',
                        style: TextStyle(
                          fontSize: AppFontSize.xxl,
                          fontWeight: AppFontWeight.bold,
                          color: _themeColor.textPrimaryColor,
                        ),
                        align: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.rem100),
                      CommonText(
                        'Select the level that matches your skills',
                        style: TextStyle(
                          fontSize: AppFontSize.md,
                          color: _themeColor.textSecondaryColor,
                        ),
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.rem400),

                // Difficulty buttons
                Column(
                  spacing: AppSpacing.rem250,
                  children: [
                    _buildDifficultyCard(
                      'Easy',
                      'Perfect for beginners',
                      Icons.child_friendly,
                      Colors.green,
                      1,
                    ),
                    _buildDifficultyCard(
                      'Medium',
                      'Good challenge for intermediate',
                      Icons.school,
                      Colors.orange,
                      5,
                    ),
                    _buildDifficultyCard(
                      'Hard',
                      'For experienced players',
                      Icons.local_fire_department,
                      Colors.red,
                      10,
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.rem400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(String title, String subtitle, IconData icon,
      Color accentColor, int level) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _themeColor.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppRouter.push(AppRouter.gameSetupScreen, params: {
              'isAIOpponent': true,
              'aiDifficulty': level,
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.rem250),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: accentColor,
                  ),
                ),
                SizedBox(width: AppSpacing.rem200),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        title,
                        style: TextStyle(
                          fontWeight: AppFontWeight.bold,
                          color: _themeColor.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: AppSpacing.rem050),
                      CommonText(
                        subtitle,
                        style: TextStyle(
                          fontSize: AppFontSize.sm,
                          color: _themeColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: accentColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
