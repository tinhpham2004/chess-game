import 'package:chess_game/core/patterns/builder/game_config_builder.dart';
import 'package:chess_game/data/datasource/db_provider.dart';
import 'package:chess_game/theme/color/app_color_factory.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

@module
abstract class AppModule {
  @injectable
  GameConfigDirector provideGameConfigDirector(GameConfigBuilder builder) => GameConfigDirector(builder);

  @injectable
  GameConfigBuilder provideGameConfigBuilder() => ChessGameConfigBuilder();

  @lazySingleton
  AppColorFactory provideColorFactory() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? AppDarkColorFactory() : AppLightColorFactory();
  }

  @preResolve
  Future<DBProvider> provideDbProvider() => DBProvider.create();

  @lazySingleton
  Database provideDatabase(DBProvider dbProvider) => dbProvider.database;
}
