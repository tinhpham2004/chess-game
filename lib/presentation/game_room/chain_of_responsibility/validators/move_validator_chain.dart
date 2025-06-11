import 'move_validator_base.dart';
import 'actual_move_validator.dart';
import 'bounds_validator.dart';
import 'occupancy_validator.dart';
import 'piece_movement_validator.dart';
import 'castling_validator.dart';
import 'en_passant_validator.dart';
import 'pawn_promotion_validator.dart';
import 'absolute_pin_validator.dart';
import 'king_safety_validator.dart';
import 'fifty_move_rule_validator.dart';
import 'threefold_repetition_validator.dart';
import 'insufficient_material_validator.dart';
import 'stalemate_validator.dart';
import 'checkmate_validator.dart';

/// Factory to create chains of validators
class MoveValidatorChain {
  /// Create the complete chain with all validators
  static MoveValidator createCompleteChain() {
    final actualMoveValidator = ActualMoveValidator();
    final boundsValidator = BoundsValidator();
    final occupancyValidator = OccupancyValidator();
    final pieceMovementValidator = PieceMovementValidator();
    final castlingValidator = CastlingValidator();
    final enPassantValidator = EnPassantValidator();
    final pawnPromotionValidator = PawnPromotionValidator();
    final absolutePinValidator = AbsolutePinValidator();
    final kingSafetyValidator = KingSafetyValidator();
    final fiftyMoveRuleValidator = FiftyMoveRuleValidator();
    final threefoldRepetitionValidator = ThreefoldRepetitionValidator();
    final insufficientMaterialValidator = InsufficientMaterialValidator();
    final stalemateValidator = StalemateValidator();
    final checkmateValidator = CheckmateValidator();

    // Chain them in optimal order (fail fast on simple checks)
    actualMoveValidator
        .setNext(boundsValidator)
        .setNext(occupancyValidator)
        .setNext(pieceMovementValidator)
        .setNext(castlingValidator)
        .setNext(enPassantValidator)
        .setNext(pawnPromotionValidator)
        .setNext(absolutePinValidator)
        .setNext(kingSafetyValidator)
        .setNext(fiftyMoveRuleValidator)
        .setNext(threefoldRepetitionValidator)
        .setNext(insufficientMaterialValidator)
        .setNext(stalemateValidator)
        .setNext(checkmateValidator);

    return actualMoveValidator;
  }

  /// Create a lightweight chain for quick validation
  static MoveValidator createBasicChain() {
    final actualMoveValidator = ActualMoveValidator();
    final boundsValidator = BoundsValidator();
    final occupancyValidator = OccupancyValidator();
    final pieceMovementValidator = PieceMovementValidator();
    final kingSafetyValidator = KingSafetyValidator();

    actualMoveValidator
        .setNext(boundsValidator)
        .setNext(occupancyValidator)
        .setNext(pieceMovementValidator)
        .setNext(kingSafetyValidator);

    return actualMoveValidator;
  }

  /// Create chain for AI move generation (skips some checks)
  static MoveValidator createAIChain() {
    final boundsValidator = BoundsValidator();
    final occupancyValidator = OccupancyValidator();
    final pieceMovementValidator = PieceMovementValidator();
    final castlingValidator = CastlingValidator();
    final enPassantValidator = EnPassantValidator();
    final absolutePinValidator = AbsolutePinValidator();
    final kingSafetyValidator = KingSafetyValidator();

    boundsValidator
        .setNext(occupancyValidator)
        .setNext(pieceMovementValidator)
        .setNext(castlingValidator)
        .setNext(enPassantValidator)
        .setNext(absolutePinValidator)
        .setNext(kingSafetyValidator);

    return boundsValidator;
  }

  /// Create FIDE rule validators (for game end condition checking)
  static Map<String, MoveValidator> createFideRuleValidators() {
    return {
      'fiftyMoveRule': FiftyMoveRuleValidator(),
      'threefoldRepetition': ThreefoldRepetitionValidator(),
      'insufficientMaterial': InsufficientMaterialValidator(),
      'stalemate': StalemateValidator(),
      'checkmate': CheckmateValidator(),
    };
  }
}
