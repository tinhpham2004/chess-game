import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/presentation/assets/assets.gen.dart';

class PieceAssetService {
  /// Get the asset path for a chess piece
  static String getPieceAssetPath(ChessPiece piece) {
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
}
