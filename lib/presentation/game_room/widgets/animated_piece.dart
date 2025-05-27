import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/services/piece_asset_service.dart';

class AnimatedPiece extends StatefulWidget {
  final ChessPiece piece;
  final Position fromPosition;
  final Position toPosition;
  final double squareSize;
  final VoidCallback onAnimationComplete;
  final Duration duration;

  const AnimatedPiece({
    super.key,
    required this.piece,
    required this.fromPosition,
    required this.toPosition,
    required this.squareSize,
    required this.onAnimationComplete,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedPiece> createState() => _AnimatedPieceState();
}

class _AnimatedPieceState extends State<AnimatedPiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Calculate offset from source to destination
    final fromOffset = Offset(
      widget.fromPosition.col * widget.squareSize,
      widget.fromPosition.row * widget.squareSize,
    );
    final toOffset = Offset(
      widget.toPosition.col * widget.squareSize,
      widget.toPosition.row * widget.squareSize,
    );

    _offsetAnimation = Tween<Offset>(
      begin: fromOffset,
      end: toOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation and call completion callback
    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Positioned(
          left: _offsetAnimation.value.dx,
          top: _offsetAnimation.value.dy,
          width: widget.squareSize,
          height: widget.squareSize,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset(
              PieceAssetService.getPieceAssetPath(widget.piece),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
