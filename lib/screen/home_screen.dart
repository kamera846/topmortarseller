import 'package:flutter/material.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/drawer/main_drawer.dart';
import 'package:topmortarseller/widget/card/card_promo_scanner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Mortar Seller'),
        backgroundColor: cWhite,
        foregroundColor: cDark100,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Hero(
              tag: AuthTagHero.faviconAuth,
              child: Image.asset(
                'assets/favicon/favicon_circle.png',
                width: 32,
              ),
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: const Center(
        child: Column(
          children: [
            HomeHeader(),
          ],
        ),
      ),
    );
  }
}
