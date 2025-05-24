import 'dart:ui';

import 'package:chess_game/app/chess_facade.dart';
import 'package:chess_game/data/datasource/db_provider.dart';
import 'package:chess_game/data/datasource/game_room_dao.dart';
import 'package:chess_game/data/repository/game_room_repository.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/color/app_color_factory.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  final dbProvider = DBProvider.instance;
  await dbProvider.init();

  final Brightness brightness = PlatformDispatcher.instance.platformBrightness;
  final AppColorFactory colorFactory = brightness == Brightness.dark ? AppDarkColorFactory() : AppLightColorFactory();
  final appTheme = AppTheme(colorFactory);

  getIt.registerSingleton<AppTheme>(appTheme);
  getIt.registerSingleton<DBProvider>(dbProvider);
  getIt.registerSingleton<GameRoomDao>(GameRoomDao(dbProvider.database));
  getIt.registerSingleton<GameRoomRepository>(GameRoomRepository(getIt<GameRoomDao>()));
  getIt.registerSingleton<ChessFacade>(ChessFacade(getIt<GameRoomRepository>()));
}
