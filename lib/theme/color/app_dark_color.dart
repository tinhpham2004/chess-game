part of 'app_color.dart';

class AppDarkColor implements IAppColor {
  @override
  Color get primaryColor => PrimaryColors.vibrant;

  @override
  Color get primaryVariant => PrimaryColors.vibrantVariant;

  @override
  Color get secondaryColor => SecondaryColors.sunlight;

  @override
  Color get backgroundColor => BackgroundColors.luminous;

  @override
  Color get surfaceColor => SurfaceColors.daySurface;

  @override
  Color get onPrimaryColor => Colors.white;

  @override
  Color get onSecondaryColor => Colors.white;

  @override
  Color get onBackgroundColor => TextColors.dayPrimaryText;

  @override
  Color get onSurfaceColor => TextColors.dayPrimaryText;

  @override
  Color get errorColor => ErrorColors.dayError;

  @override
  Color get textPrimaryColor => TextColors.dayPrimaryText;

  @override
  Color get textSecondaryColor => TextColors.daySecondaryText;

  @override
  Color get borderColor => BorderColors.dayBorder;
}
