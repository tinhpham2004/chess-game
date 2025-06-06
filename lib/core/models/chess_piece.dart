import 'package:chess_game/core/models/position.dart';

enum PieceType { pawn, rook, knight, bishop, queen, king }

enum PieceColor { white, black }

abstract class ChessPiece {
  final PieceColor color;
  PieceType type;
  Position position;

  ChessPiece({
    required this.type,
    required this.color,
    required this.position,
  });

  // Deep clone method for the Prototype Pattern
  ChessPiece clone();
  // Check if a move is valid for this piece
  bool isValidMove(Position from, Position to, List<ChessPiece> pieces);

  // Get all possible moves for this piece
  List<Position> getPossibleMoves(List<ChessPiece> pieces);
}

class Pawn extends ChessPiece {
  bool hasMoved = false;

  Pawn({
    required super.color,
    required super.position,
  }) : super(type: PieceType.pawn);

  @override
  ChessPiece clone() {
    final pawn = Pawn(color: color, position: position.clone());
    pawn.hasMoved = hasMoved;
    return pawn;
  }

  @override
  bool isValidMove(Position from, Position to, List<ChessPiece> pieces) {
    final direction = color == PieceColor.white ? -1 : 1;
    final startRow = color == PieceColor.white ? 6 : 1;

    final deltaRow = to.row - from.row;
    final deltaCol = (to.col - from.col).abs();

    final pieceAtDestination =
        pieces.where((p) => p.position == to).firstOrNull;

    // Forward move
    if (deltaCol == 0 && pieceAtDestination == null) {
      // Single move forward
      if (deltaRow == direction) return true;

      // Double move from start position
      if (from.row == startRow && deltaRow == 2 * direction) {
        return true;
      }
    }
    // Diagonal capture
    else if (deltaCol == 1 &&
        deltaRow == direction &&
        pieceAtDestination != null) {
      return pieceAtDestination.color != color;
    }

    return false;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    final moves = <Position>[];
    final direction = color == PieceColor.white ? -1 : 1;
    final startRow = color == PieceColor.white ? 6 : 1;

    // Forward moves
    final oneForward = Position(position.col, position.row + direction);
    if (oneForward.row >= 0 && oneForward.row < 8) {
      if (!pieces.any((p) => p.position == oneForward)) {
        moves.add(oneForward);

        // Double move from start position
        if (position.row == startRow) {
          final twoForward =
              Position(position.col, position.row + 2 * direction);
          if (twoForward.row >= 0 &&
              twoForward.row < 8 &&
              !pieces.any((p) => p.position == twoForward)) {
            moves.add(twoForward);
          }
        }
      }
    }

    // Diagonal captures
    for (final deltaCol in [-1, 1]) {
      final capturePos =
          Position(position.col + deltaCol, position.row + direction);
      if (capturePos.col >= 0 &&
          capturePos.col < 8 &&
          capturePos.row >= 0 &&
          capturePos.row < 8) {
        final targetPiece =
            pieces.where((p) => p.position == capturePos).firstOrNull;
        if (targetPiece != null && targetPiece.color != color) {
          moves.add(capturePos);
        }
      }
    }

    return moves;
  }
}

class Rook extends ChessPiece {
  bool hasMoved = false; // For castling

  Rook({
    required super.color,
    required super.position,
  }) : super(type: PieceType.rook);

  @override
  ChessPiece clone() {
    final rook = Rook(color: color, position: position.clone());
    rook.hasMoved = hasMoved;
    return rook;
  }

  @override
  bool isValidMove(Position from, Position to, List<ChessPiece> pieces) {
    // Rook moves horizontally or vertically
    if (from.row != to.row && from.col != to.col) return false;

    // Check if path is clear
    final deltaRow = to.row - from.row;
    final deltaCol = to.col - from.col;
    final steps =
        deltaRow.abs() > deltaCol.abs() ? deltaRow.abs() : deltaCol.abs();

    if (steps <= 1) return true;

    final rowStep = deltaRow != 0 ? deltaRow ~/ deltaRow.abs() : 0;
    final colStep = deltaCol != 0 ? deltaCol ~/ deltaCol.abs() : 0;

    for (int i = 1; i < steps; i++) {
      final checkPos =
          Position(from.col + (colStep * i), from.row + (rowStep * i));
      if (pieces.any((p) => p.position == checkPos)) {
        return false;
      }
    }

    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    final moves = <Position>[];

    // Horizontal and vertical directions
    final directions = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ];

    for (final dir in directions) {
      for (int i = 1; i < 8; i++) {
        final newPos =
            Position(position.col + dir[0] * i, position.row + dir[1] * i);

        if (newPos.col < 0 ||
            newPos.col >= 8 ||
            newPos.row < 0 ||
            newPos.row >= 8) {
          break;
        }

        final pieceAtPos =
            pieces.where((p) => p.position == newPos).firstOrNull;
        if (pieceAtPos == null) {
          moves.add(newPos);
        } else {
          if (pieceAtPos.color != color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }
}

class Knight extends ChessPiece {
  Knight({
    required super.color,
    required super.position,
  }) : super(type: PieceType.knight);

  @override
  ChessPiece clone() {
    return Knight(color: color, position: position.clone());
  }

  @override
  bool isValidMove(Position from, Position to, List<ChessPiece> pieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();

    // Knight moves in L-shape: 2 squares in one direction, 1 in perpendicular
    return (deltaRow == 2 && deltaCol == 1) || (deltaRow == 1 && deltaCol == 2);
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    final moves = <Position>[];

    // All possible knight moves (L-shaped)
    final knightMoves = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1]
    ];

    for (final move in knightMoves) {
      final newPos = Position(position.col + move[0], position.row + move[1]);

      if (newPos.col >= 0 &&
          newPos.col < 8 &&
          newPos.row >= 0 &&
          newPos.row < 8) {
        final pieceAtPos =
            pieces.where((p) => p.position == newPos).firstOrNull;
        if (pieceAtPos == null || pieceAtPos.color != color) {
          moves.add(newPos);
        }
      }
    }

    return moves;
  }
}

class Bishop extends ChessPiece {
  Bishop({
    required super.color,
    required super.position,
  }) : super(type: PieceType.bishop);

  @override
  ChessPiece clone() {
    return Bishop(color: color, position: position.clone());
  }

  @override
  bool isValidMove(Position from, Position to, List<ChessPiece> pieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();

    // Bishop moves diagonally
    if (deltaRow != deltaCol) return false;

    // Check if path is clear
    final steps = deltaRow;
    if (steps <= 1) return true;

    final rowStep = to.row > from.row ? 1 : -1;
    final colStep = to.col > from.col ? 1 : -1;

    for (int i = 1; i < steps; i++) {
      final checkPos =
          Position(from.col + (colStep * i), from.row + (rowStep * i));
      if (pieces.any((p) => p.position == checkPos)) {
        return false;
      }
    }

    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    final moves = <Position>[];

    // Diagonal directions
    final directions = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ];

    for (final dir in directions) {
      for (int i = 1; i < 8; i++) {
        final newPos =
            Position(position.col + dir[0] * i, position.row + dir[1] * i);

        if (newPos.col < 0 ||
            newPos.col >= 8 ||
            newPos.row < 0 ||
            newPos.row >= 8) {
          break;
        }

        final pieceAtPos =
            pieces.where((p) => p.position == newPos).firstOrNull;
        if (pieceAtPos == null) {
          moves.add(newPos);
        } else {
          if (pieceAtPos.color != color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }
}

class Queen extends ChessPiece {
  Queen({
    required super.color,
    required super.position,
  }) : super(type: PieceType.queen);

  @override
  ChessPiece clone() {
    return Queen(color: color, position: position.clone());
  }

  @override
  bool isValidMove(Position from, Position to, List<ChessPiece> pieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();

    // Queen moves like rook or bishop
    if (from.row == to.row || from.col == to.col || deltaRow == deltaCol) {
      // Check if path is clear
      final steps = deltaRow > deltaCol ? deltaRow : deltaCol;
      if (steps <= 1) return true;

      final rowStep = to.row == from.row ? 0 : (to.row > from.row ? 1 : -1);
      final colStep = to.col == from.col ? 0 : (to.col > from.col ? 1 : -1);

      for (int i = 1; i < steps; i++) {
        final checkPos =
            Position(from.col + (colStep * i), from.row + (rowStep * i));
        if (pieces.any((p) => p.position == checkPos)) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    final moves = <Position>[];

    // Queen moves like rook + bishop (all 8 directions)
    final directions = [
      [0, 1], [0, -1], [1, 0], [-1, 0], // Rook moves
      [1, 1], [1, -1], [-1, 1], [-1, -1] // Bishop moves
    ];

    for (final dir in directions) {
      for (int i = 1; i < 8; i++) {
        final newPos =
            Position(position.col + dir[0] * i, position.row + dir[1] * i);

        if (newPos.col < 0 ||
            newPos.col >= 8 ||
            newPos.row < 0 ||
            newPos.row >= 8) {
          break;
        }

        final pieceAtPos =
            pieces.where((p) => p.position == newPos).firstOrNull;
        if (pieceAtPos == null) {
          moves.add(newPos);
        } else {
          if (pieceAtPos.color != color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }
}

class King extends ChessPiece {
  bool hasMoved = false; // For castling

  King({
    required super.color,
    required super.position,
  }) : super(type: PieceType.king);

  @override
  ChessPiece clone() {
    final king = King(color: color, position: position.clone());
    king.hasMoved = hasMoved;
    return king;
  }

  @override
  bool isValidMove(Position from, Position to, List<ChessPiece> pieces) {
    final deltaRow = (to.row - from.row).abs();
    final deltaCol = (to.col - from.col).abs();

    // King moves one square in any direction
    return deltaRow <= 1 && deltaCol <= 1;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    final moves = <Position>[];

    // King moves one square in all directions
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    for (final dir in directions) {
      final newPos = Position(position.col + dir[0], position.row + dir[1]);

      if (newPos.col >= 0 &&
          newPos.col < 8 &&
          newPos.row >= 0 &&
          newPos.row < 8) {
        final pieceAtPos =
            pieces.where((p) => p.position == newPos).firstOrNull;
        if (pieceAtPos == null || pieceAtPos.color != color) {
          moves.add(newPos);
        }
      }
    }

    return moves;
  }
}
