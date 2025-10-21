import 'dart:async';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/merchandise_model.dart';
import 'package:topmortarseller/screen/merchandise/merchandise_detail_screen.dart';
import 'package:topmortarseller/services/merchandise_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class MerchandiseScreen extends StatefulWidget {
  final int userPoint;
  const MerchandiseScreen({super.key, required this.userPoint});

  @override
  State<MerchandiseScreen> createState() => _MerchandiseScreenState();
}

class _MerchandiseScreenState extends State<MerchandiseScreen> {
  List<MerchandiseModel> items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getList();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      items = [];
    });

    _getList();
  }

  Future<void> _getList() async {
    await MerchandiseApi().list(
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: (data) {
        items = data ?? [];
        setState(() {
          _isLoading = false;
        });
      },
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: cWhite,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Merchandise',
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 12,
                        top: 12,
                        right: 12,
                        bottom: 12,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1.5,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          color: cWhite,
                          elevation: 0.5,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MerchandiseDetailScreen(
                                    id: item.idMerchandise,
                                    userPoint: widget.userPoint,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      color: cDark600,
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Image.network(
                                        item.imgMerchandise,
                                        key: Key(item.idMerchandise),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.error,
                                                size: 40,
                                                color: Colors.grey,
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(12),
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.nameMerchandise,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            "${item.priceMerchandise} Poin",
                                            style: TextStyle(
                                              color: Colors.amber.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
