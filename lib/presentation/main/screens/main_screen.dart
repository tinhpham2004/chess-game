import 'package:chess_game/core/common/scaffold/common_bottom_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/di/injection.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  final int selectedIndex;

  const MainScreen({
    required this.child,
    required this.selectedIndex,
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      backgroundColor: _themeColor.backgroundColor,
      body: widget.child,
      bottomNavigationBar: CommonBottomBar(),
    );
  }
}
