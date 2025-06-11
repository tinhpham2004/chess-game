import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';

class ChessTimer extends StatelessWidget {
  const ChessTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = getIt.get<AppTheme>().themeColor;

    return BlocBuilder<GameRoomBloc, GameRoomState>(
      buildWhen: (previous, current) =>
          previous.whiteTimeLeft != current.whiteTimeLeft ||
          previous.blackTimeLeft != current.blackTimeLeft ||
          previous.timerRunning != current.timerRunning ||
          previous.activeTimerColor != current.activeTimerColor ||
          previous.gameEnded != current.gameEnded,
      builder: (context, state) {
        // Don't show timer if time control is disabled
        if (state.gameConfig?.timeControlMinutes == 0) {
          return const SizedBox.shrink();
        }        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.rem200,
            vertical: AppSpacing.rem100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _buildPlayerTimer(
                  context,
                  themeColor,
                  'White',
                  state.whiteTimeLeft,
                  PieceColor.white,
                  state.activeTimerColor,
                  state.timerRunning,
                  state.gameEnded,
                ),
              ),
              _buildTimerControls(context, themeColor, state),
              Flexible(
                child: _buildPlayerTimer(
                  context,
                  themeColor,
                  'Black',
                  state.blackTimeLeft,
                  PieceColor.black,
                  state.activeTimerColor,
                  state.timerRunning,
                  state.gameEnded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerTimer(
    BuildContext context,
    dynamic themeColor,
    String playerName,
    int timeLeftSeconds,
    PieceColor playerColor,
    PieceColor? activeTimerColor,
    bool timerRunning,
    bool gameEnded, {
    bool isCompact = false,
  }) {
    final isActive =
        activeTimerColor == playerColor && timerRunning && !gameEnded;
    final minutes = timeLeftSeconds ~/ 60;
    final seconds = timeLeftSeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Determine color based on time remaining
    Color backgroundColor;
    Color textColor;

    if (timeLeftSeconds <= 10 && isActive) {
      // Critical time - red background
      backgroundColor = Colors.red.shade700;
      textColor = Colors.white;
    } else if (timeLeftSeconds <= 60 && isActive) {
      // Low time - orange background
      backgroundColor = Colors.orange.shade600;
      textColor = Colors.white;
    } else if (isActive) {
      // Active timer - highlighted
      backgroundColor = themeColor.primaryColor;
      textColor = themeColor.onPrimaryColor;
    } else {
      // Inactive timer - neutral
      backgroundColor = themeColor.surfaceColor;
      textColor = themeColor.textPrimaryColor;
    }

    return isCompact
        ? Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.rem050),
            padding: EdgeInsets.all(AppSpacing.rem100),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? themeColor.primaryColor : themeColor.borderColor,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CommonText(
                    playerName,
                    style: TextStyle(
                      fontSize: AppFontSize.sm,
                      fontWeight: AppFontWeight.medium,
                      color: textColor,
                    ),
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      timeText,
                      style: TextStyle(
                        fontSize: AppFontSize.xl,
                        fontWeight: AppFontWeight.bold,
                        color: textColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(width: AppSpacing.rem050),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          )
        : Container(
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.rem050),
            padding: EdgeInsets.all(AppSpacing.rem150),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? themeColor.primaryColor : themeColor.borderColor,
                width: isActive ? 3 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: themeColor.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  playerName,
                  style: TextStyle(
                    fontSize: AppFontSize.sm,
                    fontWeight: AppFontWeight.medium,
                    color: textColor,
                  ),
                  overFlow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.rem050),
                CommonText(
                  timeText,
                  style: TextStyle(
                    fontSize: AppFontSize.xl,
                    fontWeight: AppFontWeight.bold,
                    color: textColor,
                    fontFamily: 'monospace',
                  ),
                ),
                if (isActive) ...[
                  SizedBox(height: AppSpacing.rem050),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
  }

  Widget _buildTimerControls(
    BuildContext context,
    dynamic themeColor,
    GameRoomState state, {
    bool isCompact = false,
  }) {
    if (state.gameEnded || !state.gameStarted) {
      return SizedBox(width: isCompact ? 0 : 80);
    }

    final buttonSize = isCompact ? 20.0 : 28.0;
    final containerWidth = isCompact ? 60.0 : 80.0;

    return Container(
      width: containerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.timerRunning)
            IconButton(
              onPressed: () =>
                  context.read<GameRoomBloc>().add(PauseTimerEvent()),
              icon: Icon(
                Icons.pause,
                color: themeColor.primaryColor,
                size: buttonSize,
              ),
              tooltip: 'Pause Timer',
            )
          else if (state.timerPaused)
            IconButton(
              onPressed: () =>
                  context.read<GameRoomBloc>().add(ResumeTimerEvent()),
              icon: Icon(
                Icons.play_arrow,
                color: themeColor.primaryColor,
                size: buttonSize,
              ),
              tooltip: 'Resume Timer',
            )
          else
            IconButton(
              onPressed: () =>
                  context.read<GameRoomBloc>().add(StartTimerEvent()),
              icon: Icon(
                Icons.timer,
                color: themeColor.primaryColor,
                size: buttonSize,
              ),
              tooltip: 'Start Timer',
            ),
          if (!isCompact && (state.timerRunning || state.timerPaused))
            CommonText(
              state.timerRunning ? 'Running' : 'Paused',
              style: TextStyle(
                fontSize: AppFontSize.xs,
                color: themeColor.textSecondaryColor,
              ),
            ),
        ],
      ),
    );
  }

  /// Convert seconds to a human-readable format for display
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}