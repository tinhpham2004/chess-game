import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool isLoading;

  CommonScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.isLoading = false,
  });

  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          drawer: drawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          backgroundColor: backgroundColor ?? _themeColor.backgroundColor,
        ),
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: CircularProgressIndicator(color: _themeColor.primaryColor),
            ),
          ),
      ],
    );
  }
}
