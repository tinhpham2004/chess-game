import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/border/app_border_radius.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonOutlinedButton extends StatelessWidget {
  final String? text;
  final Color? textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool isEnable;
  final int? maxLines;
  final TextOverflow? overflow;
  final themeColor = getIt.get<AppTheme>().themeColor;

  CommonOutlinedButton({
    super.key,
    this.text,
    this.textColor,
    this.borderColor,
    this.onPressed,
    this.margin,
    this.padding,
    this.isEnable = true,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? themeColor.borderColor;
    final effectiveTextColor = textColor ?? themeColor.secondaryColor;

    return Container(
      margin: margin,
      child: InkWell(
        onTap: isEnable ? onPressed : null,
        borderRadius: BorderRadius.circular(AppBorderRadius.l),
        child: Container(
          decoration: BoxDecoration(
            color: themeColor.secondaryColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.l),
            border: Border.all(color: effectiveBorderColor),
          ),
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: AppSpacing.rem450.w,
                vertical: AppSpacing.rem150.h,
              ),
          child: Center(
            child: CommonText(
              text ?? '',
              style: TextStyle(
                fontSize: AppFontSize.md,
                color: effectiveTextColor,
                fontWeight: AppFontWeight.semiBold,
              ),
              maxLines: maxLines,
              overFlow: overflow,
            ),
          ),
        ),
      ),
    );
  }
}
