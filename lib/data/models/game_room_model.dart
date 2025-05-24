import 'dart:convert';

class GameRoomModel {
  final String id;
  final String json;

  GameRoomModel({
    required this.id,
    required this.json,
  });

  factory GameRoomModel.fromMap(Map<String, dynamic> map) {
    return GameRoomModel(
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

  factory GameRoomModel.fromJson(String source) => GameRoomModel.fromMap(jsonDecode(source));
}
