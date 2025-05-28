import 'package:chess_game/core/models/game_config.dart';

// Builder pattern

abstract class IGameConfigBuilder {
  IGameConfigBuilder reset();
  IGameConfigBuilder setTimeControl(
      int timeControlMinutes, int incrementSeconds);
  IGameConfigBuilder setPlayerTypes(bool isWhiteAI, bool isBlackAI);
  IGameConfigBuilder setSoundEnabled(bool soundEnabled);
  IGameConfigBuilder setDifficultyLevel(int difficultyLevel);
  GameConfig build();
}
