import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/assets/assets.gen.dart';

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  // This will store our chess pieces
  late List<List<ChessPiece?>> _board;

  @override
  void initState() {
    super.initState();
    _setupInitialBoard();
  }

  void _setupInitialBoard() {
    // Initialize empty 8x8 board
    _board = List.generate(8, (_) => List.generate(8, (_) => null));

    // Set up initial pieces
    // Pawns
    for (int i = 0; i < 8; i++) {
      _board[1][i] = _createPiece(PieceType.pawn, PieceColor.black, Position(i, 1));
      _board[6][i] = _createPiece(PieceType.pawn, PieceColor.white, Position(i, 6));
    }

    // Rooks
    _board[0][0] = _createPiece(PieceType.rook, PieceColor.black, Position(0, 0));
    _board[0][7] = _createPiece(PieceType.rook, PieceColor.black, Position(7, 0));
    _board[7][0] = _createPiece(PieceType.rook, PieceColor.white, Position(0, 7));
    _board[7][7] = _createPiece(PieceType.rook, PieceColor.white, Position(7, 7));

    // Knights
    _board[0][1] = _createPiece(PieceType.knight, PieceColor.black, Position(1, 0));
    _board[0][6] = _createPiece(PieceType.knight, PieceColor.black, Position(6, 0));
    _board[7][1] = _createPiece(PieceType.knight, PieceColor.white, Position(1, 7));
    _board[7][6] = _createPiece(PieceType.knight, PieceColor.white, Position(6, 7));

    // Bishops
    _board[0][2] = _createPiece(PieceType.bishop, PieceColor.black, Position(2, 0));
    _board[0][5] = _createPiece(PieceType.bishop, PieceColor.black, Position(5, 0));
    _board[7][2] = _createPiece(PieceType.bishop, PieceColor.white, Position(2, 7));
    _board[7][5] = _createPiece(PieceType.bishop, PieceColor.white, Position(5, 7));

    // Queens
    _board[0][3] = _createPiece(PieceType.queen, PieceColor.black, Position(3, 0));
    _board[7][3] = _createPiece(PieceType.queen, PieceColor.white, Position(3, 7));

    // Kings
    _board[0][4] = _createPiece(PieceType.king, PieceColor.black, Position(4, 0));
    _board[7][4] = _createPiece(PieceType.king, PieceColor.white, Position(4, 7));
  }

  ChessPiece _createPiece(PieceType type, PieceColor color, Position position) {
    switch (type) {
      case PieceType.pawn:
        return Pawn(color: color, position: position);
      case PieceType.rook:
        return Rook(color: color, position: position);
      case PieceType.knight:
        return Knight(color: color, position: position);
      case PieceType.bishop:
        return Bishop(color: color, position: position);
      case PieceType.queen:
        return Queen(color: color, position: position);
      case PieceType.king:
        return King(color: color, position: position);
    }
  }

  String _getPieceAssetPath(ChessPiece piece) {
    final isWhite = piece.color == PieceColor.white;

    switch (piece.type) {
      case PieceType.pawn:
        return isWhite ? Assets.icons.pawnWhite : Assets.icons.pawnBlack;
      case PieceType.rook:
        return isWhite ? Assets.icons.rookWhite : Assets.icons.rookBlack;
      case PieceType.knight:
        return isWhite ? Assets.icons.knightWhite : Assets.icons.knightBlack;
      case PieceType.bishop:
        return isWhite ? Assets.icons.bishopWhite : Assets.icons.bishopBlack;
      case PieceType.queen:
        return isWhite ? Assets.icons.queenWhite : Assets.icons.queenBlack;
      case PieceType.king:
        return isWhite ? Assets.icons.kingWhite : Assets.icons.kingBlack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Keep the board square
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8, // 8x8 grid for chess
        ),
        itemCount: 64, // 64 squares total
        itemBuilder: (context, index) {
          // Determine if this square is white or black
          final row = index ~/ 8; // Integer division to get row number
          final col = index % 8; // Modulo to get column number
          final isWhite = (row + col) % 2 == 0;

          // Get the piece at this position
          final piece = _board[row][col];

          return Stack(
            children: [
              // The square background
              SvgPicture.asset(
                isWhite ? Assets.icons.squareWhite : Assets.icons.squareBlack,
                fit: BoxFit.cover,
              ),

              // The chess piece (if there is one)
              if (piece != null)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    _getPieceAssetPath(piece),
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
