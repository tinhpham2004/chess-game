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
    // Implementation for pawn move validation
    // This is a simplified version
    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    // Implementation to get all possible moves
    return [];
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
    // Implementation for rook move validation
    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    // Implementation to get all possible moves
    return [];
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
    // Implementation for knight move validation
    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    // Implementation to get all possible moves
    return [];
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
    // Implementation for bishop move validation
    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    // Implementation to get all possible moves
    return [];
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
    // Implementation for queen move validation
    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    // Implementation to get all possible moves
    return [];
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
    // Implementation for king move validation
    return true;
  }

  @override
  List<Position> getPossibleMoves(List<ChessPiece> pieces) {
    // Implementation to get all possible moves
    return [];
  }
}
