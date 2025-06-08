import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'package:chess_game/presentation/game_room/command/command.dart';
import 'package:chess_game/presentation/game_room/memento/chess_board_manager.dart';

/// Command cho nước đi bắt tốt qua đường (en passant)
class EnPassantCommand implements Command {
  final ChessPiece pawn;
  final Position from;
  final Position to;
  final ChessPiece capturedPawn;
  final Position capturedPawnPosition;
  final ChessBoardManager? boardManager;
  late final Position oldPawnPosition;

  EnPassantCommand({
    required this.pawn,
    required this.from,
    required this.to,
    required this.capturedPawn,
    required this.capturedPawnPosition,
    this.boardManager,
  }) {
    oldPawnPosition = pawn.position.clone();
  }

  @override
  void execute() {
    if (boardManager != null) {
      // Di chuyển tốt
      boardManager!.movePiece(from, to);
      // Xóa tốt bị bắt qua đường
      boardManager!.setPieceAt(capturedPawnPosition, null);
    } else {
      pawn.position = to;
      // Nếu không có boardManager, cần xử lý xóa capturedPawn khỏi board thủ công
    }
  }

  @override
  void undo() {
    if (boardManager != null) {
      // Trả lại tốt bị bắt qua đường
      boardManager!.setPieceAt(capturedPawnPosition, capturedPawn);
      // Trả lại tốt về vị trí cũ
      boardManager!.movePiece(to, from);
    } else {
      pawn.position = oldPawnPosition;
      // Nếu không có boardManager, cần xử lý thêm lại capturedPawn thủ công
    }
  }

  @override
  void redo() {
    execute();
  }
}
