// Subsriber interface for board updates in a game room

import 'package:chess_game/core/models/board.dart';

abstract class IBoardSubscriber {
  void update(Board board);
}
