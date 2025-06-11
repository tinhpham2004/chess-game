import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chess_game/presentation/game_room/bloc/enhanced_game_room_bloc.dart';
import 'package:chess_game/presentation/game_room/bloc/game_mediator_bloc.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/core/models/chess_piece.dart';

/// Enhanced ChessBoard widget với Mediator Pattern
class MediatedChessBoard extends StatefulWidget {
  const MediatedChessBoard({Key? key}) : super(key: key);

  @override
  State<MediatedChessBoard> createState() => _MediatedChessBoardState();
}

class _MediatedChessBoardState extends State<MediatedChessBoard> {
  late EnhancedGameRoomBloc _enhancedBloc;
  late GameMediatorBloc _mediatorBloc;

  @override
  void initState() {
    super.initState();
    _enhancedBloc = context.read<EnhancedGameRoomBloc>();
    _mediatorBloc = _enhancedBloc.mediatorBloc;

    _setupMediatorCallbacks();
  }

  void _setupMediatorCallbacks() {
    // Setup callbacks cho các components
    _mediatorBloc.chessBoardComponent.onStateChanged = () {
      if (mounted) setState(() {});
    };

    _mediatorBloc.moveHistoryComponent.onStateChanged = () {
      if (mounted) setState(() {});
    };

    _mediatorBloc.controlPanelComponent.onStateChanged = () {
      if (mounted) setState(() {});
    };

    _mediatorBloc.chatPanelComponent.onStateChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameMediatorBloc, GameMediatorState>(
      bloc: _mediatorBloc,
      builder: (context, mediatorState) {
        return BlocBuilder<EnhancedGameRoomBloc, GameRoomState>(
          bloc: _enhancedBloc,
          builder: (context, gameState) {
            return Column(
              children: [
                // Game Status Header
                _buildGameStatus(gameState, mediatorState),

                // Main Game Area
                Expanded(
                  child: Row(
                    children: [
                      // Chess Board (main game area)
                      Expanded(
                        flex: 3,
                        child: _buildChessBoard(gameState),
                      ),

                      // Side Panel (move history, controls, chat)
                      Expanded(
                        flex: 1,
                        child: _buildSidePanel(gameState, mediatorState),
                      ),
                    ],
                  ),
                ),

                // Control Panel
                _buildControlPanel(gameState, mediatorState),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGameStatus(
      GameRoomState gameState, GameMediatorState mediatorState) {
    final chessBoardComponent = _mediatorBloc.chessBoardComponent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current Turn
          Text(
            'Turn: ${gameState.isWhitesTurn ? "White" : "Black"}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          // Game Status
          if (chessBoardComponent.isGameOver())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chessBoardComponent.gameOverReason,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

          // Timer (if enabled)
          if (gameState.timerRunning)
            Row(
              children: [
                Text('⏰ White: ${_formatTime(gameState.whiteTimeLeft)}'),
                const SizedBox(width: 16),
                Text('⏰ Black: ${_formatTime(gameState.blackTimeLeft)}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChessBoard(GameRoomState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPosition =
                box.globalToLocal(details.globalPosition);
            final Position position =
                _getPositionFromOffset(localPosition, box.size);
            _enhancedBloc.onBoardSquareTapped(position);
          },
          child: _buildBoardGrid(gameState),
        ),
      ),
    );
  }

  Widget _buildBoardGrid(GameRoomState gameState) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final position = Position(col, row);

        return _buildSquare(gameState, position, row, col);
      },
    );
  }

  Widget _buildSquare(
      GameRoomState gameState, Position position, int row, int col) {
    final piece = gameState.board.isNotEmpty ? gameState.board[row][col] : null;
    final isSelected = gameState.selectedPosition == position;
    final isPossibleMove =
        gameState.possibleMoves.isNotEmpty && gameState.possibleMoves[row][col];
    final isHintFrom = gameState.hintFromPosition == position;
    final isHintTo = gameState.hintToPosition == position;

    return Container(
      decoration: BoxDecoration(
        color: _getSquareColor(
            row, col, isSelected, isPossibleMove, isHintFrom, isHintTo),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Piece
          if (piece != null)
            Center(
              child: _buildPiece(piece),
            ),

          // Possible move indicator
          if (isPossibleMove)
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // Hint indicators
          if (isHintFrom)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow, width: 3),
              ),
            ),
          if (isHintTo)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPiece(ChessPiece piece) {
    final String assetPath =
        'assets/icons/${piece.type.name}_${piece.color.name}.svg';
    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          _getPieceSymbol(piece),
          style: TextStyle(
            fontSize: 32,
            color:
                piece.color == PieceColor.white ? Colors.white : Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildSidePanel(
      GameRoomState gameState, GameMediatorState mediatorState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Move History
          Expanded(
            flex: 2,
            child: _buildMoveHistory(),
          ),

          const Divider(),

          // Chat Panel
          Expanded(
            flex: 2,
            child: _buildChatPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveHistory() {
    final moveHistory = _mediatorBloc.moveHistoryComponent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Move History',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: moveHistory.moves.length,
              itemBuilder: (context, index) {
                final move = moveHistory.moves[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    '${index + 1}. $move',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () => moveHistory.selectMove(index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatPanel() {
    final chatPanel = _mediatorBloc.chatPanelComponent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chat',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Messages
                Expanded(
                  child: ListView.builder(
                    itemCount: chatPanel.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatPanel.messages[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${message.sender}: ${message.message}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),

                // Message input
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (message) {
                            if (message.isNotEmpty) {
                              _enhancedBloc.onSendMessage(message, 'Player');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(
      GameRoomState gameState, GameMediatorState mediatorState) {
    final controlPanel = _mediatorBloc.controlPanelComponent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed:
                controlPanel.undoEnabled ? _enhancedBloc.onUndoRequested : null,
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
          ),
          ElevatedButton.icon(
            onPressed: _enhancedBloc.onRestartRequested,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Restart'),
          ),
          ElevatedButton.icon(
            onPressed:
                controlPanel.hintEnabled ? _enhancedBloc.onHintRequested : null,
            icon: const Icon(Icons.lightbulb),
            label: const Text('Hint'),
          ),
          ElevatedButton.icon(
            onPressed: _enhancedBloc.onClearMessages,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Chat'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Position _getPositionFromOffset(Offset localPosition, Size size) {
    final squareSize = size.width / 8;
    final col = (localPosition.dx / squareSize).floor();
    final row = (localPosition.dy / squareSize).floor();
    return Position(col.clamp(0, 7), row.clamp(0, 7));
  }

  Color _getSquareColor(int row, int col, bool isSelected, bool isPossibleMove,
      bool isHintFrom, bool isHintTo) {
    if (isSelected) return Colors.blue.withValues(alpha: 0.5);
    if (isPossibleMove) return Colors.green.withValues(alpha: 0.3);
    if (isHintFrom) return Colors.yellow.withValues(alpha: 0.5);
    if (isHintTo) return Colors.orange.withValues(alpha: 0.5);

    final isLight = (row + col) % 2 == 0;
    return isLight ? Colors.grey[300]! : Colors.grey[600]!;
  }

  String _getPieceSymbol(ChessPiece piece) {
    const symbols = {
      PieceType.king: '♔♚',
      PieceType.queen: '♕♛',
      PieceType.rook: '♖♜',
      PieceType.bishop: '♗♝',
      PieceType.knight: '♘♞',
      PieceType.pawn: '♙♟',
    };

    final symbol = symbols[piece.type] ?? '?';
    return piece.color == PieceColor.white ? symbol[0] : symbol[1];
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
