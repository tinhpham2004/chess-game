import 'package:flutter/material.dart';
import 'package:chess_game/presentation/game_room/mediator/components/move_history_component.dart';

class MoveHistoryWidget extends StatefulWidget {
  final MoveHistoryComponent component;
  
  const MoveHistoryWidget({
    Key? key,
    required this.component,
  }) : super(key: key);

  @override
  State<MoveHistoryWidget> createState() => _MoveHistoryWidgetState();
}

class _MoveHistoryWidgetState extends State<MoveHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Move History', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.component.moves.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text('${index + 1}. ${widget.component.moves[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}