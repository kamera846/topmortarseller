import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/feed_model.dart';
import 'package:topmortarseller/services/api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/card/card_feed_content.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class ContentSection extends StatefulWidget {
  const ContentSection({super.key});

  @override
  State<ContentSection> createState() => ContentSectionState();
}

class ContentSectionState extends State<ContentSection> {
  bool isLoading = true;
  List<FeedModel>? listFeed;
  String? mediaLink;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  void onRefresh() {
    setState(() {
      isLoading = true;
      listFeed = null;
      mediaLink = null;
    });
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    List<FeedModel>? data;
    try {
      final url = Uri.https(baseUrl, 'api/konten');
      final response = await http.get(url, headers: headerSetup);

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

        if (mounted) {
          showSnackBar(context, apiResponse.msg);
        }
      } else {
        if (mounted) {
          showSnackBar(
            context,
            '$failedRequestText. Status Code: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, '$failedRequestText. Exception: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          listFeed = data;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Informasi menarik untuk anda',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: cDark100,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _generateContent(),
      ],
    );
  }

  Widget _generateContent() {
    if (!isLoading) {
      if (listFeed != null && listFeed!.isNotEmpty) {
        return ListView.builder(
          itemCount: listFeed!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (conxtext, i) {
            final item = listFeed![i];
            return CardFeed(feed: item, mediaLink: mediaLink);
          },
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Belum ada konten',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: cDark200),
          ),
        );
      }
    } else {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Sedang memuat konten...',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: cDark200),
        ),
      );
    }
  }
}
