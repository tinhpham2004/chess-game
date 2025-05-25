import 'package:chess_game/app/app.dart';
import 'package:chess_game/app/app_bloc_observer.dart';
import 'package:chess_game/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  Bloc.observer = AppBlocObserver();

  runApp(MyApp());
}
