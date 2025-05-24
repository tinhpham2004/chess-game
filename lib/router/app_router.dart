import 'package:chess_game/presentation/game_room/screens/game_room_screen.dart';
import 'package:chess_game/presentation/home/screens/home_screen.dart';
import 'package:chess_game/router/router.dart';
import 'package:go_router/go_router.dart';

part 'config.dart';

class AppRouter {
  static const prefixPath = Config._prefixPath;
  static const homeScreen = Config._homeScreen;
  static const gameRoomScreen = Config._gameRoomScreen;

  static final routes = Config.routes;

  static void push(String path, {Object? params}) =>
      router.push(path, extra: params);
  static void go(String path, {Object? params}) =>
      router.go(path, extra: params);
  static void replace(String path, {Object? params}) =>
      router.replace(path, extra: params);
  static void pop() => router.pop();
}