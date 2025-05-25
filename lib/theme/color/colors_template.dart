import 'package:flutter/material.dart';

class PrimaryColors {
  static const Color vibrant = Color(0xFF7B61FF);
  static const Color vibrantVariant = Color(0xFF5A47CC);

  static const Color twilight = Color(0xFF7B61FF);
  static const Color twilightVariant = Color(0xFF9C87FF);
}

class SecondaryColors {
  static const Color sunlight = Color(0xFF4CAF50);
  static const Color eclipse = Color(0xFF81C784);
}

class BackgroundColors {
  static const Color luminous = Colors.white;
  static const Color midnight = Color(0xFF121212);
}

class SurfaceColors {
  static const Color daySurface = Color(0xFFF0F0FF);
  static const Color nightSurface = Color(0xFF1E1E2F);
}

class TextColors {
  static const Color dayPrimaryText = Color(0xFF1A1A1A);
  static const Color daySecondaryText = Color(0xFF666666);
  static const Color nightPrimaryText = Color(0xFFE0E0E0);
  static const Color nightSecondaryText = Color(0xFFB0B0B0);
}

class ErrorColors {
  static const Color dayError = Color(0xFFB00020);
  static const Color nightError = Color(0xFFCF6679);
}

class BorderColors {
  static const Color dayBorder = Color(0xFFE0E0E0);
  static const Color nightBorder = Color(0xFF3A3A3A);
}

class AppColors {
  static PrimaryColors primary = PrimaryColors();
  static SecondaryColors secondary = SecondaryColors();
  static BackgroundColors background = BackgroundColors();
  static SurfaceColors surface = SurfaceColors();
  static TextColors text = TextColors();
  static ErrorColors error = ErrorColors();
  static BorderColors border = BorderColors();
}
