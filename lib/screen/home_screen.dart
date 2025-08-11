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
import 'package:topmortarseller/services/point_api.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/loading_item.dart';
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

class _HomeDashboardState extends State<HomeDashboard>
    with WidgetsBindingObserver {
  late ContactModel _userData;
  final GlobalKey<ContentSectionState> contentKey = GlobalKey();
  final GlobalKey<ContentSectionState> searchComponentKey = GlobalKey();
  double searchComponentOffset = 0;
  int navCurrentIndex = 0;
  int totalPoint = 0;
  bool isLoadPoint = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getUserData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _getTotalPoint();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    _getUserData();
    contentKey.currentState?.onRefresh();
  }

  Future<void> _getUserData() async {
    final user = await getContactModel();
    setState(() {
      _userData = user ?? ContactModel();
      isLoading = false;
    });
    final prefs = await SharedPreferences.getInstance();
    final isSkipCreateBank = prefs.getBool(
      '${_userData.idContact!}-${GlobalEnum.skipCreateBank}',
    );
    if (isSkipCreateBank == null || isSkipCreateBank == false) {
      final userBanks = await CustomerBankApiService().banks(
        idContact: _userData.idContact!,
        onSuccess: (msg) {},
        onError: (e) {},
        onCompleted: () {},
      );
      if (userBanks == null || userBanks.isEmpty) {
        _goToNewRekeningScreen();
      } else {
        prefs.setBool(
          '${_userData.idContact!}-${GlobalEnum.skipCreateBank}',
          true,
        );
      }
    } else {
      prefs.setBool(
        '${_userData.idContact!}-${GlobalEnum.skipCreateBank}',
        true,
      );
    }
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
    _getTotalPoint();
  }

  Future<void> _getTotalPoint() async {
    setState(() => isLoadPoint = true);
    final prefs = await SharedPreferences.getInstance();
    final savedTotalPoint =
        prefs.getInt('${_userData.idContact!}-${GlobalEnum.savedTotalPoint}') ??
        0;
    bool isSucces = false;
    final currentPoint = await PointApi.total(
      idContact: _userData.idContact!,
      onError: (e) => showSnackBar(context, e),
      onSuccess: (e) {
        isSucces = true;
      },
      onCompleted: (point) {},
    );
    if (isSucces && mounted) {
      if (savedTotalPoint < currentPoint) {
        showPointRewardDialog(
          context,
          previousPoints: savedTotalPoint,
          currentPoints: currentPoint,
        );
      }
      prefs.setInt(
        '${_userData.idContact!}-${GlobalEnum.savedTotalPoint}',
        currentPoint,
      );
      setState(() {
        isLoadPoint = false;
        totalPoint = currentPoint;
      });
    }
  }

  void showPointRewardDialog(
    BuildContext context, {
    required int previousPoints,
    required int currentPoints,
  }) {
    final newPoints = currentPoints - previousPoints;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: cWhite,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 64,
                  color: Colors.amber.shade700,
                ),

                const SizedBox(height: 16),

                Text(
                  "Selamat",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: cDark100,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: cDark100),
                    children: [
                      const TextSpan(text: 'Kamu berhasil mendapatkan '),
                      TextSpan(
                        text: '$newPoints poin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                          fontSize: 18,
                        ),
                      ),
                      const TextSpan(text: ' tambahan!'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPointBox(previousPoints),
                    Icon(Icons.arrow_forward, color: cDark100),
                    _buildPointBox(currentPoints),
                  ],
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointBox(int point) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$point",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.amber.shade800,
        ),
      ),
    );
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
              idContact: _userData.idContact,
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
      bottomNavigationBar: isLoading
          ? null
          : BottomNavigationBar(
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
            ),
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
                      child: isLoading
                          ? const SizedBox.shrink()
                          : _generateBodyWidget(context),
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
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CatalogScreen(
                                                  searchTrigger: true,
                                                ),
                                          ),
                                        )
                                        .then((value) => _getTotalPoint());
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
                          child: MenuSection(onResumed: () => _getTotalPoint()),
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
          isLoadPoint
              ? const SizedBox(
                  width: 50,
                  child: LoadingItem(isPrimaryTheme: true),
                )
              : Text(
                  "$totalPoint Poin",
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
