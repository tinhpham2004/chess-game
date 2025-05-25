import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? elevation;

  CommonAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation,
  });

  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: CommonText(title,
          style: TextStyle(
            color: _themeColor.textPrimaryColor,
            fontSize: AppFontSize.xxxl,
            fontWeight: AppFontWeight.bold,
          )),
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor ?? _themeColor.backgroundColor,
      centerTitle: centerTitle,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
