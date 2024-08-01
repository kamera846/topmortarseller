import 'package:flutter/material.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _delayNavigate();
  }

  void _delayNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    _returnHomScreen();
  }

  void _returnHomScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // child: InkWell(
          // onTap: _returnHomScreen,
          child: Hero(
            tag: AuthTagHero.faviconAuth,
            child: Image.asset(
              'assets/favicon/favicon_circle.png',
              width: MediaQuery.of(context).size.width,
            ),
          ),
          // ),
        ),
      ),
    );
  }
}
