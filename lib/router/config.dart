part of 'app_router.dart';

class Config {
  static const _prefixPath = '/chess-game';

  static const _playScreen = '$_prefixPath/play';
  static const _historyScreen = '$_prefixPath/history';
  static const _difficultyScreen = '$_playScreen/difficulty';
  static const _gameSetupScreen = '$_playScreen/game-setup';
  static const _gameRoomScreen = '$_prefixPath/game-room-screen';

  static final shellNavigatorKey = GlobalKey<NavigatorState>();

  static final routes = <RouteBase>[
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        // Determine selected index based on current location
        int selectedIndex = 0;
        final location = state.uri.path;
        if (location.contains('/history')) {
          selectedIndex = 1;
        }

        return MainScreen(
          selectedIndex: selectedIndex,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: _playScreen,
          pageBuilder: (_, state) => NoTransitionPage(child: WelcomeScreen()),
        ),
        GoRoute(
          path: _historyScreen,
          pageBuilder: (_, state) =>
              NoTransitionPage(child: const MatchHistoryScreen()),
        ),
      ],
    ),
    GoRoute(
      path: _difficultyScreen,
      builder: (_, state) => DifficultyScreen(),
    ),
    GoRoute(
      path: _gameSetupScreen,
      builder: (_, state) {
        final params = state.extra as Map<String, dynamic>?;
        final isAIOpponent = params?['isAIOpponent'] as bool? ?? false;
        final aiDifficulty = params?['aiDifficulty'] as int?;
        return GameSetupScreen(
            isAIOpponent: isAIOpponent, aiDifficulty: aiDifficulty);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: _gameRoomScreen,
      builder: (_, state) {
        final gameRoomId = state.extra as String?;
        return GameRoomScreen(gameId: gameRoomId ?? '');
      },
    ),
  ];
}
