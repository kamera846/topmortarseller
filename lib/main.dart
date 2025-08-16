import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:topmortarseller/screen/splash_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upgrader/upgrader.dart';

final mColorScheme = ColorScheme.fromSeed(
  seedColor: cPrimary100,
  brightness: Brightness.light,
);
final mDarkColorScheme = ColorScheme.fromSeed(
  seedColor: cDark100,
  brightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  await initializeDateFormatting('id_ID', null);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'MyTop Seller',
            theme: ThemeData().copyWith(
              colorScheme: mColorScheme,
              appBarTheme: const AppBarTheme().copyWith(
                backgroundColor: cPrimary100,
                foregroundColor: cWhite,
              ),
              scaffoldBackgroundColor: cWhite,
              textTheme: GoogleFonts.openSansTextTheme(),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: mDarkColorScheme,
              appBarTheme: const AppBarTheme().copyWith(
                backgroundColor: cDark200,
                foregroundColor: cWhite,
              ),
              scaffoldBackgroundColor: cDark100,
              textTheme: GoogleFonts.openSansTextTheme(),
            ),
            themeMode: ThemeMode.light,
            routes: {'/': (context) => const SplashScreen()},
            // home: const SplashScreen(),
          ),
        );
      },
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
