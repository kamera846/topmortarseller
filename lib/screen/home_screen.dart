import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/dashboard/content_section.dart';
import 'package:topmortarseller/widget/dashboard/menu_section.dart';
import 'package:topmortarseller/widget/dashboard/promo_slider_section.dart';
import 'package:topmortarseller/widget/drawer/main_drawer.dart';
import 'package:topmortarseller/widget/card/card_promo_scanner.dart';
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
              child: Semantics(
                label: '${TagHero.faviconAuth}',
                child: Image.asset(
                  'assets/favicon/favicon_circle.png',
                  width: 32,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _userData != null ? MainDrawer(userData: _userData) : null,
      body: RefreshIndicator.adaptive(
        onRefresh: () => _onRefresh(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userData != null) CardPromoScanner(userData: _userData),
              const MenuSection(),
              const PromoSliderSection(),
              ContentSection(key: contentKey),
            ],
          ),
        ),
      ),
    );
  }
}
