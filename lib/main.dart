import 'dart:io';

import 'package:flutter/material.dart';
import 'package:topmortarseller/screen/splash_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:google_fonts/google_fonts.dart';

final mColorScheme =
    ColorScheme.fromSeed(seedColor: cPrimary100, brightness: Brightness.light);
final mDarkColorScheme =
    ColorScheme.fromSeed(seedColor: cDark100, brightness: Brightness.dark);

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Mortar Seller',
      theme: ThemeData(useMaterial3: true).copyWith(
        colorScheme: mColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: mColorScheme.primary,
          foregroundColor: mColorScheme.onPrimary,
        ),
        scaffoldBackgroundColor: cWhite,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: mDarkColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: cDark200,
          foregroundColor: cWhite,
        ),
        scaffoldBackgroundColor: cDark100,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
