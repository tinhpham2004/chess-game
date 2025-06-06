import 'package:flutter/material.dart';
import 'package:chess_game/presentation/game_room/mediator/components/move_history_component.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';

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
  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  void initState() {
    super.initState();
    // ✅ Listen to component state changes để rebuild UI
    widget.component.onStateChanged = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _themeColor.borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.rem100),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.rem100),
            decoration: BoxDecoration(
              color: _themeColor.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.rem100),
                topRight: Radius.circular(AppSpacing.rem100),
              ),
            ),
            child: Text(
              'Move History (${widget.component.moves.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _themeColor.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Moves list
          Expanded(
            child: widget.component.moves.isEmpty
                ? Center(
                    child: Text(
                      'No moves yet\nStart playing!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _themeColor.textSecondaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.rem075),
                    itemCount: widget.component.moves.length,
                    itemBuilder: (context, index) {
                      final move = widget.component.moves[index];
                      final moveNumber = (index ~/ 2) + 1;
                      final isWhiteMove = index % 2 == 0;
                      
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isWhiteMove ? Colors.white : Colors.black,
                            border: Border.all(color: _themeColor.borderColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '$moveNumber',
                              style: TextStyle(
                                fontSize: 10,
                                color: isWhiteMove ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          move,
                          style: TextStyle(
                            color: _themeColor.textPrimaryColor,
                            fontFamily: 'monospace',
                          ),
                        ),
                        subtitle: Text(
                          isWhiteMove ? 'White' : 'Black',
                          style: TextStyle(
                            fontSize: 12,
                            color: _themeColor.textSecondaryColor,
                          ),
                        ),
                        onTap: () => widget.component.selectMove(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}