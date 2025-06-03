import 'package:flutter/material.dart';
import 'package:chess_game/presentation/game_room/mediator/components/chat_panel_component.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';

class ChatPanelWidget extends StatefulWidget {
  final ChatPanelComponent component;
  
  const ChatPanelWidget({
    Key? key,
    required this.component,
  }) : super(key: key);

  @override
  State<ChatPanelWidget> createState() => _ChatPanelWidgetState();
}

class _ChatPanelWidgetState extends State<ChatPanelWidget> {
  final TextEditingController _messageController = TextEditingController();
  final _themeColor = getIt.get<AppTheme>().themeColor;

  @override
  void initState() {
    super.initState();
    // Listen to component state changes để rebuild UI
    widget.component.onStateChanged = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Tăng height để dễ nhìn hơn
      decoration: BoxDecoration(
        border: Border.all(color: _themeColor.borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.rem100),
        color: _themeColor.surfaceColor,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.rem150,
              vertical: AppSpacing.rem100,
            ),
            decoration: BoxDecoration(
              color: _themeColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.rem100),
                topRight: Radius.circular(AppSpacing.rem100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Game Chat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _themeColor.textPrimaryColor,
                  ),
                ),
                // Connection status indicator
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.rem100,
                    vertical: AppSpacing.rem050,
                  ),
                  decoration: BoxDecoration(
                    color: widget.component.isConnected 
                        ? Colors.green 
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(AppSpacing.rem050),
                  ),
                  child: Text(
                    widget.component.isConnected ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.rem100),
              itemCount: widget.component.messages.length,
              itemBuilder: (context, index) {
                final message = widget.component.messages[index];
                final isSystemMessage = message.sender == 'System';
                
                return Container(
                  margin: EdgeInsets.only(bottom: AppSpacing.rem075),
                  child: isSystemMessage 
                      ? _buildSystemMessage(message)
                      : _buildUserMessage(message),
                );
              },
            ),
          ),
          
          // Message input
          Container(
            padding: EdgeInsets.all(AppSpacing.rem100),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: _themeColor.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: _themeColor.textSecondaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.rem100),
                        borderSide: BorderSide(
                          color: _themeColor.borderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.rem100),
                        borderSide: BorderSide(
                          color: _themeColor.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.rem100),
                        borderSide: BorderSide(
                          color: _themeColor.primaryColor,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.rem150,
                        vertical: AppSpacing.rem100,
                      ),
                      filled: true,
                      fillColor: _themeColor.backgroundColor,
                    ),
                    style: TextStyle(
                      color: _themeColor.textPrimaryColor,
                    ),
                    maxLines: 1,
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                SizedBox(width: AppSpacing.rem100),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor.primaryColor,
                    foregroundColor: _themeColor.onPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.rem100),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.rem150,
                      vertical: AppSpacing.rem100,
                    ),
                  ),
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage message) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.rem100,
        vertical: AppSpacing.rem075,
      ),
      decoration: BoxDecoration(
        color: _themeColor.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.rem100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: _themeColor.secondaryColor,
          ),
          SizedBox(width: AppSpacing.rem075),
          Flexible(
            child: Text(
              message.message, // Sửa từ 'content' thành 'message'
              style: TextStyle(
                color: _themeColor.textSecondaryColor,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage message) {
    final isCurrentUser = message.sender == 'Player'; // Có thể customize logic này
    
    return Align(
      alignment: isCurrentUser 
          ? Alignment.centerRight 
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.rem100,
          vertical: AppSpacing.rem075,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser 
              ? _themeColor.primaryColor 
              : _themeColor.surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.rem100),
          border: !isCurrentUser 
              ? Border.all(color: _themeColor.borderColor) 
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCurrentUser) ...[
              Text(
                message.sender,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: _themeColor.primaryColor,
                ),
              ),
              SizedBox(height: AppSpacing.rem025),
            ],
            Text(
              message.message, // Sửa từ 'content' thành 'message'
              style: TextStyle(
                color: isCurrentUser 
                    ? _themeColor.onPrimaryColor 
                    : _themeColor.textPrimaryColor,
                fontSize: 13,
              ),
            ),
            SizedBox(height: AppSpacing.rem025),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser 
                    ? _themeColor.onPrimaryColor.withOpacity(0.7)
                    : _themeColor.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      widget.component.sendMessage(
        text,
        'Player', // Có thể lấy từ game config hoặc user preferences
      );
      _messageController.clear();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}