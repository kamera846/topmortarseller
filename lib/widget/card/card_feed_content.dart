import 'package:flutter/material.dart';
import 'package:topmortarseller/model/feed_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CardFeed extends StatelessWidget {
  const CardFeed({super.key, this.feed, this.mediaLink});

  final FeedModel? feed;
  final String? mediaLink;

  Future<void> _launchNavigation(BuildContext context, String url) async {
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
      onTap: () => _launchNavigation(context, feed!.linkKonten!),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(left: 12, top: 0, right: 12, bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.maxFinite,
          height: cardFeedHeight,
          decoration: BoxDecoration(
            color: cDark400,
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage('${mediaLink ?? ''}${feed!.imgKonten!}'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
