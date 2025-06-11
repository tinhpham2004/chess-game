import 'package:chess_game/core/models/chess_piece.dart';
import 'package:chess_game/core/models/position.dart';
import 'validators/move_validator_base.dart';
import 'validators/move_validator_chain.dart';
import 'validators/king_safety_validator.dart';
import 'validators/fifty_move_rule_validator.dart';
import 'validators/threefold_repetition_validator.dart';
import 'validators/insufficient_material_validator.dart';
import 'validators/stalemate_validator.dart';
import 'validators/checkmate_validator.dart';

/// Wrapper class for GameRoom usage
class GameRoomMoveValidator {
  final MoveValidator _validatorChain;
  final MoveValidator _aiValidatorChain;
  final Map<String, MoveValidator> _fideValidators;

  GameRoomMoveValidator()
      : _validatorChain = MoveValidatorChain.createCompleteChain(),
        _aiValidatorChain = MoveValidatorChain.createAIChain(),
        _fideValidators = MoveValidatorChain.createFideRuleValidators();

  bool validateMove(
      ChessPiece piece, Position from, Position to, List<ChessPiece> allPieces,
      {bool isAI = false, FIDERuleContext? context}) {
    final chain = isAI ? _aiValidatorChain : _validatorChain;
    return chain.validate(piece, from, to, allPieces, context);
  }

  /// Get all valid moves for a piece
  List<Position> getValidMovesForPiece(
      ChessPiece piece, List<ChessPiece> allPieces,
      [FIDERuleContext? context]) {
    final validMoves = <Position>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final to = Position(col, row);
        if (validateMove(piece, piece.position, to, allPieces,
            context: context)) {
          validMoves.add(to);
        }
      }
    }

    return validMoves;
  }

  /// Check if fifty-move rule draw can be claimed
  bool canClaimFiftyMoveRule(FIDERuleContext context) {
    final validator =
        _fideValidators['fiftyMoveRule'] as FiftyMoveRuleValidator;
    return validator.canClaimFiftyMoveRule(context);
  }

  /// Check if threefold repetition draw can be claimed
  bool canClaimThreefoldRepetition(
      FIDERuleContext context, List<ChessPiece> pieces) {
    final validator =
        _fideValidators['threefoldRepetition'] as ThreefoldRepetitionValidator;
    return validator.canClaimThreefoldRepetition(context, pieces);
  }

  /// Check if the position has insufficient material for checkmate
  bool hasInsufficientMaterial(List<ChessPiece> pieces) {
    final validator = _fideValidators['insufficientMaterial']
        as InsufficientMaterialValidator;
    return validator.hasInsufficientMaterial(pieces);
  }

  /// Check if the current position is stalemate
  bool isStalemate(PieceColor colorToMove, List<ChessPiece> pieces) {
    final validator = _fideValidators['stalemate'] as StalemateValidator;
    return validator.isStalemate(colorToMove, pieces);
  }

  /// Check if the current position is checkmate
  bool isCheckmate(PieceColor colorToMove, List<ChessPiece> pieces) {
    final validator = _fideValidators['checkmate'] as CheckmateValidator;
    return validator.isCheckmate(colorToMove, pieces);
  }

  /// Check if king is in check
  bool isKingInCheck(PieceColor kingColor, List<ChessPiece> pieces) {
    final kingSafetyValidator = KingSafetyValidator();
    return kingSafetyValidator.isKingInCheck(kingColor, pieces);
  }
}
