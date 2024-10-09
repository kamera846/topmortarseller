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
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        _goToNewRekeningScreen();
      } else {
        prefs.setBool(
            '${_userData!.idContact!}-${GlobalEnum.skipCreateBank}', true);
      }
    } else {
      prefs.setBool(
          '${_userData!.idContact!}-${GlobalEnum.skipCreateBank}', true);
    }
    setState(() => isLoading = false);
  }

  void _goToNewRekeningScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => NewRekeningScreen(
          userData: _userData,
          onSuccess: (bool? state) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: true,
        languageCode: 'id',
        durationUntilAlertAgain: const Duration(seconds: 1),
      ),
      barrierDismissible: false,
      showLater: false,
      showReleaseNotes: false,
      showIgnore: false,
      child: Stack(
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
            drawer: MainDrawer(userData: _userData),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardPromoScanner(userData: widget.userData),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12, top: 12, right: 12, bottom: 0),
                    child: Text(
                      'Informasi menarik untuk anda',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: cDark100, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const CardFeed(
                    feedUrl:
                        'https://www.instagram.com/p/DAzx9UHyNcb/?utm_source=ig_web_copy_link',
                  )
                ],
              ),
            ),
          ),
          if (isLoading) const LoadingModal()
        ],
      ),
    );
  }
}

class CardFeed extends StatelessWidget {
  const CardFeed({super.key, this.feedUrl});

  final String? feedUrl;

  void _launchNavigation(context, url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showSnackBar(context, 'Gagal membuka url konten');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Setting image card feed on 3:2 ratio
    final screenWidth = MediaQuery.of(context).size.width - 24;
    final cardFeedHeight = screenWidth * (2 / 3);

    return InkWell(
      onTap: () => _launchNavigation(context, feedUrl),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // Menentukan sudut melengkung
        ),
        child: Container(
          width: double.maxFinite,
          height: cardFeedHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
                image: NetworkImage(
                  'https://blue.kumparan.com/image/upload/fl_progressive,fl_lossy,c_fill,q_auto:best,w_640/v1634025439/01gqh05gx6ptyce3wqe5cwzevm.jpg',
                ),
                fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
