import 'package:flutter/material.dart';
import 'package:topmortarseller/model/order_item_model.dart';
import 'package:topmortarseller/model/order_model.dart';
import 'package:topmortarseller/model/product_discount_modal.dart';
import 'package:topmortarseller/services/app_order_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.idAppOrder});

  final String idAppOrder;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel order;
  List<OrderItemModel> products = [];
  List<OrderItemModel> freeProducts = [];
  List<ProductDiscountModel> discounts = [];
  double subTotalAppOrder = 0.0;
  double discountAppOrder = 0.0;
  double totalAppOrder = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    _getList();
  }

  void _getList() async {
    await AppOrderApi().detail(
      idAppOrder: widget.idAppOrder,
      onError: (e) => showSnackBar(context, e),
      onCompleted: (data) {
        setState(() {
          products.clear();
          freeProducts.clear();
          discounts.clear();
          order = data ?? OrderModel();
          subTotalAppOrder = double.tryParse(order.subTotalAppOrder) == null
              ? 0.0
              : double.parse(order.subTotalAppOrder);

          totalAppOrder = double.tryParse(order.totalAppOrder) == null
              ? 0.0
              : double.parse(order.totalAppOrder);
          discountAppOrder = double.tryParse(order.discountAppOrder) == null
              ? 0.0
              : double.parse(order.discountAppOrder);
          if (discountAppOrder > 0.0) {
            discounts.add(
              ProductDiscountModel(
                title: 'Diskon Aplikasi',
                discount: discountAppOrder,
              ),
            );
          }
          if (order.items.isNotEmpty) {
            final orders = order.items;
            products = orders
                .where((orderItem) => orderItem.isBonus == "0")
                .toList();
            freeProducts = orders
                .where((orderItem) => orderItem.isBonus == "1")
                .toList();
          }
          isLoading = false;
        });
      },
    );
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
        title: const Text('Pesanan Saya'),
        centerTitle: false,
        backgroundColor: cWhite,
        foregroundColor: cDark100,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator.adaptive(
                onRefresh: () => _onRefresh(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// --- Reminder Section ---
                      generateReminderSection(context),

                      /// --- List Order Information ---
                      generateOrderInformation(context),

                      /// --- List Products Section ---
                      generateProductItems(context, products, 'Pesanan'),

                      /// --- List Free Products Section ---
                      if (freeProducts.isNotEmpty)
                        generateProductItems(context, freeProducts, '🎉Bonus'),

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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  CurrencyFormat().format(
                                    amount: subTotalAppOrder,
                                    fractionDigits: 2,
                                  ),
                                  style: const TextStyle(color: cPrimary200),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ListView.separated(
                              itemCount: discounts.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, idx) {
                                var discountCo = discounts[idx];
                                return Row(
                                  children: [
                                    Expanded(child: Text(discountCo.title)),
                                    Text(
                                      '- ${CurrencyFormat().format(amount: discountCo.discount, fractionDigits: 2)}',
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
                                if (subTotalAppOrder != totalAppOrder)
                                  Text(
                                    CurrencyFormat().format(
                                      amount: subTotalAppOrder,
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
                                    amount: totalAppOrder,
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
      ),
    );
  }

  String getTotalPrices() {
    var totalPrice = 0.0;
    for (var item in order.items) {
      double totalPriceProduct =
          double.parse(item.priceProduk) * double.parse(item.qtyAppOrderDetail);
      setState(() {
        totalPrice += totalPriceProduct;
      });
    }
    return CurrencyFormat().format(amount: totalPrice, fractionDigits: 2);
  }

  Widget generateReminderSection(BuildContext context) {
    var statusAppOrder = order.statusAppOrder.toLowerCase();
    Color color = Colors.yellow[700]!.withAlpha(180);
    Icon icon = const Icon(Icons.info_outline);
    String title = '-';
    String description = '-';

    if (statusAppOrder == 'diproses') {
      color = Colors.grey[400]!;
      icon = const Icon(Icons.inventory_2_outlined);
      title = 'Pesanan Dalam Proses';
      description = 'Kami sedang menyiapkan pesanan Anda. Tunggu sebentar ya!';
    } else if (statusAppOrder == 'dikirim') {
      color = Colors.blue[100]!;
      icon = const Icon(Icons.fire_truck_rounded);
      title = 'Disiapkan Pengiriman';
      description =
          'Pesanan sedang disiapkan untuk segera dikirim. Terima kasih atas kesabarannya!';
    } else if (statusAppOrder == 'selesai') {
      color = Colors.green[100]!;
      icon = const Icon(Icons.check_circle_sharp);
      title = 'Pesanan Selesai';
      description =
          'Terima kasih sudah berbelanja. Semoga suka dengan pesanannya!';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      color: color,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget generateOrderInformation(BuildContext context) {
    List<Map<String, String>> items = [];
    items.add({
      "label": "Pesanan Dibuat",
      "value": MyDateFormat.formatDate(
        order.createdAt,
        outputFormat: 'dd MMM yyyy, HH:mm',
      ),
    });
    items.add({"label": "No. Pesanan", "value": order.noOrder});
    if (order.noSuratJalan != '-') {
      items.add({"label": "No. Pengiriman", "value": order.noSuratJalan});
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      color: cWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              var item = items[idx];
              return Row(
                children: [
                  Expanded(child: Text(item['label'] as String)),
                  Text(item['value'] as String),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget generateProductItems(
    BuildContext context,
    List<OrderItemModel> products,
    String title,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      color: cWhite,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Text(
                '${products.length} produk',
                style: const TextStyle(color: cDark200),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.separated(
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (conxtext, i) {
              final product = products[i];
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
                          product.imageProduk.isNotEmpty
                              ? product.imageProduk
                              : 'https://google.com',
                          key: Key(product.idProduct),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.nameProduk,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${CurrencyFormat().format(amount: double.parse(product.priceProduk))} / ${product.nameSatuan}',
                              ),
                              Text(
                                CurrencyFormat().format(
                                  amount: (double.parse(
                                    product.totalAppOrderDetail,
                                  )),
                                ),
                                style: const TextStyle(color: cPrimary200),
                              ),
                            ],
                          ),
                          Text(
                            'x${product.qtyAppOrderDetail}${product.isBonus == "1" ? ' (Free)' : ''}',
                            style: TextStyle(color: cDark200),
                          ),
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
    );
  }
}
