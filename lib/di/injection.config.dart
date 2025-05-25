// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chess_game/core/patterns/builder/game_config_builder.dart'
    as _i855;
import 'package:chess_game/data/datasource/db_provider.dart' as _i862;
import 'package:chess_game/data/datasource/game_room_dao.dart' as _i1034;
import 'package:chess_game/data/datasource/match_history_dao.dart' as _i169;
import 'package:chess_game/data/repository/game_room_repository.dart' as _i721;
import 'package:chess_game/data/repository/match_history_repository.dart'
    as _i65;
import 'package:chess_game/di/app_module.dart' as _i950;
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart'
    as _i736;
import 'package:chess_game/theme/app_theme.dart' as _i789;
import 'package:chess_game/theme/color/app_color_factory.dart' as _i613;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sqflite/sqflite.dart' as _i779;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.factory<_i855.GameConfigBuilder>(
        () => appModule.provideGameConfigBuilder());
    await gh.factoryAsync<_i862.DBProvider>(
      () => appModule.provideDbProvider(),
      preResolve: true,
    );
    gh.lazySingleton<_i613.AppColorFactory>(
        () => appModule.provideColorFactory());
    gh.lazySingleton<_i779.Database>(
        () => appModule.provideDatabase(gh<_i862.DBProvider>()));
    gh.factory<_i855.GameConfigDirector>(() =>
        appModule.provideGameConfigDirector(gh<_i855.GameConfigBuilder>()));
    gh.factory<_i1034.GameRoomDao>(
        () => _i1034.GameRoomDao(gh<_i779.Database>()));
    gh.factory<_i169.MatchHistoryDao>(
        () => _i169.MatchHistoryDao(gh<_i779.Database>()));
    gh.singleton<_i789.AppTheme>(
        () => _i789.AppTheme(gh<_i613.AppColorFactory>()));
    gh.factory<_i65.MatchHistoryRepository>(
        () => _i65.MatchHistoryRepository(gh<_i169.MatchHistoryDao>()));
    gh.factory<_i721.GameRoomRepository>(
        () => _i721.GameRoomRepository(gh<_i1034.GameRoomDao>()));
    gh.factory<_i736.GameRoomBloc>(() => _i736.GameRoomBloc(
          gh<_i721.GameRoomRepository>(),
          gh<_i65.MatchHistoryRepository>(),
        ));
    return this;
  }
}

class _$AppModule extends _i950.AppModule {}
