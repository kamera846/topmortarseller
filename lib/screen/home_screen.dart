import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/drawer/main_drawer.dart';
import 'package:topmortarseller/widget/card/card_promo_scanner.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ContactModel? _userData;
  bool isLoading = true;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    final data = widget.userData ?? await getContactModel();
    setState(() => _userData = data);
    final prefs = await SharedPreferences.getInstance();
    final isSkipCreateBank =
        prefs.getBool('${_userData!.idContact!}-${GlobalEnum.skipCreateBank}');

    if (isSkipCreateBank == null || isSkipCreateBank == false) {
      final userBanks = await CustomerBankApiService().banks(
        idContact: _userData!.idContact!,
        onSuccess: (msg) {},
        onError: (e) {},
        onCompleted: () {},
      );

      if (userBanks == null || userBanks.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => NewRekeningScreen(
              userData: _userData,
              onSuccess: (bool? state) {},
            ),
          ),
        );
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
          drawer: MainDrawer(userData: _userData),
          body: Center(
            child: Column(
              children: [
                HomeHeader(userData: widget.userData),
              ],
            ),
          ),
        ),
        if (isLoading) const LoadingModal()
      ],
    );
  }
}
