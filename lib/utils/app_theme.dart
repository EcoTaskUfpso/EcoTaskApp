import 'package:flutter/material.dart';

class AppColors {
  // Colores ambientales y de reciclaje
  static const Color primary = Color.fromRGBO(76, 175, 80, 1); // Verde principal
  static const Color secondary = Color.fromRGBO(139, 195, 74, 1); // Verde lima
  static const Color accent = Color.fromRGBO(0, 150, 136, 1); // Verde azulado
  static const Color darkGreen = Color.fromRGBO(27, 94, 32, 1); // Verde oscuro
  static const Color brown = Color.fromRGBO(121, 85, 72, 1); // Tierra/marrón
  static const Color lightBlue = Color.fromRGBO(227, 242, 253, 1); // Azul cielo claro
  
  // Colores neutros
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color textPrimary = Color.fromRGBO(33, 33, 33, 1); // Texto principal
  static const Color gray = Color.fromRGBO(129, 131, 134, 1);
  static const Color gray50 = Color.fromRGBO(129, 131, 134, 0.5);
  static const Color surface = Color.fromRGBO(248, 251, 248, 1); // Fondo verde muy claro
}

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.darkGreen,
      error: AppColors.brown,
      onError: Colors.white,
    );

    final baseTextTheme = Typography.material2021().black.apply(
      bodyColor: AppColors.black,
      displayColor: AppColors.black,
      fontFamily: 'Trebuchet MS',
      fontFamilyFallback: const ['Helvetica'],
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Trebuchet MS',
      textTheme: baseTextTheme.copyWith(
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.gray),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          color: AppColors.gray,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: AppColors.gray),
        prefixIconColor: AppColors.gray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gray50),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gray50),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Trebuchet MS',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.gray50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          textStyle: const TextStyle(
            fontFamily: 'Trebuchet MS',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
