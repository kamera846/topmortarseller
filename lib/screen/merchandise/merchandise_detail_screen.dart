import 'dart:async';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/merchandise_model.dart';
import 'package:topmortarseller/services/merchandise_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class MerchandiseDetailScreen extends StatefulWidget {
  final String id;
  final int userPoint;
  const MerchandiseDetailScreen({
    super.key,
    required this.id,
    required this.userPoint,
  });

  @override
  State<MerchandiseDetailScreen> createState() =>
      _MerchandiseDetailScreenState();
}

class _MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  MerchandiseModel? item;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getItem();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      item = null;
    });

    _getItem();
  }

  Future<void> _getItem() async {
    return await MerchandiseApi().detail(
      id: widget.id,
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: (data) {
        item = data;
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: cDark600,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Merchandise',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.userPoint} Poin Saya',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            scrolledUnderElevation: 0,
            backgroundColor: cWhite,
            foregroundColor: cDark100,
          ),
          body: SafeArea(
            child: RefreshIndicator.adaptive(
              onRefresh: () => _onRefresh(),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : item == null
                  ? const Center(
                      child: Text(
                        "Gagal memuat konten.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            item!.imgMerchandise,
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Icon(Icons.error, color: Colors.grey),
                                ),
                            fit: BoxFit.fitWidth,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item!.nameMerchandise,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  item!.descMerchandise,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          bottomNavigationBar: !isLoading && item != null
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: cWhite,
                    border: Border.symmetric(
                      horizontal: BorderSide(color: cDark500, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    child: MElevatedButton(
                      onPressed: () {},
                      title: 'Tukarkan ${item!.priceMerchandise} Poin',
                      isFullWidth: true,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
