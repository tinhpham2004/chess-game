import 'package:chess_game/app/chess_facade.dart';
import 'package:chess_game/data/models/game_room_model.dart';
import 'package:chess_game/di/injection.dart';
import 'package:chess_game/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _gameIdController = TextEditingController(text: '12345');
  final List<GameRoomModel> _savedGames = [];
  final ChessFacade _chessFacade = getIt<ChessFacade>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedGames();
  }

  Future<void> _loadSavedGames() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<GameRoomModel> gameRooms = await _chessFacade.getAllGameRooms();

      setState(() {
        _savedGames.clear();
        _savedGames.addAll(gameRooms);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved games: $e');
      setState(() {
        _savedGames.clear();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndNavigateToGameRoom() async {
    final gameId = _gameIdController.text.trim();
    if (gameId.isEmpty) return;

    // Create a game room model and save it
    final gameRoom = GameRoomModel(
      id: gameId,
      json: '{"gameId": "$gameId", "createdAt": "${DateTime.now().toIso8601String()}"}',
    );
    await _chessFacade.saveGameRoom(gameRoom);

    // Reload game rooms from the database
    await _loadSavedGames();

    // Navigate to the game room
    if (mounted) {
      AppRouter.push(AppRouter.gameRoomScreen, params: gameId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _gameIdController,
              decoration: const InputDecoration(
                labelText: 'Game ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveAndNavigateToGameRoom,
              child: const Text('Lưu và vào ván cờ'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ván cờ đã lưu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _savedGames.isEmpty
                      ? const Center(child: Text('Chưa có ván cờ nào được lưu'))
                      : ListView.builder(
                          itemCount: _savedGames.length,
                          itemBuilder: (context, index) {
                            final game = _savedGames[index];
                            return Card(
                              child: ListTile(
                                title: Text('Game ID: ${game.id}'),
                                subtitle: Text('JSON: ${game.json}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await _chessFacade.deleteGameRoom(game.id);
                                    await _loadSavedGames();
                                  },
                                ),
                                onTap: () {
                                  AppRouter.push(AppRouter.gameRoomScreen, params: game.id);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameIdController.dispose();
    super.dispose();
  }
}
