import 'dart:convert';

import 'package:injectable/injectable.dart';

// Product class
class GameConfig {
  final int timeControlMinutes;
  final int incrementSeconds;
  final bool isWhitePlayerAI;
  final bool isBlackPlayerAI;
  final int aiDifficultyLevel; // 1-10
  final String boardTheme;
  final String pieceSet;
  final bool soundEnabled;

  GameConfig({
    required this.timeControlMinutes,
    required this.incrementSeconds,
    required this.isWhitePlayerAI,
    required this.isBlackPlayerAI,
    required this.aiDifficultyLevel,
    required this.boardTheme,
    required this.pieceSet,
    required this.soundEnabled,
  });

  // Convert to JSON string (for storage)
  String toJson() => jsonEncode({
        'timeControlMinutes': timeControlMinutes,
        'incrementSeconds': incrementSeconds,
        'isWhitePlayerAI': isWhitePlayerAI,
        'isBlackPlayerAI': isBlackPlayerAI,
        'aiDifficultyLevel': aiDifficultyLevel,
        'boardTheme': boardTheme,
        'pieceSet': pieceSet,
        'soundEnabled': soundEnabled,
      });

  // Create from JSON (for loading)
  factory GameConfig.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return GameConfig(
      timeControlMinutes: map['timeControlMinutes'],
      incrementSeconds: map['incrementSeconds'],
      isWhitePlayerAI: map['isWhitePlayerAI'],
      isBlackPlayerAI: map['isBlackPlayerAI'],
      aiDifficultyLevel: map['aiDifficultyLevel'],
      boardTheme: map['boardTheme'],
      pieceSet: map['pieceSet'],
      soundEnabled: map['soundEnabled'],
    );
  }

  // Prototype pattern - create clone with possibly different settings
  GameConfig clone({
    int? timeControlMinutes,
    int? incrementSeconds,
    bool? isWhitePlayerAI,
    bool? isBlackPlayerAI,
    int? aiDifficultyLevel,
    String? boardTheme,
    String? pieceSet,
    bool? soundEnabled,
  }) {
    return GameConfig(
      timeControlMinutes: timeControlMinutes ?? this.timeControlMinutes,
      incrementSeconds: incrementSeconds ?? this.incrementSeconds,
      isWhitePlayerAI: isWhitePlayerAI ?? this.isWhitePlayerAI,
      isBlackPlayerAI: isBlackPlayerAI ?? this.isBlackPlayerAI,
      aiDifficultyLevel: aiDifficultyLevel ?? this.aiDifficultyLevel,
      boardTheme: boardTheme ?? this.boardTheme,
      pieceSet: pieceSet ?? this.pieceSet,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  // Create with swapped player colors (for "Play Again" with reversed colors)
  GameConfig withSwappedColors() {
    return clone(
      isWhitePlayerAI: isBlackPlayerAI,
      isBlackPlayerAI: isWhitePlayerAI,
    );
  }
}

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
