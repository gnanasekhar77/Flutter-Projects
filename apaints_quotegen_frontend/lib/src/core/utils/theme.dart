import 'package:APaints_QGen/src/core/utils/border_radius.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AsianPaintsTheme {
  static ThemeData getTheme(
    bool isDark,
  ) {
    TextStyle _getTextStyle({
      required double fontSize,
      FontWeight? fontWeight,
      Color? color,
    }) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
        letterSpacing: 0,
        color: color ??
            (isDark
                ? AsianPaintColors.whiteColor
                : AsianPaintColors.blackColor),
        fontFamily: 'Poppins',
      );
    }

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: isDark
          ? AsianPaintColors.kPrimaryColor
          : AsianPaintColors.kPrimaryLightColor,
      primaryColorDark: AsianPaintColors.kPrimaryColor,
      textTheme: TextTheme(
        displayLarge: _getTextStyle(
          fontSize: 30.0,
          // fontWeight: FontWeight.bold,
        ),
        displayMedium: _getTextStyle(
          fontSize: 28.0,
        ),
        displaySmall: _getTextStyle(
          fontSize: 28.0,
        ),
        headlineMedium: _getTextStyle(
          fontSize: 24.0,
        ),
        headlineSmall: _getTextStyle(
          fontSize: 20.0,
        ),
        titleLarge: _getTextStyle(
          fontSize: 18.0,
        ),
        titleMedium: _getTextStyle(
          fontSize: 16,
          // fontWeight: FontWeight.bold,
        ),
        titleSmall: _getTextStyle(
          fontSize: 14.0,
        ),
        // will be used for labels (for form fields)
        bodyLarge: _getTextStyle(
          fontSize: 12.0,
        ),
        // will be used for default body text
        bodyMedium: _getTextStyle(
          fontSize: 11.0,
        ),
        // Smallest text or caption
        bodySmall: _getTextStyle(
          fontSize: 10.0,
        ),
        // form field error messages or any other smaller text
        labelSmall: _getTextStyle(
          fontSize: 12.0,
        ),
        labelLarge: _getTextStyle(
          fontSize: 16.0,
        ),
      ).apply(
        bodyColor:
            isDark ? AsianPaintColors.whiteColor : AsianPaintColors.blackColor,
        displayColor:
            isDark ? AsianPaintColors.whiteColor : AsianPaintColors.blackColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AsianPaintColors.kPrimaryColor
            : AsianPaintColors.kPrimaryLightColor,
        titleTextStyle: _getTextStyle(
          fontSize: 18,
          color: AsianPaintColors.blackColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: AsianPaintColors.kPrimaryColor,
              onPrimary: AsianPaintColors.kPrimaryColor,
              secondary: AsianPaintColors.kPrimaryColor,
              onSecondary: AsianPaintColors.kPrimaryColor,
              background: AsianPaintColors.kPrimaryColor,
              onBackground: AsianPaintColors.kPrimaryColor,
            )
          : ColorScheme.light(
              primary: AsianPaintColors.kPrimaryLightColor,
              onPrimary: AsianPaintColors.kPrimaryLightColor,
              secondary: AsianPaintColors.kPrimaryLightColor,
              background: AsianPaintColors.kPrimaryLightColor,
              onBackground: AsianPaintColors.kPrimaryLightColor,
            ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: isDark
              ? AsianPaintColors.kPrimaryColor
              : AsianPaintColors.kPrimaryLightColor,
          padding: AsianPaintEdgeInsets.vertical_15,
          textStyle: _getTextStyle(
            fontSize: 16,
            color: AsianPaintColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? AsianPaintColors.whiteColor
              : AsianPaintColors.kPrimaryColor,
          side: BorderSide(
            color: isDark
                ? AsianPaintColors.whiteColor
                : AsianPaintColors.blackColor,
            width: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: AsianPaintEdgeInsets.vertical_15,
          textStyle: _getTextStyle(
            fontSize: 16,
            color: isDark
                ? AsianPaintColors.whiteColor
                : AsianPaintColors.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark
                ? AsianPaintColors.whiteColor
                : AsianPaintColors.kPrimaryColor,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(APBorderRadius.CIRCULAR_50),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(APBorderRadius.CIRCULAR_50),
          borderSide: BorderSide(
            color: isDark
                ? AsianPaintColors.whiteColor
                : AsianPaintColors.kPrimaryColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark
                ? AsianPaintColors.whiteColor
                : AsianPaintColors.kPrimaryColor,
            width: 0.1,
          ),
          borderRadius: const BorderRadius.all(APBorderRadius.CIRCULAR_50),
        ),
        hintStyle: _getTextStyle(
          fontSize: 14,
          color: AsianPaintColors.userTypeTextColor,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? AsianPaintColors.kPrimaryColor
            : AsianPaintColors.kPrimaryColor,
        selectedItemColor: AsianPaintColors.whiteColor,
        unselectedItemColor: AsianPaintColors.whiteColor,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? AsianPaintColors.whiteColor : AsianPaintColors.whiteColor,
      ),
      tabBarTheme: TabBarTheme(
        labelStyle: _getTextStyle(
          fontSize: 16,
          color: isDark
              ? AsianPaintColors.kPrimaryColor
              : AsianPaintColors.whiteColor,
        ),
        unselectedLabelStyle: _getTextStyle(
          fontSize: 16,
          color: isDark
              ? AsianPaintColors.whiteColor
              : AsianPaintColors.kPrimaryColor,
        ),
        labelColor: isDark
            ? AsianPaintColors.kPrimaryColor
            : AsianPaintColors.whiteColor,
        unselectedLabelColor: isDark
            ? AsianPaintColors.whiteColor
            : AsianPaintColors.userTypeTextColor,
      ),
      sliderTheme: SliderThemeData(
        thumbColor: isDark
            ? AsianPaintColors.whiteColor
            : AsianPaintColors.kPrimaryColor,
        thumbShape:
            const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 4),
        activeTrackColor: isDark
            ? AsianPaintColors.whiteColor
            : AsianPaintColors.kPrimaryColor,
        valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
      ),
    );
  }
}
