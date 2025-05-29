import 'package:chess_game/data/datasource/db_provider.dart';
import 'package:chess_game/presentation/setup/builder/implementation/game_config_builder.dart';
import 'package:chess_game/presentation/setup/builder/implementation/game_config_director.dart';
import 'package:chess_game/presentation/setup/builder/interface/game_config_builder_interface.dart';
import 'package:chess_game/theme/color/app_color_factory.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

@module
abstract class AppModule {
  @injectable
  GameConfigDirector provideGameConfigDirector(IGameConfigBuilder builder) =>
      GameConfigDirector(builder);

  @injectable
  IGameConfigBuilder provideGameConfigBuilder() => GameConfigBuilder();

  @lazySingleton
  AppColorFactory provideColorFactory() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark
        ? AppDarkColorFactory()
        : AppLightColorFactory();
  }

  @preResolve
  Future<DBProvider> provideDbProvider() => DBProvider.create();

  @lazySingleton
  Database provideDatabase(DBProvider dbProvider) => dbProvider.database;
}
