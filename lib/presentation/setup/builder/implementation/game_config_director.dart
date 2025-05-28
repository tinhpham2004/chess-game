import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/presentation/setup/builder/implementation/game_config_builder.dart';
import 'package:chess_game/presentation/setup/builder/interface/game_config_builder_interface.dart';
import 'package:chess_game/presentation/setup/builder/interface/game_config_director_interface.dart';

class GameConfigDirector implements IGameConfigDirector {
  IGameConfigBuilder? _builder;

  GameConfigDirector(IGameConfigBuilder builder) {
    _builder = builder;
  }

  @override
  void setBuilder(IGameConfigBuilder builder) {
    _builder = builder;
  }

  @override
  GameConfig buildBulletGameConfig(
      {bool soundEnabled = true,
      int timeControlMinutes = 1,
      int incrementSeconds = 0}) {
    _builder ??= GameConfigBuilder();
    return createCustomConfig(
        minutes: timeControlMinutes,
        increment: incrementSeconds,
        soundEnabled: soundEnabled);
  }

  @override
  GameConfig buildBlitzGameConfig(
      {bool soundEnabled = true,
      int timeControlMinutes = 3,
      int incrementSeconds = 2}) {
    _builder ??= GameConfigBuilder();
    return createCustomConfig(
        minutes: timeControlMinutes,
        increment: incrementSeconds,
        soundEnabled: soundEnabled);
  }

  @override
  GameConfig buildClassicGameConfig(
      {bool soundEnabled = true,
      int timeControlMinutes = 15,
      int incrementSeconds = 10}) {
    _builder ??= GameConfigBuilder();
    return createCustomConfig(
        minutes: timeControlMinutes,
        increment: incrementSeconds,
        soundEnabled: soundEnabled);
  }

  @override
  GameConfig buildGameConfig() {
    if (_builder == null) {
      throw Exception('Builder not set.');
    }

    return _builder!.build();
  }

  @override
  GameConfig createCustomConfig({
    int aiLevel = 1,
    bool isWhiteAI = false,
    bool isBlackAI = true,
    required int minutes,
    required int increment,
    required bool soundEnabled,
  }) {
    _builder ??= GameConfigBuilder();
    return _builder!
        .setTimeControl(minutes, increment)
        .setPlayerTypes(isWhiteAI, isBlackAI)
        .setDifficultyLevel(aiLevel)
        .setSoundEnabled(soundEnabled)
        .build();
  }
}
