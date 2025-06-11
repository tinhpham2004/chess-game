import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/router/app_router.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});
  final _themeColor = getIt.get<AppTheme>().themeColor;
  void _onPlayWithAI() {
    AppRouter.push(AppRouter.difficultyScreen);
  }

  void _onPlayWithFriend() {
    AppRouter.push(AppRouter.gameSetupScreen, params: {'isAIOpponent': false});
  }
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      backgroundColor: _themeColor.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _themeColor.primaryColor.withOpacity(0.1),
              _themeColor.backgroundColor,
              _themeColor.surfaceColor.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.rem300),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                // Hero section with chess pieces decoration
                Container(
                  padding: EdgeInsets.all(AppSpacing.rem400),
                  decoration: BoxDecoration(
                    color: _themeColor.surfaceColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _themeColor.primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Chess crown icon or decorative element
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _themeColor.primaryColor,
                              _themeColor.primaryColor.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _themeColor.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: AppSpacing.rem300),
                      
                      CommonText(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: AppFontSize.xl,
                          fontWeight: AppFontWeight.regular,
                          color: _themeColor.textSecondaryColor,
                        ),
                        align: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.rem100),
                      CommonText(
                        'Chess Master',
                        style: TextStyle(
                          fontSize: AppFontSize.xxxl,
                          fontWeight: AppFontWeight.bold,
                          color: _themeColor.textPrimaryColor,
                          letterSpacing: 1.2,
                        ),
                        align: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.rem150),
                      CommonText(
                        'Challenge yourself with AI or play with friends',
                        style: TextStyle(
                          fontSize: AppFontSize.md,
                          fontWeight: AppFontWeight.regular,
                          color: _themeColor.textSecondaryColor,
                        ),
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                // Action buttons with modern styling
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    spacing: AppSpacing.rem200,
                    children: [
                      _buildModernButton(
                        'Play with AI',
                        Icons.smart_toy,
                        _onPlayWithAI,
                        isPrimary: true,
                      ),
                      _buildModernButton(
                        'Play with Friend',
                        Icons.people,
                        _onPlayWithFriend,
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton(String text, IconData icon, VoidCallback onPressed,
      {required bool isPrimary}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  _themeColor.primaryColor,
                  _themeColor.primaryColor.withOpacity(0.8),
                ],
              )
            : null,
        color: isPrimary ? null : _themeColor.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(
                color: _themeColor.primaryColor.withOpacity(0.3),
                width: 2,
              ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? _themeColor.primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: isPrimary ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.rem300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : _themeColor.primaryColor,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.rem150),
                CommonText(
                  text,
                  style: TextStyle(
                    fontWeight: AppFontWeight.semiBold,
                    color: isPrimary ? Colors.white : _themeColor.primaryColor,
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
