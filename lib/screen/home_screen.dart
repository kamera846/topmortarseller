import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/drawer/main_drawer.dart';
import 'package:topmortarseller/widget/card/card_promo_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ContactModel? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    final data = await getContactModel();
    setState(() {
      userData = data;
    });
  }

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
              tag: TagHero.faviconAuth,
              child: Image.asset(
                'assets/favicon/favicon_circle.png',
                width: 32,
              ),
            ),
          ),
        ],
      ),
      drawer: MainDrawer(
        userData: userData,
      ),
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
