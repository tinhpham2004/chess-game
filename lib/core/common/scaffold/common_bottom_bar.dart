import 'package:chess_game/di/injection.dart';
import 'package:chess_game/router/app_router.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/border/app_border_wh.dart';
import 'package:flutter/material.dart';

class CommonBottomBar extends StatefulWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? elevation;

  const CommonBottomBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation,
  });

  @override
  State<CommonBottomBar> createState() => _CommonBottomBarState();
}

class _CommonBottomBarState extends State<CommonBottomBar> {
  final _themeColor = getIt.get<AppTheme>().themeColor;
  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        AppRouter.go(AppRouter.playScreen);
        break;
      case 1:
        AppRouter.go(AppRouter.historyScreen);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _themeColor.borderColor.withValues(alpha: 0.3),
            width: AppBorderWH.xs,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: _themeColor.surfaceColor,
        selectedItemColor: _themeColor.primaryColor,
        unselectedItemColor: _themeColor.textSecondaryColor,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            activeIcon: Icon(Icons.videogame_asset),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
