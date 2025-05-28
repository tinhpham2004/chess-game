import 'dart:convert';

import 'package:chess_game/core/patterns/prototype/prototype.dart';

class GameConfig implements Prototype {
  final int timeControlMinutes;
  final int incrementSeconds;
  final bool isWhitePlayerAI;
  final bool isBlackPlayerAI;
  final int aiDifficultyLevel; // 1-10
  // final String boardTheme;
  // final String pieceSet;
  final bool soundEnabled;

  GameConfig({
    required this.timeControlMinutes,
    required this.incrementSeconds,
    required this.isWhitePlayerAI,
    required this.isBlackPlayerAI,
    required this.aiDifficultyLevel,
    // required this.boardTheme,
    // required this.pieceSet,
    required this.soundEnabled,
  });

  // Convert to JSON string (for storage)
  String toJson() => jsonEncode({
        'timeControlMinutes': timeControlMinutes,
        'incrementSeconds': incrementSeconds,
        'isWhitePlayerAI': isWhitePlayerAI,
        'isBlackPlayerAI': isBlackPlayerAI,
        'aiDifficultyLevel': aiDifficultyLevel,
        // 'boardTheme': boardTheme,
        // 'pieceSet': pieceSet,
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
      // boardTheme: map['boardTheme'],
      // pieceSet: map['pieceSet'],
      soundEnabled: map['soundEnabled'],
    );
  }

  @override
  GameConfig clone({
    int? timeControlMinutes,
    int? incrementSeconds,
    bool? isWhitePlayerAI,
    bool? isBlackPlayerAI,
    int? aiDifficultyLevel,
    // String? boardTheme,
    // String? pieceSet,
    bool? soundEnabled,
  }) {
    return GameConfig(
      timeControlMinutes: timeControlMinutes ?? this.timeControlMinutes,
      incrementSeconds: incrementSeconds ?? this.incrementSeconds,
      isWhitePlayerAI: isWhitePlayerAI ?? this.isWhitePlayerAI,
      isBlackPlayerAI: isBlackPlayerAI ?? this.isBlackPlayerAI,
      aiDifficultyLevel: aiDifficultyLevel ?? this.aiDifficultyLevel,
      // boardTheme: boardTheme ?? this.boardTheme,
      // pieceSet: pieceSet ?? this.pieceSet,
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
