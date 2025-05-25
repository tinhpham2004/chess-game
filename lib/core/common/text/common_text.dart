import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final String? text;
  final InlineSpan? textSpan;
  final TextAlign? align;
  final TextStyle? style;
  final TextOverflow? overFlow;
  final int? maxLines;
  final themeColor = getIt.get<AppTheme>().themeColor;

  CommonText(
    this.text, {
    super.key,
    this.align,
    this.style,
    this.overFlow,
    this.maxLines,
  }) : textSpan = null;

  CommonText.rich(
    this.textSpan, {
    super.key,
    this.align,
    this.style,
    this.overFlow,
    this.maxLines,
  }) : text = null;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: AppFontSize.md,
      color: themeColor.textPrimaryColor,
      fontWeight: AppFontWeight.regular,
    );

    return Text.rich(
      textSpan ?? TextSpan(text: text, style: style ?? defaultStyle),
      textAlign: align,
      overflow: overFlow,
      maxLines: maxLines,
      style: style ?? defaultStyle,
    );
  }
}
