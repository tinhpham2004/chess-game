import 'package:chess_game/core/patterns/observer/board_observer.dart';
import 'package:flutter/material.dart';

class ChessBoardViewObserver extends StatefulWidget implements BoardObserver {
  final VoidCallback onUpdate;

  ChessBoardViewObserver({Key? key, required this.onUpdate}) : super(key: key);

  @override
  ChessBoardViewObserverState createState() => ChessBoardViewObserverState();

  @override
  void update() {
    onUpdate();
  }
}

class ChessBoardViewObserverState extends State<ChessBoardViewObserver> {
  @override
  Widget build(BuildContext context) {
    // This widget will be updated when the board state changes
    return Container(); // Placeholder - will be implemented in the actual UI
  }
}
