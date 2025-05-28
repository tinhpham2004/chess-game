import 'package:chess_game/core/models/game_config.dart';

// Builder pattern

abstract class IGameConfigBuilder {
  IGameConfigBuilder reset();
  IGameConfigBuilder setTimeControl(int minutes, int seconds);
  IGameConfigBuilder setPlayerType(String playerType);
  IGameConfigBuilder setBoardTheme(String boardTheme);
  IGameConfigBuilder setPieceSet(String pieceSet);
  IGameConfigBuilder setSoundEnabled(bool soundEnabled);
  IGameConfigBuilder setDifficultyLevel(int difficultyLevel);
  GameConfig build();
}
