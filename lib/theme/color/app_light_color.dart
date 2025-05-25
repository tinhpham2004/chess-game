part of 'app_color.dart';

class AppLightColor implements IAppColor {
  @override
  Color get primaryColor => PrimaryColors.twilight;

  @override
  Color get primaryVariant => PrimaryColors.twilightVariant;

  @override
  Color get secondaryColor => SecondaryColors.eclipse;

  @override
  Color get backgroundColor => BackgroundColors.midnight;

  @override
  Color get surfaceColor => SurfaceColors.nightSurface;

  @override
  Color get onPrimaryColor => Colors.black;

  @override
  Color get onSecondaryColor => Colors.black;

  @override
  Color get onBackgroundColor => TextColors.nightPrimaryText;

  @override
  Color get onSurfaceColor => TextColors.nightPrimaryText;

  @override
  Color get errorColor => ErrorColors.nightError;

  @override
  Color get textPrimaryColor => TextColors.nightPrimaryText;

  @override
  Color get textSecondaryColor => TextColors.nightSecondaryText;

  @override
  Color get borderColor => BorderColors.nightBorder;
}
