part of 'app_router.dart';

class Config {
  static const _prefixPath = '/chess-game';

  static const _welcomeScreen = '$_prefixPath/welcome';
  static const _difficultyScreen = '$_prefixPath/difficulty';
  static const _gameSetupScreen = '$_prefixPath/game-setup';
  static const _gameRoomScreen = '$_prefixPath/game-room-screen';
  static const _matchHistoryScreen = '$_prefixPath/match-history';

  static final routes = <GoRoute>[
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: _welcomeScreen,
      builder: (_, state) {
        return WelcomeScreen();
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: _difficultyScreen,
      builder: (_, state) {
        return DifficultyScreen();
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: _gameSetupScreen,
      builder: (_, state) {
        final params = state.extra as Map<String, dynamic>?;
        final isAIOpponent = params?['isAIOpponent'] as bool? ?? false;
        final aiDifficulty = params?['aiDifficulty'] as int?;
        return GameSetupScreen(isAIOpponent: isAIOpponent, aiDifficulty: aiDifficulty);
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
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: _matchHistoryScreen,
      builder: (_, state) {
        return const MatchHistoryScreen();
      },
    ),
  ];
}
