import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/home_screen.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/enum.dart';
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
    final loginState = await getLoginState();
    if (loginState) {
      final userData = await getContactModel();
      if (userData != null) {
        _returnHomeScreen(userData);
      } else {
        _returnAuthScreen();
      }
    } else {
      _returnAuthScreen();
    }
  }

  void _returnHomeScreen(ContactModel? userData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userData: userData),
      ),
    );
  }

  void _returnAuthScreen() {
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
          child: Hero(
            tag: TagHero.faviconAuth,
            child: Semantics(
              label: '${TagHero.faviconAuth}',
              child: Image.asset(
                'assets/favicon/favicon_circle.png',
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
