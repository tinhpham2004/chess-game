import 'package:chess_game/data/datasource/match_history_dao.dart';
import 'package:chess_game/data/entities/match_history_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class MatchHistoryRepository {
  final MatchHistoryDao _dao;

  MatchHistoryRepository(this._dao);

  Future<void> saveMatchHistory(MatchHistoryEntity matchHistory) async {
    await _dao.insertMatchHistory(matchHistory);
  }

  Future<MatchHistoryEntity?> fetchMatchHistory(String id) async {
    return await _dao.getMatchHistory(id);
  }

  Future<List<MatchHistoryEntity>> fetchMatchHistoryByGameId(String gameId) async {
    return await _dao.getMatchHistoryByGameId(gameId);
  }

  Future<List<MatchHistoryEntity>> fetchAllMatchHistory() async {
    return await _dao.getAllMatchHistory();
  }

  Future<void> deleteMatchHistory(String id) async {
    await _dao.deleteMatchHistory(id);
  }

  Future<void> deleteMatchHistoryByGameId(String gameId) async {
    await _dao.deleteMatchHistoryByGameId(gameId);
  }

  Future<void> clearAllMatchHistory() async {
    await _dao.clearAll();
  }
}
