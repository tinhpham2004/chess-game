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
    _debugPrintDatabaseInfo();
  }

  Future<void> _debugPrintDatabaseInfo() async {
    try {
      final dbProvider = getIt<DBProvider>();
      final db = dbProvider.database;

      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='match_history';");
      print('Database tables: $tables');

      if (tables.isNotEmpty) {
        final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM match_history');
        final count = Sqflite.firstIntValue(countResult) ?? 0;
        print('Number of records in match_history table: $count');

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
          Container(
            margin: EdgeInsets.only(right: AppSpacing.rem150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _themeColor.primaryColor.withOpacity(0.1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                color: _themeColor.primaryColor,
              ),
              onPressed: _loadMatchHistory,
              tooltip: 'Refresh match history',
            ),
          ),
        ],
      ),
      backgroundColor: _themeColor.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _themeColor.surfaceColor.withOpacity(0.3),
              _themeColor.backgroundColor,
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _themeColor.primaryColor),
                    ),
                    SizedBox(height: AppSpacing.rem200),
                    CommonText(
                      'Loading match history...',
                      style: TextStyle(
                        color: _themeColor.textSecondaryColor,
                        fontSize: AppFontSize.md,
                      ),
                    ),
                  ],
                ),
              )
            : _matchHistory.isEmpty
                ? _buildEmptyState()
                : _buildMatchList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.rem400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _themeColor.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.history,
                size: 60,
                color: _themeColor.primaryColor.withOpacity(0.5),
              ),
            ),
            SizedBox(height: AppSpacing.rem300),
            CommonText(
              'No matches yet',
              style: TextStyle(
                fontSize: AppFontSize.xl,
                fontWeight: AppFontWeight.bold,
                color: _themeColor.textPrimaryColor,
              ),
            ),
            SizedBox(height: AppSpacing.rem150),
            CommonText(
              'Start playing games to see your match history here',
              style: TextStyle(
                fontSize: AppFontSize.md,
                color: _themeColor.textSecondaryColor,
              ),
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.rem200),
      child: ListView.builder(
        itemCount: _matchHistory.length,
        itemBuilder: (context, index) {
          final match = _matchHistory[index];
          return _buildMatchCard(match);
        },
      ),
    );
  }

  Widget _buildMatchCard(MatchHistoryEntity match) {
    Color getResultColor() {
      if (match.winner == 'draw') return Colors.amber;
      return Colors.green;
    }

    IconData getResultIcon() {
      if (match.winner == 'draw') return Icons.handshake;
      return Icons.emoji_events;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.rem200),
      decoration: BoxDecoration(
        color: _themeColor.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getResultColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.rem200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            getResultColor(),
                            getResultColor().withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Icon(
                        getResultIcon(),
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: AppSpacing.rem150),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'Match #${match.id}',
                          style: TextStyle(
                            fontWeight: AppFontWeight.bold,
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
                        SizedBox(height: AppSpacing.rem075),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.rem150,
                            vertical: AppSpacing.rem075,
                          ),
                          decoration: BoxDecoration(
                            color: getResultColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getResultColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: CommonText(
                            _getResultText(match.winner, match.whitePlayer,
                                match.blackPlayer),
                            style: TextStyle(
                              fontWeight: AppFontWeight.bold,
                              fontSize: AppFontSize.sm,
                              color: getResultColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: AppSpacing.rem200),

            // Players row
            Container(
              padding: EdgeInsets.all(AppSpacing.rem150),
              decoration: BoxDecoration(
                color: _themeColor.backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // White player
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: _themeColor.borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.rem100),
                        Expanded(
                          child: CommonText(
                            match.whitePlayer,
                            style: TextStyle(
                              fontSize: AppFontSize.md,
                              fontWeight: AppFontWeight.medium,
                              color: _themeColor.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // VS indicator
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.rem100),
                    child: CommonText(
                      'VS',
                      style: TextStyle(
                        fontSize: AppFontSize.sm,
                        fontWeight: AppFontWeight.bold,
                        color: _themeColor.textSecondaryColor,
                      ),
                    ),
                  ),

                  // Black player
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(
                              color: _themeColor.borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.rem100),
                        Expanded(
                          child: CommonText(
                            match.blackPlayer,
                            style: TextStyle(
                              fontSize: AppFontSize.md,
                              fontWeight: AppFontWeight.medium,
                              color: _themeColor.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // AI info
            if (match.isAiOpponent) ...[
              SizedBox(height: AppSpacing.rem150),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.rem150,
                  vertical: AppSpacing.rem075,
                ),
                decoration: BoxDecoration(
                  color: _themeColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 16,
                      color: _themeColor.primaryColor,
                    ),
                    SizedBox(width: AppSpacing.rem075),
                    CommonText(
                      'AI Opponent (Level ${match.aiDifficulty})',
                      style: TextStyle(
                        fontSize: AppFontSize.sm,
                        fontWeight: AppFontWeight.medium,
                        color: _themeColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppSpacing.rem150),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  'View Details',
                  Icons.visibility,
                  _themeColor.primaryColor,
                  () {
                    // Open match details or replay screen
                  },
                ),
                SizedBox(width: AppSpacing.rem100),
                _buildActionButton(
                  'Delete',
                  Icons.delete_outline,
                  Colors.red,
                  () async {
                    await _showDeleteConfirmation(match);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.rem150,
              vertical: AppSpacing.rem100,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                SizedBox(width: AppSpacing.rem075),
                CommonText(
                  label,
                  style: TextStyle(
                    fontSize: AppFontSize.sm,
                    fontWeight: AppFontWeight.medium,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(MatchHistoryEntity match) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: CommonText(
            'Delete Match',
            style: TextStyle(
              fontWeight: AppFontWeight.bold,
              color: _themeColor.textPrimaryColor,
            ),
          ),
          content: CommonText(
            'Are you sure you want to delete this match from history?',
            style: TextStyle(
              color: _themeColor.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: CommonText(
                'Cancel',
                style: TextStyle(
                  color: _themeColor.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: CommonText(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: AppFontWeight.medium,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _matchHistoryRepository.deleteMatchHistory(match.id);
      _loadMatchHistory();
    }
  }
}
