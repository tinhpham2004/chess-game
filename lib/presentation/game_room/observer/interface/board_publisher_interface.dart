// Publisher interface for the Oberver pattern in a game room context

import 'package:chess_game/core/models/board.dart';
import 'package:chess_game/presentation/game_room/observer/interface/board_subscriber_interface.dart';

abstract class IBoardPublisher {
  void subscribe(IBoardSubscriber observer);
  void unsubscribe(IBoardSubscriber observer);
  void notifySubscribers(Board board);
}
