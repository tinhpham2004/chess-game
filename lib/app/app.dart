import 'package:chess_game/app/chess_facade.dart';
import 'package:chess_game/presentation/game_room/bloc/game_room_bloc.dart';
import 'package:chess_game/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final chessFacade = GetIt.instance<ChessFacade>();

    return MultiBlocProvider(
      providers: [BlocProvider.value(value: GameRoomBloc(chessFacade))],
      child: MaterialApp.router(
        routerConfig: BaseRouter().baseRouter,
        title: 'Chess App',
      ),
    );
  }
}
