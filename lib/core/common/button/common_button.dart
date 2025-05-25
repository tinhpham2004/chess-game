import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/border/app_border_radius.dart';
import 'package:chess_game/theme/border/app_border_wh.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool isEnable;
  final int? maxLines;
  final TextOverflow? overflow;
  final themeColor = getIt.get<AppTheme>().themeColor;

  CommonButton({
    super.key,
    this.text,
    this.onPressed,
    this.margin,
    this.padding,
    this.isEnable = true,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isEnable ? themeColor.primaryColor : themeColor.borderColor;

    final borderColor = isEnable ? themeColor.borderColor : themeColor.borderColor;

    final borderWidth = isEnable ? AppBorderWH.s : AppBorderWH.xs;

    return Container(
      margin: margin,
      child: InkWell(
        onTap: isEnable ? onPressed : null,
        borderRadius: BorderRadius.circular(AppBorderRadius.l),
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.l),
            border: Border.all(
              width: borderWidth,
              color: borderColor,
            ),
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
                color: isEnable ? themeColor.textPrimaryColor : themeColor.secondaryColor,
                fontWeight: AppFontWeight.semiBold,
                fontSize: AppFontSize.md,
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
