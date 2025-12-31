import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the agricultural monitoring application.
/// Optimized for outdoor readability and professional agricultural use.
class AppTheme {
  AppTheme._();

  // Agricultural color palette - optimized for outdoor visibility
  // Primary: Agricultural green for primary actions and healthy sensor status
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryVariantLight = Color(0xFF1B5E20);

  // Secondary: Earth brown for secondary elements and rice variety identification
  static const Color secondaryLight = Color(0xFF8D6E63);
  static const Color secondaryVariantLight = Color(0xFF6D4C41);

  // Surface: Clean background optimized for outdoor screen visibility
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFAFAFA);

  // Status colors - high contrast for immediate recognition
  static const Color errorLight = Color(0xFFD32F2F); // Critical sensor alerts
  static const Color warningLight = Color(
    0xFFF57C00,
  ); // Moisture level cautions
  static const Color successLight = Color(0xFF388E3C); // Optimal conditions
  static const Color infoLight = Color(0xFF1976D2); // Data insights

  // Accent: Selective highlighting for active sensors
  static const Color accentLight = Color(0xFFFF8F00);

  // Text colors - high contrast for outdoor readability
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF212121);
  static const Color onSurfaceLight = Color(0xFF212121);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Dark theme colors - maintaining data readability
  static const Color primaryDark = Color(0xFF4CAF50);
  static const Color primaryVariantDark = Color(0xFF2E7D32);
  static const Color secondaryDark = Color(0xFFA1887F);
  static const Color secondaryVariantDark = Color(0xFF8D6E63);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warningDark = Color(0xFFFF9800);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color infoDark = Color(0xFF42A5F5);
  static const Color accentDark = Color(0xFFFFB74D);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color onErrorDark = Color(0xFF000000);

  // Card and dialog colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF2D2D2D);

  // Shadow colors - subtle elevation for functional hierarchy
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x14FFFFFF);

  // Divider colors - minimal usage for sensor group separation
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // Text emphasis levels
  static const Color textHighEmphasisLight = Color(0xDE212121); // 87% opacity
  static const Color textMediumEmphasisLight = Color(0x99757575); // 60% opacity
  static const Color textDisabledLight = Color(0x61757575); // 38% opacity

  static const Color textHighEmphasisDark = Color(0xDEE0E0E0); // 87% opacity
  static const Color textMediumEmphasisDark = Color(0x99E0E0E0); // 60% opacity
  static const Color textDisabledDark = Color(0x61E0E0E0); // 38% opacity

  /// Light theme - optimized for outdoor agricultural use
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: accentLight,
      onTertiary: onPrimaryLight,
      tertiaryContainer: accentLight,
      onTertiaryContainer: onPrimaryLight,
      error: errorLight,
      onError: onErrorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: dividerLight,
      shadow: shadowLight,
      scrim: shadowLight,
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,
    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      elevation: 2.0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimaryLight,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      elevation: 4.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentLight,
      foregroundColor: onPrimaryLight,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
        ),
        minimumSize: const Size(88, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryLight, width: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
        ),
        minimumSize: const Size(88, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
        ),
        minimumSize: const Size(88, 48),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: surfaceLight,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerLight, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerLight, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorLight, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorLight, width: 2.0),
      ),
      labelStyle: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasisLight,
      ),
      hintStyle: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: textDisabledLight,
      ),
      errorStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorLight,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textDisabledLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.5);
        }
        return textDisabledLight.withValues(alpha: 0.3);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryLight),
      side: const BorderSide(color: dividerLight, width: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textSecondaryLight;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: dividerLight,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      thumbColor: primaryLight,
      overlayColor: primaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: dividerLight,
      trackHeight: 4.0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: surfaceLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryLight,
      contentTextStyle: GoogleFonts.openSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: surfaceLight,
      ),
      actionTextColor: accentLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4.0,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1.0,
      space: 1.0,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: surfaceLight,
      collapsedBackgroundColor: surfaceLight,
      textColor: textPrimaryLight,
      collapsedTextColor: textPrimaryLight,
      iconColor: textSecondaryLight,
      collapsedIconColor: textSecondaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ), dialogTheme: DialogThemeData(backgroundColor: dialogLight),
  );

  /// Dark theme - maintaining data readability in low light conditions
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: onPrimaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryVariantDark,
      onSecondaryContainer: onSecondaryDark,
      tertiary: accentDark,
      onTertiary: onPrimaryDark,
      tertiaryContainer: accentDark,
      onTertiaryContainer: onPrimaryDark,
      error: errorDark,
      onError: onErrorDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textMediumEmphasisDark,
      outline: dividerDark,
      outlineVariant: dividerDark,
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,
    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceDark,
      foregroundColor: onSurfaceDark,
      elevation: 2.0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurfaceDark,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: onSurfaceDark),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textMediumEmphasisDark,
      elevation: 4.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentDark,
      foregroundColor: onPrimaryDark,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryDark,
        backgroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
        ),
        minimumSize: const Size(88, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryDark, width: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
        ),
        minimumSize: const Size(88, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
        ),
        minimumSize: const Size(88, 48),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: surfaceDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerDark, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerDark, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryDark, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorDark, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorDark, width: 2.0),
      ),
      labelStyle: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasisDark,
      ),
      hintStyle: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: textDisabledDark,
      ),
      errorStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorDark,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textDisabledDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.5);
        }
        return textDisabledDark.withValues(alpha: 0.3);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryDark),
      side: const BorderSide(color: dividerDark, width: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textMediumEmphasisDark;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: dividerDark,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryDark,
      thumbColor: primaryDark,
      overlayColor: primaryDark.withValues(alpha: 0.2),
      inactiveTrackColor: dividerDark,
      trackHeight: 4.0,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textMediumEmphasisDark,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: onSurfaceDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: surfaceDark,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardDark,
      contentTextStyle: GoogleFonts.openSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceDark,
      ),
      actionTextColor: accentDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4.0,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerDark,
      thickness: 1.0,
      space: 1.0,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: surfaceDark,
      collapsedBackgroundColor: surfaceDark,
      textColor: onSurfaceDark,
      collapsedTextColor: onSurfaceDark,
      iconColor: textMediumEmphasisDark,
      collapsedIconColor: textMediumEmphasisDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ), dialogTheme: DialogThemeData(backgroundColor: dialogDark),
  );

  /// Helper method to build text theme based on brightness
  /// Implements typography standards for agricultural data readability
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis = isLight
        ? textHighEmphasisLight
        : textHighEmphasisDark;
    final Color textMediumEmphasis = isLight
        ? textMediumEmphasisLight
        : textMediumEmphasisDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
      // Display styles - Roboto for headings
      displayLarge: GoogleFonts.roboto(
        fontSize: 96,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 60,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
      ),

      // Headline styles - Roboto for strong character recognition
      headlineLarge: GoogleFonts.roboto(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0.25,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
      ),

      // Title styles - Roboto for section headers
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0.15,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0.1,
      ),

      // Body styles - Open Sans for extended reading
      bodyLarge: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.openSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
      ),

      // Label styles - Inter (replacing Source Sans Pro) for captions
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 1.25,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: textDisabled,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Custom text style for data display - Roboto Mono for numerical values
  static TextStyle dataTextStyle({
    required bool isLight,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isLight ? textHighEmphasisLight : textHighEmphasisDark,
      letterSpacing: 0.5,
    );
  }

  /// Status color helper for sensor indicators
  static Color getStatusColor(String status, {required bool isLight}) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'optimal':
      case 'success':
        return isLight ? successLight : successDark;
      case 'warning':
      case 'caution':
        return isLight ? warningLight : warningDark;
      case 'error':
      case 'critical':
      case 'alert':
        return isLight ? errorLight : errorDark;
      case 'info':
      case 'normal':
        return isLight ? infoLight : infoDark;
      default:
        return isLight ? textSecondaryLight : textMediumEmphasisDark;
    }
  }
}
