import 'package:flutter/material.dart';
import 'package:chess_game/presentation/game_room/mediator/components/control_panel_component.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';

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
      padding: EdgeInsets.all(AppSpacing.rem100),
      decoration: BoxDecoration(
        color: _themeColor.surfaceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.rem100),
        border: Border.all(color: _themeColor.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.undo,
            label: 'Undo',
            enabled: widget.component.undoEnabled,
            onPressed: widget.component.onUndoPressed,
          ),
          _buildControlButton(
            icon: Icons.lightbulb_outline,
            label: 'Hint',
            enabled: widget.component.hintEnabled,
            onPressed: widget.component.onHintPressed,
          ),
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Restart',
            enabled: true,
            onPressed: widget.component.restartGame,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled 
                ? _themeColor.primaryColor 
                : _themeColor.surfaceColor,
            foregroundColor: enabled 
                ? Colors.white 
                : _themeColor.textSecondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.rem075),
            ),
            padding: EdgeInsets.all(AppSpacing.rem100),
          ),
          child: Icon(icon),
        ),
        SizedBox(height: AppSpacing.rem050),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled 
                ? _themeColor.textPrimaryColor 
                : _themeColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}