import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/cart_model.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/screen/products/checkout_screen.dart';
import 'package:topmortarseller/services/cart_api.dart';
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
  CartModel? cartItem;
  bool _showOverlay = false;
  bool _isLoading = true;
  bool _isCartLoading = true;
  ProductModel? _selectedItem;
  String dummyImageUrl =
      'https://topmortar.com/wp-content/uploads/2021/10/TOP-THINBED-2.png';

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    final data = await getContactModel();
    setState(() {
      _userData = data;
    });

    _onRefresh();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      items = [];
      _showOverlay = false;
      _selectedItem = null;
    });
    _getCart();
  }

  void _getCart() async {
    setState(() {
      checkoutedItems = [];
    });
    await CartApiService().get(
      idContact: _userData != null ? _userData?.idContact ?? '-1' : 'null',
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: (data) async {
        if (items.isEmpty) {
          await _getList();
        }

        if (data != null && data.details.isNotEmpty) {
          for (var product in data.details) {
            var dummyObject = product.copyWith(imageProduk: dummyImageUrl);
            checkoutedItems.add(dummyObject);

            int foundIndex = items.indexWhere(
              (item) => item.idProduk == dummyObject.idProduk,
            );

            if (foundIndex >= 0) {
              setState(() {
                items[foundIndex] = dummyObject;
              });
            }
          }
        }

        setState(() {
          cartItem = data;
          _isCartLoading = false;
        });
      },
    );
  }

  Future<void> _getList() async {
    await ProductApiService().list(
      idContact: _userData != null ? _userData?.idContact ?? '-1' : 'null',
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: (data) {
        items = [];
        for (var item in data) {
          var dummyObject = item.copyWith(imageProduk: dummyImageUrl);
          items.add(dummyObject);
        }
        setState(() {
          _isLoading = false;
        });
      },
    );
    return;
  }

  void _insertCart(String idCart, String idProduct, String qty) async {
    setState(() {
      _isCartLoading = true;
    });
    await CartApiService().insert(
      idCart: idCart,
      idProduct: idProduct,
      qty: qty,
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: () {
        setState(() {
          _selectedItem = null;
          _showOverlay = false;
        });

        _getCart();
      },
    );
  }

  void _deleteCart(String idCartDetail) async {
    setState(() {
      _isCartLoading = true;
    });
    await CartApiService().delete(
      idCartDetail: idCartDetail,
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: () {
        if (_selectedItem != null) {
          int foundIndex = items.indexWhere(
            (item) => item.idProduk == _selectedItem!.idProduk,
          );
          if (foundIndex >= 0) {
            setState(() {
              items[foundIndex] = _selectedItem!.copyWith(
                idCartDetail: '',
                idCart: '',
                qtyCartDetail: '',
                imageProduk: dummyImageUrl,
              );
            });
          }
        }

        setState(() {
          _selectedItem = null;
          _showOverlay = false;
        });

        _getCart();
      },
    );
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
            actions: [
              PopupMenuButton(
                enabled: !_isCartLoading && checkoutedItems.isNotEmpty,
                position: PopupMenuPosition.under,
                color: Colors.white,
                icon: Badge(
                  label: Text(checkoutedItems.length.toString()),
                  isLabelVisible: !_isCartLoading && checkoutedItems.isNotEmpty,
                  alignment: Alignment(1.2, -1),
                  child: Icon(Icons.trolley),
                ),
                itemBuilder: (context) {
                  return checkoutedItems.map((item) {
                    return PopupMenuItem(
                      onTap: () {
                        setState(() {
                          _selectedItem = item;
                          _showOverlay = true;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(4),
                            child: Container(
                              color: cDark600,
                              width: 40,
                              height: 40,
                              child: Image.network(
                                item.imageProduk ?? 'https://google.com',
                                key: Key(item.idProduk ?? '-1'),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 25,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaProduk ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '${item.qtyCartDetail} ${item.nameSatuan}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: cDark200),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _selectedItem = item;
                                });
                                _deleteCart(_selectedItem?.idCartDetail ?? '0');
                              },
                              padding: EdgeInsets.zero,
                              color: Colors.grey,
                              icon: Icon(Icons.delete_forever),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ],
            backgroundColor: cWhite,
            foregroundColor: cDark100,
          ),
          bottomNavigationBar: !_isCartLoading && checkoutedItems.isNotEmpty
              ? CheckoutedItems(
                  items: checkoutedItems,
                  totalItems: checkoutedItems.length,
                  totalPrice: int.parse(cartItem?.subtotalPrice ?? '0'),
                  onCheckout: _isCartLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => CheckoutScreen(
                                idCart: cartItem?.idCart ?? '-1',
                              ),
                            ),
                          ).then((value) {
                            if (value != null &&
                                value is String &&
                                value == 'isCheckouted') {
                              _onRefresh();
                            }
                          });
                        },
                )
              : null,
          body: SafeArea(
            child: RefreshIndicator.adaptive(
              onRefresh: () => _onRefresh(),
              child: _isLoading
                  ? const LoadingModal()
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
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
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedItem = item;
                                _showOverlay = true;
                              });
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: cDark600,
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Image.network(
                                        item.imageProduk ??
                                            'https://google.com',
                                        key: Key(
                                          item.idProduk ?? index.toString(),
                                        ),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.broken_image,
                                                size: 80,
                                                color: Colors.grey,
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
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
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.namaProduk ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  CurrencyFormat().format(
                                                    amount: double.parse(
                                                      item.hargaProduk!,
                                                    ),
                                                  ),
                                                  style: const TextStyle(
                                                    color: cPrimary400,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (item
                                                      .qtyCartDetail!
                                                      .isNotEmpty &&
                                                  item.qtyCartDetail !=
                                                      '0') ...[
                                                const Icon(Icons.shopping_bag),
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: cPrimary100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      item.qtyCartDetail ?? '',
                                                      style: const TextStyle(
                                                        color: cWhite,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
        if (_showOverlay && _selectedItem != null && !_isLoading)
          OverlayItem(
            selectedItem: _selectedItem!,
            onClear: () => _deleteCart(_selectedItem?.idCartDetail ?? '0'),
            onSubmit: (checkoutCount) => _insertCart(
              cartItem?.idCart ?? '0',
              _selectedItem?.idProduk ?? '0',
              checkoutCount,
            ),
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
  final Function()? onCheckout;

  @override
  Widget build(BuildContext context) {
    int totalQtyItems = 0;

    for (var item in items) {
      totalQtyItems += int.parse(item.qtyCartDetail ?? '0');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        totalQtyItems < 10
            ? Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.withValues(alpha: 0.45),
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    Text('Minimal order 10 item!'),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.symmetric(
              horizontal: BorderSide(color: cDark600, width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormat().format(
                        amount: double.parse('$totalPrice'),
                      ),
                      style: const TextStyle(
                        color: cPrimary100,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('Total ${items.length} produk, $totalQtyItems item.'),
                    // Text('${items.length} produk $totalItems item'),
                  ],
                ),
                onCheckout != null
                    ? MElevatedButton(
                        onPressed: onCheckout!,
                        enabled: totalQtyItems > 9,
                        title: 'Checkout',
                      )
                    : CircularProgressIndicator.adaptive(),
              ],
            ),
          ),
        ),
      ],
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
    if (widget.selectedItem.qtyCartDetail != null &&
        widget.selectedItem.qtyCartDetail!.isNotEmpty) {
      _itemCountController.text = widget.selectedItem.qtyCartDetail!;
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
    setState(() {
      int countPlus = countNow + value;
      _itemCountController.text = '$countPlus';
    });
  }

  void _itemCountControllerChanged(String value) {
    if (value.isNotEmpty && int.tryParse(value) != null) {
      if (int.parse(value) <= 0) {
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
                        widget.selectedItem.imageProduk ?? 'https://google.com',
                        key: Key(widget.selectedItem.idProduk ?? '-1'),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          );
                        },
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
                      'Stok tersedia',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton.filled(
                          onPressed: int.parse(_itemCountController.text) > 0
                              ? () => _minusCountItem(2)
                              : null,
                          icon: const Icon(Icons.exposure_minus_2),
                        ),
                        IconButton.filled(
                          onPressed: int.parse(_itemCountController.text) > 0
                              ? () => _minusCountItem(1)
                              : null,
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
                        if (widget.selectedItem.qtyCartDetail != null &&
                            widget.selectedItem.qtyCartDetail!.isNotEmpty) ...[
                          IconButton(
                            onPressed: widget.onClear,
                            style: IconButton.styleFrom(
                              backgroundColor: cDark400,
                              foregroundColor: cDark200,
                            ),
                            icon: const Icon(Icons.delete_forever),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  int.parse(_itemCountController.text) <= 0
                                  ? cPrimary600
                                  : cPrimary200,
                              foregroundColor: cWhite,
                              iconColor: cWhite,
                              overlayColor: cWhite,
                              shadowColor: cDark600,
                            ),
                            onPressed: int.parse(_itemCountController.text) <= 0
                                ? null
                                : () {
                                    widget.onSubmit(_itemCountController.text);
                                  },
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
