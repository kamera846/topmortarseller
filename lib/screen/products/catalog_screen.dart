import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/screen/products/checkout_screen.dart';
import 'package:topmortarseller/services/product_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.userData});

  final ContactModel? userData;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  ContactModel? _userData;
  List<ProductModel> items = [];
  List<ProductModel> checkoutedItems = [];
  bool _showOverlay = false;
  bool _isLoading = true;
  ProductModel? _selectedItem;
  int totalPrice = 0;
  int totalItems = 0;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    // final data = widget.userData ?? await getContactModel();
    final data = await getContactModel();
    setState(() {
      _userData = data;
    });

    _getList();
  }

  void _getList() async {
    await ProductApiService().list(
      idCity: _userData != null ? _userData!.idCity : '',
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: (data) {
        items = [];
        for (var item in data) {
          var dummyObject = item.copyWith(
            checkoutCount: '',
            imageProduk:
                'https://topmortar.com/wp-content/uploads/2021/10/TOP-THINBED-2.png',
          );
          items.add(dummyObject);
        }
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      items = [];
      checkoutedItems = [];
      _showOverlay = false;
      _selectedItem = null;
      totalPrice = 0;
      totalItems = 0;
    });
    _getList();
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
            title: const Text('Katalog Produk'),
            centerTitle: false,
            backgroundColor: cWhite,
            foregroundColor: cDark100,
          ),
          body: RefreshIndicator(
            onRefresh: () => _onRefresh(),
            child: _isLoading
                ? const LoadingModal()
                : Column(
                    children: [
                      Expanded(
                        child: GridView(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1 / 1.5,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                              ),
                          children: [
                            for (final item in items)
                              Card(
                                color: cWhite,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: InkWell(
                                  onTap: item.stok == null || item.stok! == 0
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedItem = item;
                                            _showOverlay = true;
                                          });
                                        },
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                color: cDark600,
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: Hero(
                                                  tag:
                                                      'product-${item.idProduk}',
                                                  child: Image.network(
                                                    item.imageProduk ?? '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                color: Colors.white,
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                width: double.infinity,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.namaProduk ?? '',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          CurrencyFormat().format(
                                                            amount: double.parse(
                                                              item.hargaProduk!,
                                                            ),
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    cPrimary400,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'Stok ${item.stok != null && item.stok! != 0 ? 'tersedia' : 'habis'}',
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      cDark200,
                                                                ),
                                                          ),
                                                        ),
                                                        if (item
                                                                .checkoutCount!
                                                                .isNotEmpty &&
                                                            item.checkoutCount !=
                                                                '0') ...[
                                                          const Icon(
                                                            Icons.trolley,
                                                          ),
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  cPrimary100,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    100,
                                                                  ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                item.checkoutCount ??
                                                                    '',
                                                                style: const TextStyle(
                                                                  color: cWhite,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (item.stok == null ||
                                            item.stok! == 0)
                                          BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 1.5,
                                              sigmaY: 1.5,
                                            ),
                                            child: Container(
                                              color: cDark200.withValues(
                                                alpha: 0.7,
                                              ),
                                              width: double.infinity,
                                              height: double.infinity,
                                              child: const Center(
                                                child: Text(
                                                  'Stok Habis',
                                                  style: TextStyle(
                                                    color: cWhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (checkoutedItems.isNotEmpty)
                        CheckoutedItems(
                          items: checkoutedItems,
                          totalItems: totalItems,
                          totalPrice: totalPrice,
                          onCheckout: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    CheckoutScreen(items: checkoutedItems),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
          ),
        ),
        if (_showOverlay && _selectedItem != null && !_isLoading)
          OverlayItem(
            selectedItem: _selectedItem!,
            onClear: () {
              setState(() {
                var indexOfItems = items.indexWhere(
                  (data) => data.idProduk == _selectedItem?.idProduk,
                );
                items[indexOfItems] = items[indexOfItems].copyWith(
                  checkoutCount: "",
                );

                var indexOfCheckoutItems = checkoutedItems.indexWhere(
                  (data) => data.idProduk == _selectedItem?.idProduk,
                );
                if (indexOfCheckoutItems == -1) {
                  checkoutedItems.add(
                    _selectedItem!.copyWith(checkoutCount: ""),
                  );
                } else {
                  checkoutedItems[indexOfCheckoutItems] =
                      checkoutedItems[indexOfCheckoutItems].copyWith(
                        checkoutCount: "",
                      );
                }

                totalPrice = 0;
                totalItems = 0;

                for (var item in checkoutedItems) {
                  if (item.checkoutCount!.isNotEmpty) {
                    totalPrice +=
                        int.parse(item.hargaProduk!) *
                        int.parse(item.checkoutCount!);
                    totalItems += int.parse(item.checkoutCount!);
                  }
                }

                if (totalItems == 0 && totalPrice == 0) {
                  checkoutedItems.clear();
                }

                _selectedItem = null;
                _showOverlay = false;
              });
            },
            onSubmit: (checkoutCount) {
              setState(() {
                var indexOfItems = items.indexWhere(
                  (data) => data.idProduk == _selectedItem?.idProduk,
                );
                items[indexOfItems] = items[indexOfItems].copyWith(
                  checkoutCount: checkoutCount,
                );

                var indexOfCheckoutItems = checkoutedItems.indexWhere(
                  (data) => data.idProduk == _selectedItem?.idProduk,
                );
                if (indexOfCheckoutItems == -1) {
                  checkoutedItems.add(
                    _selectedItem!.copyWith(checkoutCount: checkoutCount),
                  );
                } else {
                  checkoutedItems[indexOfCheckoutItems] =
                      checkoutedItems[indexOfCheckoutItems].copyWith(
                        checkoutCount: checkoutCount,
                      );
                }

                totalPrice = 0;
                totalItems = 0;

                for (var item in checkoutedItems) {
                  totalPrice +=
                      int.parse(item.hargaProduk!) *
                      int.parse(item.checkoutCount!);
                  totalItems += int.parse(item.checkoutCount!);
                }

                _selectedItem = null;
                _showOverlay = false;
              });
            },
            onClose: () {
              setState(() {
                _selectedItem = null;
                _showOverlay = false;
              });
            },
          ),
      ],
    );
  }
}

class CheckoutedItems extends StatelessWidget {
  const CheckoutedItems({
    super.key,
    required this.items,
    required this.onCheckout,
    required this.totalPrice,
    required this.totalItems,
  });

  final List<ProductModel> items;
  final int totalPrice;
  final int totalItems;
  final Function() onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: cDark600, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormat().format(amount: double.parse('$totalPrice')),
                  style: const TextStyle(
                    color: cPrimary100,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('Total ${items.length} produk'),
                // Text('${items.length} produk $totalItems item'),
              ],
            ),
          ),
          MElevatedButton(onPressed: onCheckout, title: 'Checkout'),
        ],
      ),
    );
  }
}

class OverlayItem extends StatefulWidget {
  const OverlayItem({
    super.key,
    required this.selectedItem,
    required this.onClear,
    required this.onSubmit,
    required this.onClose,
  });

  final ProductModel selectedItem;
  final Function() onClear;
  final Function(String checkoutCount) onSubmit;
  final Function() onClose;

  @override
  State<OverlayItem> createState() => _OverlayItemState();
}

class _OverlayItemState extends State<OverlayItem> {
  final _itemCountController = TextEditingController();

  @override
  void initState() {
    if (widget.selectedItem.checkoutCount != null &&
        widget.selectedItem.checkoutCount!.isNotEmpty) {
      _itemCountController.text = widget.selectedItem.checkoutCount!;
    } else {
      _itemCountController.text = "0";
    }
    super.initState();
  }

  @override
  void dispose() {
    _itemCountController.dispose();
    super.dispose();
  }

  void _minusCountItem(int value) {
    var countNow = int.parse(_itemCountController.text);
    if (countNow > 0) {
      var countMinus = countNow - value;
      if (countMinus < 0) {
        setState(() {
          _itemCountController.text = '0';
        });
      } else {
        setState(() {
          _itemCountController.text = '$countMinus';
        });
      }
    }
  }

  void _plusCountItem(int value) {
    var countNow = int.parse(_itemCountController.text);
    if (countNow < widget.selectedItem.stok!) {
      setState(() {
        int countPlus = countNow + value;
        if (countPlus < widget.selectedItem.stok!) {
          _itemCountController.text = '$countPlus';
        } else {
          _itemCountController.text = '${widget.selectedItem.stok!}';
        }
      });
    }
  }

  void _itemCountControllerChanged(String value) {
    if (value.isNotEmpty && int.tryParse(value) != null) {
      if (int.parse(value) > widget.selectedItem.stok!) {
        setState(() {
          _itemCountController.text = widget.selectedItem.stok!.toStringAsFixed(
            0,
          );
        });
      } else if (int.parse(value) <= 0) {
        setState(() {
          _itemCountController.text = '0';
        });
      } else {
        setState(() {
          _itemCountController.text = value;
        });
      }
    } else {
      setState(() {
        _itemCountController.text = '0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          color: cDark100.withValues(alpha: 0.7),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.selectedItem.imageProduk ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      CurrencyFormat().format(
                        amount: double.parse(widget.selectedItem.hargaProduk!),
                      ),
                      style: const TextStyle(
                        color: cPrimary400,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.selectedItem.namaProduk ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Stok ${widget.selectedItem.stok != null && widget.selectedItem.stok! != 0 ? 'tersedia ${widget.selectedItem.stok!}' : 'habis'}',
                      style: const TextStyle(color: cDark200),
                    ),
                    // Text(
                    //   'Rp. ${widget.selectedItem!.hargaProduk}',
                    //   style: const TextStyle(
                    //       color: cPrimary400,
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    const SizedBox(height: 32),
                    if (widget.selectedItem.stok != null &&
                        widget.selectedItem.stok! != 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton.filled(
                            onPressed: () => _minusCountItem(2),
                            icon: const Icon(Icons.exposure_minus_2),
                          ),
                          IconButton.filled(
                            onPressed: () => _minusCountItem(1),
                            icon: const Icon(Icons.exposure_minus_1),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _itemCountController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: cDark100,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onChanged: _itemCountControllerChanged,
                            ),
                          ),
                          IconButton.filled(
                            onPressed: () => _plusCountItem(1),
                            icon: const Icon(Icons.exposure_plus_1),
                          ),
                          IconButton.filled(
                            onPressed: () => _plusCountItem(2),
                            icon: const Icon(Icons.exposure_plus_2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (widget.selectedItem.checkoutCount != null &&
                              widget
                                  .selectedItem
                                  .checkoutCount!
                                  .isNotEmpty) ...[
                            IconButton(
                              onPressed: widget.onClear,
                              style: IconButton.styleFrom(
                                backgroundColor: cDark200,
                                foregroundColor: cWhite,
                              ),
                              icon: const Icon(CupertinoIcons.trash),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _itemCountController.text == "0"
                                    ? cPrimary600
                                    : cPrimary200,
                                foregroundColor: cWhite,
                                iconColor: cWhite,
                                overlayColor: cWhite,
                                shadowColor: cDark600,
                              ),
                              onPressed: _itemCountController.text == "0"
                                  ? null
                                  : () {
                                      widget.onSubmit(
                                        _itemCountController.text,
                                      );
                                    },
                              // onPressed: () => print('Hello there..'),
                              child: const Text(
                                'Tambahkan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
