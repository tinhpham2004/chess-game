import 'dart:convert';

class GameRoomEntity {
  final String id;
  final String json;

  GameRoomEntity({
    required this.id,
    required this.json,
  });

  factory GameRoomEntity.fromMap(Map<String, dynamic> map) {
    return GameRoomEntity(
      id: map['id'],
      json: map['json'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'json': json,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory GameRoomEntity.fromJson(String source) => GameRoomEntity.fromMap(jsonDecode(source));
}
