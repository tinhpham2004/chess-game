// Product class
import 'package:chess_game/core/models/game_config.dart';

// Abstract builder interface
abstract class GameConfigBuilder {
  void setTimeControl(int minutes, int incrementSeconds);
  void setPlayerTypes(bool isWhiteAI, bool isBlackAI);
  void setAIDifficulty(int level);
  void setBoardTheme(String theme);
  void setPieceSet(String pieceSet);
  void setSoundSettings(bool enabled);
  GameConfig build();
}

// Concrete builder implementation
class ChessGameConfigBuilder implements GameConfigBuilder {
  int _timeControlMinutes = 10;
  int _incrementSeconds = 0;
  bool _isWhitePlayerAI = false;
  bool _isBlackPlayerAI = true;
  int _aiDifficultyLevel = 3;
  String _boardTheme = 'classic';
  String _pieceSet = 'standard';
  bool _soundEnabled = true;

  @override
  void setTimeControl(int minutes, int incrementSeconds) {
    _timeControlMinutes = minutes;
    _incrementSeconds = incrementSeconds;
  }

  @override
  void setPlayerTypes(bool isWhiteAI, bool isBlackAI) {
    _isWhitePlayerAI = isWhiteAI;
    _isBlackPlayerAI = isBlackAI;
  }

  @override
  void setAIDifficulty(int level) {
    _aiDifficultyLevel = level.clamp(1, 10);
  }

  @override
  void setBoardTheme(String theme) {
    _boardTheme = theme;
  }

  @override
  void setPieceSet(String pieceSet) {
    _pieceSet = pieceSet;
  }

  @override
  void setSoundSettings(bool enabled) {
    _soundEnabled = enabled;
  }

  @override
  GameConfig build() {
    return GameConfig(
      timeControlMinutes: _timeControlMinutes,
      incrementSeconds: _incrementSeconds,
      isWhitePlayerAI: _isWhitePlayerAI,
      isBlackPlayerAI: _isBlackPlayerAI,
      aiDifficultyLevel: _aiDifficultyLevel,
      boardTheme: _boardTheme,
      pieceSet: _pieceSet,
      soundEnabled: _soundEnabled,
    );
  }
}

class GameConfigDirector {
  GameConfigBuilder _builder;

  GameConfigDirector(this._builder);

  // Switch to a different builder
  void changeBuilder(GameConfigBuilder builder) {
    _builder = builder;
  }

  // Create a blitz game configuration
  GameConfig createBlitzConfig() {
    _builder.setTimeControl(3, 2);
    _builder.setBoardTheme('classic');
    _builder.setPieceSet('standard');
    _builder.setSoundSettings(true);
    return _builder.build();
  }

  // Create a classical game configuration
  GameConfig createClassicalConfig() {
    _builder.setTimeControl(15, 10);
    _builder.setBoardTheme('tournament');
    _builder.setPieceSet('standard');
    _builder.setSoundSettings(true);
    return _builder.build();
  }

  // Create a bullet game configuration
  GameConfig createBulletConfig() {
    _builder.setTimeControl(1, 0);
    _builder.setBoardTheme('blitz');
    _builder.setPieceSet('minimal');
    _builder.setSoundSettings(true);
    return _builder.build();
  }

  // Create a custom game configuration
  GameConfig createCustomConfig({
    required int minutes,
    required int increment,
    required bool isWhiteAI,
    required bool isBlackAI,
    required int aiLevel,
    required String boardTheme,
    required String pieceSet,
    required bool soundEnabled,
  }) {
    _builder.setTimeControl(minutes, increment);
    _builder.setPlayerTypes(isWhiteAI, isBlackAI);
    _builder.setAIDifficulty(aiLevel);
    _builder.setBoardTheme(boardTheme);
    _builder.setPieceSet(pieceSet);
    _builder.setSoundSettings(soundEnabled);
    return _builder.build();
  }
}
