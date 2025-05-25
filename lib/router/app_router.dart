import 'package:chess_game/presentation/game_room/screens/game_room_screen.dart';
import 'package:chess_game/presentation/welcome/screens/welcome_screen.dart';
import 'package:chess_game/presentation/difficulty/screens/difficulty_screen.dart';
import 'package:chess_game/presentation/setup/screens/game_setup_screen.dart';
import 'package:chess_game/presentation/match_history/screens/match_history_screen.dart';
import 'package:chess_game/router/router.dart';
import 'package:go_router/go_router.dart';

part 'config.dart';

class AppRouter {
  static const prefixPath = Config._prefixPath;
  static const welcomeScreen = Config._welcomeScreen;
  static const difficultyScreen = Config._difficultyScreen;
  static const gameSetupScreen = Config._gameSetupScreen;
  static const gameRoomScreen = Config._gameRoomScreen;
  static const matchHistoryScreen = Config._matchHistoryScreen;

  static final routes = Config.routes;

  static void push(String path, {Object? params}) => router.push(path, extra: params);
  static void go(String path, {Object? params}) => router.go(path, extra: params);
  static void replace(String path, {Object? params}) => router.replace(path, extra: params);
  static void pop() => router.pop();
}
