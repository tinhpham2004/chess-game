import 'package:chess_game/core/models/game_config.dart';
import 'package:chess_game/presentation/setup/builder/interface/game_config_builder_interface.dart';

class GameConfigBuilder implements IGameConfigBuilder {
  int _timeControlMinutes = 10;
  int _incrementSeconds = 0;
  bool _isWhitePlayerAI = false;
  bool _isBlackPlayerAI = false;
  int _aiDifficultyLevel = 3;
  // String _boardTheme = 'classic';
  // String _pieceSet = 'standard';
  bool _soundEnabled = true;
  @override
  IGameConfigBuilder reset() {
    _timeControlMinutes = 10;
    _incrementSeconds = 0;
    _isWhitePlayerAI = false;
    _isBlackPlayerAI = false;
    _aiDifficultyLevel = 3;
    // _boardTheme = 'classic';
    // _pieceSet = 'standard';
    _soundEnabled = true;

    return this;
  }

  @override
  IGameConfigBuilder setTimeControl(
      int timeControlMinutes, int incrementSeconds) {
    _timeControlMinutes = timeControlMinutes;
    _incrementSeconds = incrementSeconds;
    return this;
  }

  @override
  IGameConfigBuilder setPlayerTypes(bool isWhiteAI, bool isBlackAI) {
    if (isWhiteAI && isBlackAI) {
      throw Exception('Both players cannot be AI.');
    }

    _isWhitePlayerAI = isWhiteAI;
    _isBlackPlayerAI = isBlackAI;
    return this;
  }

  @override
  IGameConfigBuilder setDifficultyLevel(int level) {
    _aiDifficultyLevel = level.clamp(1, 10);
    return this;
  }

  @override
  IGameConfigBuilder setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    return this;
  }

  @override
  GameConfig build() {
    return GameConfig(
      timeControlMinutes: _timeControlMinutes,
      incrementSeconds: _incrementSeconds,
      isWhitePlayerAI: _isWhitePlayerAI,
      isBlackPlayerAI: _isBlackPlayerAI,
      aiDifficultyLevel: _aiDifficultyLevel,
      // boardTheme: _boardTheme,
      // pieceSet: _pieceSet,
      soundEnabled: _soundEnabled,
    );
  }
}
