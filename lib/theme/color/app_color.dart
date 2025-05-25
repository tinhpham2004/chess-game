import 'package:chess_game/theme/color/colors_template.dart';
import 'package:flutter/material.dart';

part 'app_light_color.dart';
part 'app_dark_color.dart';

abstract class IAppColor {
  Color get primaryColor;
  Color get primaryVariant;
  Color get secondaryColor;
  Color get backgroundColor;
  Color get surfaceColor;
  Color get onPrimaryColor;
  Color get onSecondaryColor;
  Color get onBackgroundColor;
  Color get onSurfaceColor;
  Color get errorColor;
  Color get textPrimaryColor;
  Color get textSecondaryColor;
  Color get borderColor;  
}
