part of 'app_router.dart';

class Config {
  static const _prefixPath = '/chess-game';

  static const _homeScreen = '$_prefixPath/home';
  static const _gameRoomScreen = '$_prefixPath/game-room-screen';

  static final routes = <GoRoute>[
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: _homeScreen,
      builder: (_, state) {
        return HomeScreen();
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
