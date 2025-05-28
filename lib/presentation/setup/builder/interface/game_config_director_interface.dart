import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/presentation/setup/builder/interface/game_config_builder_interface.dart';

abstract class IGameConfigDirector {
  void setBuilder(IGameConfigBuilder builder);
  GameConfig buildBulletGameConfig(
      {bool soundEnabled = true,
      int timeControlMinutes = 1,
      int incrementSeconds = 0});
  GameConfig buildBlitzGameConfig(
      {bool soundEnabled = true,
      int timeControlMinutes = 3,
      int incrementSeconds = 2});
  GameConfig buildClassicGameConfig(
      {bool soundEnabled = true,
      int timeControlMinutes = 15,
      int incrementSeconds = 10});
  GameConfig createCustomConfig({
    required int minutes,
    required int increment,
    required bool isWhiteAI,
    required bool isBlackAI,
    required int aiLevel,
    // required String boardTheme,
    // required String pieceSet,
    required bool soundEnabled,
  });
  GameConfig buildGameConfig();
}
