import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/services/api.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/drawer/main_drawer.dart';
import 'package:topmortarseller/widget/card/card_promo_scanner.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:http/http.dart' as http;

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
  bool isFeedLoading = true;
  List<FeedModel>? listFeed;
  String? mediaLink;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _userData = null;
      isLoading = true;
      isFeedLoading = true;
      listFeed = null;
      mediaLink = null;
    });
    _getUserData();
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
    loadFeed();
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

  void loadFeed() async {
    List<FeedModel>? data;
    try {
      final url = Uri.https(baseUrl, 'api/konten');
      final response = await http.get(
        url,
        headers: headerSetup,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            mediaLink = apiResponse.mediaLink;
            data = apiResponse.listData
                ?.map((item) => FeedModel.fromJson(item))
                .toList();
            return;
          }
        }

        showSnackBar(context, apiResponse.msg);
      } else {
        showSnackBar(
            context, '$failedRequestText. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, '$failedRequestText. Exception: $e');
    } finally {
      setState(() {
        isFeedLoading = false;
        listFeed = data;
      });
      // print('List Feed: ${jsonEncode(listFeed)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget listFeedContent = Container();

    if (!isFeedLoading) {
      if (listFeed != null && listFeed!.isNotEmpty) {
        listFeedContent = ListView.builder(
            itemCount: listFeed!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (conxtext, i) {
              final item = listFeed![i];
              return CardFeed(feed: item, mediaLink: mediaLink);
            });
      } else {
        listFeedContent = Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Belum ada konten',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: cDark200,
                ),
          ),
        );
      }
    } else {
      listFeedContent = Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Sedang memuat konten...',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: cDark200,
              ),
        ),
      );
    }

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
            body: RefreshIndicator(
              onRefresh: () => _onRefresh(),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardPromoScanner(userData: widget.userData),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Informasi menarik untuk anda',
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: cDark100,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      listFeedContent
                    ],
                  ),
                ),
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
  const CardFeed({super.key, this.feed, this.mediaLink});

  final FeedModel? feed;
  final String? mediaLink;

  void _launchNavigation(context, String url) async {
    try {
      launchUrlString(url);
    } catch (e) {
      showSnackBar(context, 'Gagal membuka $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Setting image card feed on 3:2 ratio
    final screenWidth = MediaQuery.of(context).size.width - 24;
    final cardFeedHeight = screenWidth * (2 / 3);

    return InkWell(
      onTap: () => _launchNavigation(
        context,
        feed!.linkKonten!,
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(left: 12, top: 0, right: 12, bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          height: cardFeedHeight,
          decoration: BoxDecoration(
            color: cDark400,
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
                image: NetworkImage(
                  '${mediaLink ?? ''}${feed!.imgKonten!}',
                ),
                fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class FeedModel {
  const FeedModel({
    this.idKonten,
    this.titleKonten,
    this.imgKonten,
    this.createdAt,
    this.udpatedAt,
    this.linkKonten,
  });

  final String? idKonten;
  final String? titleKonten;
  final String? imgKonten;
  final String? createdAt;
  final String? udpatedAt;
  final String? linkKonten;

  Map<String, dynamic> toJson() => {
        'id_konten': idKonten ?? '',
        'title_konten': titleKonten ?? '',
        'img_konten': imgKonten ?? '',
        'created_at': createdAt ?? '',
        'udpated_at': udpatedAt ?? '',
        'link_konten': linkKonten ?? '',
      };

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      idKonten: json['id_konten'] ?? '',
      titleKonten: json['title_konten'] ?? '',
      imgKonten: json['img_konten'] ?? '',
      createdAt: json['created_at'] ?? '',
      udpatedAt: json['udpated_at'] ?? '',
      linkKonten: json['link_konten'] ?? '',
    );
  }
}
