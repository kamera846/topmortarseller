import 'package:flutter/material.dart';
import 'package:topmortarseller/screens/splash_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';

final mColorScheme =
    ColorScheme.fromSeed(seedColor: cPrimary100, brightness: Brightness.light);
final mDarkColorScheme =
    ColorScheme.fromSeed(seedColor: cDark100, brightness: Brightness.dark);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Mortar Seller',
      theme: ThemeData().copyWith(
        colorScheme: mColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: mColorScheme.primary,
          foregroundColor: mColorScheme.onPrimary,
        ),
        scaffoldBackgroundColor: cWhite,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: mDarkColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: cDark300,
          foregroundColor: cWhite,
        ),
        scaffoldBackgroundColor: cDark100,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
