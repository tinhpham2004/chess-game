class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  // Deep clone method (part of Prototype pattern)
  Position clone() => Position(x, y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  // Get algebraic notation (e.g. "e4")
  String get algebraic {
    final file = String.fromCharCode('a'.codeUnitAt(0) + x);
    final rank = 8 - y;
    return '$file$rank';
  }

  // Add row/col getters for compatibility with other code in the codebase
  int get row => y;
  int get col => x;

  // Create position from algebraic notation
  factory Position.fromAlgebraic(String notation) {
    final file = notation[0];
    final rank = int.parse(notation[1]);

    final x = file.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final y = 8 - rank;

    return Position(x, y);
  }
}
