import 'package:chess_game/theme/color/app_color.dart';
import 'package:chess_game/theme/color/app_color_factory.dart';

class AppTheme {
  final AppColorFactory factory;

  AppTheme(this.factory);

  IAppColor get themeColor => factory.createColor();
}