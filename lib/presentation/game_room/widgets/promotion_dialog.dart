import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A dialog that allows the player to choose which piece to promote a pawn to.
class PromotionDialog extends StatelessWidget {
  /// The color of the pawn being promoted
  final PieceColor pawnColor;

  /// Callback when a piece type is selected
  final void Function(PieceType) onPieceSelected;

  PromotionDialog({
    required this.pawnColor,
    required this.onPieceSelected,
    super.key,
  });

  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _themeColor.backgroundColor,
      title: CommonText(
        'Promote Pawn',
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
            'Choose which piece to promote to:',
            style: TextStyle(
              fontSize: AppFontSize.md,
              color: _themeColor.textPrimaryColor,
            ),
          ),
          SizedBox(height: AppSpacing.rem300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPieceOption(PieceType.queen),
              _buildPieceOption(PieceType.rook),
              _buildPieceOption(PieceType.bishop),
              _buildPieceOption(PieceType.knight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieceOption(PieceType pieceType) {
    final pieceIcon = _getPieceIcon(pieceType, pawnColor);
    final pieceName = _getPieceName(pieceType);

    return GestureDetector(
      onTap: () => onPieceSelected(pieceType),
      child: Container(
        width: 60,
        height: 80,
        padding: EdgeInsets.all(AppSpacing.rem100),
        decoration: BoxDecoration(
          color: _themeColor.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _themeColor.primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: SvgPicture.asset(
                pieceIcon,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppSpacing.rem050),
            CommonText(
              pieceName,
              style: TextStyle(
                fontSize: AppFontSize.xs,
                fontWeight: AppFontWeight.medium,
                color: _themeColor.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPieceIcon(PieceType pieceType, PieceColor color) {
    final colorSuffix = color == PieceColor.white ? 'white' : 'black';

    switch (pieceType) {
      case PieceType.queen:
        return 'assets/icons/queen_$colorSuffix.svg';
      case PieceType.rook:
        return 'assets/icons/rook_$colorSuffix.svg';
      case PieceType.bishop:
        return 'assets/icons/bishop_$colorSuffix.svg';
      case PieceType.knight:
        return 'assets/icons/knight_$colorSuffix.svg';
      default:
        return 'assets/icons/queen_$colorSuffix.svg';
    }
  }

  String _getPieceName(PieceType pieceType) {
    switch (pieceType) {
      case PieceType.queen:
        return 'Queen';
      case PieceType.rook:
        return 'Rook';
      case PieceType.bishop:
        return 'Bishop';
      case PieceType.knight:
        return 'Knight';
      default:
        return 'Queen';
    }
  }
}
