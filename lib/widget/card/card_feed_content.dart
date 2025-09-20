import 'package:flutter/material.dart';
import 'package:topmortarseller/model/feed_model.dart';
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

    return SizedBox(
      width: double.infinity,
      height: cardFeedHeight,
      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(16),
          child: InkWell(
            onTap: () => _launchNavigation(context, feed!.linkKonten!),
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              '${mediaLink ?? ''}${feed!.imgKonten!}',
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Icon(Icons.error, color: Colors.grey),
              ),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
