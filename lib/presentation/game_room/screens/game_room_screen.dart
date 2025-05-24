import 'package:flutter/material.dart';

class GameRoomScreen extends StatelessWidget {
  final String gameId;
  const GameRoomScreen({required this.gameId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ván cờ: $gameId'),
      ),
      body: Center(
        child: Text(
          'Đang hiển thị nội dung của ván cờ có ID: $gameId',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
