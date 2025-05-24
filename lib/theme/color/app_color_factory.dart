import 'package:chess_game/theme/color/app_color.dart';

part 'app_light_color_factory.dart';
part 'app_dark_color_factory.dart';


abstract class AppColorFactory {
  IAppColor createColor();
}
