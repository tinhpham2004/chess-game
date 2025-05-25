import 'dart:convert';

class MatchHistoryEntity {
  final String id;
  final String gameId;
  final String whitePlayer;
  final String blackPlayer;
  final String winner; // 'white', 'black', or 'draw'
  final String moveHistory;
  final DateTime date;
  final bool isAiOpponent;
  final int? aiDifficulty;

  MatchHistoryEntity({
    required this.id,
    required this.gameId,
    required this.whitePlayer,
    required this.blackPlayer,
    required this.winner,
    required this.moveHistory,
    required this.date,
    required this.isAiOpponent,
    this.aiDifficulty,
  });

  factory MatchHistoryEntity.fromMap(Map<String, dynamic> map) {
    return MatchHistoryEntity(
      id: map['id'],
      gameId: map['gameId'],
      whitePlayer: map['whitePlayer'],
      blackPlayer: map['blackPlayer'],
      winner: map['winner'],
      moveHistory: map['moveHistory'],
      date: DateTime.parse(map['date']),
      isAiOpponent: map['isAiOpponent'] == 1,
      aiDifficulty: map['aiDifficulty'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameId': gameId,
      'whitePlayer': whitePlayer,
      'blackPlayer': blackPlayer,
      'winner': winner,
      'moveHistory': moveHistory,
      'date': date.toIso8601String(),
      'isAiOpponent': isAiOpponent ? 1 : 0,
      'aiDifficulty': aiDifficulty,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory MatchHistoryEntity.fromJson(String source) => MatchHistoryEntity.fromMap(jsonDecode(source));
}
