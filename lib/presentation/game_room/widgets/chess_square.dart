import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/assets/assets.gen.dart';
import 'package:chess_game/presentation/game_room/services/piece_asset_service.dart';

class ChessSquare extends StatelessWidget {
  final int row;
  final int col;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isHovered;
  final bool isPossibleMove;
  final bool isDraggedPiece;
  final bool isHintFrom;
  final bool isHintTo;
  final bool isKingInCheck;
  final Function(int row, int col) onTap;
  final Function(Position from, Position to) onPieceDropped;
  final Function(Position position) onHoverEnter;
  final Function() onHoverExit;
  final Function(ChessPiece piece) onDragStarted;
  final Function(bool wasAccepted) onDragEnd;

  const ChessSquare({
    super.key,
    required this.row,
    required this.col,
    required this.piece,
    required this.isSelected,
    required this.isHovered,
    required this.isPossibleMove,
    required this.isDraggedPiece,
    this.isHintFrom = false,
    this.isHintTo = false,
    this.isKingInCheck = false,
    required this.onTap,
    required this.onPieceDropped,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  bool get _isWhiteSquare => (row + col) % 2 == 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverEnter(Position(col, row)),
      onExit: (_) => onHoverExit(),
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (dragTargetDetails) {
          final fromPos = dragTargetDetails.data['position'] as Position;
          return isPossibleMove && fromPos != Position(col, row);
        },
        onAcceptWithDetails: (dragTargetDetails) {
          final fromPos = dragTargetDetails.data['position'] as Position;
          onPieceDropped(fromPos, Position(col, row));
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () => onTap(row, col),
            child: Stack(
              children: [
                _buildSquareBackground(),
                if (piece != null) _buildChessPiece(),
                if (isPossibleMove) _buildPossibleMoveIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSquareBackground() {
    return Container(
      decoration: BoxDecoration(
        border: isKingInCheck
            ? Border.all(color: Colors.red, width: 4)
            : isSelected
                ? Border.all(color: Colors.amber, width: 4)
                : isHintFrom
                    ? Border.all(color: Colors.blue, width: 3)
                    : isHintTo
                        ? Border.all(color: Colors.purple, width: 3)
                        : isHovered && isPossibleMove
                            ? Border.all(color: Colors.green, width: 2)
                            : null,
        boxShadow: isKingInCheck
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ]
            : isSelected
                ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : isHintFrom
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : isHintTo
                        ? [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : isHovered && isPossibleMove
                            ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
      ),
      child: SvgPicture.asset(
        _isWhiteSquare ? Assets.icons.squareWhite : Assets.icons.squareBlack,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildChessPiece() {
    return Draggable<Map<String, dynamic>>(
      data: {
        'position': Position(col, row),
        'piece': piece,
      },
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 60,
          height: 60,
          child: SvgPicture.asset(
            PieceAssetService.getPieceAssetPath(piece!),
            fit: BoxFit.contain,
          ),
        ),
      ),
      childWhenDragging: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
      ),
      onDragStarted: () => onDragStarted(piece!),
      onDragEnd: (details) => onDragEnd(details.wasAccepted),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SvgPicture.asset(
          PieceAssetService.getPieceAssetPath(piece!),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPossibleMoveIndicator() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: piece == null ? 20 : 12,
        height: piece == null ? 20 : 12,
        decoration: BoxDecoration(
          color: piece == null ? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
