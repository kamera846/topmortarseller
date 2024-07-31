import 'package:flutter/material.dart';
import 'package:topmortarseller/screens/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _returnHomScreen();
  }

  void _returnHomScreen() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/logo.png',
          ),
        ),
      ),
    );
  }
}
