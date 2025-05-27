import 'package:chess_game/presentation/game_room/screens/game_room_screen.dart';
import 'package:chess_game/presentation/welcome/screens/welcome_screen.dart';
import 'package:chess_game/presentation/difficulty/screens/difficulty_screen.dart';
import 'package:chess_game/presentation/setup/screens/game_setup_screen.dart';
import 'package:chess_game/presentation/match_history/screens/match_history_screen.dart';
import 'package:chess_game/presentation/main/screens/main_screen.dart';
import 'package:chess_game/router/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'config.dart';

class AppRouter {
  static const prefixPath = Config._prefixPath;
  static const playScreen = Config._playScreen;
  static const historyScreen = Config._historyScreen;
  static const difficultyScreen = Config._difficultyScreen;
  static const gameSetupScreen = Config._gameSetupScreen;
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
