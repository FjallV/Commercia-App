import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
   // primarySwatch: Colors.red,
    colorScheme: colorScheme,
    //scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        surfaceTintColor: Colors.transparent,
        elevation: 1.0,
        shadowColor: Colors.grey,
        scrolledUnderElevation: 0.0,
        titleTextStyle: TextStyle(
            color: Colors.red, fontWeight: FontWeight.w400, fontSize: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.red,
          statusBarIconBrightness: Brightness.dark, // Android
          statusBarBrightness: Brightness.dark, // iOS
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        )),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.white,
      elevation: 1.0,
      shadowColor: Colors.grey,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(color: Colors.red, fontSize: 10)),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.red)),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(Colors.red),
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2.0),
          ),
        ),
  );
}

ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    //scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 1.0,
        shadowColor: Colors.grey,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 24), //TODO: FontWeight doesnt apply in web
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepPurple,
          statusBarIconBrightness: Brightness.light, // Android
          statusBarBrightness: Brightness.light, // iOS
          systemNavigationBarColor: Colors.deepPurple,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        )),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Color(0xFF121212),
      elevation: 1.0,
      shadowColor: Colors.grey,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        indicatorColor: Colors.transparent,
        // labelTextStyle:
        //     WidgetStatePropertyAll(TextStyle(color: Colors.deepPurple, fontSize: 10)),
        // iconTheme:
        //     WidgetStatePropertyAll(IconThemeData(color: Colors.deepPurple)),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        //foregroundColor: WidgetStatePropertyAll(Colors.deepPurple),
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2.0, color: Colors.white),
          ),
        ),
  );
}

ThemeData get testTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.green,
      elevation: 1.0,
      shadowColor: Colors.grey,
      scrolledUnderElevation: 1.0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

final ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.red,
  surfaceTint: Color(4294967295),
  onPrimary: Color(4294967295),
  primaryContainer: Colors.white,
  onPrimaryContainer: Color(4294967295),
  secondary: Color(4284420197),
  onSecondary: Color(4294967295),
  secondaryContainer: Color(4287052171),
  onSecondaryContainer: Color(4294967295),
  tertiary: Color(4285940736),
  onTertiary: Color(4294967295),
  tertiaryContainer: Color(4289291264),
  onTertiaryContainer: Color(4294967295),
  error: Color(4290386458),
  onError: Color(4294967295),
  errorContainer: Color(4294957782),
  onErrorContainer: Color(4282449922),
  surface: Color(4294768888),
  onSurface: Color(4280032027),
  onSurfaceVariant: Color(4284301116),
  outline: Color(4287786602),
  outlineVariant: Color(4293377208),
);


final ColorScheme colorScheme1 = ColorScheme(
      brightness: Brightness.light,
      primary: Color(4289003536),
      surfaceTint: Color(4294967295),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4293204515),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4284420197),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4287052171),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4285940736),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4289291264),
      onTertiaryContainer: Color(4294967295),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294768888),
      onSurface: Color(4280032027),
      onSurfaceVariant: Color(4284301116),
      outline: Color(4287786602),
      outlineVariant: Color(4293377208),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281413680),
      inversePrimary: Color(4294948012),
      primaryFixed: Color(4294957782),
      onPrimaryFixed: Color(4282449922),
      primaryFixedDim: Color(4294948012),
      onPrimaryFixedVariant: Color(4287823885),
      secondaryFixed: Color(4294956794),
      onSecondaryFixed: Color(4281794620),
      secondaryFixedDim: Color(4294945277),
      onSecondaryFixedVariant: Color(4285670775),
      tertiaryFixed: Color(4294958269),
      onTertiaryFixed: Color(4281079296),
      tertiaryFixedDim: Color(4294948974),
      onTertiaryFixedVariant: Color(4285086720),
      surfaceDim: Color(4292729305),
      surfaceBright: Color(4294768888),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294374386),
      surfaceContainer: Color(4294045164),
      surfaceContainerHigh: Color(4293650407),
      surfaceContainerHighest: Color(4293255905),
);