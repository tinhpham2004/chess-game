import 'package:flutter/material.dart';
import 'package:chess_game/presentation/game_room/mediator/components/control_panel_component.dart';

class ControlPanelWidget extends StatefulWidget {
  final ControlPanelComponent component;
  
  const ControlPanelWidget({
    Key? key,
    required this.component,
  }) : super(key: key);

  @override
  State<ControlPanelWidget> createState() => _ControlPanelWidgetState();
}

class _ControlPanelWidgetState extends State<ControlPanelWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: widget.component.undoEnabled 
              ? widget.component.onUndoPressed 
              : null,
          child: Text('Undo'),
        ),
        ElevatedButton(
          onPressed: widget.component.hintEnabled 
              ? widget.component.onHintPressed 
              : null,
          child: Text('Hint'),
        ),
        ElevatedButton(
          onPressed: widget.component.restartGame,
          child: Text('Restart'),
        ),
      ],
    );
  }
}