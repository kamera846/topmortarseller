import 'dart:async';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/order_model.dart';
import 'package:topmortarseller/model/order_tabs_model.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/screen/products/checkout_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final List<OrderTabsModel> _tabsData = [];
  // ContactModel? _userData;

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    _getUserData();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getUserData() async {
    // final data = widget.userData ?? await getContactModel();
    setState(() {
      // _userData = data;
      _tabsData.add(
        OrderTabsModel(
          header: const Tab(
            icon: Icon(Icons.border_all_rounded),
          ),
          body: const ListOrder(),
        ),
      );
      _tabsData.add(
        OrderTabsModel(
          header: const Tab(
            icon: Icon(Icons.inventory_2_outlined),
          ),
          body: const ListOrder(status: 'diproses'),
        ),
      );
      _tabsData.add(
        OrderTabsModel(
          header: const Tab(
            icon: Icon(Icons.fire_truck_rounded),
          ),
          body: const ListOrder(status: 'dikirim'),
        ),
      );
      _tabsData.add(
        OrderTabsModel(
          header: const Tab(
            icon: Icon(Icons.payment_rounded),
          ),
          body: const ListOrder(
            status: 'invoice',
          ),
        ),
      );
      _tabsData.add(
        OrderTabsModel(
          header: const Tab(
            icon: Icon(Icons.check_circle_sharp),
          ),
          body: const ListOrder(status: 'selesai'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pesanan Saya'),
        centerTitle: false,
        backgroundColor: cDark600,
        foregroundColor: cDark100,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabsData.map(
            (item) {
              return item.header;
            },
          ).toList(),
        ),
      ),
      backgroundColor: cDark600,
      body: TabBarView(
        controller: _tabController,
        children: _tabsData.map(
          (item) {
            return item.body;
          },
        ).toList(),
      ),
    );
  }
}

class ListOrder extends StatefulWidget {
  const ListOrder({super.key, this.status});

  final String? status;

  @override
  State<ListOrder> createState() => _ListOrderState();
}

class _ListOrderState extends State<ListOrder> {
  final List<OrderModel> _items = [];
  bool _isLoading = true;
  late Timer _getItemTimer;

  @override
  void initState() {
    _getList();
    super.initState();
  }

  @override
  void dispose() {
    _getItemTimer.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    _getList();
  }

  void _getList() {
    var product1 = const ProductModel(
        idProduk: '1',
        idCity: '1',
        namaProduk: 'Thinbed',
        hargaProduk: '78000',
        imageProduk:
            'https://topmortar.com/wp-content/uploads/2021/10/TOP-THINBED-2.png',
        checkoutCount: '2',
        stok: 500);
    var product2 = const ProductModel(
        idProduk: '2',
        idCity: '1',
        namaProduk: 'Plaster',
        hargaProduk: '69000',
        imageProduk:
            'https://topmortar.com/wp-content/uploads/2021/10/MOCKUP-TA-1000-x-1000.png',
        checkoutCount: '1',
        stok: 200);
    _getItemTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        if (widget.status == null || widget.status == 'diproses') {
          _items.add(
            OrderModel(
              orderDate: '09 Februari 2025',
              orderStatus: 'diproses',
              orderStatusColors:
                  List.of({Colors.grey[400]!, Colors.grey[800]!}),
              orderItems: List.of(
                {product1, product2},
              ),
            ),
          );
        }
        if (widget.status == null || widget.status == 'dikirim') {
          _items.add(
            OrderModel(
              orderDate: '08 Februari 2025',
              orderStatus: 'dikirim',
              orderStatusColors:
                  List.of({Colors.blue[100]!, Colors.blue[800]!}),
              orderItems: List.of(
                {product1},
              ),
            ),
          );
          _items.add(
            OrderModel(
              orderDate: '07 Februari 2025',
              orderStatus: 'dikirim',
              orderStatusColors:
                  List.of({Colors.blue[100]!, Colors.blue[800]!}),
              orderItems: List.of(
                {product2},
              ),
            ),
          );
        }
        if (widget.status == null || widget.status == 'invoice') {
          _items.add(
            OrderModel(
              orderDate: '06 Februari 2025',
              orderStatus: 'invoice',
              orderStatusColors:
                  List.of({Colors.orange[100]!, Colors.orange[800]!}),
              orderItems: List.of(
                {product1, product2},
              ),
            ),
          );
        }
        if (widget.status == null || widget.status == 'selesai') {
          _items.add(
            OrderModel(
              orderDate: '05 Februari 2025',
              orderStatus: 'selesai',
              orderStatusColors:
                  List.of({Colors.green[100]!, Colors.green[800]!}),
              orderItems: List.of(
                {product1},
              ),
            ),
          );
        }
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(),
      child: _isLoading
          ? const LoadingModal()
          : Padding(
              padding: _items.isEmpty
                  ? const EdgeInsets.all(12)
                  : const EdgeInsets.symmetric(horizontal: 12),
              child: _items.isEmpty
                  ? const Text(
                      'Belum ada pesananan',
                      textAlign: TextAlign.center,
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (ctx, idx) {
                        var orderItem = _items[idx];
                        return Padding(
                          padding: idx == 0
                              ? const EdgeInsets.only(top: 12)
                              : idx == _items.length - 1
                                  ? const EdgeInsets.only(bottom: 12)
                                  : const EdgeInsets.all(0),
                          child: CardOrder(item: orderItem),
                        );
                      },
                    ),
            ),
    );
  }
}

class CardOrder extends StatelessWidget {
  const CardOrder({super.key, required this.item});

  final OrderModel item;

  String _countPrice(List<ProductModel> products) {
    var totalPrices = 0.0;
    for (var product in products) {
      totalPrices += double.parse(product.hargaProduk ?? '0') *
          double.parse(product.checkoutCount ?? '0');
    }
    return CurrencyFormat().format(amount: totalPrices);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cWhite,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shadowColor: cDark600,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: cDark200,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.orderDate,
                      style: const TextStyle(color: cDark200),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.orderStatusColors[0].withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.orderStatus.toUpperCase(),
                    style: TextStyle(
                      color: item.orderStatusColors[1],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: const Divider(
                height: 1,
                color: cDark500,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: item.orderItems.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = item.orderItems[index];
                return Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: cDark600,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(
                              product.imageProduk ?? '',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.namaProduk ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '${CurrencyFormat().format(amount: double.parse(product.hargaProduk ?? '0'))} (${product.checkoutCount}x)',
                                style: const TextStyle(
                                    fontSize: 12, color: cPrimary100),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Rp 100.000',
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total ${item.orderItems.length} produk',
                      ),
                      Text(
                        _countPrice(item.orderItems),
                        style: const TextStyle(
                            color: cPrimary100, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (item.orderStatus == 'invoice' ||
                    item.orderStatus == 'selesai') ...[
                  InkWell(
                    onTap: () {},
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: cPrimary100.withAlpha(200),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Lihat Invoice',
                          style: TextStyle(
                            color: cPrimary100,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => CheckoutScreen(
                          items: item.orderItems,
                          orderItem: item,
                        ),
                      ),
                    );
                  },
                  splashColor: cDark100,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: cPrimary100.withAlpha(200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Detail Pesanan',
                        style: TextStyle(
                          color: cWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
