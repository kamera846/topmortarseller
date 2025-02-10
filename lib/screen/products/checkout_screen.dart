import 'package:flutter/material.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class ProductDiskonModel {
  const ProductDiskonModel({
    required this.title,
    required this.diskon,
  });

  final String title;
  final double diskon;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.items,
  });

  final List<ProductModel> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<ProductModel> items = [];
  List<ProductModel> checkoutedItems = [];
  List<ProductDiskonModel> diskons = [];
  bool _isLoading = true;
  double totalPrice = 0.0;
  double totalDiskon = 0.0;
  double totalAfterDiskon = 0.0;

  @override
  void initState() {
    _getList();
    super.initState();
  }

  void _getList() async {
    setState(() {
      items = widget.items;
      diskons.add(
          const ProductDiskonModel(title: 'Diskon aplikasi', diskon: -10000));
      diskons.add(const ProductDiskonModel(
          title: 'Diskon toko priority', diskon: -15000));
      diskons.add(
          const ProductDiskonModel(title: 'Voucher 10.000', diskon: -10000));
      diskons.add(const ProductDiskonModel(title: 'Biaya admin', diskon: 500));
      _isLoading = false;
    });
  }

  String getTotalPrices() {
    var totalPrice = 0.0;
    for (var item in items) {
      double totalPriceProduct = double.parse(item.hargaProduk ?? '0') *
          double.parse(item.checkoutCount ?? '0');
      setState(() {
        totalPrice += totalPriceProduct;
      });
    }
    return CurrencyFormat().format(amount: totalPrice, fractionDigits: 2);
  }

  String getTotalAfterDiskon() {
    var totalPrice = 0.0;
    var totalDiskon = 0.0;
    for (var item in items) {
      double totalPriceProduct = double.parse(item.hargaProduk ?? '0') *
          double.parse(item.checkoutCount ?? '0');
      setState(() {
        totalPrice += totalPriceProduct;
      });
    }
    for (var item in diskons) {
      totalDiskon += item.diskon;
    }
    var totalAfterDiskon = totalPrice + totalDiskon;
    return CurrencyFormat().format(amount: totalAfterDiskon, fractionDigits: 2);
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
        title: const Text('Checkout'),
        centerTitle: false,
        backgroundColor: cWhite,
        foregroundColor: cDark100,
      ),
      body: _isLoading
          ? const LoadingModal()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(24),
                          color: Colors.yellow[700]?.withAlpha(180),
                          width: double.infinity,
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Periksa produk sebelum checkout',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Pastikan setiap detail sudah sesuai'),
                                ],
                              )
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${items.length} produk',
                                    style: const TextStyle(color: cDark200),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ListView.builder(
                                itemCount: items.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(0),
                                itemBuilder: (conxtext, i) {
                                  final item = items[i];
                                  return Container(
                                    margin: i < items.length - 1
                                        ? const EdgeInsets.only(bottom: 24)
                                        : null,
                                    height: 90,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: cDark600,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                item.imageProduk ?? '',
                                              ),
                                              fit: BoxFit.cover,
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
                                                item.namaProduk ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                    '${CurrencyFormat().format(amount: double.parse(item.hargaProduk ?? '0'))} / satuan'),
                                              ),
                                              Text('x ${item.checkoutCount}'),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            CurrencyFormat().format(
                                                amount: (int.parse(
                                                            item.hargaProduk ??
                                                                '0') *
                                                        int.parse(
                                                            item.checkoutCount ??
                                                                '0'))
                                                    .toDouble()),
                                            style: const TextStyle(
                                              color: cPrimary100,
                                            ),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    getTotalPrices(),
                                    style: const TextStyle(color: cPrimary100),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ListView.builder(
                                  itemCount: diskons.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(0),
                                  itemBuilder: (ctx, idx) {
                                    var diskonItem = diskons[idx];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              diskonItem.title,
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormat().format(
                                                amount: diskonItem.diskon,
                                                fractionDigits: 2),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
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
                                children: [
                                  Text(
                                    getTotalAfterDiskon(),
                                    style: const TextStyle(
                                        color: cPrimary200,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    getTotalPrices(),
                                    style: const TextStyle(
                                        color: cPrimary200,
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: cDark600,
                        width: 1,
                      ),
                    ),
                  ),
                  child: MElevatedButton(
                    onPressed: () {},
                    title: 'Checkout Sekarang',
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
    );
  }
}
