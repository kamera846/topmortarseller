import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/profile/detail_profile_screen.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/screen/scanner/qr_scanner_screen.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/dashboard/content_section.dart';
import 'package:topmortarseller/widget/dashboard/hero_section.dart';
import 'package:topmortarseller/widget/dashboard/menu_section.dart';
import 'package:topmortarseller/widget/dashboard/promo_slider_section.dart';
import 'package:upgrader/upgrader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.userData});

  final ContactModel? userData;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        languageCode: 'id',
        durationUntilAlertAgain: const Duration(seconds: 1),
      ),
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      barrierDismissible: false,
      showLater: false,
      showReleaseNotes: false,
      showIgnore: false,
      child: const HomeDashboard(),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final GlobalKey<ContentSectionState> contentKey = GlobalKey();
  ContactModel? _userData;
  int navCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _userData = null;
    });
    _getUserData();
    contentKey.currentState?.onRefresh();
  }

  Future<void> _getUserData() async {
    final data = await getContactModel();
    setState(() => _userData = data);
    final prefs = await SharedPreferences.getInstance();
    final isSkipCreateBank = prefs.getBool(
      '${_userData!.idContact!}-${GlobalEnum.skipCreateBank}',
    );
    if (isSkipCreateBank == null || isSkipCreateBank == false) {
      final userBanks = await CustomerBankApiService().banks(
        idContact: _userData!.idContact!,
        onSuccess: (msg) {},
        onError: (e) {},
        onCompleted: () {},
      );
      if (userBanks == null || userBanks.isEmpty) {
        _goToNewRekeningScreen();
      } else {
        prefs.setBool(
          '${_userData!.idContact!}-${GlobalEnum.skipCreateBank}',
          true,
        );
      }
    } else {
      prefs.setBool(
        '${_userData!.idContact!}-${GlobalEnum.skipCreateBank}',
        true,
      );
    }
  }

  void _goToNewRekeningScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) =>
            NewRekeningScreen(userData: _userData, onSuccess: (bool? state) {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light, // For Android
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    return Scaffold(
      bottomNavigationBar: _userData != null
          ? BottomNavigationBar(
              backgroundColor: Colors.white,
              onTap: (value) => value == 1
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => QRScannerScreen(userData: _userData),
                      ),
                    )
                  : setState(() {
                      navCurrentIndex = value;
                    }),
              currentIndex: navCurrentIndex,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_filled),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_outlined),
                  label: 'Scanner',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_alt_circle),
                  activeIcon: Icon(CupertinoIcons.person_alt_circle_fill),
                  label: 'Profil',
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(
              color: Colors.amber,
              width: double.infinity,
              child: Image.asset(
                'assets/bg_shape_primary_vertical.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: navCurrentIndex == 0
                ? SafeArea(
                    child: RefreshIndicator.adaptive(
                      onRefresh: () => _onRefresh(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeroSection(userData: _userData),
                            Material(
                              color: cWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const MenuSection(),
                                  const PromoSliderSection(),
                                  ContentSection(key: contentKey),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : DetailProfileScreen(userData: _userData),
          ),
        ],
      ),
    );
  }
}
