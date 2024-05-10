/// Creating custom color palettes is part of creating a custom app. The idea is to create
/// your class of custom colors, in this case `CompanyColors` and then create a `ThemeData`
/// object with those colors you just defined.
///
/// Resource:
/// A good resource would be this website: http://mcg.mbitson.com/
/// You simply need to put in the colour you wish to use, and it will generate all shades
/// for you. Your primary colour will be the `500` value.
///
/// Colour Creation:
/// In order to create the custom colours you need to create a `Map<int, Color>` object
/// which will have all the shade values. `const Color(0xFF...)` will be how you create
/// the colours. The six character hex code is what follows. If you wanted the colour
/// #114488 or #D39090 as primary colours in your setting, then you would have
/// `const Color(0x114488)` and `const Color(0xD39090)`, respectively.
///
/// Usage:
/// In order to use this newly created setting or even the colours in it, you would just
/// `import` this file in your project, anywhere you needed it.
/// `import 'path/to/setting.dart';`
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  // static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  // static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData = themeData(lightColorScheme);
  static ThemeData darkThemeData = themeData(darkColorScheme);

  static ThemeData themeData(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _textTheme,
      // Matches manifest.json colors and background color.
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: colorScheme.errorContainer,
      // inputDecorationTheme: InputDecorationTheme(
      //   border: OutlineInputBorder(
      //       borderSide: BorderSide(color: colorScheme.onSurface, )),
      //   enabledBorder: OutlineInputBorder(
      //       borderSide: BorderSide(color: colorScheme.onSurface)),
      //   errorBorder: OutlineInputBorder(
      //       borderSide: BorderSide(color: colorScheme.error)),
      //   focusedErrorBorder: OutlineInputBorder(
      //       borderSide: BorderSide(color: colorScheme.error)),
      // ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        contentTextStyle: _textTheme.titleMedium!.apply(color: _darkFillColor),
      ),
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFFd21e1d),
    primaryContainer: Color(0xFF9e1718),
    secondary: Color(0xFFEFF3F3),
    secondaryContainer: Color.fromARGB(255, 255, 255, 255),
    background: Color.fromARGB(255, 245, 245, 245),
    surface: Color.fromARGB(255, 245, 245, 245),
    onBackground: Colors.white,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
    onSecondaryContainer: _darkFillColor,
    errorContainer: Color.fromARGB(255, 247, 109, 109),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFFFF8383),
    primaryContainer: Color.fromARGB(255, 222, 132, 28),
    secondary: Color(0xFF241E30),
    secondaryContainer: Color.fromARGB(255, 53, 53, 53),
    background: Color(0xFF241E30),
    surface: Color.fromARGB(255, 63, 63, 63),
    onBackground: Color(0x0DFFFFFF),
    // White with 0.05 opacity
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
    onSecondaryContainer: _lightFillColor,
    errorContainer: Color.fromARGB(255, 247, 109, 109),
  );

  // static const lightColorScheme = ColorScheme(
  //   //   brightness: Brightness.light,
  //   primary: Color(0xFF2158C1),
  //   //   onPrimary: Color(0xFFFFFFFF),
  //   primaryContainer: Color(0xFFDAE2FF),
  //   onPrimaryContainer: Color(0xFF001947),
  //   secondary: Color(0xFF1860A5),
  //   onSecondary: Color(0xFFFFFFFF),
  //   secondaryContainer: Color(0xFFD3E3FF),
  //   onSecondaryContainer: Color(0xFF001C39),
  //   tertiary: Color(0xFF2D5CAF),
  //   onTertiary: Color(0xFFFFFFFF),
  //   tertiaryContainer: Color(0xFFD8E2FF),
  //   onTertiaryContainer: Color(0xFF001A43),
  //   error: Color(0xFFBA1A1A),
  //   errorContainer: Color(0xFFFFDAD6),
  //   onError: Color(0xFFFFFFFF),
  //   onErrorContainer: Color(0xFF410002),
  //   background: Color(0xFFFDFBFF),
  //   onBackground: Color(0xFF001B3D),
  //   surface: Color(0xFFFDFBFF),
  //   onSurface: _lightFillColor,
  //   surfaceVariant: Color(0xFFE1E2EC),
  //   onSurfaceVariant: Color(0xFF44464F),
  //   outline: Color(0xFF757780),
  //   onInverseSurface: Color(0xFFECF0FF),
  //   inverseSurface: Color(0xFF003062),
  //   inversePrimary: Color(0xFFB1C5FF),
  //   shadow: Color(0xFF000000),
  //   surfaceTint: Color(0xFF2158C1),
  //   outlineVariant: Color(0xFFC5C6D0),
  //   scrim: Color(0xFF000000),
  // );

  // static const darkColorScheme = ColorScheme(
  //   brightness: Brightness.dark,
  //   primary: Color(0xFFB1C5FF),
  //   onPrimary: Color(0xFF002C71),
  //   primaryContainer: Color(0xFF00419F),
  //   onPrimaryContainer: Color(0xFFDAE2FF),
  //   secondary: Color(0xFFA3C9FF),
  //   onSecondary: Color(0xFF00315C),
  //   secondaryContainer: Color(0xFF004883),
  //   onSecondaryContainer: Color(0xFFD3E3FF),
  //   tertiary: Color(0xFFAEC6FF),
  //   onTertiary: Color(0xFF002E6B),
  //   tertiaryContainer: Color(0xFF044395),
  //   onTertiaryContainer: Color(0xFFD8E2FF),
  //   error: Color(0xFFFFB4AB),
  //   errorContainer: Color(0xFF93000A),
  //   onError: Color(0xFF690005),
  //   onErrorContainer: Color(0xFFFFDAD6),
  //   background: Color(0xFF001B3D),
  //   onBackground: Color(0xFFD6E3FF),
  //   surface: Color(0xFF001B3D),
  //   onSurface: _darkFillColor,
  //   surfaceVariant: Color(0xFF44464F),
  //   onSurfaceVariant: Color(0xFFC5C6D0),
  //   outline: Color(0xFF8F9099),
  //   onInverseSurface: Color(0xFF001B3D),
  //   inverseSurface: Color(0xFFD6E3FF),
  //   inversePrimary: Color(0xFF2158C1),
  //   shadow: Color(0xFF000000),
  //   surfaceTint: Color(0xFFB1C5FF),
  //   outlineVariant: Color(0xFF44464F),
  //   scrim: Color(0xFF000000),
  // );

  // Light and dark ColorSchemes made by FlexColorScheme v7.3.1.
// These ColorScheme objects require Flutter 3.7 or later.
  // static const ColorScheme lightColorScheme = ColorScheme(
  //   brightness: Brightness.light,
  //   primary: Color(0xff355ca8),
  //   onPrimary: Color(0xffffffff),
  //   primaryContainer: Color.fromARGB(255, 127, 147, 211),
  //   onPrimaryContainer: Color(0xff001944),
  //   secondary: Color(0xff51606f),
  //   onSecondary: Color(0xffffffff),
  //   secondaryContainer: Color(0xffd4e4f6),
  //   onSecondaryContainer: Color(0xff0d1d2a),
  //   tertiary: Color(0xff505e7d),
  //   onTertiary: Color(0xffffffff),
  //   tertiaryContainer: Color(0xffd8e2ff),
  //   onTertiaryContainer: Color(0xff0b1b36),
  //   error: Color(0xffba1a1a),
  //   onError: Color(0xffffffff),
  //   errorContainer: Color(0xffffdad6),
  //   onErrorContainer: Color(0xff410002),
  //   background: Color(0xfffefbff),
  //   onBackground: Color(0xff1b1b1f),
  //   surface: _lightFillColor,
  //   onSurface: Color(0xff1b1b1f),
  //   surfaceVariant: Color(0xffe1e2ec),
  //   onSurfaceVariant: Color(0xff44464f),
  //   outline: Color(0xff757780),
  //   outlineVariant: Color(0xffc5c6d0),
  //   shadow: Color(0xff000000),
  //   scrim: Color(0xff000000),
  //   inverseSurface: Color(0xff303034),
  //   onInverseSurface: Color(0xfff2f0f4),
  //   inversePrimary: Color(0xffafc6ff),
  //   surfaceTint: Color(0xff355ca8),
  // );

  // static const ColorScheme darkColorScheme = ColorScheme(
  //   brightness: Brightness.dark,
  //   primary: Color(0xffabc7ff),
  //   onPrimary: Color(0xff002f66),
  //   primaryContainer: Color(0xff06458e),
  //   onPrimaryContainer: Color(0xffd7e2ff),
  //   secondary: Color(0xffb7c9d8),
  //   onSecondary: Color(0xff21323e),
  //   secondaryContainer: Color(0xff384956),
  //   onSecondaryContainer: Color(0xffd2e5f5),
  //   tertiary: Color(0xffb6c7e9),
  //   onTertiary: Color(0xff1f314c),
  //   tertiaryContainer: Color(0xff364764),
  //   onTertiaryContainer: Color(0xffd6e3ff),
  //   error: Color(0xffffb4ab),
  //   onError: Color(0xff690005),
  //   errorContainer: Color(0xff93000a),
  //   onErrorContainer: Color(0xffffb4ab),
  //   background: Color(0xff1a1b1f),
  //   onBackground: Color(0xffe3e2e6),
  //   surface: _darkFillColor,
  //   onSurface: Color(0xffe3e2e6),
  //   surfaceVariant: Color(0xff44474e),
  //   onSurfaceVariant: Color(0xffc4c6d0),
  //   outline: Color(0xff8e9099),
  //   outlineVariant: Color(0xff44474e),
  //   shadow: Color(0xff000000),
  //   scrim: Color(0xff000000),
  //   inverseSurface: Color(0xffe3e2e6),
  //   onInverseSurface: Color(0xff2f3033),
  //   inversePrimary: Color(0xff2d5da7),
  //   surfaceTint: Color(0xffabc7ff),
  // );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headlineMedium: GoogleFonts.montserrat(fontWeight: _bold, fontSize: 20.0),
    bodySmall: GoogleFonts.oswald(fontWeight: _semiBold, fontSize: 16.0),
    headlineSmall: GoogleFonts.oswald(fontWeight: _medium, fontSize: 16.0),
    titleMedium: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 16.0),
    labelSmall: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 12.0),
    bodyLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    titleSmall: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 14.0),
    bodyMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    titleLarge: GoogleFonts.montserrat(fontWeight: _bold, fontSize: 16.0),
    labelLarge: GoogleFonts.montserrat(fontWeight: _semiBold, fontSize: 14.0),
  );
}
