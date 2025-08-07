import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/screen/products/catalog_screen.dart';
import 'package:topmortarseller/screen/profile/detail_profile_screen.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/screen/scanner/qr_scanner_screen.dart';
import 'package:topmortarseller/services/auth_api.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/dashboard/content_section.dart';
import 'package:topmortarseller/widget/dashboard/hero_section.dart';
import 'package:topmortarseller/widget/dashboard/menu_section.dart';
import 'package:topmortarseller/widget/dashboard/promo_slider_section.dart';
import 'package:topmortarseller/widget/modal/info_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';
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
  final GlobalKey<ContentSectionState> searchComponentKey = GlobalKey();
  double searchComponentOffset = 0;
  ContactModel? _userData;
  int navCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = searchComponentKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final height = box.size.height + 16;

        setState(() {
          searchComponentOffset = height / 2;
        });
      }
    });
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

  void _onRequestDeleteAccount() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return MInfoModal(
          contentName: 'Apakah anda yakin ingin menghapus akun?',
          contentDescription:
              'Dengan menghapus akun, data anda akan kami hapus permanen dalam 7 hari.',
          contentIcon: Icons.warning_rounded,
          contentIconColor: cPrimary100,
          cancelText: 'Batal',
          confirmText: 'Hapus',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () async {
            await AuthApiService().requestDeleteAccount(
              idContact: _userData?.idContact,
              onError: (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  showSnackBar(context, e);
                }
              },
              onSuccess: (e) async {
                await removeLoginState();
                await removeContactModel();
                _clearAllScreenToAuth();
              },
            );
          },
        );
      },
    );
  }

  void _onRequestLogoutAccount() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return MInfoModal(
          contentName: 'Keluar dari akun?',
          contentDescription:
              'Anda diharuskan login kembali ketika mengakses aplikasi jika keluar dari akun.',
          contentIcon: Icons.warning_rounded,
          contentIconColor: cPrimary100,
          cancelText: 'Batal',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () async {
            await removeLoginState();
            await removeContactModel();
            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const AuthScreen()),
              );
            }
          },
        );
      },
    );
  }

  void _clearAllScreenToAuth() {
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    }
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
      backgroundColor: Colors.transparent,
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
                  activeIcon: Icon(Icons.home_sharp),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_outlined),
                  label: 'Scanner',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_alt_circle),
                  activeIcon: Icon(CupertinoIcons.person_alt_circle_fill),
                  label: 'Akun',
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
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 60, child: _generateHeaderWidget(context)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: _generateBodyWidget(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _generateBodyWidget(BuildContext context) {
    return navCurrentIndex == 0
        ? RefreshIndicator.adaptive(
            onRefresh: () => _onRefresh(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, bottom: 0),
                    child: HeroSection(userData: _userData),
                  ),
                  SizedBox(
                    height: searchComponentOffset * 2,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: searchComponentOffset,
                            color: cWhite,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 8,
                          right: 0,
                          child: Padding(
                            key: searchComponentKey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            child: Hero(
                              tag: "search-component",
                              child: Material(
                                color: Colors.white,
                                elevation: 1,
                                borderRadius: BorderRadius.circular(100),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CatalogScreen(
                                              searchTrigger: true,
                                            ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(100),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(Icons.search),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text("Cari produk sekarang"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: cWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 6,
                          ),
                          child: const MenuSection(),
                        ),
                        const PromoSliderSection(),
                        ContentSection(key: contentKey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : DetailProfileScreen(userData: _userData);
  }

  Row _generateHeaderWidget(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            'Top Mortar Seller',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: cWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (navCurrentIndex == 0) ...[
          Text(
            "0 Poin",
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 24),
        ] else ...[
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: cWhite),

            itemBuilder: (ctx) {
              return [
                PopupMenuItem<String>(
                  onTap: _onRequestLogoutAccount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Keluar dari akun'),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  onTap: _onRequestDeleteAccount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Ajukan penghapusan akun',
                        style: TextStyle(color: cPrimary100),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 12),
        ],
      ],
    );
  }
}
