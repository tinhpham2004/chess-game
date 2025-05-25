import 'package:chess_game/core/common/scaffold/common_app_bar.dart';
import 'package:chess_game/core/common/scaffold/common_scaffold.dart';
import 'package:chess_game/core/common/text/common_text.dart';
import 'package:chess_game/data/entities/match_history_entity.dart';
import 'package:chess_game/data/repository/match_history_repository.dart';
import 'package:chess_game/data/datasource/db_provider.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/theme/app_theme.dart';
import 'package:chess_game/theme/font/app_font_size.dart';
import 'package:chess_game/theme/font/app_font_weight.dart';
import 'package:chess_game/theme/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  final MatchHistoryRepository _matchHistoryRepository = getIt<MatchHistoryRepository>();
  final List<MatchHistoryEntity> _matchHistory = [];
  final _themeColor = getIt.get<AppTheme>().themeColor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchHistory();

    // Debug: Print database information
    _debugPrintDatabaseInfo();
  }

  Future<void> _debugPrintDatabaseInfo() async {
    try {
      final dbProvider = getIt<DBProvider>();
      final db = dbProvider.database;

      // Check if the match_history table exists
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='match_history';");

      print('Database tables: $tables');

      if (tables.isNotEmpty) {
        // Count records in the match_history table
        final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM match_history');
        final count = Sqflite.firstIntValue(countResult) ?? 0;

        print('Number of records in match_history table: $count');

        // Get all records for debugging
        if (count > 0) {
          final records = await db.query('match_history');
          print('Match history records: $records');
        }
      }
    } catch (e) {
      print('Debug database info error: $e');
    }
  }

  Future<void> _loadMatchHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<MatchHistoryEntity> history = await _matchHistoryRepository.fetchAllMatchHistory();

      setState(() {
        _matchHistory.clear();
        _matchHistory.addAll(history);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading match history: $e');
      setState(() {
        _matchHistory.clear();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getResultText(String winner, String whitePlayer, String blackPlayer) {
    if (winner == 'white') {
      return '$whitePlayer thắng';
    } else if (winner == 'black') {
      return '$blackPlayer thắng';
    } else {
      return 'Hòa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        title: 'Match History',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatchHistory,
            tooltip: 'Refresh match history',
          ),
        ],
      ),
      backgroundColor: _themeColor.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matchHistory.isEmpty
              ? Center(
                  child: CommonText(
                    'No matches found',
                    style: TextStyle(
                      fontSize: AppFontSize.lg,
                      color: _themeColor.textPrimaryColor,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(AppSpacing.rem100),
                  child: ListView.builder(
                    itemCount: _matchHistory.length,
                    itemBuilder: (context, index) {
                      final match = _matchHistory[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: AppSpacing.rem100),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.rem200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CommonText(
                                    'Match #${match.id}',
                                    style: TextStyle(
                                      fontWeight: AppFontWeight.bold,
                                      fontSize: AppFontSize.md,
                                      color: _themeColor.textPrimaryColor,
                                    ),
                                  ),
                                  CommonText(
                                    _formatDate(match.date),
                                    style: TextStyle(
                                      color: _themeColor.textSecondaryColor,
                                      fontSize: AppFontSize.sm,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        'White: ${match.whitePlayer}',
                                        style: TextStyle(
                                          fontWeight: match.winner == 'white' ? AppFontWeight.bold : AppFontWeight.regular,
                                          color: _themeColor.textPrimaryColor,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.rem050),
                                      CommonText(
                                        'Black: ${match.blackPlayer}',
                                        style: TextStyle(
                                          fontWeight: match.winner == 'black' ? AppFontWeight.bold : AppFontWeight.regular,
                                          color: _themeColor.textPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.rem150,
                                      vertical: AppSpacing.rem075,
                                    ),
                                    decoration: BoxDecoration(
                                      color: match.winner == 'draw' ? Colors.amber[100] : Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CommonText(
                                      _getResultText(match.winner, match.whitePlayer, match.blackPlayer),
                                      style: TextStyle(
                                        color: match.winner == 'draw' ? Colors.amber[900] : Colors.green[900],
                                        fontWeight: AppFontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (match.isAiOpponent)
                                Padding(
                                  padding: EdgeInsets.only(top: AppSpacing.rem100),
                                  child: CommonText(
                                    'Opponent: AI (Difficulty: ${match.aiDifficulty})',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: _themeColor.textSecondaryColor,
                                    ),
                                  ),
                                ),
                              SizedBox(height: AppSpacing.rem100),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.visibility),
                                    label: CommonText('View Details'),
                                    onPressed: () {
                                      // Open match details or replay screen
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      await _matchHistoryRepository.deleteMatchHistory(match.id);
                                      _loadMatchHistory();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
