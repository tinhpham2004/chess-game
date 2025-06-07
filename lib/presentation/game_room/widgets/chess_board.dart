import 'package:chess_game/core/common/button/common_button.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/widgets/chess_square.dart';
import 'package:chess_game/presentation/game_room/widgets/animated_piece.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';

// This widget has been refactored to use BLoC pattern instead of ChessLogicService
class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  Position? _hoveredPosition;
  Position? _draggedPiecePosition;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameRoomBloc, GameRoomState>(
      builder: (context, state) {
        if (!state.gameStarted) {
          return _buildStartGamePrompt(context);
        }

        return Column(
          children: [
            // Game status info
            _buildGameStatus(context, state),
            SizedBox(height: AppSpacing.rem300), // Chess board
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown, width: 4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final squareSize = constraints.maxWidth / 8;

                    return Stack(
                      children: [
                        // Chess board grid
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                          ),
                          itemCount: 64,
                          itemBuilder: (context, index) {
                            final row = index ~/ 8;
                            final col = index % 8;

                            // Hide piece if it's currently being animated
                            ChessPiece? piece = state.board.isNotEmpty
                                ? state.board[row][col]
                                : null;
                            if (state.animatingMove != null &&
                                state.animatingMove!.fromPosition.row == row &&
                                state.animatingMove!.fromPosition.col == col) {
                              piece =
                                  null; // Hide the piece at source position during animation
                            }

                            final isSelected =
                                state.selectedPosition?.row == row &&
                                    state.selectedPosition?.col == col;
                            final isHovered = _hoveredPosition?.row == row &&
                                _hoveredPosition?.col == col;
                            final isPossibleMove =
                                state.possibleMoves.isNotEmpty &&
                                    state.possibleMoves[row][col];
                            final isDraggedPiece =
                                _draggedPiecePosition?.row == row &&
                                    _draggedPiecePosition?.col == col;
                            final isHintFrom =
                                state.hintFromPosition?.row == row &&
                                    state.hintFromPosition?.col == col;
                            final isHintTo = state.hintToPosition?.row == row &&
                                state.hintToPosition?.col == col;

                            // Check if this square contains a king in check
                            final isKingInCheck = piece != null &&
                                piece.type == PieceType.king &&
                                ((piece.color == PieceColor.white &&
                                        state.isWhiteKingInCheck) ||
                                    (piece.color == PieceColor.black &&
                                        state.isBlackKingInCheck));

                            // Check if this square contains an attacking piece
                            final currentPosition = Position(col, row);
                            final isAttackingPiece = piece != null &&
                                (state.whiteAttackingPieces
                                        .contains(currentPosition) ||
                                    state.blackAttackingPieces
                                        .contains(currentPosition));

                            return ChessSquare(
                              row: row,
                              col: col,
                              piece: piece,
                              isSelected: isSelected,
                              isHovered: isHovered,
                              isPossibleMove: isPossibleMove,
                              isDraggedPiece: isDraggedPiece,
                              isHintFrom: isHintFrom,
                              isHintTo: isHintTo,
                              isKingInCheck: isKingInCheck,
                              isAttackingPiece: isAttackingPiece,
                              onTap: _onSquareTapped,
                              onPieceDropped: _onPieceDropped,
                              onHoverEnter: _onHoverEnter,
                              onHoverExit: _onHoverExit,
                              onDragStarted: _onDragStarted,
                              onDragEnd: _onDragEnd,
                            );
                          },
                        ),

                        // Animated piece overlay
                        if (state.animatingMove != null)
                          AnimatedPiece(
                            piece: state.animatingMove!.piece,
                            fromPosition: state.animatingMove!.fromPosition,
                            toPosition: state.animatingMove!.toPosition,
                            squareSize: squareSize,
                            onAnimationComplete: () {
                              context.read<GameRoomBloc>().add(
                                    AnimationCompletedEvent(
                                      from: state.animatingMove!.fromPosition,
                                      to: state.animatingMove!.toPosition,
                                    ),
                                  );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStartGamePrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Ready to start a new chess game?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.rem200),
          BlocBuilder<GameRoomBloc, GameRoomState>(
            builder: (context, state) {
              if (state.gameConfig != null) {
                return CommonButton(
                  text: 'Start Game',
                  onPressed: () {
                    context
                        .read<GameRoomBloc>()
                        .add(StartNewGameEvent(gameConfig: state.gameConfig!));
                  },
                );
              } else {
                return const Text(
                  'Loading game configuration...',
                  style: TextStyle(fontSize: 16),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatus(BuildContext context, GameRoomState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Turn: ${state.isWhitesTurn ? "White" : "Black"}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (state.gameEnded && state.winner != null)
            Text(
              'Winner: ${state.winner!.toUpperCase()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          if (state.aiColor != null)
            Row(
              children: [
                const Icon(Icons.computer, size: 16),
                const SizedBox(width: 4),
                Text(
                  'AI: ${state.aiColor == PieceColor.white ? "White" : "Black"}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _onSquareTapped(int row, int col) {
    final position = Position(col, row);
    final bloc = context.read<GameRoomBloc>();
    final state = bloc.state;

    if (state.selectedPosition == null) {
      // No piece selected, try to select this piece
      if (state.board.isNotEmpty &&
          row < state.board.length &&
          col < state.board[row].length &&
          state.board[row][col] != null) {
        bloc.add(SelectPieceEvent(position: position));
      }
    } else {
      // A piece is already selected
      if (state.selectedPosition!.row == row &&
          state.selectedPosition!.col == col) {
        // Tapped on the same piece, deselect
        bloc.add(DeselectPieceEvent());
      } else if (state.possibleMoves.isNotEmpty &&
          row < state.possibleMoves.length &&
          col < state.possibleMoves[row].length &&
          state.possibleMoves[row][col]) {
        // Valid move, execute it
        bloc.add(MovePieceEvent(
          from: state.selectedPosition!,
          to: position,
        ));
      } else if (state.board.isNotEmpty &&
          row < state.board.length &&
          col < state.board[row].length &&
          state.board[row][col] != null) {
        // Tapped on another piece, select it
        bloc.add(SelectPieceEvent(position: position));
      } else {
        // Tapped on empty square (invalid move), deselect
        bloc.add(DeselectPieceEvent());
      }
    }
  }

  void _onPieceDropped(Position from, Position to) {
    final bloc = context.read<GameRoomBloc>();
    final state = bloc.state;

    if (state.possibleMoves.isNotEmpty &&
        to.row < state.possibleMoves.length &&
        to.col < state.possibleMoves[to.row].length &&
        state.possibleMoves[to.row][to.col]) {
      bloc.add(MovePieceEvent(from: from, to: to));
    }

    setState(() {
      _draggedPiecePosition = null;
    });
  }

  void _onHoverEnter(Position position) {
    setState(() {
      _hoveredPosition = position;
    });
  }

  void _onHoverExit() {
    setState(() {
      _hoveredPosition = null;
    });
  }

  void _onDragStarted(ChessPiece piece) {
    final bloc = context.read<GameRoomBloc>();

    setState(() {
      _draggedPiecePosition = piece.position;
    });

    // Select the piece being dragged
    bloc.add(SelectPieceEvent(position: piece.position));
  }

  void _onDragEnd(bool wasAccepted) {
    if (!wasAccepted) {
      // If drag was not accepted, deselect the piece
      context.read<GameRoomBloc>().add(DeselectPieceEvent());
    }

    setState(() {
      _draggedPiecePosition = null;
    });
  }
}
