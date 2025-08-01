import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/model/cart_model.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/product_discount_modal.dart';
import 'package:topmortarseller/services/cart_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.idCart});

  final String idCart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late ContactModel userData;
  late CartModel cart;
  List<ProductDiscountModel> discounts = [];
  double subTotalPrice = 0.0;
  double totalPrice = 0.0;
  double totalDiscountApp = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    final data = await getContactModel();
    setState(() {
      userData = data ?? ContactModel();
    });

    _onRefresh();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    _getList();
  }

  void _getList() async {
    await CartApiService().get(
      idContact: userData.idContact ?? '-1',
      onError: (e) => showSnackBar(context, e),
      onCompleted: (data) {
        setState(() {
          cart = data ?? CartModel();
          subTotalPrice = double.tryParse(cart.subtotalPrice) == null
              ? 0.0
              : double.parse(cart.subtotalPrice);
          totalDiscountApp = double.tryParse(cart.totalDiscountApp) == null
              ? 0.0
              : double.parse(cart.totalDiscountApp);
          if (totalDiscountApp > 0.0) {
            discounts.add(
              ProductDiscountModel(
                title: 'Diskon Aplikasi',
                discount: totalDiscountApp,
              ),
            );
          }
          totalPrice = subTotalPrice - totalDiscountApp;
          isLoading = false;
        });
      },
    );
  }

  void _checkoutConfirmation() {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text('Konfirmasi'),
          content: Text('Apakah anda yakin ingin checkout sekarang?'),
          actions: <Widget>[
            adaptiveAction(
              context: context,
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.pop(context);
                _submitCheckout();
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitCheckout() async {
    setState(() {
      isLoading = true;
    });
    await CartApiService().checkout(
      idContact: userData.idContact ?? '-1',
      idCart: cart.idCart,
      onError: (e) {
        showSnackBar(context, e);
      },
      onSuccess: (e) {
        showSnackBar(context, e);
      },
      onCompleted: (status) {
        if (status) {
          Navigator.pop(context, 'isCheckouted');
        } else {
          setState(() {
            isLoading = false;
          });
        }
      },
    );
  }

  Widget adaptiveAction({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TextButton(onPressed: onPressed, child: child);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoDialogAction(onPressed: onPressed, child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cDark600,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Checkout Pesanan'),
        centerTitle: false,
        backgroundColor: cWhite,
        foregroundColor: cDark100,
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.symmetric(
            horizontal: BorderSide(color: cDark600, width: 1),
          ),
        ),
        child: SafeArea(
          child: MElevatedButton(
            onPressed: () => _checkoutConfirmation(),
            title: 'Checkout Sekarang',
            isFullWidth: true,
          ),
        ),
      ),
      body: isLoading
          ? const LoadingModal()
          : RefreshIndicator.adaptive(
              onRefresh: () => _onRefresh(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      color: getReminderBackgroundColor(),
                      width: double.infinity,
                      child: Row(
                        children: [
                          getReminderIcon(),
                          const SizedBox(width: 12),
                          getReminderTitleAndDescriptionText(),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      color: cWhite,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Keranjang',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${cart.details.length} produk',
                                style: const TextStyle(color: cDark200),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ListView.separated(
                            itemCount: cart.details.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(0),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 24),
                            itemBuilder: (conxtext, i) {
                              final product = cart.details[i];
                              return SizedBox(
                                height: 90,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        color: cDark600,
                                        width: 90,
                                        height: 90,
                                        child: Image.network(
                                          product.imageProduk ??
                                              'https://google.com',
                                          key: Key(
                                            product.idProduk ?? i.toString(),
                                          ),
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
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.namaProduk ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${CurrencyFormat().format(amount: double.parse(product.hargaProduk ?? '0'))} / ${product.nameSatuan}',
                                              ),
                                              Text(
                                                CurrencyFormat().format(
                                                  amount:
                                                      (int.parse(
                                                                product.hargaProduk ??
                                                                    '0',
                                                              ) *
                                                              int.parse(
                                                                product.qtyCartDetail ??
                                                                    '0',
                                                              ))
                                                          .toDouble(),
                                                ),
                                                style: const TextStyle(
                                                  color: cPrimary100,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text('x ${product.qtyCartDetail}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      color: cWhite,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Total Harga',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                CurrencyFormat().format(
                                  amount: subTotalPrice,
                                  fractionDigits: 2,
                                ),
                                style: const TextStyle(color: cPrimary100),
                              ),
                            ],
                          ),
                          if (discounts.isNotEmpty)
                            ListView.separated(
                              itemCount: discounts.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 24),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, idx) {
                                var discountItem = discounts[idx];
                                return Row(
                                  children: [
                                    Expanded(child: Text(discountItem.title)),
                                    Text(
                                      '- ${CurrencyFormat().format(amount: discountItem.discount, fractionDigits: 2)}',
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      color: cWhite,
                      width: double.infinity,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Total Bayar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (subTotalPrice != totalPrice)
                                Text(
                                  CurrencyFormat().format(
                                    amount: subTotalPrice,
                                    fractionDigits: 2,
                                  ),
                                  style: const TextStyle(
                                    color: cPrimary200,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: cPrimary200,
                                    decorationThickness: 2,
                                  ),
                                ),
                              Text(
                                CurrencyFormat().format(
                                  amount: totalPrice,
                                  fractionDigits: 2,
                                ),
                                style: const TextStyle(
                                  color: cPrimary200,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Color getReminderBackgroundColor() {
    return Colors.yellow[700]!.withAlpha(180);
  }

  Widget getReminderIcon() {
    return const Icon(Icons.info_outline);
  }

  Column getReminderTitleAndDescriptionText() {
    String title = 'Periksa produk sebelum checkout';
    String description = 'Pastikan setiap detail sudah sesuai';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(description),
      ],
    );
  }
}
